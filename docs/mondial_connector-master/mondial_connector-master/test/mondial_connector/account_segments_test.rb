# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/mondial_connector'
require_relative '../../lib/mondial_connector/account_segments'

# This is the message that is returned to the MondialConnector::AccountSegments instance from the api_call() method
# Put the new connector's API response here
API_RESPONSE =
  [
    {
      'id' => 7,
      'name' => 'region',
      'ordinal' => 2,
      'field_validator_id' => 49,
      'enforce_balancing' => false
    },
    {
      'id' => 8,
      'name' => 'department',
      'ordinal' => 3,
      'field_validator_id' => 49,
      'enforce_balancing' => false
    }
  ].freeze

# This is the format of an acceptable returned result of MondialConnector::AccountSegments#get_records()
REQUIRED_RESULT =
  [
    {
      name: 'region',
      ordinal: 2
    },
    {
      name: 'department',
      ordinal: 3
    }
  ].freeze

class AccountSegmentsTest < Minitest::Test
  def test_standard_records
    account_segments = MondialConnector::AccountSegments.new

    account_segments.stub :api_call, API_RESPONSE do
      returned_records = account_segments.standard_records

      # Test that it contains the correct keys
      assert_equal %i[name ordinal], returned_records.map(&:keys).uniq.flatten.sort

      # Names are all strings
      assert_equal [String], returned_records.map { |h| h[:name].class }.flatten.uniq

      # Ordinals are a sequence of integers beginning at 2
      assert_equal [Integer], returned_records.map { |h| h[:ordinal].class }.flatten.uniq
      assert_equal 2, returned_records.map { |h| h[:ordinal] }.flatten.min
      assert_equal (2..returned_records.length + 1).to_a, returned_records.map { |h| h[:ordinal] }.flatten.uniq.sort
    end
  end
end
