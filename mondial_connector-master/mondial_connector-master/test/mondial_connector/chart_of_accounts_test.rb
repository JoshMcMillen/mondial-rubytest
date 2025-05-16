# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/mondial_connector'
require_relative '../../lib/mondial_connector/chart_of_accounts'

# This is the message that is returned to the MondialConnector::AccountSegments instance from the api_call() method
# Put the new connector's API response here

# This is the format of an acceptable returned result of MondialConnector::AccountSegments#get_records()
class ChartOfAccountsTest < Minitest::Test
  def test_standard_records
    ogla_response_path = File.dirname(__FILE__) + '/api_responses/ogla_response.json'
    ogla_response = JSON.parse(File.read(ogla_response_path))
    gla_response_path = File.dirname(__FILE__) + '/api_responses/gla_response.json'
    gla_response = JSON.parse(File.read(gla_response_path))

    chart_of_accounts_iot = MondialConnector::ChartOfAccounts.new

    chart_of_accounts_iot.stub :ogla_response, ogla_response do
      chart_of_accounts_iot.stub :gla_response, gla_response do 

        returned_records = chart_of_accounts_iot.standard_records

        # Returned Records are in an array of hashes
        assert returned_records.instance_of?(Array)
        assert returned_records.all? {|e| e.instance_of?(Hash)}
        # Test that it contains the correct keys
        assert_equal %i[account_number currency_code description gl_account_subtype gl_account_type name source_system_name], returned_records.map(&:keys).uniq.flatten.sort

        # All strings
        assert_equal [String], returned_records.map { |h| h[:account_number].class }.flatten.compact.uniq
        assert_equal [String], returned_records.map { |h| h[:name].class }.flatten.compact.uniq
        assert_equal [String], returned_records.map { |h| h[:source_system_name].class }.flatten.compact.uniq

      end
    end
  end
end
