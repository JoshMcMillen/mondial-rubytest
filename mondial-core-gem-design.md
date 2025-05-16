# Mondial Core Gem Design

## Overview

This document outlines the design for a `mondial-core` gem that provides base functionality for interacting with the Mondial Relay API and can be extended to create connectors for various ERPs. The gem is designed with extensibility, maintainability, and flexibility in mind.

## Project Structure

```
mondial-core/
├── bin/                              # Executable scripts
│   ├── console                       # REPL console for development
│   └── setup                         # Setup script
├── lib/
│   ├── mondial/
│   │   ├── version.rb                # Gem version definition
│   │   ├── configuration.rb          # Configuration handling
│   │   ├── client.rb                 # Main API client
│   │   ├── error.rb                  # Custom error classes
│   │   ├── middleware/               # Faraday middleware for request/response
│   │   │   ├── authentication.rb     # Authentication middleware
│   │   │   ├── error_handler.rb      # Error handling middleware
│   │   │   └── logging.rb            # Logging middleware
│   │   ├── resources/                # API resources
│   │   │   ├── base_resource.rb      # Base class for all resources
│   │   │   ├── tracking.rb           # Tracking-related endpoints
│   │   │   ├── shipping.rb           # Shipping/label generation endpoints
│   │   │   └── pickup.rb             # Pickup points endpoints
│   │   ├── models/                   # Data models
│   │   │   ├── base_model.rb         # Base class for all models
│   │   │   ├── tracking_info.rb      # Tracking information model
│   │   │   ├── pickup_point.rb       # Pickup point model
│   │   │   └── shipping_label.rb     # Shipping label model
│   │   ├── adapters/                 # ERP adapter interfaces
│   │   │   ├── base_adapter.rb       # Base adapter class
│   │   │   └── null_adapter.rb       # Default null implementation
│   │   └── utils/                    # Utility classes and modules
│   │       ├── validators.rb         # Input validation
│   │       └── response_parser.rb    # Response parsing utilities
│   └── mondial.rb                    # Main entry point
├── spec/                             # Test files
│   ├── cassettes/                    # VCR cassettes for API tests
│   ├── mondial/
│   │   ├── client_spec.rb
│   │   ├── resources/
│   │   ├── models/
│   │   └── adapters/
│   ├── spec_helper.rb
│   └── fixtures/                     # Test fixtures/mock responses
├── .rspec                            # RSpec configuration
├── .rubocop.yml                      # RuboCop configuration
├── .gitignore                        # Git ignore file
├── Gemfile                           # Gem dependencies
├── Rakefile                          # Rake tasks
├── LICENSE.txt                       # License file
├── README.md                         # Documentation
└── mondial-core.gemspec              # Gem specification
```

## Core Components Design

### Main Library Entry Point (lib/mondial.rb)

```ruby
# frozen_string_literal: true

require "mondial/version"
require "mondial/configuration"
require "mondial/error"
require "mondial/client"
require "mondial/resources/base_resource"
require "mondial/resources/tracking"
require "mondial/resources/shipping"
require "mondial/resources/pickup"

# Main module for Mondial API client
module Mondial
  class << self
    attr_accessor :configuration, :client

    # Configure the Mondial client
    # @yield [config] Configuration object
    # @return [Mondial::Configuration] The configuration object
    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
      self.client = Client.new(configuration)
      configuration
    end

    # Get the current configuration or create a new one
    # @return [Mondial::Configuration] The current configuration
    def configuration
      @configuration ||= Configuration.new
    end

    # Get the current client or create a new one
    # @return [Mondial::Client] The API client
    def client
      @client ||= Client.new(configuration)
    end

    # Access the tracking resource
    # @return [Mondial::Resources::Tracking] The tracking resource
    def tracking
      @tracking ||= Resources::Tracking.new(client)
    end

    # Access the shipping resource
    # @return [Mondial::Resources::Shipping] The shipping resource
    def shipping
      @shipping ||= Resources::Shipping.new(client)
    end

    # Access the pickup resource
    # @return [Mondial::Resources::Pickup] The pickup resource
    def pickup
      @pickup ||= Resources::Pickup.new(client)
    end

    # Reset the client configuration
    # @return [void]
    def reset!
      @configuration = nil
      @client = nil
      @tracking = nil
      @shipping = nil
      @pickup = nil
    end
  end
end
```

