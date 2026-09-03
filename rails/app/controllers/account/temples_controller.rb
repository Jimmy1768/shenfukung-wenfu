module Account
  class TemplesController < BaseController
    skip_before_action :authenticate_user!, only: :index
    skip_before_action :ensure_temple_context, only: :index

    def index
      @temples = Temples::Manifest.all.map do |entry|
        record = Temple.find_by(slug: entry["slug"])
        entry.merge(
          "display_name" => record&.name || entry["label"] || entry["slug"].humanize,
          # Through hero_image_for, not the raw map: home is removable now, and
          # reaching around the resolver meant the picker fell through to a
          # primary_image_url the demo yml leaves blank, losing its image while
          # every other surface correctly showed the placeholder floor.
          "hero_image_url" => record&.hero_image_for("home") || record&.primary_image_url
        )
      end
    end
  end
end
