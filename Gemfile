source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.2"

gem "ancestry", "~> 4.1"
gem "bootsnap", "~> 1.9", require: false
gem "cssbundling-rails", github: "rails/cssbundling-rails", branch: "main"
gem "devise-argon2", "~> 1.1"
gem "devise", github: "heartcombo/devise", branch: "main"
gem "fast_jsonparser", github: "Watson1978/fast_jsonparser", branch: "fix-performance"
gem "hairtrigger", "~> 0.2.24"
gem "httparty", "~> 0.20.0"
gem "importmap-rails", github: "rails/importmap-rails", branch: "main"
gem "jsonb_accessor", "~> 1.3"
gem "nokogiri", "~> 1.12"
gem "pg_search", "~> 2.3"
gem "pg", "~> 1.2"
gem "puma", "~> 5.5"
gem "rails", github: "rails/rails", branch: "main"
gem "redis", "~> 4.5"
gem "sidekiq-cron", "~> 1.2"
gem "sidekiq", "~> 6.3"
gem "sprockets-rails", github: "rails/sprockets-rails", branch: "master"
gem "stimulus-rails", github: "hotwired/stimulus-rails", branch: "main"
gem "turbo-rails", github: "hotwired/turbo-rails", branch: "main"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"
# Use Sass to process CSS
# gem "sassc-rails", "~> 2.1"

group :development, :test do
  gem "debug", ">= 1.0.0", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "annotate", "~> 3.1"
  gem "better_errors", "~> 2.9"
  gem "binding_of_caller", "~> 1.0"
  gem "pry-rails"
  gem "pry"
  gem "standard", "~> 1.4"
  gem "web-console", ">= 4.2.0"
end

gem "foreman", "~> 0.87.2"
