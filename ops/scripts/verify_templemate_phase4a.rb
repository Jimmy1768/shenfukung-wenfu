#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "open3"
require "rbconfig"
require "tmpdir"

ROOT_DIR = File.expand_path("../..", __dir__)
ENV_TEMPLATE = File.join(ROOT_DIR, "ops", "env", "template.temple.env")
RENDERER = File.join(ROOT_DIR, "ops", "scripts", "render_ops_templates.rb")
SLUG = "shengfukung-wenfu"

REQUIRED_ENV_KEYS = %w[
  STRIPE_TEMPLEMATE_PLATFORM_ACCOUNT_ID
  STRIPE_TEMPLEMATE_SETUP_PRICE_ID
  STRIPE_TEMPLEMATE_MONTHLY_PRICE_ID
  STRIPE_TEMPLEMATE_PLATFORM_WEBHOOK_SECRET
].freeze

EXPECTED_UNITS = {
  "#{SLUG}-platform-billing-monthly-close.service" => {
    job: "PlatformBillingMonthlyCloseJob",
    assertions: [
      "Type=oneshot",
      "Restart=on-failure",
      "RestartSec=5min",
      "StartLimitIntervalSec=1h",
      "StartLimitBurst=3"
    ]
  },
  "#{SLUG}-platform-billing-monthly-close.timer" => {
    assertions: [
      "OnCalendar=*-*-* 00:20:00 Asia/Taipei",
      "Persistent=true",
      "RandomizedDelaySec=0",
      "Unit=#{SLUG}-platform-billing-monthly-close.service"
    ]
  },
  "#{SLUG}-platform-billing-lifecycle.service" => {
    job: "PlatformBillingLifecycleJob",
    assertions: [
      "Type=oneshot",
      "Restart=on-failure",
      "RestartSec=5min",
      "StartLimitIntervalSec=1h",
      "StartLimitBurst=3"
    ]
  },
  "#{SLUG}-platform-billing-lifecycle.timer" => {
    assertions: [
      "OnCalendar=*-*-* *:05:00 Asia/Taipei",
      "Persistent=true",
      "RandomizedDelaySec=0",
      "Unit=#{SLUG}-platform-billing-lifecycle.service"
    ]
  }
}.freeze

def verify!(condition, message)
  raise "TempleMate Phase 4A verification failed: #{message}" unless condition
end

template = File.read(ENV_TEMPLATE)
REQUIRED_ENV_KEYS.each do |key|
  matches = template.lines.grep(/^#{Regexp.escape(key)}=/)
  verify!(matches.length == 1, "#{key} must appear exactly once")
  verify!(matches.first == "#{key}=\n", "#{key} must have an empty value")
end

verify!(!template.match?(/(?:acct_|price_|sk_|pk_|whsec_)/),
        "environment template must not contain Stripe identifier or secret value prefixes")

Dir.mktmpdir("templemate-phase4a-") do |output_dir|
  stdout, stderr, status = Open3.capture3(RbConfig.ruby, RENDERER, "--slug", SLUG, "--output", output_dir)
  verify!(status.success?, "renderer failed: #{stderr.empty? ? stdout : stderr}")

  systemd_dir = File.join(output_dir, "systemd")
  EXPECTED_UNITS.each do |unit_name, contract|
    path = File.join(systemd_dir, unit_name)
    verify!(File.file?(path), "missing rendered unit #{unit_name}")
    content = File.read(path)
    contract.fetch(:assertions).each do |expected|
      verify!(content.include?(expected), "#{unit_name} must contain #{expected.inspect}")
    end

    next unless contract[:job]

    expected_job = contract.fetch(:job)
    verify!(content.include?("#{expected_job}.perform_later"),
            "#{unit_name} must enqueue #{expected_job}")
    jobs = content.scan(/\b[A-Z][A-Za-z0-9]*Job\b/).uniq
    verify!(jobs == [expected_job], "#{unit_name} may reference only #{expected_job}; found #{jobs.join(', ')}")
  end

  {
    "#{SLUG}-platform-billing-monthly-close.timer" => "OnCalendar=*-*-* 00:20:00 Asia/Taipei\n",
    "#{SLUG}-platform-billing-lifecycle.timer" => "OnCalendar=*-*-* *:05:00 Asia/Taipei\n"
  }.each do |unit_name, expected_calendar|
    calendars = File.readlines(File.join(systemd_dir, unit_name)).grep(/\AOnCalendar=/)
    verify!(calendars == [expected_calendar],
            "#{unit_name} must have exactly #{expected_calendar.strip.inspect}; found #{calendars.map(&:strip).join(', ')}")
  end
end

puts "TempleMate Phase 4A verification passed"
