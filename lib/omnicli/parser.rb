# frozen_string_literal: true

require_relative "errors"

module OmniCli
  # Parser for Omni CLI arguments from environment variables
  class Parser
    # Parse arguments from environment variables into a Hash with symbol keys
    #
    # @return [Hash{Symbol => Object}] parsed arguments with proper types
    # @raise [ArgListMissingError] if OMNI_ARG_LIST is not set
    # @raise [InvalidBooleanValueError] if a boolean value is invalid
    # @raise [InvalidIntegerValueError] if an integer value is invalid
    # @raise [InvalidFloatValueError] if a float value is invalid
    # @example
    #   parser = OmniCli::Parser.new
    #   args = parser.parse!
    #   puts args[:verbose] if args[:verbose]
    def parse!
      list = arg_list
      return {} if list.empty?

      list.each_with_object({}) do |name, args|
        args[name.downcase.to_sym] = parse_argument(name)
      end
    end

    private

    def arg_list
      ENV["OMNI_ARG_LIST"]&.split || raise(ArgListMissingError)
    end

    def parse_argument(name)
      type_info = arg_type(name)
      return nil unless type_info

      base_type, size = type_info

      if size
        Array.new(size) { |i| arg_value(name, base_type, i) }
      else
        arg_value(name, base_type)
      end
    end

    def arg_type(name)
      return nil unless (type_str = ENV.fetch("OMNI_ARG_#{name.upcase}_TYPE", nil))

      if type_str.include?("/")
        base_type, size = type_str.split("/")
        [base_type, size.to_i]
      else
        [type_str, nil]
      end
    end

    def arg_value(name, type, index = nil)
      key = ["OMNI_ARG", name.upcase, "VALUE", index].compact.join("_")
      value = ENV.fetch(key, nil)

      return default_value(type) if value.nil?

      convert_value(value, type)
    end

    def default_value(type)
      type == "str" ? "" : nil
    end

    def convert_value(value, type)
      case type
      when "bool"
        parse_boolean(value)
      when "int"
        parse_integer(value)
      when "float"
        parse_float(value)
      else
        value
      end
    end

    def parse_boolean(value)
      case value.downcase
      when "true" then true
      when "false" then false
      else raise InvalidBooleanValueError, value
      end
    end

    def parse_integer(value)
      Integer(value)
    rescue ArgumentError, TypeError
      raise InvalidIntegerValueError, value
    end

    def parse_float(value)
      Float(value)
    rescue ArgumentError, TypeError
      raise InvalidFloatValueError, value
    end
  end
end
