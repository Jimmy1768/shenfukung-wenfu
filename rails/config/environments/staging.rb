# config/environments/staging.rb
#
# Staging is infrastructure separation only, not a distinct application
# behavior -- it must run identically to production so it's a meaningful
# check before promoting to release/current. Reusing production.rb
# directly (rather than duplicating its settings here) is what actually
# guarantees that: there is no second copy of these settings to drift out
# of sync with production over time.
#
# What makes a deployment "staging" instead of "production" is entirely
# in the environment it's given (a separate WEB_DOMAIN, PUMA_PORT, and
# database, and a separate checkout on its own branch) -- not in this
# file, and not in RAILS_ENV pretending to be "production" the way some
# sibling projects' staging setups do. Wenfu's config/puma.rb already
# has a real `when "staging"` case distinct from production; this file
# is what makes RAILS_ENV=staging actually bootable rather than crashing
# on `config/environments/staging.rb not found`.
require_relative "production"