### Configuration (lib/mondial/configuration.rb)

```ruby
# frozen_string_literal: true

require "logger"

module Mondial
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

    # @return [Mondial::Adapters::BaseAdapter] ERP adapter
    attr_accessor :adapter

    def initialize
      @endpoint = "https://api.mondialrelay.com/v1"
      @language = "en"
      @timeout = 30
      @test_mode = false
      @logger = Logger.new($stdout)
      @log_level = Logger::INFO
      @adapter = Mondial::Adapters::NullAdapter.new
    end

    # Validate the configuration
    # @raise [Mondial::Error::ConfigurationError] If configuration is invalid
    # @return [Boolean] true if valid
    def validate!
      errors = []
      errors << "API key is required" if api_key.nil?
      errors << "Private key is required" if private_key.nil?
      
      unless errors.empty?
        raise Mondial::Error::ConfigurationError, errors.join(", ")
      end
      
      true
    end
  end
end
```

### API Client (lib/mondial/client.rb)

```ruby
# frozen_string_literal: true

require "faraday"
require "faraday_middleware"
require "json"
require "mondial/middleware/authentication"
require "mondial/middleware/error_handler"
require "mondial/middleware/logging"

module Mondial
  # The API client for making requests to the Mondial Relay API
  class Client
    # @return [Mondial::Configuration] The client configuration
    attr_reader :config

    # Initialize a new API client
    # @param config [Mondial::Configuration] Configuration object
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

    # Make a PUT request
    # @param path [String] API endpoint path
    # @param params [Hash] Request parameters
    # @return [Hash] Parsed response
    def put(path, params = {})
      request(:put, path, params)
    end

    # Make a DELETE request
    # @param path [String] API endpoint path
    # @param params [Hash] Request parameters
    # @return [Hash] Parsed response
    def delete(path, params = {})
      request(:delete, path, params)
    end

    private

    # Build the connection with middleware
    # @return [Faraday::Connection] The configured connection
    def connection
      @connection ||= Faraday.new(url: config.endpoint) do |conn|
        # Add authentication middleware
        conn.use Mondial::Middleware::Authentication, config.api_key, config.private_key
        
        # Add error handling middleware
        conn.use Mondial::Middleware::ErrorHandler
        
        # Add logging middleware if enabled
        conn.use Mondial::Middleware::Logging, config.logger, config.log_level
        
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
      
      response.body
    end
  end
end
```

### Error Classes (lib/mondial/error.rb)

```ruby
# frozen_string_literal: true

module Mondial
  module Error
    # Base error class for all Mondial errors
    class Error < StandardError; end

    # Error raised when configuration is invalid
    class ConfigurationError < Error; end

    # Error raised when authentication fails
    class AuthenticationError < Error; end

    # Error raised when a resource is not found
    class ResourceNotFoundError < Error; end

    # Error raised when request validation fails
    class ValidationError < Error; end

    # Error raised when the API returns an error
    class ApiError < Error
      # @return [String] The error code from the API
      attr_reader :code
      
      # @return [Hash] Full error details from the API
      attr_reader :details

      # Initialize a new API error
      # @param code [String] Error code
      # @param message [String] Error message
      # @param details [Hash] Error details
      def initialize(code, message, details = nil)
        @code = code
        @details = details
        super(message)
      end
    end

    # Error raised when required parameters are missing
    class MissingParamsError < Error
      # Initialize a new missing parameters error
      # @param params [Array<String>] Missing parameter names
      def initialize(params)
        message = "Missing required parameters: #{params.join(', ')}"
        super(message)
      end
    end

    # Error raised when data is invalid
    class InvalidDataError < Error; end

    # Error raised for network-related issues
    class NetworkError < Error; end

    # Error raised when a request times out
    class TimeoutError < NetworkError; end
  end
end
```

