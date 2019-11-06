require_relative 'app'

use Rack::Reloader, 0
use Rack::ContentLength

run App.new
