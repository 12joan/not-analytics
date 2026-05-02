require 'test_helper'

class HitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_app = apps(:test_app)
    @test_app_with_key = apps(:test_app_with_key)
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

    assert_ok
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

    assert_ok
  end

  test 'creates a hit from a signed request' do
    encrypted = NotAnalyticsClient::MessageEncryptor
      .new(@test_app_with_key.key)
      .encrypt_and_sign('nonce:normal-hit')

    assert_difference 'Hit.count', 1 do
      post '/', params: {
        hit: {
          app_id: @test_app_with_key.id,
          event: 'normal-hit',
          signature: encrypted.ciphertext,
          iv: encrypted.iv,
          auth_tag: encrypted.auth_tag,
          nonce: 'nonce',
        },
      }
    end

    assert_ok
  end

  test 'creating a hit fails if a signature is required but not provided' do
    assert_no_difference 'Hit.count' do
      post '/', params: {
        hit: {
          app_id: @test_app_with_key.id,
          event: 'normal-hit',
        },
      }
    end

    assert_not_ok 'Missing signature'
  end

  test 'creating a hit fails if an invalid signature is provided' do
    wrong_key = Base64.encode64(SecureRandom.random_bytes(32))

    encrypted = NotAnalyticsClient::MessageEncryptor
      .new(wrong_key)
      .encrypt_and_sign('nonce:normal-hit')

    assert_no_difference 'Hit.count' do
      post '/', params: {
        hit: {
          app_id: @test_app_with_key.id,
          event: 'normal-hit',
          signature: encrypted.ciphertext,
          iv: encrypted.iv,
          auth_tag: encrypted.auth_tag,
          nonce: 'nonce',
        },
      }
    end

    assert_not_ok 'Invalid signature'
  end

  test 'creating a hit fails if the signature does not match the event' do
    encrypted = NotAnalyticsClient::MessageEncryptor
      .new(@test_app_with_key.key)
      .encrypt_and_sign('nonce:wrong')

    assert_no_difference 'Hit.count' do
      post '/', params: {
        hit: {
          app_id: @test_app_with_key.id,
          event: 'normal-hit',
          signature: encrypted.ciphertext,
          iv: encrypted.iv,
          auth_tag: encrypted.auth_tag,
          nonce: 'nonce',
        },
      }
    end

    assert_not_ok 'Invalid signature'
  end

  test 'creating a hit fails if the signature does not match the nonce' do
    encrypted = NotAnalyticsClient::MessageEncryptor
      .new(@test_app_with_key.key)
      .encrypt_and_sign('wrong:normal-hit')

    assert_no_difference 'Hit.count' do
      post '/', params: {
        hit: {
          app_id: @test_app_with_key.id,
          event: 'normal-hit',
          signature: encrypted.ciphertext,
          iv: encrypted.iv,
          auth_tag: encrypted.auth_tag,
          nonce: 'nonce',
        },
      }
    end

    assert_not_ok 'Invalid signature'
  end

  test 'creating a hit fails if the nonce has already been used' do
    Nonce.remember('nonce')

    encrypted = NotAnalyticsClient::MessageEncryptor
      .new(@test_app_with_key.key)
      .encrypt_and_sign('nonce:normal-hit')

    assert_no_difference 'Hit.count' do
      post '/', params: {
        hit: {
          app_id: @test_app_with_key.id,
          event: 'normal-hit',
          signature: encrypted.ciphertext,
          iv: encrypted.iv,
          auth_tag: encrypted.auth_tag,
          nonce: 'nonce',
        },
      }
    end

    assert_not_ok 'Invalid nonce'
  end

  test 'fetches hits for app' do
    get "/apps/#{@test_app.id}/hits", params: {
      token: @test_app.read_token,
    }

    assert_response :success

    hits = JSON.parse(response.body).fetch('hits')
    assert_includes hits, @six_am_normal_hits.as_json(only: [:event, :time, :count])
  end

  private

  def assert_ok
    parsed_response = JSON.parse(response.body)
    assert parsed_response['ok'], "Expected ok, but got #{response.body}"
  end

  def assert_not_ok expected_error
    parsed_response = JSON.parse(response.body)
    refute parsed_response['ok'], "Expected ok to be false"
    assert_equal expected_error, parsed_response['error']
  end
end
