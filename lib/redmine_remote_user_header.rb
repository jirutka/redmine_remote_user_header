# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Jakub Jirutka <jakub@jirutka.cz>
# frozen_string_literal: true

require_relative 'redmine_remote_user_header/controller_patch'

# Redmine evaluates plugin initializers within its to_prepare callback.
# Re-include on development reloads, but never register duplicate callbacks.
unless ApplicationController < RedmineRemoteUserHeader::ControllerPatch
  ApplicationController.include RedmineRemoteUserHeader::ControllerPatch
end
