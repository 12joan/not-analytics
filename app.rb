require "yaml/store"
require "active_support/security_utils"

class App

  attr_reader :request

  def call(env)
    @request = Rack::Request.new(env)

    begin
      [ 200, {}, [ get ] ]
    rescue StandardError => e
      puts "Runtime error: #{e}"
      puts e.backtrace.join("\n\t")
      [ 500, {}, [ "500 error occurred" ] ]
    end
  end

  attr_reader :app_id, :path, :log_db

  def get
    @app_id, @path = request.path.match(/\/([^\/]+)(\/.*)/)&.captures || [nil, nil]
    return "invalid app id" unless app_id_valid?
    set_log_db 
    log_request
    "ok"
  end

  private

  def log_request
    log_db.transaction do
      log_db[time] ||= {}
      log_db[time][path] ||= 0
      log_db[time][path] += 1
    end
  end

  def time
    Time.now.strftime("%a %e %b %Y %H:00")
  end

  def app_id_valid?
    whitelisted_ids.any? { |x| ActiveSupport::SecurityUtils.secure_compare(x, app_id) }
  end

  def whitelisted_ids
    File.readlines(app_id_whitelist_path).map(&:strip).select { |x| x.length > 0 }
  end

  def set_log_db
    @log_db = YAML::Store.new(db_path, true)
  end

  def db_path
    File.join("db", app_id + ".yml")
  end

  def app_id_whitelist_path
    File.join("conf", "apps")
  end

end
