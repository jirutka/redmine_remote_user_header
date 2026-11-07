# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Jakub Jirutka <jakub@jirutka.cz>
# frozen_string_literal: true

require 'test_helper'

class RemoteUserHeaderTest < ActionDispatch::IntegrationTest
  def teardown
    User.current = nil
    super
  end

  def test_anonymous_request_receives_anonymous_header
    get '/login'
    assert_response :success
    assert_equal 'anonymous', response.headers['Remote-User']
  end

  def test_successful_login_and_followup_request_are_attributed
    post '/login', params: {username: 'jsmith', password: 'jsmith'}
    assert_response :redirect
    assert_equal 'jsmith', response.headers['Remote-User']

    get '/my/page'
    assert_response :success
    assert_equal 'jsmith', response.headers['Remote-User']
  end

  def test_failed_login_remains_anonymous
    post '/login', params: {username: 'jsmith', password: 'invalid'}
    assert_equal 'anonymous', response.headers['Remote-User']
  end

  def test_logout_response_is_not_misattributed
    post '/login', params: {username: 'jsmith', password: 'jsmith'}
    assert_equal 'jsmith', response.headers['Remote-User']

    post '/logout'
    assert_response :redirect
    assert_equal 'anonymous', response.headers['Remote-User']
  end

  def test_authorization_denial_still_has_effective_user
    post '/login', params: {username: 'jsmith', password: 'jsmith'}
    get '/admin'
    assert_response :forbidden
    assert_equal 'jsmith', response.headers['Remote-User']
  end

  def test_api_key_authentication
    with_settings rest_api_enabled: '1' do
      user = User.find(2)
      get '/users/current.json', headers: {'X-Redmine-API-Key' => user.api_key}
      assert_response :success
      assert_equal user.login, response.headers['Remote-User']
    end
  end

  def test_failed_api_key_authentication_is_anonymous
    with_settings rest_api_enabled: '1' do
      get '/users/current.json', headers: {'X-Redmine-API-Key' => 'invalid'}
      assert_response :unauthorized
      assert_equal 'anonymous', response.headers['Remote-User']
    end
  end
end
