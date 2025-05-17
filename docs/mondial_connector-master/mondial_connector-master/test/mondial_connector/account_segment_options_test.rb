# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/mondial_connector'
require_relative '../../lib/mondial_connector/account_segment_options'

# This is the message that is returned to the MondialConnector::AccountSegments instance from the api_call() method
# Put the new connector's API response here
API_RESPONSES =
  [[{"id"=>6, "name"=>"Default", "code"=>"000", "short_description"=>"Def", "created_at"=>"2023-12-24T19:24:03.904Z", "updated_at"=>"2023-12-24T19:24:03.904Z", "gl_account_segment"=>{"id"=>7, "name"=>"region"}}, {"id"=>7, "name"=>"East", "code"=>"100", "short_description"=>"Eas", "created_at"=>"2023-12-24T19:24:03.909Z", "updated_at"=>"2023-12-24T19:24:03.909Z", "gl_account_segment"=>{"id"=>7, "name"=>"region"}}, {"id"=>8, "name"=>"West", "code"=>"200", "short_description"=>"Wes", "created_at"=>"2023-12-24T19:24:03.915Z", "updated_at"=>"2023-12-24T19:24:03.915Z", "gl_account_segment"=>{"id"=>7, "name"=>"region"}}, {"id"=>9, "name"=>"North", "code"=>"300", "short_description"=>"Nor", "created_at"=>"2023-12-24T19:24:03.919Z", "updated_at"=>"2023-12-24T19:24:03.919Z", "gl_account_segment"=>{"id"=>7, "name"=>"region"}}, {"id"=>10, "name"=>"South", "code"=>"400", "short_description"=>"Sou", "created_at"=>"2023-12-24T19:24:03.924Z", "updated_at"=>"2023-12-24T19:24:03.924Z", "gl_account_segment"=>{"id"=>7, "name"=>"region"}}], [{"id"=>11, "name"=>"Default", "code"=>"00", "short_description"=>"Def", "created_at"=>"2023-12-24T19:24:03.946Z", "updated_at"=>"2023-12-24T19:24:03.946Z", "gl_account_segment"=>{"id"=>8, "name"=>"department"}}, {"id"=>12, "name"=>"Engineering", "code"=>"10", "short_description"=>"Eng", "created_at"=>"2023-12-24T19:24:03.951Z", "updated_at"=>"2023-12-24T19:24:03.951Z", "gl_account_segment"=>{"id"=>8, "name"=>"department"}}, {"id"=>13, "name"=>"Marketing", "code"=>"20", "short_description"=>"Mar", "created_at"=>"2023-12-24T19:24:03.955Z", "updated_at"=>"2023-12-24T19:24:03.955Z", "gl_account_segment"=>{"id"=>8, "name"=>"department"}}, {"id"=>14, "name"=>"Sales", "code"=>"30", "short_description"=>"Sal", "created_at"=>"2023-12-24T19:24:03.960Z", "updated_at"=>"2023-12-24T19:24:03.960Z", "gl_account_segment"=>{"id"=>8, "name"=>"department"}}, {"id"=>15, "name"=>"Admin", "code"=>"40", "short_description"=>"Adm", "created_at"=>"2023-12-24T19:24:03.966Z", "updated_at"=>"2023-12-24T19:24:03.966Z", "gl_account_segment"=>{"id"=>8, "name"=>"department"}}, {"id"=>16, "name"=>"Manufacturing", "code"=>"50", "short_description"=>"Man", "created_at"=>"2023-12-24T19:24:03.971Z", "updated_at"=>"2023-12-24T19:24:03.971Z", "gl_account_segment"=>{"id"=>8, "name"=>"department"}}]].freeze

# This is the format of an acceptable returned result of MondialConnector::AccountSegments#get_records()
REQUIRED_RESULT =
  [
    {:name=>"Default", :code=>"000", :short_description=>"Def", :gl_account_segment_name=>"region"},
    {:name=>"East", :code=>"100", :short_description=>"Eas", :gl_account_segment_name=>"region"},
    {:name=>"West", :code=>"200", :short_description=>"Wes", :gl_account_segment_name=>"region"},
    {:name=>"North", :code=>"300", :short_description=>"Nor", :gl_account_segment_name=>"region"},
    {:name=>"South", :code=>"400", :short_description=>"Sou", :gl_account_segment_name=>"region"},
    {:name=>"Default", :code=>"00", :short_description=>"Def", :gl_account_segment_name=>"department"},
    {:name=>"Engineering", :code=>"10", :short_description=>"Eng", :gl_account_segment_name=>"department"},
    {:name=>"Marketing", :code=>"20", :short_description=>"Mar", :gl_account_segment_name=>"department"},
    {:name=>"Sales", :code=>"30", :short_description=>"Sal", :gl_account_segment_name=>"department"},
    {:name=>"Admin", :code=>"40", :short_description=>"Adm", :gl_account_segment_name=>"department"},
    {:name=>"Manufacturing", :code=>"50", :short_description=>"Man", :gl_account_segment_name=>"department"}
  ].freeze

class AccountSegmentOptionsTest < Minitest::Test
  def test_standard_records
    account_segment_options = MondialConnector::AccountSegmentOptions.new

    account_segment_options.stub :api_calls, API_RESPONSES do
      account_segment_options.stub :api_call, [] do 
        returned_records = account_segment_options.standard_records

        # Returned Records are in an array of hashes
        assert returned_records.instance_of?(Array)
        assert returned_records.all? {|e| e.instance_of?(Hash)}

        # Test that it contains the correct keys
        assert_equal %i[code gl_account_segment_name name short_description], returned_records.map(&:keys).uniq.flatten.sort

        # Names are all strings
        assert_equal [String], returned_records.map { |h| h[:name].class }.flatten.uniq

        # Codes are all strings
        assert_equal [String], returned_records.map { |h| h[:code].class }.flatten.uniq

        # GL Account Segment Names are all strings
        assert_equal [String], returned_records.map { |h| h[:gl_account_segment_name].class }.flatten.uniq

        # Short Descriptions are all strings
        assert_equal [String], returned_records.map { |h| h[:short_description].class }.flatten.uniq


      end
    end
  end
end
