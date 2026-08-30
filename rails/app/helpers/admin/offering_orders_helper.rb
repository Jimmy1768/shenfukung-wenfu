# frozen_string_literal: true

module Admin
  module OfferingOrdersHelper
    def registration_field_control(builder, field, type:, schema:, value:, html_options: {}, suggestions: [])
      # A cached multi-value field accumulates a list. Never hand a list to a
      # single-value control -- that rendered every past choice as the
      # current answer. Prefill is scalarized upstream; anything still
      # array-shaped here is defensive.
      value = Array(value).last if value.is_a?(Array)
      options = schema.field_options(field)
      suggestions = Array(suggestions).map(&:to_s).reject(&:blank?).uniq

      if options.present?
        # Temple-authored menu wins; remembered values that are not on it are
        # appended so a past answer stays reachable without being preselected.
        merged = options | suggestions.reject { |entry| options.include?(entry) }
        builder.select(field, options_for_select(merged, value), { include_blank: value.blank? }, html_options)
      elsif suggestions.any?
        list_id = "reuse-suggestions-#{field}"
        safe_join([
          render_input(builder, field, type, html_options.merge(list: list_id), value),
          content_tag(:datalist, id: list_id) do
            safe_join(suggestions.map { |entry| tag.option(value: entry) })
          end
        ])
      else
        render_input(builder, field, type, html_options, value)
      end
    end

    def registration_multi_value_toggle(field, schema)
      return unless schema.allow_multiple?(field)
      # "Save this as an additional remembered value" is meaningless for a
      # field nobody declared reusable -- ReusableDefaults refuses the write.
      return unless schema.reusable?(field)

      field_id = "multi-value-#{field}"
      content_tag(:div, class: "field-addon multi-value-toggle") do
        safe_join([
          content_tag(:label, for: field_id) do
            safe_join([
              check_box_tag("temple_event_registration[multi_value_fields][]", field, false, id: field_id),
              content_tag(:span, I18n.t("admin.registration_form.labels.save_additional"))
            ])
          end,
          content_tag(:p, I18n.t("admin.registration_form.hints.save_additional"), class: "hint")
        ])
      end
    end

    private

    def render_input(builder, field, type, html_options, value)
      case type
      when :number
        builder.number_field(field, html_options.merge(value: value))
      when :email
        builder.email_field(field, html_options.merge(value: value))
      when :telephone
        builder.telephone_field(field, html_options.merge(value: value))
      when :textarea
        rows = html_options.delete(:rows)
        builder.text_area(field, html_options.merge(value: value, rows: rows || 3))
      when :date
        html_options[:class] = merge_css_classes(html_options[:class], "admin-date-input")
        html_options[:placeholder] ||= "yyyy/mm/dd"
        builder.date_field(field, html_options.merge(value: value))
      else
        builder.text_field(field, html_options.merge(value: value))
      end
    end

    def merge_css_classes(existing, additional)
      existing_classes = Array(existing).flat_map { |value| value.to_s.split(" ") }
      ([additional] + existing_classes).compact.uniq.join(" ").strip
    end
  end
end
