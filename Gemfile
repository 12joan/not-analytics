source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.10'

# Rails
gem 'activesupport'
gem 'actionpack'
gem 'actionview'
gem 'activemodel'
gem 'activerecord'
gem 'railties'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use Puma as the app server
gem 'puma', '~> 6.4'

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

gem 'not_analytics_client', '~> 0.3.0', github: '12joan/not-analytics-client', branch: 'main'

gem 'groupdate', '~> 6.5'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '~> 3.3'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
