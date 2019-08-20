source 'https://rubygems.org'
ruby '2.3.1'

gem 'bootstrap_form'
gem 'bootstrap-sass', '3.1.1.1'
gem 'bcrypt'
gem 'carrierwave'
gem 'coffee-rails'
gem 'draper', '~> 2.1'
gem 'fabrication', '2.15.2'
gem 'faker', '1.6.1'
gem 'mini_magick'
gem 'rb-readline'
gem 'rails', '4.2.0'
gem 'foreman'
gem 'mailgun-ruby'
gem 'haml-rails'
gem 'sass-rails'
gem 'stripe'
gem 'rake', '<11.0'
gem 'uglifier'
gem 'unicorn'
gem 'jquery-rails'
gem 'pg', '0.20'
gem 'sentry-raven'
gem 'sidekiq'

group :development do
  gem 'thin'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'letter_opener'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'pry'
  gem 'pry-nav'
  gem 'rspec-rails'
end

group :test do
  gem 'nokogiri', '>=1.8'
  gem 'capybara', '3.15.1'
  gem 'capybara-email'
  gem 'database_cleaner', '1.4.1'
  gem 'launchy'
  gem 'shoulda-matchers', '2.7.0'
  gem 'vcr', '2.9.3'
  gem 'webmock', '~> 2.1'
  gem 'webdrivers'
end

group :production, :staging do
  gem 'fog-aws'
  gem 'rails_12factor'
end
