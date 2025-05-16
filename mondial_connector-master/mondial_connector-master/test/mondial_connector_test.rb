# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/mondial_connector'

REQUIRED_CLASSES = [
  MondialConnector::Base,
  MondialConnector::AccountSegments,
  MondialConnector::AccountSegmentOptions,
  MondialConnector::ChartOfAccounts,
  MondialConnector::AccountingTransactions
].freeze

class MondialConnectorTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MondialConnector::VERSION
  end

  def test_that_all_required_classes_are_visible
    REQUIRED_CLASSES.each do |required_class|
      assert_equal required_class, required_class.new.class
    end
  end
end
