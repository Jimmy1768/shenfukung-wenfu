#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "tmpdir"

ROOT_DIR = File.expand_path("../..", __dir__)
VUE_DIR = File.join(ROOT_DIR, "vue")

def verify!(condition, message)
  raise "Tenant-local public API verification failed: #{message}" unless condition
end

def read(path)
  File.read(File.join(ROOT_DIR, path))
end

temple_api = read("vue/src/app/templeApi.js")
verify!(temple_api.include?("const API_ROOT = '/api/v1/temple';"),
        "public API client must use the singular tenant-local root")
verify!(!temple_api.match?(/VITE_|localhost|temples\//),
        "public API client must not contain configuration, localhost, or plural paths")

theme = read("vue/src/app/theme.js")
verify!(theme.include?("fetch('/dev/theme'"), "theme persistence must be relative")
verify!(!theme.include?("VITE_API_BASE_URL"), "theme helper must not use an API base URL")

account_links = read("vue/src/utils/accountLinks.js")
verify!(account_links.include?("VITE_ACCOUNT_BASE_URL"), "account origin may be explicitly configured")
verify!(!account_links.include?("VITE_API_BASE_URL"), "account links must not use the API base URL")
verify!(account_links.include?("http://localhost:3001"), "development account fallback must use port 3001")
verify!(account_links.include?("TENANT_SELECTOR_KEYS"), "account links must reject tenant selectors")
verify!(!account_links.match?(/DEFAULT_TEMPLE_SLUG|VITE_TEMPLE_SLUG/),
        "account links must not derive a temple selector")

demo = read("vue/src/showcase/DemoShowcase.vue")
verify!(demo.include?("const apiEndpoint = '/api/v1/demo_contacts';"),
        "demo contact endpoint must be relative")
verify!(!demo.include?("VITE_API_BASE_URL"), "demo contact must not use an API base URL")

vite_config = read("vue/vite.config.js")
verify!(vite_config.include?("process.env.VITE_DEV_API_PROXY || 'http://localhost:3001'"),
        "Vite proxy must default to the local-development port")

origins = read("vue/src/utils/origins.js")
verify!(origins.include?("import.meta.env.DEV ? \"http://localhost:3001/marketing/admin\""),
        "development admin origin must use port 3001")

env_template = read("ops/env/template.temple.env")
verify!(!env_template.include?("VITE_API_BASE_URL"), "environment template must not expose an API base URL")

puma = read("rails/config/puma.rb")
verify!(puma.match?(/when "development" then 3001/) && puma.match?(/when "staging" then 3002/) && puma.match?(/else 3000/),
        "Puma must preserve the 3000/3001/3002 convention")

cors = read("rails/config/initializers/cors.rb")
verify!(cors.include?("http://localhost:3001") && !cors.include?("localhost:3002"),
        "development CORS must allow 3001 and not stale 3002")

development = read("rails/config/environments/development.rb")
verify!(development.include?("port: 3001") && development.include?("ws://localhost:3001/cable"),
        "development mailer and Cable defaults must use port 3001")

Dir.mktmpdir("wenfu-tenant-local-api-") do |output_dir|
  stdout, stderr, status = Open3.capture3(
    { "VITE_API_BASE_URL" => nil, "VITE_DEV_API_PROXY" => nil },
    "npm", "exec", "vite", "build", "--", "--outDir", output_dir,
    chdir: VUE_DIR
  )
  verify!(status.success?, "Vue build failed: #{stderr.empty? ? stdout : stderr}")

  artifact = Dir.glob(File.join(output_dir, "**", "*")).select { |path| File.file?(path) }
                .map { |path| File.binread(path) }.join("\n")
  forbidden = {
    "localhost" => /localhost/i,
    "raw internal application port" => /(?:^|[^0-9])300[012](?:[^0-9]|$)/,
    "obsolete API base variable" => /VITE_API_BASE_URL/,
    "plural public API path" => %r{/api/v1/temples(?:/|["'])},
    "public API tenant selector" => %r{/api/v1/temple[^"']*[?&](?:temple|slug|tenant)=}
  }
  forbidden.each do |label, pattern|
    verify!(!artifact.match?(pattern), "compiled artifact contains #{label}")
  end
end

puts "Tenant-local public API verification passed"
