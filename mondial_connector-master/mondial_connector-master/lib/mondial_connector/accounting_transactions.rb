# frozen_string_literal: true

module MondialConnector
  # This class returns the source ERP system's Accounting Transactions
  class AccountingTransactions < Base
    ACCOUNTING_TRANSACTIONS_PER_PAGE = 100

    def accounting_transactions_response(options={})
      @atr = api_call(options)

      # path = File.dirname(__FILE__) + '/../../test/mondial_connector/api_responses/accounting_transactions_response.json'
      # File.open(path, 'w') do |f|
      #   f.write(@atr.to_json)
      # end

      @atr
    end

    def transaction_count_response
      api_call({ resource: "/accounting_transactions/count" })

      #       {"count"=>150003}

    end

    def transaction_backlog

      result = transaction_count_response.to_hash #.with_indifferent_access

      remainder = (result["count"].to_i % ACCOUNTING_TRANSACTIONS_PER_PAGE)
      pages = (result["count"].to_i / ACCOUNTING_TRANSACTIONS_PER_PAGE).to_i
      pages += 1 unless remainder.zero?

      result["pages"] = pages

      # {"count"=>150003, "pages"=>301}

      result
    end

    def standard_records(options = {})
      accounting_transactions_resource = {
        resource: '/accounting_transactions',
        query: { limit: ACCOUNTING_TRANSACTIONS_PER_PAGE, offset: options[:offset] }
      }


      response = accounting_transactions_response(accounting_transactions_resource)

      #  p response[0]
      #  {
      #    "id"=>"0190efc9-5f38-7016-bb5e-7c00801e866c", 
      #    "parent_id"=>nil, 
      #    "transaction_date"=>"2022-12-22", 
      #    "description"=>"Template Account Transaction Ut at et ab.", 
      #    "accounting_transaction_subtype_id"=>nil, 
      #    "external_transaction_id"=>"01913851-a000-77d9-ae5b-9a4e9fe125f4", 
      #    "reversed"=>"false", 
      #    "created_at"=>"2023-12-24T19:27:41.106Z", 
      #    "updated_at"=>"2023-12-24T19:27:41.106Z", 
      #    "accounting_transaction_details"=>[
      #      {
      #        "id"=>"0190efc9-760d-7e3f-a542-c94749333a9a", 
      #        "organization_gl_account_id"=>6075, 
      #        "amount"=>"6081.93", 
      #        "home_currency_amount"=>"6081.93", 
      #        "description"=>nil, 
      #        "external_transaction_detail_id"=>nil, 
      #        "account_number"=>"6726-100-20", 
      #        "debit_credit_flag"=>"DR", 
      #        "currency_code"=>"GBP", 
      #        "tags"=>[
      #          {"id"=>9, "external_id"=>"Demographic", "values"=>[{"id"=>60, "external_id"=>"Teens", "fraction"=>"100.0", "scalar"=>"0.0", "comment"=>""}]}
      #        ]
      #      }, 
      #      {
      #        "id"=>"0190efc9-760d-712a-8d5a-745027b2898d", 
      #        "organization_gl_account_id"=>3324, 
      #        "amount"=>"6081.93", 
      #        "home_currency_amount"=>"6081.93", 
      #        "description"=>nil, 
      #        "external_transaction_detail_id"=>nil, 
      #        "account_number"=>"4701-200-50", 
      #        "debit_credit_flag"=>"CR", 
      #        "currency_code"=>"GBP", 
      #        "tags"=>[
      #          {"id"=>9, "external_id"=>"Demographic", "values"=>[{"id"=>60, "external_id"=>"Teens", "fraction"=>"100.0", "scalar"=>"0.0", "comment"=>""}]}
      #        ]
      #      }
      #    ]
      #  }


      #   The returned result will be a Ruby nested Hash object of the following structure:
      #
      #     [
      #       {
      #         unique_identifier:     nil,  #    text                           | not null |  This must be unique.
      #                          If the source system doesn't provide a unique ID, the connector must generate one.
      #
      #         description:           nil,  #    text                           | not null |
      #         transaction_date:      nil,  #    date                           | not null |
      #         posted_date:           nil,  #    date                           | not null |
      #         source_system_id:      nil,  #    integer                        |          |
      #         source_system_journal: nil,  #    text                           |          |
      #         external_created_at:   nil,  #    timestamp(6) without time zone |          |
      #         external_updated_at:   nil,  #    timestamp(6) without time zone |          |
      #         accounting_transaction_details: [
      #           {
      #             accounting_transaction_id:      nil,   # uuid    | not null |
      #             transaction_detail_seq_id:      nil,   # integer | not null |
      #             gl_account_id:                  nil,   # integer | not null |
      #             currency_amount:                nil,   # numeric | not null |  Typically, this is a positive amount.
      #                                      However, we've seen instances where this amount is negative (i.e. -1000.00)
      #             currency_id:                    nil,   # integer | not null |
      #             home_currency_amount:           nil,   # numeric | not null |
      #             debit_credit_flag:              false, # boolean |          |
      #             description:                    nil,   # text    |          |
      #             external_transaction_detail_id: nil    # text    | not null |
      #           },
      #           {
      #             accounting_transaction_id:      nil,   # uuid    | not null |
      #             transaction_detail_seq_id:      nil,   # integer | not null |
      #             gl_account_id:                  nil,   # integer | not null |
      #             currency_amount:                nil,   # numeric | not null |
      #             currency_id:                    nil,   # integer | not null |
      #             home_currency_amount:           nil,   # numeric | not null |
      #             debit_credit_flag:              true,  # boolean |          |
      #             description:                    nil,   # text    |          |
      #             external_transaction_detail_id: nil    # text    | not null |
      #           }
      #          # ...
      #         ]
      #       }
      #       # ...
      #     ]

      response.map do |transaction|

        # p "-------------------------------------"
        # p transaction.class
        # p transaction
        # p "-------------------------------------"

        details = transaction.delete('accounting_transaction_details')

        # p "================================"
        # p details.class
        # p details
        # p "================================"

        tx_hash =
          {
            unique_identifier: transaction['id'],              #    text  | not null |  This must be unique. If the source system doesn't provide a unique ID, the connector must generate one.
            description: transaction['description'],           #    text  | not null |
            transaction_date: transaction['transaction_date'], #    date  | not null |
            posted_date: transaction['transaction_date'],      #    date  | not null |
            external_created_at: transaction['created_at'],    #    timestamp(6) without time zone |          |
            external_updated_at: transaction['updated_at']     #    timestamp(6) without time zone |          |
          }

        detail_seq_id = 0
        tx_hash['accounting_transaction_details'] = details.map do |detail|
          detail_seq_id += 1

          ext_txd_id = if detail['external_transaction_detail_id'].nil? || detail['external_transaction_detail_id'].blank? 
                         SecureRandom.uuid
                       else
                         detail['external_transaction_detail_id']
                       end

          {
            transaction_detail_seq_id: detail_seq_id,             # integer | not null |  If no line item ordinal field is provided then this field is generated by the connector
            gl_account_number: detail['account_number'],          # full_segmented_account_number | not null |
            currency_amount: detail['amount'],                    # numeric | not null |  Typically, this is a positive amount.  However, we've seen instances where this amount is negative (i.e. -1000.00)
            currency_code: detail['currency_code'],               # integer | not null |
            home_currency_amount: detail['home_currency_amount'], # numeric | not null |
            debit_credit_flag: detail['debit_credit_flag'],       # text | "DR" or "CR"
            description: detail['description'],                   # text    |          |
            external_transaction_detail_id: ext_txd_id            # text
          }
        end

        tx_hash
      end
    end
  end
end
