# frozen_string_literal: true

require "test_helper"

class PatronOrderedTest < ActiveSupport::TestCase
  setup do
    @temple = create_temple(slug: "patron-order", name: "Order")
  end

  # A newly created event used to sort below events that had already ended,
  # because every consumer ordered plainly ascending. The Director hit it on
  # the public site, then again on the account web and in the app.
  test "what a patron can still attend comes first, finished ones newest-first" do
    past_old = gathering("past-old", starts: Date.current - 200, ends: Date.current - 200)
    past_recent = gathering("past-recent", starts: Date.current - 20, ends: Date.current - 20)
    upcoming_far = gathering("upcoming-far", starts: Date.current + 120, ends: Date.current + 120)
    upcoming_soon = gathering("upcoming-soon", starts: Date.current + 5, ends: Date.current + 5)
    ongoing = gathering("ongoing", starts: Date.current - 1, ends: Date.current + 1)

    assert_equal [ongoing, upcoming_soon, upcoming_far, past_recent, past_old].map(&:slug),
                 @temple.temple_gatherings.order_for_patrons.map(&:slug)
  end

  test "the ordering agrees with timeline_status, which is what the badge shows" do
    gathering("finished", starts: Date.current - 30, ends: Date.current - 30)
    gathering("later", starts: Date.current + 30, ends: Date.current + 30)

    ordered = @temple.temple_gatherings.order_for_patrons.to_a
    refute_equal :past, ordered.first.timeline_status,
      "a finished gathering must never sort above one a patron can still attend"
    assert_equal :past, ordered.last.timeline_status
  end

  test "an undated gathering falls back to its creation date rather than vanishing" do
    undated = @temple.temple_gatherings.create!(slug: "undated", title: "Undated", currency: "TWD", price_cents: 0, status: "published")

    assert_includes @temple.temple_gatherings.order_for_patrons.map(&:slug), undated.slug
  end

  private

  def gathering(slug, starts:, ends:)
    @temple.temple_gatherings.create!(
      slug: slug, title: slug, currency: "TWD", price_cents: 0,
      status: "published", starts_on: starts, ends_on: ends
    )
  end
end
