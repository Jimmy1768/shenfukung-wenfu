# frozen_string_literal: true

require "json"

module AppConstants
  module TempleProfilePlaceholders
    CONFIG_PATH =
      Rails.root.join("..", "shared", "app_constants", "temple_profile_placeholders.json").freeze
    RAW_CONFIG = JSON.parse(File.read(CONFIG_PATH))

    CONTACT = RAW_CONFIG.fetch("contact", {}).freeze
    SERVICE_TIMES = RAW_CONFIG.fetch("service_times", {}).freeze
    VISIT_INFO = RAW_CONFIG.fetch("visit_info", {}).freeze
    ABOUT = RAW_CONFIG.fetch("about", {}).freeze
    HERO_IMAGES = RAW_CONFIG.fetch("hero_images", {}).freeze

    def self.contact
      CONTACT
    end

    def self.service_times
      SERVICE_TIMES
    end

    def self.visit_info
      VISIT_INFO
    end

    def self.about
      ABOUT
    end

    # The image a temple shows when a hero tab has none of its own. Lives in
    # the shared JSON so Rails and Vue read one value -- as a Ruby-only
    # constant the frontend could not see it, which is why siteContent.js grew
    # its own copy of the fallback chain.
    def self.default_hero_image
      HERO_IMAGES.fetch("default")
    end
  end
end
