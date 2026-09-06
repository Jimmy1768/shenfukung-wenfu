# frozen_string_literal: true

require "json"
require "pathname"

module MultiTempleEnvLoader
  module_function

  def load!(dotenv: default_dotenv, env: ENV, rails_env: nil, root: default_project_root)
    return unless dotenv

    environment_name = rails_env || env["RAILS_ENV"] || env["RACK_ENV"] || env["APP_ENV"] || "development"
    load_file(dotenv, root.join(".env"))
    load_file(dotenv, root.join(".env.#{environment_name}"))
    load_temple_override(dotenv, env, root)
  end

  def env_file_for(slug, root = default_project_root)
    root.join("etc", "default", "#{slug}.env")
  end

  def default_project_root
    @default_project_root ||= Pathname.new(File.expand_path("../..", __dir__))
  end

  # A temple's own env file overloads, because its whole purpose is to beat the
  # generic files for that tenant.
  #
  # The fallback does NOT overload. It re-reads `.env.development`, which
  # `load!` has usually already loaded a line earlier, so overloading there
  # added nothing except clobbering variables the caller had exported --
  # silently, after boot. That is what made `bin/review_admin_server`'s
  # `export PGDATABASE=<slug>_review` a no-op: the review server ran
  # `db:create`, `db:migrate` and `admin_review:prepare` against the real
  # development database, and no review database was ever created under either
  # its old or new name.
  def load_temple_override(dotenv, env, root)
    slug = resolved_slug(env, root)
    temple_file = env_file_for(slug, root)
    if temple_file.exist?
      load_file(dotenv, temple_file, overload: true)
    else
      load_file(dotenv, root.join(".env.development"))
    end
  end

  def resolved_slug(env = ENV, root = default_project_root)
    slug = first_present_value(env["TEMPLE_SLUG"], env["PROJECT_SLUG"])
    return slug unless slug.nil?

    project_config(root)["slug"] || "golden-template"
  end

  def project_config(root = default_project_root)
    @project_config ||= {}
    @project_config[root] ||= begin
      file = root.join("shared", "app_constants", "project.json")
      file.exist? ? JSON.parse(file.read) : {}
    rescue JSON::ParserError
      {}
    end
  end

  def load_file(dotenv, path, overload: false)
    return unless path.exist?

    dotenv.public_send(overload ? :overload : :load, path.to_s)
  end

  def first_present_value(*values)
    values.each do |value|
      next if value.nil?
      stringified = value.to_s.strip
      return stringified unless stringified.empty?
    end
    nil
  end

  def default_dotenv
    Object.const_get(:Dotenv)
  rescue NameError
    nil
  end
end
