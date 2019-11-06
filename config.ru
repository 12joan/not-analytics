require_relative 'app'

use Rack::ContentLength

run App.new
