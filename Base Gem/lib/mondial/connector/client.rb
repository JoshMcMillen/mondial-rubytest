# frozen_string_literal: true

require "faraday"
require "faraday_middleware"
require "json"

module Mondial
  module Connector
    # The API client for making requests to the Mondial Relay API
    class Client
      # @return [Mondial::Connector::Configuration] The client configuration
      attr_reader :config

      # Initialize a new API client
      # @param config [Mondial::Connector::Configuration] Configuration object
      def initialize(config)
        @config = config
        @config.validate!
      end

      # Make a GET request
      # @param path [String] API endpoint path
      # @param params [Hash] Request parameters
      # @return [Hash] Parsed response
      def get(path, params = {})
        request(:get, path, params)
      end

      # Make a POST request
      # @param path [String] API endpoint path
      # @param params [Hash] Request parameters
      # @return [Hash] Parsed response
      def post(path, params = {})
        request(:post, path, params)
      end

      private

      # Build the connection with middleware
      # @return [Faraday::Connection] The configured connection
      def connection
        @connection ||= Faraday.new(url: config.endpoint) do |conn|
          # Add authentication parameters
          conn.request :url_encoded
          
          # Set response parsing middleware
          conn.response :json, content_type: /\bjson$/
          
          # Set adapter
          conn.adapter Faraday.default_adapter
          
          # Set timeouts
          conn.options.timeout = config.timeout
          conn.options.open_timeout = config.timeout
        end
      end

      # Make a request to the API
      # @param method [Symbol] HTTP method (:get, :post, etc.)
      # @param path [String] API endpoint path
      # @param params [Hash] Request parameters
      # @return [Hash] Parsed response
      def request(method, path, params = {})
        # Add authentication parameters
        params = add_auth_params(params)
        
        response = connection.public_send(method) do |request|
          request.url path
          request.headers["Accept-Language"] = config.language
          request.headers["Content-Type"] = "application/json"
          
          if [:post, :put, :patch].include?(method)
            request.body = JSON.generate(params)
          else
            request.params = params
          end
        end
        
        handle_response(response)
      end
      
      # Add authentication parameters to the request
      # @param params [Hash] Original parameters
      # @return [Hash] Parameters with authentication added
      def add_auth_params(params)
        # Actual authentication will depend on Mondial Relay's requirements
        # This is a placeholder for now
        params.merge({
          enseigne: config.api_key,
          timestamp: Time.now.to_i
        })
      end
      
      # Handle the API response
      # @param response [Faraday::Response] The API response
      # @return [Hash] Parsed response body
      # @raise [Mondial::Connector::Error] If the response indicates an error
      def handle_response(response)
        case response.status
        when 200..299
          response.body
        when 401, 403
          raise Error, "Authentication failed: #{response.body}"
        when 404
          raise Error, "Resource not found: #{response.body}"
        when 422
          raise Error, "Validation failed: #{response.body}"
        when 500..599
          raise Error, "Server error: #{response.body}"
        else
          raise Error, "Unknown error: #{response.status} - #{response.body}"
        end
      end
    end
  end
end