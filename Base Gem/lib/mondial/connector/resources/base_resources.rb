# frozen_string_literal: true

module Mondial
  module Connector
    module Resources
      # Base class for all API resources
      class BaseResource
        # @return [Mondial::Connector::Client] The API client
        attr_reader :client

        # Initialize a new resource
        # @param client [Mondial::Connector::Client] The API client
        def initialize(client)
          @client = client
        end

        protected

        # Validate required parameters
        # @param params [Hash] Parameters to validate
        # @param required [Array<Symbol>] Required parameter keys
        # @raise [Mondial::Connector::Error] If required parameters are missing
        # @return [void]
        def validate_params(params, required)
          missing = required.select { |param| !params.key?(param) || params[param].nil? }
          raise Error, "Missing required parameters: #{missing.join(', ')}" unless missing.empty?
        end
      end
    end
  end
end