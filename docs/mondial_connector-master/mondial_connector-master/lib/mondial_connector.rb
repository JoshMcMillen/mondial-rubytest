# frozen_string_literal: true

require 'mondial_connector/version'
require 'mondial_connector/base'
require 'mondial_connector/account_segments'
require 'mondial_connector/account_segment_options'
require 'mondial_connector/chart_of_accounts'
require 'mondial_connector/accounting_transactions'

module MondialConnector
  class Error < StandardError; end
end
