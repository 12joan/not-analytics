class HitsController < ApplicationController
  def create
    hit_params = params.require(:hit).permit(
      :app_id,
      :event,
      :signature,
      :iv,
      :auth_tag,
      :nonce,
    )

    app = App.find(hit_params[:app_id])

    if app.key.present?
      # Verify signature
      expected = NotAnalyticsClient::MessageEncryptor.new(app.key).decrypt_and_verify(
        hit_params[:signature],
        iv: hit_params[:iv],
        auth_tag: hit_params[:auth_tag],
      )

      actual = "#{hit_params[:nonce]}:#{hit_params[:event]}"

      unless expected == actual
        render json: { ok: false, error: 'Invalid signature' }
        return
      end

      # Verify nonce
      unless Nonce.remember(hit_params[:nonce])
        render json: { ok: false, error: 'Invalid nonce' }
        return
      end
    end

    hit = app.hits.find_or_create_by(
      time: DateTime.now.beginning_of_hour,
      event: hit_params[:event],
    )

    Hit.increment_counter(:count, hit.id)

    render json: { ok: true }
  end
end