### Base Resource (lib/mondial/resources/base_resource.rb)

```ruby
# frozen_string_literal: true

module Mondial
  module Resources
    # Base class for all API resources
    class BaseResource
      # @return [Mondial::Client] The API client
      attr_reader :client

      # Initialize a new resource
      # @param client [Mondial::Client] The API client
      def initialize(client)
        @client = client
      end

      protected

      # Validate required parameters
      # @param params [Hash] Parameters to validate
      # @param required [Array<Symbol>] Required parameter keys
      # @raise [Mondial::Error::MissingParamsError] If required parameters are missing
      # @return [void]
      def validate_params(params, required)
        missing = required.select { |param| !params.key?(param) || params[param].nil? }
        raise Mondial::Error::MissingParamsError.new(missing) unless missing.empty?
      end
    end
  end
end
```

### Tracking Resource (lib/mondial/resources/tracking.rb)

```ruby
# frozen_string_literal: true

require "mondial/resources/base_resource"
require "mondial/models/tracking_info"
require "mondial/models/tracking_event"

module Mondial
  module Resources
    # Resource for tracking-related endpoints
    class Tracking < BaseResource
      # Track a shipment by tracking number
      # @param tracking_number [String] The tracking number
      # @return [Mondial::Models::TrackingInfo] Tracking information
      def get(tracking_number)
        validate_params({ tracking_number: tracking_number }, [:tracking_number])
        response = client.get("/tracking", { tracking_number: tracking_number })
        Mondial::Models::TrackingInfo.new(response)
      end

      # Get detailed tracking events for a shipment
      # @param tracking_number [String] The tracking number
      # @return [Array<Mondial::Models::TrackingEvent>] Array of tracking events
      def events(tracking_number)
        validate_params({ tracking_number: tracking_number }, [:tracking_number])
        response = client.get("/tracking/events", { tracking_number: tracking_number })
        response.map { |event| Mondial::Models::TrackingEvent.new(event) }
      end
    end
  end
end
```

### Shipping Resource (lib/mondial/resources/shipping.rb)

```ruby
# frozen_string_literal: true

require "mondial/resources/base_resource"
require "mondial/models/shipping_label"

module Mondial
  module Resources
    # Resource for shipping-related endpoints
    class Shipping < BaseResource
      # Generate a shipping label
      # @param params [Hash] Label generation parameters
      # @option params [String] :sender_name Sender's name
      # @option params [String] :sender_address Sender's address
      # @option params [String] :sender_city Sender's city
      # @option params [String] :sender_postal_code Sender's postal code
      # @option params [String] :sender_country Sender's country code
      # @option params [String] :recipient_name Recipient's name
      # @option params [String] :recipient_address Recipient's address
      # @option params [String] :recipient_city Recipient's city
      # @option params [String] :recipient_postal_code Recipient's postal code
      # @option params [String] :recipient_country Recipient's country code
      # @option params [Float] :weight Package weight in kg
      # @option params [String] :delivery_type Delivery type (home_delivery or pickup_point)
      # @option params [String] :pickup_point_id Pickup point ID (for pickup_point delivery type)
      # @return [Mondial::Models::ShippingLabel] The generated shipping label
      def create_label(params)
        required_params = [
          :sender_name, :sender_address, :sender_city, :sender_postal_code, :sender_country,
          :recipient_name, :recipient_address, :recipient_city, :recipient_postal_code, :recipient_country,
          :weight, :delivery_type
        ]
        
        validate_params(params, required_params)
        
        # Additional validation for pickup point delivery
        if params[:delivery_type] == "pickup_point" && !params[:pickup_point_id]
          raise Mondial::Error::MissingParamsError.new(["pickup_point_id"])
        end
        
        response = client.post("/shipping/label", params)
        Mondial::Models::ShippingLabel.new(response)
      end

      # Track a shipment by its shipping number
      # @param shipping_number [String] The shipping number
      # @return [Mondial::Models::ShippingInfo] Shipping information
      def track(shipping_number)
        validate_params({ shipping_number: shipping_number }, [:shipping_number])
        response = client.get("/shipping/track", { shipping_number: shipping_number })
        Mondial::Models::ShippingInfo.new(response)
      end
    end
  end
end
```

