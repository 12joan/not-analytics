class HitsController < ApplicationController
  before_action :set_app_with_read_token, only: [:index]

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

  def index
    start_date = params[:start_date]&.then { DateTime.parse _1 }
    end_date = params[:end_date]&.then { DateTime.parse _1 }

    hit_scope = @app.hits.where(time: start_date..end_date)

    events = hit_scope.distinct.pluck(:event)

    render json: {
      ok: true,
      start_date: start_date,
      end_date: end_date,
      hits: events.flat_map do |event|
        hit_scope
          .where(event: event)
          .group_by_period(params.fetch(:period, :hour), :time, permit: %i[hour day week month quarter year])
          .sum(:count)
          .map do |time, count|
          {
            time: time,
            event: event,
            count: count,
          }
        end
      end,
    }
  end
end
