# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Jakub Jirutka <jakub@jirutka.cz>
# frozen_string_literal: true

require_relative 'lib/redmine_remote_user_header'

Redmine::Plugin.register :redmine_remote_user_header do
  name 'Remote-User Response Header'
  author 'Jakub Jirutka'
  description 'Adds the authenticated Redmine login to the Remote-User HTTP response header for reverse-proxy access logging.'
  version '0.0.0'
  url 'https://github.com/jirutka/redmine_remote_user_header'
  author_url 'https://github.com/jirutka'
  requires_redmine version_or_higher: '6.0.0'
end
