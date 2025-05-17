# frozen_string_literal: true

require 'httparty'
module MondialConnector
  # This is a base class that will handle intialization and the API calls for all subclasses.
  class Base
    include HTTParty

    attr_reader :options

    def initialize(options = {})
      @options = {
        source_system_uri: nil,
        source_system_api_license: nil,
        source_system_api_key: nil
      }.merge(options)

      @source_system_uri = @options[:source_system_uri]
    end

    private

    def api_call(options = {})
      options = {
        resource: nil
      }.merge(options)

      query_options = {
        read_timeout: 600, # 10 minutes
        timeout: 600, # 10 minutes
        headers: {
          Authorization: token
        }
      }.merge(options)

      # Note that we constrain the API resource to a specific version
      HTTParty.get("#{@source_system_uri}/api/v1#{options[:resource]}", query_options).parsed_response
    end

    def token
      options = {
        body: {
          license: (@options[:source_system_api_license]).to_s,
          password: (@options[:source_system_api_key]).to_s
        }
      }

      HTTParty.post("#{@source_system_uri}/api/v1/authentication", options).parsed_response.fetch('auth_token')
    end
  end
end
