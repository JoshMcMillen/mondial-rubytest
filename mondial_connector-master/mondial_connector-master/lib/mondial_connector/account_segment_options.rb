# frozen_string_literal: true

module MondialConnector
  # This class returns the source system's Options for each of its Account Segments
  class AccountSegmentOptions < Base
    # This identifies the Mondial API resource
    def resource(segment_id)
      "/gl_account_segments/#{segment_id}/gl_account_segment_options"
    end

    def standard_records(_options = {})
      # options = {
      #   as_of_date: nil
      # }.merge(options)

      response = api_calls

      # p response
      # [
      #   [
      #     {
      #       "id"=>6,
      #       "name"=>"Default",
      #       "code"=>"000",
      #       "short_description"=>"Def",
      #       "created_at"=>"2023-12-24T19:24:03.904Z",
      #       "updated_at"=>"2023-12-24T19:24:03.904Z",
      #       "gl_account_segment"=>{
      #         "id"=>7,
      #         "name"=>"region"
      #       }
      #     },
      #     {
      #       "id"=>7,
      #       "name"=>"East",
      #       "code"=>"100",
      #       "short_description"=>"Eas",
      #       "created_at"=>"2023-12-24T19:24:03.909Z",
      #       "updated_at"=>"2023-12-24T19:24:03.909Z",
      #       "gl_account_segment"=>{
      #         "id"=>7,
      #         "name"=>"region"
      #       }
      #     },
      #     ...
      #   ]
      # ]

      response.flatten.map do |segment_option_hash|
        {
          name: segment_option_hash['name'],
          code: segment_option_hash['code'],
          short_description: segment_option_hash['short_description'],
          gl_account_segment_name: segment_option_hash['gl_account_segment']['name']
        }
      end

      #       p result
      #       [
      #         {:name=>"Default", :code=>"000", :short_description=>"Def", :gl_account_segment_name=>"region"},
      #         {:name=>"East", :code=>"100", :short_description=>"Eas", :gl_account_segment_name=>"region"},
      #         {:name=>"West", :code=>"200", :short_description=>"Wes", :gl_account_segment_name=>"region"},
      #         {:name=>"North", :code=>"300", :short_description=>"Nor", :gl_account_segment_name=>"region"},
      #         {:name=>"South", :code=>"400", :short_description=>"Sou", :gl_account_segment_name=>"region"},
      #         {:name=>"Default", :code=>"00", :short_description=>"Def", :gl_account_segment_name=>"department"},
      #         {:name=>"Engineering", :code=>"10", :short_description=>"Eng", :gl_account_segment_name=>"department"},
      #         {:name=>"Marketing", :code=>"20", :short_description=>"Mar", :gl_account_segment_name=>"department"},
      #         {:name=>"Sales", :code=>"30", :short_description=>"Sal", :gl_account_segment_name=>"department"},
      #         {:name=>"Admin", :code=>"40", :short_description=>"Adm", :gl_account_segment_name=>"department"},
      #         {:name=>"Manufacturing", :code=>"50", :short_description=>"Man", :gl_account_segment_name=>"department"}
      #       ]
    end

    def api_calls
      gl_account_segments_resource = {
        resource: '/gl_account_segments'
      }

      response = api_call(gl_account_segments_resource)

      gl_account_segment_ids = response[0..1].map { |h| h['id'] }

      responses = []

      gl_account_segment_ids.each do |segment_id|
        gl_account_segment_options_resource = {
          resource: resource(segment_id)
        }

        responses << api_call(gl_account_segment_options_resource)

        #         p response 1
        #         [
        #           {
        #             "id"=>6,
        #             "name"=>"Default",
        #             "code"=>"000",
        #             "short_description"=>"Def",
        #             "created_at"=>"2023-12-24T19:24:03.904Z",
        #             "updated_at"=>"2023-12-24T19:24:03.904Z",
        #             "gl_account_segment"=>{"id"=>7, "name"=>"region"}
        #           },
        #           {
        #             "id"=>7,
        #             "name"=>"East",
        #             "code"=>"100",
        #             "short_description"=>"Eas",
        #             "created_at"=>"2023-12-24T19:24:03.909Z",
        #             "updated_at"=>"2023-12-24T19:24:03.909Z",
        #             "gl_account_segment"=>{"id"=>7, "name"=>"region"}
        #           },
        #           {
        #             "id"=>8,
        #             "name"=>"West",
        #             "code"=>"200",
        #             "short_description"=>"Wes",
        #             "created_at"=>"2023-12-24T19:24:03.915Z",
        #             "updated_at"=>"2023-12-24T19:24:03.915Z",
        #             "gl_account_segment"=>{"id"=>7, "name"=>"region"}
        #           },
        #           {
        #             "id"=>9,
        #             "name"=>"North",
        #             "code"=>"300",
        #             "short_description"=>"Nor",
        #             "created_at"=>"2023-12-24T19:24:03.919Z",
        #             "updated_at"=>"2023-12-24T19:24:03.919Z",
        #             "gl_account_segment"=>{"id"=>7, "name"=>"region"}
        #           },
        #           {
        #             "id"=>10,
        #             "name"=>"South",
        #             "code"=>"400",
        #             "short_description"=>"Sou",
        #             "created_at"=>"2023-12-24T19:24:03.924Z",
        #             "updated_at"=>"2023-12-24T19:24:03.924Z",
        #             "gl_account_segment"=>{"id"=>7, "name"=>"region"}
        #           }
        #         ]
        #
        #         p response 2
        #         [
        #           {
        #             "id"=>11,
        #             "name"=>"Default",
        #             "code"=>"00",
        #             "short_description"=>"Def",
        #             "created_at"=>"2023-12-24T19:24:03.946Z",
        #             "updated_at"=>"2023-12-24T19:24:03.946Z",
        #             "gl_account_segment"=>{"id"=>8, "name"=>"department"}
        #           },
        #           {
        #             "id"=>12,
        #             "name"=>"Engineering",
        #             "code"=>"10",
        #             "short_description"=>"Eng",
        #             "created_at"=>"2023-12-24T19:24:03.951Z",
        #             "updated_at"=>"2023-12-24T19:24:03.951Z",
        #             "gl_account_segment"=>{"id"=>8, "name"=>"department"}
        #           },
        #           {
        #             "id"=>13,
        #             "name"=>"Marketing",
        #             "code"=>"20",
        #             "short_description"=>"Mar",
        #             "created_at"=>"2023-12-24T19:24:03.955Z",
        #             "updated_at"=>"2023-12-24T19:24:03.955Z",
        #             "gl_account_segment"=>{"id"=>8, "name"=>"department"}
        #           },
        #           {
        #             "id"=>14,
        #             "name"=>"Sales",
        #             "code"=>"30",
        #             "short_description"=>"Sal",
        #             "created_at"=>"2023-12-24T19:24:03.960Z",
        #             "updated_at"=>"2023-12-24T19:24:03.960Z",
        #             "gl_account_segment"=>{"id"=>8, "name"=>"department"}
        #           },
        #           {
        #             "id"=>15,
        #             "name"=>"Admin",
        #             "code"=>"40",
        #             "short_description"=>"Adm",
        #             "created_at"=>"2023-12-24T19:24:03.966Z",
        #             "updated_at"=>"2023-12-24T19:24:03.966Z",
        #             "gl_account_segment"=>{"id"=>8, "name"=>"department"}
        #           },
        #           {
        #             "id"=>16,
        #             "name"=>"Manufacturing",
        #             "code"=>"50",
        #             "short_description"=>"Man",
        #             "created_at"=>"2023-12-24T19:24:03.971Z",
        #             "updated_at"=>"2023-12-24T19:24:03.971Z",
        #             "gl_account_segment"=>{"id"=>8, "name"=>"department"}
        #           }
        #         ]
      end

      responses
    end
  end
end
