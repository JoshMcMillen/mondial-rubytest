# frozen_string_literal: true

require "logger"

module Mondial
  module Connector
    # Handles configuration options for the Mondial API client
    class Configuration
      # @return [String] API key (Enseigne) for Mondial Relay
      attr_accessor :api_key
      
      # @return [String] Private key for Mondial Relay
      attr_accessor :private_key
      
      # @return [String] API endpoint URL
      attr_accessor :endpoint
      
      # @return [String] Language for API responses
      attr_accessor :language
      
      # @return [Integer] Connection timeout in seconds
      attr_accessor :timeout
      
      # @return [Boolean] Whether to use test mode
      attr_accessor :test_mode
      
      # @return [Logger] Logger instance
      attr_accessor :logger
      
      # @return [String] Log level
      attr_accessor :log_level

      def initialize
        @endpoint = "https://api.mondialrelay.com/v1"
        @language = "en"
        @timeout = 30
        @test_mode = false
        @logger = Logger.new($stdout)
        @log_level = Logger::INFO
      end

      # Validate the configuration
      # @raise [Mondial::Connector::Error] If configuration is invalid
      # @return [Boolean] true if valid
      def validate!
        errors = []
        errors << "API key is required" if api_key.nil?
        errors << "Private key is required" if private_key.nil?
        
        unless errors.empty?
          raise Error, errors.join(", ")
        end
        
        true
      end
    end
  end
end