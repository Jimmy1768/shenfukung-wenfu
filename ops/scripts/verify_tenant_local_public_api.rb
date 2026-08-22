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
verify!(account_links.include?("http://localhost:4001"), "development account fallback must use port 4001")
verify!(account_links.include?("TENANT_SELECTOR_KEYS"), "account links must reject tenant selectors")
verify!(!account_links.match?(/DEFAULT_TEMPLE_SLUG|VITE_TEMPLE_SLUG/),
        "account links must not derive a temple selector")

demo = read("vue/src/showcase/DemoShowcase.vue")
verify!(demo.include?("const apiEndpoint = '/api/v1/demo_contacts';"),
        "demo contact endpoint must be relative")
verify!(!demo.include?("VITE_API_BASE_URL"), "demo contact must not use an API base URL")

vite_config = read("vue/vite.config.js")
verify!(vite_config.include?("process.env.VITE_DEV_API_PROXY || 'http://localhost:4001'"),
        "Vite proxy must default to the local-development port")

origins = read("vue/src/utils/origins.js")
verify!(origins.include?("import.meta.env.DEV ? \"http://localhost:4001/marketing/admin\""),
        "development admin origin must use port 4001")

env_template = read("ops/env/template.temple.env")
verify!(!env_template.include?("VITE_API_BASE_URL"), "environment template must not expose an API base URL")

puma = read("rails/config/puma.rb")
verify!(puma.match?(/when "development" then 4001/) && puma.match?(/when "staging" then 4002/) && puma.match?(/else 4003/),
        "Puma must preserve the 4001/4002/4003 convention")

cors = read("rails/config/initializers/cors.rb")
verify!(cors.include?("http://localhost:4001") && !cors.include?("localhost:4002"),
        "development CORS must allow 4001 and not stale 4002")

development = read("rails/config/environments/development.rb")
verify!(development.include?("port: 4001") && development.include?("ws://localhost:4001/cable"),
        "development mailer and Cable defaults must use port 4001")

app_origins = read("rails/app/lib/app_constants/origins.rb")
verify!(app_origins.include?("DEV_ADMIN_ORIGIN = \"http://localhost:4001/marketing/admin\""),
        "Rails development admin origin must use port 4001")
verify!(!app_origins.include?("localhost:4002"),
        "Rails development admin origin must not use the staging port")

smoke_script = read("bin/run_smoke_tests")
verify!(smoke_script.include?("SMOKE_DEFAULT_BASE_URL:-http://localhost:4001"),
        "smoke script default must use the local-development port")
verify!(smoke_script.include?("${base_url%/}/api/v1/temple"),
        "smoke script must use the singular tenant-local endpoint")
verify!(!smoke_script.match?(%r{/api/v1/temples/}),
        "smoke script must not construct plural slug routes")

active_docs = {
  "commands" => "ops/docs/commands.md",
  "deployment reference" => "ops/docs/reference/deployment_notes.md",
  "onboarding reference" => "ops/docs/reference/onboarding.md",
  "inquiry reference" => "ops/docs/reference/inquiry_support_workflows.md",
  "admin portal reference" => "ops/docs/reference/admin_portal.md"
}
active_docs.each do |label, path|
  contents = read(path)
  verify!(contents.include?("/api/v1/temple"), "#{label} must document the singular tenant-local endpoint")
  verify!(!contents.match?(%r{/api/v1/temples(?:/|:)}), "#{label} must not document a plural public route")
end

deployment_readiness = read("ops/docs/plans/DEPLOYMENT_READINESS.md")
verify!(deployment_readiness.include?("Historical evidence note:"),
        "deployment readiness must label its retained historical plural-route evidence")
verify!(deployment_readiness.include?("Current post-hardening contract:"),
        "deployment readiness must state the current singular-route contract")

