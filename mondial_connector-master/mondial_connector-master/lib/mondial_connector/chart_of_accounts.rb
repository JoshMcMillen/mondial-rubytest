# frozen_string_literal: true

module MondialConnector
  # This class returns the source ERP system's chart of accounts.
  class ChartOfAccounts < Base
    # This identifies the Mondial API resource
    def gla_response
      unless @glar
        @glar = api_call({ resource: '/gl_accounts' })
        #  path = File.dirname(__FILE__) + '/../../test/mondial_connector/api_responses/gla_response.json'
        #  File.open(path, 'w') do |f|
        #    f.write(@glar.to_json)
        #  end
      end
      @glar
    end

      #       p api_call returns the following
      #       [
      #         {
      #           "id"=>403,
      #           "name"=>"Hegmann, Von and Mante",
      #           "description"=>"Quis modi molestiae qui.",
      #           "natural_account_number"=>"1732",
      #           "gl_account_type"=>"Asset",
      #           "gl_account_subtype"=>nil,
      #           "gl_account_type_id"=>1,
      #           "gl_account_subtype_id"=>nil,
      #           "currency_code"=>nil,
      #           "currency_id"=>nil,
      #           "created_at"=>"2023-12-24T19:24:04.050Z",
      #           "updated_at"=>"2023-12-24T19:24:04.050Z",
      #           "account_number"=>nil
      #         },
      #         {
      #           "id"=>404,
      #           "name"=>"Marks Inc",
      #           "description"=>"Molestiae laborum facilis nulla.",
      #           "natural_account_number"=>"2563",
      #           "gl_account_type"=>"Asset",
      #           "gl_account_subtype"=>nil,
      #           "gl_account_type_id"=>1,
      #           "gl_account_subtype_id"=>nil,
      #           "currency_code"=>nil,
      #           "currency_id"=>nil,
      #           "created_at"=>"2023-12-24T19:24:04.883Z",
      #           "updated_at"=>"2023-12-24T19:24:04.883Z",
      #           "account_number"=>nil
      #         },
      #         {
      #           "id"=>405,
      #           "name"=>"Mills-Purdy",
      #           "description"=>"Culpa ad vel illum.",
      #           "natural_account_number"=>"1477",
      #           "gl_account_type"=>"Asset",
      #           "gl_account_subtype"=>nil,
      #           "gl_account_type_id"=>1,
      #           "gl_account_subtype_id"=>nil,
      #           "currency_code"=>nil,
      #           "currency_id"=>nil,
      #           "created_at"=>"2023-12-24T19:24:05.732Z",
      #           "updated_at"=>"2023-12-24T19:24:05.732Z",
      #           "account_number"=>nil
      #         },
      #         {
      #           "id"=>406,
      #           "name"=>"Cassin, Lesch and Lebsack",
      #           "description"=>"Id et aut sapiente.",
      #           "natural_account_number"=>"2305",
      #           "gl_account_type"=>"Asset",
      #           "gl_account_subtype"=>nil,
      #           "gl_account_type_id"=>1,
      #           "gl_account_subtype_id"=>nil,
      #           "currency_code"=>nil,
      #           "currency_id"=>nil,
      #           "created_at"=>"2023-12-24T19:24:06.546Z",
      #           "updated_at"=>"2023-12-24T19:24:06.546Z",
      #           "account_number"=>nil
      #         },
      #         {
      #           "id"=>407,
      #           "name"=>"Zieme LLC",
      #           "description"=>"Sint nemo laborum tempore.",
      #           "natural_account_number"=>"1882",
      #           "gl_account_type"=>"Asset",
      #           "gl_account_subtype"=>nil,
      #           "gl_account_type_id"=>1,
      #           "gl_account_subtype_id"=>nil,
      #           "currency_code"=>nil,
      #           "currency_id"=>nil,
      #           "created_at"=>"2023-12-24T19:24:07.385Z",
      #           "updated_at"=>"2023-12-24T19:24:07.385Z",
      #           "account_number"=>nil
      #         }
      #       ]

    def ogla_response
      unless @oglar
        @oglar = api_call({ resource: '/organization_gl_accounts' })
        # path = File.dirname(__FILE__) + '/../../test/mondial_connector/api_responses/ogla_response.json'
        # File.open(path, 'w') do |f|
        #   f.write(@oglar.to_json)
        # end
      end
      @oglar
    end

    def standard_records(options = {})
      #  Within this example implementation, the source system distinguishes between
      #    a) Natural GL Accounts, which define the natural account number and the account type
      #    (i.e. Asset, Liability, Revenue, etc.)
      #    b) Segments, which are appended to the natural account number to form a unique number that characterises the
      #    Natural Account
      #  For instance, a business might have a Natural Account (4000 / Revenue) and appended segments for
      #  Region (100 / North America) and Market (86 / Menswear)
      #
      #  The Fully Qualified Account Number (FQAN) would be 4000-100-86
      #
      #  For a 3-segment account number, this is the RegEx that would be used to qualify the
      #  number: /^([aA-zZ0-9]+)-([aA-zZ0-9]+)-([aA-zZ0-9]+)$/
      #
      #  Defining the Natural Account requires an Account Name, such as "Sales".
      #  For reporting purposes, no additional account naming is required:  A user will know from the account code
      #  that 4000-100-86 is Sales related to North American menswear.
      #
      #  Even so, many ERP systems allow assigning a unique name to each FQAN.  So, account 4000-100-86 might be assigned a
      #  name such as "SALES of North American Menswear".
      #
      #  Within Mondial, such unique names for FQANs are optional.
      #


      #       p ogla_response[0..4]
      #       [
      #         {
      #           "id"=>1207,
      #           "part_id"=>nil,
      #           "external_id"=>"124663",
      #           "full_segmented_account_number"=>"1732-000-00",
      #           "source_system_name"=>{
      #             "id"=>1207,
      #             "organization_gl_account_id"=>1207,
      #             "name"=>"Hegmann, Von and Mante"
      #           },
      #           "gl_account"=>{
      #             "id"=>403,
      #             "account_number"=>"1732"
      #           }
      #         },
      #         {
      #           "id"=>1208,
      #           "part_id"=>nil,
      #           "external_id"=>"124664",
      #           "full_segmented_account_number"=>"1732-000-10",
      #           "source_system_name"=>{
      #             "id"=>1208,
      #             "organization_gl_account_id"=>1208,
      #             "name"=>"Howe, Romaguera and Hauck"
      #           },
      #           "gl_account"=>{
      #             "id"=>403,
      #             "account_number"=>"1732"
      #           }
      #         },
      #         {
      #           "id"=>1209,
      #           "part_id"=>nil,
      #           "external_id"=>"124665",
      #           "full_segmented_account_number"=>"1732-000-20",
      #           "source_system_name"=>{
      #             "id"=>1209,
      #             "organization_gl_account_id"=>1209,
      #             "name"=>"Satterfield-Sipes"
      #           },
      #           "gl_account"=>{
      #             "id"=>403,
      #             "account_number"=>"1732"
      #           }
      #         },
      #         {
      #           "id"=>1210,
      #           "part_id"=>nil,
      #           "external_id"=>"124666",
      #           "full_segmented_account_number"=>"1732-000-30",
      #           "source_system_name"=>{
      #             "id"=>1210,
      #             "organization_gl_account_id"=>1210,
      #             "name"=>"Predovic-Zemlak"
      #           },
      #           "gl_account"=>{
      #             "id"=>403,
      #             "account_number"=>"1732"
      #           }
      #         },
      #         {
      #           "id"=>1211,
      #           "part_id"=>nil,
      #           "external_id"=>"124667",
      #           "full_segmented_account_number"=>"1732-000-40",
      #           "source_system_name"=>{
      #             "id"=>1211,
      #             "organization_gl_account_id"=>1211,
      #             "name"=>"Kihn and Sons"
      #           },
      #           "gl_account"=>{
      #             "id"=>403,
      #             "account_number"=>"1732"
      #           }
      #         }
      #       ]

      #    The possible account types and their optional subtypes, if required, are:
      #
      #         gl_account_type  |             gl_account_subtype
      #       -------------------+---------------------------------------------
      #        Asset             | Cash
      #        Asset             | Accounts Receivable
      #        Asset             | Undeposited Funds
      #        Asset             | Supplier Prepayments
      #        Asset             | Fixed Asset
      #        Asset             | Inventory
      #        Contra asset      | Accumulated Depreciation
      #        Liability         | Credit Card
      #        Liability         | Customer Deposits
      #        Liability         | Accounts Payable
      #        Liability         | Accrued Liabilities
      #        Liability         | Taxes Payable
      #        Contra liability  |
      #        Equity            |
      #        Retained Earnings |
      #        Revenue           |
      #        Contra revenue    | Discounts Granted
      #        Expense           | Cost of Goods Sold
      #        Expense           | Exchange Rate Gains & Losses
      #        Expense           | Realized gains/losses on disposal of assets
      #        Contra expense    | Discounts Taken
      #
      #      Common ISO 4217 currency codes:
      #
      #               name       | alphabetic_code
      #         -----------------+-----------------
      #          US Dollar       | USD
      #          Canadian Dollar | CAD
      #          Euro            | EUR
      #          Mexican Peso    | MXN
      #          Pound Sterling  | GBP
      #          Yuan Renminbi   | CNY
      #          Yen             | JPY
      #

      ogla_response.map do |account|
        gl_account = gla_response.detect do |gla_account|
          gla_account['natural_account_number'] == /^([0-9]+)/.match(account['full_segmented_account_number'])[1]
        end

        {
          account_number:     account['full_segmented_account_number'], # mandatory
          name:               account['name'] || gl_account['name'],    # mandatory
          gl_account_type:    gl_account['gl_account_type'],            # mandatory
          description:        account['description'],                   # optional
          gl_account_subtype: gl_account['gl_account_subtype'],         # optional
          source_system_name: account['source_system_name']['name'],    # optional
          currency_code:      gl_account['currency_code']               # optional: Any ISO 4217 Alphabetic Code. Required only for accounts of sub-type "Cash".
        }
      end

      #
      #        Here is a (shortened) sample of all accounts, each with a unique source_system_name.
      #        Note that they are in groups ordered by their natural account number.
      #         [
      #           {:account_number=>"1732-000-00", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Hegmann, Von and Mante", :currency_code=>nil},
      #           {:account_number=>"1732-000-10", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Howe, Romaguera and Hauck", :currency_code=>nil},
      #           {:account_number=>"1732-000-20", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Satterfield-Sipes", :currency_code=>nil},
      #           {:account_number=>"1732-000-30", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Predovic-Zemlak", :currency_code=>nil},
      #           {:account_number=>"1732-000-40", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Kihn and Sons", :currency_code=>nil},
      #           {:account_number=>"1732-000-50", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Hackett and Sons", :currency_code=>nil},
      #           {:account_number=>"1732-100-00", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Steuber-Altenwerth", :currency_code=>nil},
      #           {:account_number=>"1732-100-10", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Lockman LLC", :currency_code=>nil},
      #           {:account_number=>"1732-100-20", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Bergnaum Group", :currency_code=>nil},
      #           {:account_number=>"1732-100-30", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"D'Amore-Bosco", :currency_code=>nil},
      #           {:account_number=>"1732-100-40", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Bode-Graham", :currency_code=>nil},
      #           {:account_number=>"1732-100-50", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Connelly-Schultz", :currency_code=>nil},
      #           {:account_number=>"1732-200-00", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Carroll, Wuckert and Feeney", :currency_code=>nil},
      #           {:account_number=>"1732-200-10", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Schuster Group", :currency_code=>nil},
      #           {:account_number=>"1732-200-20", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Davis LLC", :currency_code=>nil},
      #           {:account_number=>"1732-200-30", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Torp, Glover and West", :currency_code=>nil},
      #           {:account_number=>"1732-200-40", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Brown-Bechtelar", :currency_code=>nil},
      #           {:account_number=>"1732-200-50", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Cassin, Jacobson and Mraz", :currency_code=>nil},
      #           {:account_number=>"1732-300-00", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Bernier-Schneider", :currency_code=>nil},
      #           {:account_number=>"1732-300-10", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Daniel-Shields", :currency_code=>nil},
      #           {:account_number=>"1732-300-20", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Krajcik, Lang and Morissette", :currency_code=>nil},
      #           {:account_number=>"1732-300-30", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Lockman Inc", :currency_code=>nil},
      #           {:account_number=>"1732-300-40", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Farrell-Mueller", :currency_code=>nil},
      #           {:account_number=>"1732-300-50", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Roberts LLC", :currency_code=>nil},
      #           {:account_number=>"1732-400-00", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Zemlak-Bashirian", :currency_code=>nil},
      #           {:account_number=>"1732-400-10", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Thiel and Sons", :currency_code=>nil},
      #           {:account_number=>"1732-400-20", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Johns, Johns and Kreiger", :currency_code=>nil},
      #           {:account_number=>"1732-400-30", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Treutel Inc", :currency_code=>nil},
      #           {:account_number=>"1732-400-40", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Botsford LLC", :currency_code=>nil},
      #           {:account_number=>"1732-400-50", :name=>"Hegmann, Von and Mante", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Gutmann-Johnson", :currency_code=>nil},
      #           {:account_number=>"2563-000-00", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Marks Inc", :currency_code=>nil},
      #           {:account_number=>"2563-000-10", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Becker, Paucek and Sawayn", :currency_code=>nil},
      #           {:account_number=>"2563-000-20", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Lubowitz Group", :currency_code=>nil},
      #           {:account_number=>"2563-000-30", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Dach-Crist", :currency_code=>nil},
      #           {:account_number=>"2563-000-40", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Emmerich Inc", :currency_code=>nil},
      #           {:account_number=>"2563-000-50", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Rippin-Von", :currency_code=>nil},
      #           {:account_number=>"2563-100-00", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Waters, McDermott and Hills", :currency_code=>nil},
      #           {:account_number=>"2563-100-10", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Stiedemann, Casper and Powlowski", :currency_code=>nil},
      #           {:account_number=>"2563-100-20", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Schmitt, Schaefer and Kiehn", :currency_code=>nil},
      #           {:account_number=>"2563-100-30", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Tillman-Orn", :currency_code=>nil},
      #           {:account_number=>"2563-100-40", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Morissette-Hane", :currency_code=>nil},
      #           {:account_number=>"2563-100-50", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Mante, Boehm and Daugherty", :currency_code=>nil},
      #           {:account_number=>"2563-200-00", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Dickens Inc", :currency_code=>nil},
      #           {:account_number=>"2563-200-10", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Volkman, Brekke and Kautzer", :currency_code=>nil},
      #           {:account_number=>"2563-200-20", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Beer, Roob and Cole", :currency_code=>nil},
      #           {:account_number=>"2563-200-30", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Beatty-Stiedemann", :currency_code=>nil},
      #           {:account_number=>"2563-200-40", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Torphy, Kub and Yost", :currency_code=>nil},
      #           {:account_number=>"2563-200-50", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Will, Fritsch and Kreiger", :currency_code=>nil},
      #           {:account_number=>"2563-300-00", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Haley-Turcotte", :currency_code=>nil},
      #           {:account_number=>"2563-300-10", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Bradtke Inc", :currency_code=>nil},
      #           {:account_number=>"2563-300-20", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Crist-Heathcote", :currency_code=>nil},
      #           {:account_number=>"2563-300-30", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Kilback-Zemlak", :currency_code=>nil},
      #           {:account_number=>"2563-300-40", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Crist Inc", :currency_code=>nil},
      #           {:account_number=>"2563-300-50", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Zboncak Inc", :currency_code=>nil},
      #           {:account_number=>"2563-400-00", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Bosco Group", :currency_code=>nil},
      #           {:account_number=>"2563-400-10", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Rodriguez-Leuschke", :currency_code=>nil},
      #           {:account_number=>"2563-400-20", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Sanford-Kuphal", :currency_code=>nil},
      #           {:account_number=>"2563-400-30", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Hills-Fisher", :currency_code=>nil},
      #           {:account_number=>"2563-400-40", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Graham, Schaden and Schumm", :currency_code=>nil},
      #           {:account_number=>"2563-400-50", :name=>"Marks Inc", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Leffler-Nicolas", :currency_code=>nil},
      #           {:account_number=>"1477-000-00", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Mills-Purdy", :currency_code=>nil},
      #           {:account_number=>"1477-000-10", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Cruickshank-Skiles", :currency_code=>nil},
      #           {:account_number=>"1477-000-20", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Hayes-Barrows", :currency_code=>nil},
      #           {:account_number=>"1477-000-30", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Marvin-Mitchell", :currency_code=>nil},
      #           {:account_number=>"1477-000-40", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Lynch and Sons", :currency_code=>nil},
      #           {:account_number=>"1477-000-50", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Schuppe-Kshlerin", :currency_code=>nil},
      #           {:account_number=>"1477-100-00", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Mayert, Ruecker and Sipes", :currency_code=>nil},
      #           {:account_number=>"1477-100-10", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Kuhn, Abernathy and Kuhlman", :currency_code=>nil},
      #           {:account_number=>"1477-100-20", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Larson Inc", :currency_code=>nil},
      #           {:account_number=>"1477-100-30", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Schneider, Sanford and Stamm", :currency_code=>nil},
      #           {:account_number=>"1477-100-40", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Witting-Kuvalis", :currency_code=>nil},
      #           {:account_number=>"1477-100-50", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Okuneva-Lemke", :currency_code=>nil},
      #           {:account_number=>"1477-200-00", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Grady-Harber", :currency_code=>nil},
      #           {:account_number=>"1477-200-10", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Langworth-Mertz", :currency_code=>nil},
      #           {:account_number=>"1477-200-20", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Wiza-Stracke", :currency_code=>nil},
      #           {:account_number=>"1477-200-30", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Macejkovic Group", :currency_code=>nil},
      #           {:account_number=>"1477-200-40", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Borer Inc", :currency_code=>nil},
      #           {:account_number=>"1477-200-50", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Wehner, Considine and Walter", :currency_code=>nil},
      #           {:account_number=>"1477-300-00", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Kovacek LLC", :currency_code=>nil},
      #           {:account_number=>"1477-300-10", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Volkman-Lueilwitz", :currency_code=>nil},
      #           {:account_number=>"1477-300-20", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Abernathy Group", :currency_code=>nil},
      #           {:account_number=>"1477-300-30", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Mosciski, Streich and Kautzer", :currency_code=>nil},
      #           {:account_number=>"1477-300-40", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Satterfield, Cassin and Zieme", :currency_code=>nil},
      #           {:account_number=>"1477-300-50", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Lynch-Boyle", :currency_code=>nil},
      #           {:account_number=>"1477-400-00", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Bode Group", :currency_code=>nil},
      #           {:account_number=>"1477-400-10", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Runolfsson LLC", :currency_code=>nil},
      #           {:account_number=>"1477-400-20", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Waelchi-Adams", :currency_code=>nil},
      #           {:account_number=>"1477-400-30", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Koelpin, MacGyver and Ziemann", :currency_code=>nil},
      #           {:account_number=>"1477-400-40", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Casper, Will and Franecki", :currency_code=>nil},
      #           {:account_number=>"1477-400-50", :name=>"Mills-Purdy", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Prohaska Inc", :currency_code=>nil},
      #           {:account_number=>"2305-000-00", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Cassin, Lesch and Lebsack", :currency_code=>nil},
      #           {:account_number=>"2305-000-10", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Ullrich LLC", :currency_code=>nil},
      #           {:account_number=>"2305-000-20", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Witting LLC", :currency_code=>nil},
      #           {:account_number=>"2305-000-30", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Williamson, Schmitt and Sauer", :currency_code=>nil},
      #           {:account_number=>"2305-000-40", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Hermiston, Smith and Pacocha", :currency_code=>nil},
      #           {:account_number=>"2305-000-50", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Ortiz, Grimes and Zulauf", :currency_code=>nil},
      #           {:account_number=>"2305-100-00", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Champlin, Hane and Renner", :currency_code=>nil},
      #           {:account_number=>"2305-100-10", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Goodwin-Hackett", :currency_code=>nil},
      #           {:account_number=>"2305-100-20", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Yost LLC", :currency_code=>nil},
      #           {:account_number=>"2305-100-30", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"O'Keefe-Kunde", :currency_code=>nil},
      #           {:account_number=>"2305-100-40", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Erdman Inc", :currency_code=>nil},
      #           {:account_number=>"2305-100-50", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Botsford-Lockman", :currency_code=>nil},
      #           {:account_number=>"2305-200-00", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Prohaska LLC", :currency_code=>nil},
      #           {:account_number=>"2305-200-10", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Mante-Stanton", :currency_code=>nil},
      #           {:account_number=>"2305-200-20", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Deckow, Hills and Lockman", :currency_code=>nil},
      #           {:account_number=>"2305-200-30", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Paucek Group", :currency_code=>nil},
      #           {:account_number=>"2305-200-40", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Boehm and Sons", :currency_code=>nil},
      #           {:account_number=>"2305-200-50", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Ryan, Dicki and Feest", :currency_code=>nil},
      #           {:account_number=>"2305-300-00", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Purdy-O'Reilly", :currency_code=>nil},
      #           {:account_number=>"2305-300-10", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Marquardt LLC", :currency_code=>nil},
      #           {:account_number=>"2305-300-20", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Kiehn LLC", :currency_code=>nil},
      #           {:account_number=>"2305-300-30", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Zulauf, Jaskolski and Walker", :currency_code=>nil},
      #           {:account_number=>"2305-300-40", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Mayert and Sons", :currency_code=>nil},
      #           {:account_number=>"2305-300-50", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Welch and Sons", :currency_code=>nil},
      #           {:account_number=>"2305-400-00", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Doyle, Bergstrom and Grimes", :currency_code=>nil},
      #           {:account_number=>"2305-400-10", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Metz Group", :currency_code=>nil},
      #           {:account_number=>"2305-400-20", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Olson-Rosenbaum", :currency_code=>nil},
      #           {:account_number=>"2305-400-30", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Maggio LLC", :currency_code=>nil},
      #           {:account_number=>"2305-400-40", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Brekke, Gerhold and Armstrong", :currency_code=>nil},
      #           {:account_number=>"2305-400-50", :name=>"Cassin, Lesch and Lebsack", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Morissette, Towne and Runolfsson", :currency_code=>nil},
      #           {:account_number=>"1882-000-00", :name=>"Zieme LLC", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Zieme LLC", :currency_code=>nil},
      #           {:account_number=>"1882-000-10", :name=>"Zieme LLC", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Gislason, King and Beatty", :currency_code=>nil},
      #           {:account_number=>"1882-000-20", :name=>"Zieme LLC", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Baumbach-Larkin", :currency_code=>nil},
      #           {:account_number=>"1882-000-30", :name=>"Zieme LLC", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Batz LLC", :currency_code=>nil},
      #           {:account_number=>"1882-000-40", :name=>"Zieme LLC", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Schmeler, Rowe and Marks", :currency_code=>nil},
      #           {:account_number=>"1882-000-50", :name=>"Zieme LLC", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Roberts, Deckow and Ernser", :currency_code=>nil},
      #           {:account_number=>"1882-100-00", :name=>"Zieme LLC", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Carter and Sons", :currency_code=>nil},
      #           {:account_number=>"1882-100-10", :name=>"Zieme LLC", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>nil, :source_system_name=>"Schumm-Ankunding", :currency_code=>nil},
      #           ...skipping...
      #           {:account_number=>"6576-400-10", :name=>"Volkman LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Wunsch, Huels and Becker", :currency_code=>nil},
      #           {:account_number=>"6576-400-20", :name=>"Volkman LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Walker, Wiegand and Kuvalis", :currency_code=>nil},
      #           {:account_number=>"6576-400-30", :name=>"Volkman LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Ledner Inc", :currency_code=>nil},
      #           {:account_number=>"6576-400-40", :name=>"Volkman LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Bartoletti LLC", :currency_code=>nil},
      #           {:account_number=>"6576-400-50", :name=>"Volkman LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Kreiger and Sons", :currency_code=>nil},
      #           {:account_number=>"6394-000-00", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Abbott and Sons", :currency_code=>nil},
      #           {:account_number=>"6394-000-10", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Maggio LLC", :currency_code=>nil},
      #           {:account_number=>"6394-000-20", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Greenfelder-Spencer", :currency_code=>nil},
      #           {:account_number=>"6394-000-30", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Marks-Streich", :currency_code=>nil},
      #           {:account_number=>"6394-000-40", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Kessler LLC", :currency_code=>nil},
      #           {:account_number=>"6394-000-50", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Smith-Bashirian", :currency_code=>nil},
      #           {:account_number=>"6394-100-00", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Mayer-Glover", :currency_code=>nil},
      #           {:account_number=>"6394-100-10", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Waelchi, Block and Leannon", :currency_code=>nil},
      #           {:account_number=>"6394-100-20", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Johns-Cronin", :currency_code=>nil},
      #           {:account_number=>"6394-100-30", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Kassulke-Brakus", :currency_code=>nil},
      #           {:account_number=>"6394-100-40", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Schmidt and Sons", :currency_code=>nil},
      #           {:account_number=>"6394-100-50", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Schuppe, Gerhold and Bernhard", :currency_code=>nil},
      #           {:account_number=>"6394-200-00", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Ruecker, Ryan and Altenwerth", :currency_code=>nil},
      #           {:account_number=>"6394-200-10", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Breitenberg and Sons", :currency_code=>nil},
      #           {:account_number=>"6394-200-20", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Feeney, Grant and Hoeger", :currency_code=>nil},
      #           {:account_number=>"6394-200-30", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Lehner and Sons", :currency_code=>nil},
      #           {:account_number=>"6394-200-40", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Olson-Weber", :currency_code=>nil},
      #           {:account_number=>"6394-200-50", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Haag-Greenholt", :currency_code=>nil},
      #           {:account_number=>"6394-300-00", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Corwin-Reilly", :currency_code=>nil},
      #           {:account_number=>"6394-300-10", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Dach-Bins", :currency_code=>nil},
      #           {:account_number=>"6394-300-20", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Reynolds, Smith and Morar", :currency_code=>nil},
      #           {:account_number=>"6394-300-30", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Lueilwitz and Sons", :currency_code=>nil},
      #           {:account_number=>"6394-300-40", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Bins, Nienow and Brekke", :currency_code=>nil},
      #           {:account_number=>"6394-300-50", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Witting-Marks", :currency_code=>nil},
      #           {:account_number=>"6394-400-00", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Steuber-Kozey", :currency_code=>nil},
      #           {:account_number=>"6394-400-10", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Parker Inc", :currency_code=>nil},
      #           {:account_number=>"6394-400-20", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Grady, Upton and Vandervort", :currency_code=>nil},
      #           {:account_number=>"6394-400-30", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Weber LLC", :currency_code=>nil},
      #           {:account_number=>"6394-400-40", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Shanahan Inc", :currency_code=>nil},
      #           {:account_number=>"6394-400-50", :name=>"Abbott and Sons", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Bergstrom LLC", :currency_code=>nil},
      #           {:account_number=>"6846-000-00", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Stoltenberg LLC", :currency_code=>nil},
      #           {:account_number=>"6846-000-10", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Kuhlman, Toy and DuBuque", :currency_code=>nil},
      #           {:account_number=>"6846-000-20", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Spinka, Turner and Stamm", :currency_code=>nil},
      #           {:account_number=>"6846-000-30", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Walker, Feest and Runolfsdottir", :currency_code=>nil},
      #           {:account_number=>"6846-000-40", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Reichel Inc", :currency_code=>nil},
      #           {:account_number=>"6846-000-50", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Denesik LLC", :currency_code=>nil},
      #           {:account_number=>"6846-100-00", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Sporer, Hauck and Grimes", :currency_code=>nil},
      #           {:account_number=>"6846-100-10", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Hilpert, Rempel and Orn", :currency_code=>nil},
      #           {:account_number=>"6846-100-20", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Conn LLC", :currency_code=>nil},
      #           {:account_number=>"6846-100-30", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Konopelski, Gulgowski and Moen", :currency_code=>nil},
      #           {:account_number=>"6846-100-40", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Bartoletti, Brown and Block", :currency_code=>nil},
      #           {:account_number=>"6846-100-50", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Wintheiser-Swaniawski", :currency_code=>nil},
      #           {:account_number=>"6846-200-00", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Moore-Lehner", :currency_code=>nil},
      #           {:account_number=>"6846-200-10", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Graham Inc", :currency_code=>nil},
      #           {:account_number=>"6846-200-20", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Batz, Weissnat and Crist", :currency_code=>nil},
      #           {:account_number=>"6846-200-30", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Bauch LLC", :currency_code=>nil},
      #           {:account_number=>"6846-200-40", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Osinski-Kihn", :currency_code=>nil},
      #           {:account_number=>"6846-200-50", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Jones Inc", :currency_code=>nil},
      #           {:account_number=>"6846-300-00", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Franecki, Willms and Dickens", :currency_code=>nil},
      #           {:account_number=>"6846-300-10", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Pfeffer Group", :currency_code=>nil},
      #           {:account_number=>"6846-300-20", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Kovacek-Pouros", :currency_code=>nil},
      #           {:account_number=>"6846-300-30", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Harvey, Balistreri and Schmeler", :currency_code=>nil},
      #           {:account_number=>"6846-300-40", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Dooley-Wiza", :currency_code=>nil},
      #           {:account_number=>"6846-300-50", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Thompson-Hamill", :currency_code=>nil},
      #           {:account_number=>"6846-400-00", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Doyle, Goldner and Roberts", :currency_code=>nil},
      #           {:account_number=>"6846-400-10", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Rowe-Bergnaum", :currency_code=>nil},
      #           {:account_number=>"6846-400-20", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Wintheiser Group", :currency_code=>nil},
      #           {:account_number=>"6846-400-30", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Doyle-Mosciski", :currency_code=>nil},
      #           {:account_number=>"6846-400-40", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Hoeger LLC", :currency_code=>nil},
      #           {:account_number=>"6846-400-50", :name=>"Stoltenberg LLC", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Hoeger-Balistreri", :currency_code=>nil},
      #           {:account_number=>"5000-000-00", :name=>"Sales", :description=>nil, :gl_account_type=>"Revenue", :gl_account_subtype=>nil, :source_system_name=>"Sales", :currency_code=>nil},
      #           {:account_number=>"1200-000-00", :name=>"Accounts Receivable", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>"Accounts Receivable", :source_system_name=>"Accounts Receivable", :currency_code=>nil},
      #           {:account_number=>"3200-000-00", :name=>"Accounts Payable", :description=>nil, :gl_account_type=>"Liability", :gl_account_subtype=>"Accounts Payable", :source_system_name=>"Accounts Payable", :currency_code=>nil},
      #           {:account_number=>"6750-000-00", :name=>"Unrealized FX Gains and Losses", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Unrealized FX Gains and Losses", :currency_code=>nil},
      #           {:account_number=>"6751-000-00", :name=>"Realized FX Gains and Losses", :description=>nil, :gl_account_type=>"Expense", :gl_account_subtype=>nil, :source_system_name=>"Realized FX Gains and Losses", :currency_code=>nil},
      #           {:account_number=>"4750-000-00", :name=>"Cummulative Translation Adjustment", :description=>nil, :gl_account_type=>"Equity", :gl_account_subtype=>nil, :source_system_name=>"Cummulative Translation Adjustment", :currency_code=>nil},
      #           {:account_number=>"1000-000-00", :name=>"Cash", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>"Cash", :source_system_name=>"Cash", :currency_code=>"GBP"},
      #           {:account_number=>"1001-000-00", :name=>"Foreign Currency Cash 1", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>"Cash", :source_system_name=>"Foreign Currency Cash 1", :currency_code=>"USD"},
      #           {:account_number=>"1002-000-00", :name=>"Foreign Currency Cash 2", :description=>nil, :gl_account_type=>"Asset", :gl_account_subtype=>"Cash", :source_system_name=>"Foreign Currency Cash 2", :currency_code=>"EUR"}
      #         ]
    end
  end
end
