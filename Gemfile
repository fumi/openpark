source 'https://rubygems.org'

gem 'rails', github: 'rails/rails', branch: '4-2-stable'
gem 'sqlite3', '~> 1.3.6'
gem 'sass-rails', '~> 4.0.5'
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'haml-rails'

gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'knockoutjs-rails'
gem 'jquery-rails'

# Leaflet
gem 'leaflet-rails'
#gem 'leaflet-markercluster-rails', :git => 'https://github.com/Mapotempo/leaflet-markercluster-rails.git'
gem 'rails-assets-leaflet.markercluster', source: 'https://rails-assets.org'

# Linked Data & RDF
gem 'linkeddata'
gem 'spira'
gem 'sparql'
gem 'sparql-client'
gem 'rack-linkeddata'

gem 'execjs'
gem 'therubyracer'

group :production do
  gem 'unicorn'
end

group :development do
  gem 'erb2haml'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'turnip'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "jasmine-rails"
  gem "guard-jasmine"
  gem "rb-readline"
  gem "database_cleaner"
  gem "growl"
end