### Pickup Resource (lib/mondial/resources/pickup.rb)

```ruby
# frozen_string_literal: true

require "mondial/resources/base_resource"
require "mondial/models/pickup_point"

module Mondial
  module Resources
    # Resource for pickup point-related endpoints
    class Pickup < BaseResource
      # Find pickup points near a location
      # @param params [Hash] Search parameters
      # @option params [String] :postal_code Postal code
      # @option params [String] :country Country code
      # @option params [Integer] :radius Search radius in km (default: 10)
      # @return [Array<Mondial::Models::PickupPoint>] Array of pickup points
      def find(params)
        required_params = [:postal_code, :country]
        validate_params(params, required_params)
        
        params[:radius] ||= 10
        
        response = client.get("/pickup/points", params)
        response.map { |point| Mondial::Models::PickupPoint.new(point) }
      end

      # Get details for a specific pickup point
      # @param id [String] Pickup point ID
      # @return [Mondial::Models::PickupPoint] Pickup point details
      def get(id)
        validate_params({ id: id }, [:id])
        response = client.get("/pickup/points/#{id}")
        Mondial::Models::PickupPoint.new(response)
      end
    end
  end
end
```

### Base Model (lib/mondial/models/base_model.rb)

```ruby
# frozen_string_literal: true

module Mondial
  module Models
    # Base class for all data models
    class BaseModel
      # Initialize a new model from attributes
      # @param attributes [Hash] Model attributes
      def initialize(attributes = {})
        attributes.each do |key, value|
          setter = "#{key}="
          send(setter, value) if respond_to?(setter)
        end
      end

      # Convert model to hash
      # @return [Hash] Model as hash
      def to_h
        instance_variables.each_with_object({}) do |var, hash|
          key = var.to_s.delete("@")
          hash[key.to_sym] = instance_variable_get(var)
        end
      end
    end
  end
end
```

### ERP Adapter Interface (lib/mondial/adapters/base_adapter.rb)

```ruby
# frozen_string_literal: true

module Mondial
  module Adapters
    # Base adapter interface for ERP integration
    class BaseAdapter
      # Transform ERP order data to Mondial shipping label request format
      # @param order [Object] Order from the ERP system
      # @return [Hash] Data in Mondial API format
      def order_to_shipping_params(order)
        raise NotImplementedError, "Subclasses must implement #order_to_shipping_params"
      end

      # Transform tracking data from Mondial to ERP format
      # @param tracking_info [Mondial::Models::TrackingInfo] Tracking information
      # @return [Object] Data in ERP system format
      def tracking_to_erp_data(tracking_info)
        raise NotImplementedError, "Subclasses must implement #tracking_to_erp_data"
      end

      # Transform pickup point data from Mondial to ERP format
      # @param pickup_points [Array<Mondial::Models::PickupPoint>] Pickup points
      # @return [Array] Data in ERP system format
      def pickup_points_to_erp_data(pickup_points)
        raise NotImplementedError, "Subclasses must implement #pickup_points_to_erp_data"
      end

      # Callback for successful shipping label creation
      # @param label [Mondial::Models::ShippingLabel] The generated label
      # @param order [Object] Original order from the ERP system
      # @return [void]
      def on_label_created(label, order)
        raise NotImplementedError, "Subclasses must implement #on_label_created"
      end

      # Callback for shipping label creation failure
      # @param error [Exception] The error that occurred
      # @param order [Object] Original order from the ERP system
      # @return [void]
      def on_label_error(error, order)
        raise NotImplementedError, "Subclasses must implement #on_label_error"
      end
    end
  end
end
```

