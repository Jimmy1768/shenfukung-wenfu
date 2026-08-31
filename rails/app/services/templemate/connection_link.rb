# frozen_string_literal: true

module Templemate
  # The exact string the TempleMate app expects to scan.
  #
  # mobile/app/tenant/binding.js#parseProductionConnectionLink accepts it only
  # when: scheme is https, origin matches the app's configured apiBaseUrl,
  # path is exactly PATH, there is no userinfo or fragment, and the only
  # permitted query parameter is v=1. Anything else is rejected as
  # invalid_connection_link -- so this is built from the request's own origin
  # rather than assembled from parts.
  module ConnectionLink
    PATH = "/connect/templemate/v1"
    MODULE_SIZE = 6
    QUIET_ZONE = 2

    def self.for(request:)
      "#{request.base_url}#{PATH}"
    end

    # standalone: true keeps the <svg> element (standalone: false omits it and
    # returns bare shapes); the XML prolog it also emits is stripped, since
    # this is inlined into an HTML page rather than served as a document.
    def self.qr_svg(url)
      RQRCode::QRCode.new(url, level: :m).as_svg(
        module_size: MODULE_SIZE,
        offset: QUIET_ZONE * MODULE_SIZE,
        standalone: true,
        use_path: true,
        color: "000",
        fill: "fff",
        viewbox: true,
        svg_attributes: { role: "img" }
      ).sub(/\A<\?xml[^>]*\?>/, "").html_safe
    end
  end
end
