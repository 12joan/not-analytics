require 'yaml/store'

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
    { "14b6a51577c125505e0524226783c895" => true }.fetch(app_id, false)
  end

  def set_log_db
    @log_db = YAML::Store.new(db_path, true)
  end

  def db_path
    File.join("db", app_id + ".yml")
  end

end
