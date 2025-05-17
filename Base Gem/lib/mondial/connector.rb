# frozen_string_literal: true

require_relative "connector/version"
require_relative "connector/configuration"
require_relative "connector/client"

module Mondial
  module Connector
    class Error < StandardError; end
    
    class << self
      attr_accessor :configuration, :client
      
      # Configure the Mondial client
      # @yield [config] Configuration object
      # @return [Mondial::Connector::Configuration] The configuration object
      def configure
        self.configuration ||= Configuration.new
        yield(configuration) if block_given?
        self.client = Client.new(configuration)
        configuration
      end
      
      # Get the current configuration or create a new one
      # @return [Mondial::Connector::Configuration] The current configuration
      def configuration
        @configuration ||= Configuration.new
      end
      
      # Get the current client or create a new one
      # @return [Mondial::Connector::Client] The API client
      def client
        @client ||= Client.new(configuration)
      end
      
      # Reset the configuration to defaults
      # @return [void]
      def reset!
        @configuration = nil
        @client = nil
      end
    end
  end
end