### Null Adapter (lib/mondial/adapters/null_adapter.rb)

```ruby
# frozen_string_literal: true

require "mondial/adapters/base_adapter"

module Mondial
  module Adapters
    # Default null implementation that does nothing
    class NullAdapter < BaseAdapter
      # Transform ERP order data to Mondial shipping label request format
      # @param order [Object] Order from the ERP system
      # @return [Hash] Data in Mondial API format
      def order_to_shipping_params(order)
        # Just pass through the order as-is
        order
      end

      # Transform tracking data from Mondial to ERP format
      # @param tracking_info [Mondial::Models::TrackingInfo] Tracking information
      # @return [Object] Data in ERP system format
      def tracking_to_erp_data(tracking_info)
        # Just pass through the tracking info as-is
        tracking_info
      end

      # Transform pickup point data from Mondial to ERP format
      # @param pickup_points [Array<Mondial::Models::PickupPoint>] Pickup points
      # @return [Array] Data in ERP system format
      def pickup_points_to_erp_data(pickup_points)
        # Just pass through the pickup points as-is
        pickup_points
      end

      # Callback for successful shipping label creation
      # @param label [Mondial::Models::ShippingLabel] The generated label
      # @param order [Object] Original order from the ERP system
      # @return [void]
      def on_label_created(label, order)
        # Do nothing
      end

      # Callback for shipping label creation failure
      # @param error [Exception] The error that occurred
      # @param order [Object] Original order from the ERP system
      # @return [void]
      def on_label_error(error, order)
        # Do nothing
      end
    end
  end
end
```

## Usage Examples

### Basic Usage

```ruby
# Configure the client
Mondial.configure do |config|
  config.api_key = "YOUR_MONDIAL_RELAY_ENSEIGNE"
  config.private_key = "YOUR_MONDIAL_RELAY_PRIVATE_KEY"
  config.language = "en"
  config.test_mode = true # Use test mode for development
end

# Track a shipment
tracking_info = Mondial.tracking.get("123456789")
puts "Status: #{tracking_info.status}"
puts "Estimated delivery: #{tracking_info.estimated_delivery_date}"

# Find pickup points
pickup_points = Mondial.pickup.find(
  postal_code: "75001",
  country: "FR"
)
puts "Found #{pickup_points.size} pickup points"

# Create a shipping label
label = Mondial.shipping.create_label(
  sender_name: "Sender Company",
  sender_address: "123 Sender Street",
  sender_city: "Sender City",
  sender_postal_code: "12345",
  sender_country: "FR",
  recipient_name: "Recipient Name",
  recipient_address: "456 Recipient Avenue",
  recipient_city: "Recipient City",
  recipient_postal_code: "67890",
  recipient_country: "FR",
  weight: 1.5,
  delivery_type: "home_delivery"
)
puts "Label URL: #{label.url}"
```

### Using with an ERP Adapter

```ruby
# Create a custom ERP adapter
class MyERPAdapter < Mondial::Adapters::BaseAdapter
  def order_to_shipping_params(order)
    {
      sender_name: order.company_name,
      sender_address: order.address_line1,
      sender_city: order.city,
      sender_postal_code: order.zip,
      sender_country: order.country_code,
      recipient_name: order.customer_name,
      recipient_address: order.shipping_address_line1,
      recipient_city: order.shipping_city,
      recipient_postal_code: order.shipping_zip,
      recipient_country: order.shipping_country_code,
      weight: order.total_weight,
      delivery_type: order.shipping_method == "pickup" ? "pickup_point" : "home_delivery",
      pickup_point_id: order.pickup_location_id
    }
  end
  
  def on_label_created(label, order)
    # Update order in ERP with tracking number
    order.update(
      tracking_number: label.tracking_number,
      label_url: label.url,
      shipping_status: "label_created"
    )
  end
  
  def on_label_error(error, order)
    # Log error in ERP
    order.update(
      shipping_error: error.message,
      shipping_status: "label_error"
    )
  end
end

# Configure Mondial with the custom adapter
Mondial.configure do |config|
  config.api_key = "YOUR_MONDIAL_RELAY_ENSEIGNE"
  config.private_key = "YOUR_MONDIAL_RELAY_PRIVATE_KEY"
  config.adapter = MyERPAdapter.new
end

# Process an order from the ERP
order = MyERP::Order.find(123)

begin
  # Convert order to shipping params
  shipping_params = Mondial.config.adapter.order_to_shipping_params(order)
  
  # Create shipping label
  label = Mondial.shipping.create_label(shipping_params)
  
  # Handle success
  Mondial.config.adapter.on_label_created(label, order)
rescue => e
  # Handle error
  Mondial.config.adapter.on_label_error(e, order)
end
```