Dir.mktmpdir("wenfu-tenant-local-smoke-") do |directory|
  curl_path = File.join(directory, "curl")
  File.write(curl_path, <<~SH)
    #!/usr/bin/env bash
    set -euo pipefail
    printf '%s\\n' "$*" >> "$SMOKE_CURL_LOG"
    printf '200'
  SH
  File.chmod(0o755, curl_path)
  curl_log = File.join(directory, "curl.log")
  stdout, stderr, status = Open3.capture3(
    { "PATH" => "#{directory}:#{ENV.fetch('PATH')}", "SMOKE_BASE_URL" => "http://tenant.test", "SMOKE_CURL_LOG" => curl_log },
    "bash", "bin/run_smoke_tests",
    chdir: ROOT_DIR
  )
  verify!(status.success?, "controlled smoke contract failed: #{stderr.empty? ? stdout : stderr}")
  requests = File.read(curl_log)
  verify!(requests.include?("http://tenant.test/api/v1/temple"),
          "controlled smoke contract must request the singular endpoint")
  verify!(!requests.match?(%r{/api/v1/temples/}),
          "controlled smoke contract must not request a plural endpoint")
end

Dir.mktmpdir("wenfu-tenant-local-api-") do |output_dir|
  stdout, stderr, status = Open3.capture3(
    { "VITE_API_BASE_URL" => nil, "VITE_DEV_API_PROXY" => nil },
    "npm", "exec", "vite", "build", "--", "--outDir", output_dir,
    chdir: VUE_DIR
  )
  verify!(status.success?, "Vue build failed: #{stderr.empty? ? stdout : stderr}")

  # Scoped to an allowlist of text formats, not a denylist of binary ones: a
  # leaked port/URL string could only ever meaningfully appear in text output
  # (JS/CSS/HTML/JSON/sourcemaps), never in compressed image/font bytes --
  # and compressed binary data can and does coincidentally contain any given
  # short digit sequence by chance (real incident: port 4001 collided with
  # random bytes inside one compiled PNG the first time this check ran with
  # the new port numbers). An allowlist fails safe here: a future binary
  # format the build starts emitting (.avif, .pdf, whatever) is silently
  # skipped rather than needing this list updated to avoid a false alarm;
  # only a genuinely new *text* format needs adding, and forgetting to add
  # one just means under-scanning, not a false leak report. .svg is text
  # (XML) and could genuinely carry a leaked URL, so it stays in scope.
  text_extensions = %w[.js .mjs .cjs .css .html .json .map .txt .svg]
  scanned = Dir.glob(File.join(output_dir, "**", "*"))
    .select { |path| File.file?(path) && text_extensions.include?(File.extname(path).downcase) }
  # An allowlist that matches nothing is a silent false negative, not a
  # clean pass: an empty artifact string trivially satisfies every
  # !artifact.match?(pattern) check below, having verified nothing at all.
  # A denylist couldn't fail this way (it scanned everything except a few
  # known binary types, so it almost always had content) -- inverting to an
  # allowlist traded a false-positive risk for a false-negative one, which
  # needs its own guard rather than being left implicit.
  verify!(scanned.any?, "compiled artifact scan matched no text files under #{output_dir} -- allowlist or output path is wrong")
  artifact = scanned.map { |path| File.read(path, encoding: "UTF-8", invalid: :replace, undef: :replace) }.join("\n")
  forbidden = {
    "localhost" => /localhost/i,
    "raw internal application port" => /(?:^|[^0-9])400[123](?:[^0-9]|$)/,
    "obsolete API base variable" => /VITE_API_BASE_URL/,
    "plural public API path" => %r{/api/v1/temples(?:/|["'])},
    "public API tenant selector" => %r{/api/v1/temple[^"']*[?&](?:temple|slug|tenant)=}
  }
  forbidden.each do |label, pattern|
    verify!(!artifact.match?(pattern), "compiled artifact contains #{label}")
  end
end

puts "Tenant-local public API verification passed"
