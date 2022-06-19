require 'test_helper'

class HitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_app = apps(:test_app)
    @six_am_normal_hits = hits(:six_am_normal_hits)
  end

  test 'increments the hit count for the event and current hour' do
    travel_to Time.zone.local(2022, 1, 1, 6, 10, 50) do
      assert_difference '@six_am_normal_hits.count', 1 do
        post '/', params: {
          hit: {
            app_id: @test_app.id,
            event: 'normal-hit',
          },
        }

        @six_am_normal_hits.reload
      end
    end
  end

  test 'creates a new hit if one does not exist' do
    travel_to Time.zone.local(2022, 1, 1, 7, 10, 50) do
      assert_difference 'Hit.count', 1 do
        post '/', params: {
          hit: {
            app_id: @test_app.id,
            event: 'normal-hit',
          },
        }
      end

      hit = Hit.last
      assert_equal @test_app.id, hit.app_id
      assert_equal 'normal-hit', hit.event
      assert_equal Time.zone.local(2022, 1, 1, 7, 0, 0), hit.time
      assert_equal 1, hit.count
    end
  end

  test 'fetches hits for app' do
    get "/apps/#{@test_app.id}/hits", params: {
      token: @test_app.read_token,
    }

    assert_response :success

    hits = JSON.parse(response.body).fetch('hits')
    assert_includes hits, @six_am_normal_hits.as_json(only: [:event, :time, :count])
  end
end
