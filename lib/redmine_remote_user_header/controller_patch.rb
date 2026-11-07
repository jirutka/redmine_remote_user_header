# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Jakub Jirutka <jakub@jirutka.cz>
# frozen_string_literal: true

module RedmineRemoteUserHeader
  module ControllerPatch
    HEADER_NAME = 'Remote-User'

    # Redmine validates logins as ASCII letters, digits, _, -, @ and .
    # Revalidate before emitting an HTTP header to fail closed if an invalid
    # login was inserted through a custom integration or direct DB access.
    SAFE_LOGIN = /\A[a-zA-Z0-9_.@-]{1,60}\z/

    def self.included(base)
      # Wrap the full controller callback chain. Unlike after_action, this
      # also runs when a before_action renders/redirects (e.g., a 403).
      base.prepend_around_action :redmine_remote_user_header
    end

    private

    def redmine_remote_user_header
      yield
    ensure
      user = User.current

      if user&.logged?
        login = user.login.to_s
        if login.valid_encoding? && SAFE_LOGIN.match?(login)
          response.headers[HEADER_NAME] = login
        else
          # Do not mislabel an invalid authenticated identity as anonymous.
          response.headers.delete(HEADER_NAME)
        end
      elsif user
        response.headers[HEADER_NAME] = 'anonymous'
      else
        # No reliable identity was available; do not retain a stale header.
        response.headers.delete(HEADER_NAME)
      end
    end
  end
end
