class AppsController < ApplicationController
  def show
    app = App.find(params[:id])

    expected_token = app.read_token
    actual_token = params[:token]

    unless expected_token.present? && actual_token.present? && ActiveSupport::SecurityUtils.secure_compare(expected_token, actual_token)
      render json: { ok: false, error: 'Invalid token' }, status: :unauthorized
      return
    end

    render json: {
      id: app.id,
      name: app.name,
      created_at: app.created_at,
      updated_at: app.updated_at,
    }
  end
end
