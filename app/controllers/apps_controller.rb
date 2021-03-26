class AppsController < ApplicationController
  before_action :set_app_with_read_token

  def show
    render json: {
      ok: true,
      app: {
        id: @app.id,
        name: @app.name,
        created_at: @app.created_at,
        updated_at: @app.updated_at,
      },
    }
  end
end
