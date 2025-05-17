# frozen_string_literal: true

module MondialConnector
  # This class returns the source system's Account Segments
  class AccountSegments < Base
    def resource
      '/gl_account_segments'
    end

    def standard_records
      options = {
        resource: resource
      }

      response = api_call(options)

      #       response => [
      #         {
      #           "id"=>7,
      #           "name"=>"region",
      #           "ordinal"=>2,
      #           "field_validator_id"=>49,
      #           "enforce_balancing"=>false
      #         },
      #         {
      #           "id"=>8,
      #           "name"=>"department",
      #           "ordinal"=>3,
      #           "field_validator_id"=>49,
      #           "enforce_balancing"=>false
      #         }
      #       ]

      #       # Convert the response to the required return format, which is an array of hashes of the format:
      #
      #       [
      #         {
      #           name: "region",
      #           ordinal: 2,
      #         },
      #         {
      #           name: "department",
      #           ordinal: 3,
      #         }
      #       ]

      response[0..1].map { |h| { name: h['name'], ordinal: h['ordinal'] } }

      # An appropriate result would be:
      # => [{:name=>"region", :ordinal=>2}, {:name=>"department", :ordinal=>3}]
      # Note that the first segment is not required; it is always assumed to be the Natural Account Number
    end
  end
end
