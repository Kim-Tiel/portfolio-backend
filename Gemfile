source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.11'

gem 'bootsnap', '>= 1.4.4', require: false
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rails', '~> 6.1.7', '>= 6.1.7.10'

# API
gem 'aws-sdk-s3', '~> 1', require: false
gem 'bcrypt', '~> 3.1.7'
gem 'jwt'
gem 'rack-attack'
gem 'rack-cors'
gem 'sassc-rails'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails', '~> 6.0'
end

group :development do
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'listen', '~> 3.3'
  gem 'rubocop', require: false
  gem 'spring'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
