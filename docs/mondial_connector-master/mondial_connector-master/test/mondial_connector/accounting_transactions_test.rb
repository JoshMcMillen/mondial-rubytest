# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/mondial_connector'
require_relative '../../lib/mondial_connector/accounting_transactions'

# This is the message that is returned to the MondialConnector::AccountSegments instance from the api_call() method
# Put the new connector's API response here

# This is the format of an acceptable returned result of MondialConnector::AccountSegments#get_records()
class AccountingTransactionsTest < Minitest::Test
  def test_standard_records
    accounting_transactions_response_path = File.dirname(__FILE__) + '/api_responses/accounting_transactions_response.json'
    accounting_transactions_response      = JSON.parse(File.read(accounting_transactions_response_path))

    accounting_transactions_iot = MondialConnector::AccountingTransactions.new

    accounting_transactions_iot.stub :accounting_transactions_response, accounting_transactions_response do
      accounting_transactions_iot.stub :transaction_backlog, {"count"=>150003, "pages"=>301} do 

        returned_records = accounting_transactions_iot.standard_records({offset: 0})

        # Returned Records are in an array of hashes
        assert returned_records.instance_of?(Array)
        assert returned_records.all? {|e| e.instance_of?(Hash)}
        # Test that it contains the correct keys
        # p "*********************************************"
        # p returned_records.map(&:keys).uniq.flatten.map {|k| k.to_sym}.sort.flatten
        # p "*********************************************"
        assert_equal [:accounting_transaction_details, :description, :external_created_at, :external_updated_at, :posted_date, :transaction_date, :unique_identifier], returned_records.map(&:keys).uniq.flatten.map {|k| k.to_sym}.sort.flatten

        # p "*********************************************"
        #     returned_records.each do |r|
        #       p r["accounting_transaction_details"]
        #     end
        # p "*********************************************"

        assert_equal [Array], returned_records.map { |h| h["accounting_transaction_details"].class }.flatten.compact.uniq
        assert_equal [Hash], returned_records.map { |h| h["accounting_transaction_details"].map {|d| d.class }.flatten.compact.uniq }.flatten.compact.uniq
        assert_equal [
          :currency_amount, 
          :currency_code, 
          :debit_credit_flag, 
          :description, 
          :external_transaction_detail_id, 
          :gl_account_number, 
          :home_currency_amount, 
          :transaction_detail_seq_id
        ], returned_records.map {|r| r["accounting_transaction_details"].map(&:keys).flatten.uniq }.flatten.uniq.sort

      end
    end
  end

  def test_transaction_backlog
    accounting_transactions_iot = MondialConnector::AccountingTransactions.new
    accounting_transactions_iot.stub :transaction_count_response, {"count"=>150003} do
      result = accounting_transactions_iot.transaction_backlog
      expected_result = {
        "count"=>150003, 
        "pages"=>1501
      }
      assert_equal expected_result, result
    end
  end
end