## ERP Connector Example

This shows how you can create a specific ERP connector gem that builds on top of the mondial-core gem:

```ruby
# In mondial-erp-connector.gemspec
Gem::Specification.new do |spec|
  spec.name          = "mondial-erp-connector"
  spec.version       = "0.1.0"
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]
  spec.summary       = "Mondial Relay connector for ERP System"
  spec.description   = "Connects ERP System with Mondial Relay for shipping and tracking"
  spec.homepage      = "https://github.com/yourusername/mondial-erp-connector"
  spec.license       = "MIT"
  
  spec.add_dependency "mondial-core", "~> 0.1.0"
  # Add other dependencies specific to this connector
end

# In lib/mondial/erp_connector.rb
require "mondial-core"
require "mondial/erp_connector/version"
require "mondial/erp_connector/adapter"

module Mondial
  module ERPConnector
    def self.setup
      Mondial.configure do |config|
        config.adapter = Mondial::ERPConnector::Adapter.new
        yield(config) if block_given?
      end
    end
  end
end

# In lib/mondial/erp_connector/adapter.rb
module Mondial
  module ERPConnector
    class Adapter < Mondial::Adapters::BaseAdapter
      # Implement ERP-specific adapter methods
    end
  end
end
```

## Testing Strategy

The gem includes a comprehensive testing suite:

1. **Unit Tests**: Test individual components in isolation
2. **Integration Tests**: Test interaction between components
3. **API Tests**: Test actual API calls using VCR to record/replay
4. **Adapter Tests**: Test the adapter interface and implementations

Example test setup:

```ruby
# In spec/spec_helper.rb
require "mondial"
require "vcr"
require "webmock/rspec"

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  
  # Filter sensitive data
  config.filter_sensitive_data("<API_KEY>") { ENV["MONDIAL_API_KEY"] }
  config.filter_sensitive_data("<PRIVATE_KEY>") { ENV["MONDIAL_PRIVATE_KEY"] }
end

RSpec.configure do |config|
  config.before(:each) do
    Mondial.reset!
    Mondial.configure do |c|
      c.api_key = ENV["MONDIAL_API_KEY"] || "test_key"
      c.private_key = ENV["MONDIAL_PRIVATE_KEY"] || "test_private_key"
      c.test_mode = true
    end
  end
end
```

## Development and Contribution

The gem is set up with development tools to ensure code quality:

- **RSpec**: For testing
- **RuboCop**: For code style enforcement
- **YARD**: For documentation
- **SimpleCov**: For test coverage analysis

Follow these steps to contribute:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Implement the feature
5. Run tests and ensure they pass
6. Submit a pull request

## Conclusion

This design provides a solid foundation for a Mondial API client gem that can be extended with ERP-specific adapters. The architecture separates concerns properly and follows Ruby best practices, making it maintainable and flexible for future enhancements.

Key benefits of this design:
- Clean separation between API client code and ERP-specific logic
- Flexible adapter system that can be extended for different ERPs
- Comprehensive error handling
- Well-documented code with type information
- Thorough testing strategy
