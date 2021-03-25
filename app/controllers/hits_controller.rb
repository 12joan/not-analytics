class HitsController < ApplicationController
  before_action :set_app
  before_action :verify_signature
  before_action :verify_nonce

  def create
    @hit = @app.hits.find_or_create_by(
      time: DateTime.now.beginning_of_hour,
      event: hit_params[:event],
    )

    Hit.increment_counter(:count, @hit.id)

    render json: { ok: true }
  end

  private

  def set_app
    @app = App.find(hit_params[:app_id])
  end

  def verify_signature
    if @app.key.present?
      expected = NotAnalyticsClient::MessageEncryptor.new(@app.key).decrypt_and_verify(
        hit_params[:signature],
        iv: hit_params[:iv],
        auth_tag: hit_params[:auth_tag],
      )

      actual = "#{hit_params[:nonce]}:#{hit_params[:event]}"

      unless expected == actual
        render json: { ok: false, error: 'Invalid signature' }
      end
    end
  end

  def verify_nonce
    if @app.key.present?
      unless Nonce.remember(hit_params[:nonce])
        render json: { ok: false, error: 'Invalid nonce' }
      end
    end
  end

  def hit_params
    params.require(:hit).permit(
      :app_id,
      :event,
      :signature,
      :iv,
      :auth_tag,
      :nonce,
    )
  end
end
