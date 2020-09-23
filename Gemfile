source "https://rubygems.org"

gem "rails", "6.0.3.3"

gem "aws-sdk-s3"
gem "bootsnap", require: false
gem "faraday"
gem "gds-api-adapters"
gem "gds-sso"
gem "govuk_app_config"
gem "govuk_document_types"
gem "govuk_sidekiq", git: "https://github.com/alphagov/govuk_sidekiq", branch: "sidekiq-6"
gem "json-schema"
gem "jwt"
gem "nokogiri"
gem "notifications-ruby-client"
gem "pg"
gem "plek"
gem "ratelimit"
gem "redcarpet"
gem "sidekiq-scheduler"
gem "sidekiq-unique-jobs"
gem "with_advisory_lock"

group :test do
  gem "climate_control"
  gem "equivalent-xml"
  gem "factory_bot_rails"
  gem "webmock"
end

group :development, :test do
  gem "listen"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "simplecov"
end
