# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "json"
require Rails.root.join("lib/multi_temple_env_loader")

class MultiTempleEnvLoaderTest < ActiveSupport::TestCase
  class FakeDotenv
    attr_reader :loaded, :overloaded

    def initialize
      @loaded = []
      @overloaded = []
    end

    def load(path)
      loaded << path
    end

    def overload(path)
      overloaded << path
    end
  end

  def setup
    @tmp_root = Pathname.new(Dir.mktmpdir("multi-temple-env-loader"))
    write_json(@tmp_root.join("shared/app_constants/project.json"), { slug: "alpha" })
  end

  def teardown
    FileUtils.remove_entry(@tmp_root) if @tmp_root&.exist?
  end

  test "loads temple override when env file exists" do
    write_file(@tmp_root.join(".env"))
    write_file(@tmp_root.join(".env.test"))
    write_file(@tmp_root.join("etc/default/alpha.env"))

    dotenv = FakeDotenv.new
    MultiTempleEnvLoader.load!(dotenv:, env: {}, rails_env: "test", root: @tmp_root)

    assert_includes dotenv.loaded, @tmp_root.join(".env").to_s
    assert_includes dotenv.loaded, @tmp_root.join(".env.test").to_s
    assert_equal [@tmp_root.join("etc/default/alpha.env").to_s], dotenv.overloaded
  end

  # The fallback loads without overloading, so a variable the caller exported
  # survives. It used to overload, which silently rewrote exported values after
  # boot -- `bin/review_admin_server` set PGDATABASE to an isolated review
  # database and got the development one instead.
  test "falls back to .env.development when temple file is missing, without overloading" do
    write_file(@tmp_root.join(".env"))
    write_file(@tmp_root.join(".env.test"))
    write_file(@tmp_root.join(".env.development"))

    dotenv = FakeDotenv.new
    MultiTempleEnvLoader.load!(dotenv:, env: {}, rails_env: "test", root: @tmp_root)

    assert_empty dotenv.overloaded, "the generic fallback must not overwrite exported variables"
    assert_includes dotenv.loaded, @tmp_root.join(".env.development").to_s
  end

  # The reason the bug mattered, stated as a test: an exported variable must
  # still be the effective one after the loader has run.
  test "an exported variable survives the fallback" do
    write_file(@tmp_root.join(".env.development"), "PGDATABASE=from_env_file")

    env = { "PGDATABASE" => "exported_by_caller" }
    real = Class.new do
      def initialize(env) = @env = env
      def load(path)
        File.readlines(path, chomp: true).each do |line|
          key, value = line.split("=", 2)
          next if key.nil? || value.nil?
          @env[key] ||= value
        end
      end
      def overload(path)
        File.readlines(path, chomp: true).each do |line|
          key, value = line.split("=", 2)
          next if key.nil? || value.nil?
          @env[key] = value
        end
      end
    end.new(env)

    MultiTempleEnvLoader.load!(dotenv: real, env:, rails_env: "development", root: @tmp_root)

    assert_equal "exported_by_caller", env["PGDATABASE"]
  end

  test "prefers explicit TEMPLE_SLUG env" do
    write_file(@tmp_root.join(".env"))
    write_file(@tmp_root.join(".env.test"))
    write_file(@tmp_root.join("etc/default/beta.env"))

    dotenv = FakeDotenv.new
    MultiTempleEnvLoader.load!(dotenv:, env: { "TEMPLE_SLUG" => "beta" }, rails_env: "test", root: @tmp_root)

    assert_equal [@tmp_root.join("etc/default/beta.env").to_s], dotenv.overloaded
  end

  private

  def write_file(path, contents = "")
    FileUtils.mkdir_p(path.dirname)
    path.write(contents)
  end

  def write_json(path, payload)
    write_file(path, JSON.dump(payload))
  end
end
