class ApplicationController < ActionController::API
  private

  def set_app_with_read_token
    app = App.find(params[:id])

    expected_token = app.read_token
    actual_token = params[:token]

    if expected_token.present? && actual_token.present? && ActiveSupport::SecurityUtils.secure_compare(expected_token, actual_token)
      @app = app
    else
      render json: { ok: false, error: 'Invalid token' }, status: :unauthorized
    end
  end
end
