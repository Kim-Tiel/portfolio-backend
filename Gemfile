source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.11'

gem 'rails', '~> 6.1.7', '>= 6.1.7.10'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'bootsnap', '>= 1.4.4', require: false

# API
gem 'rack-cors'
gem 'jwt'
gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'dotenv-rails'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'rubocop', require: false
end

group :test do
  gem 'shoulda-matchers'
  gem 'database_cleaner-active_record'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]