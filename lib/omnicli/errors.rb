# frozen_string_literal: true

module OmniCli
  # Base exception for omnicli-related errors
  class Error < StandardError; end

  # Raised when the OMNI_ARG_LIST environment variable is missing
  class ArgListMissingError < Error
    def initialize(msg = "OMNI_ARG_LIST environment variable is not set. " \
                         'Are you sure "argparser: true" is set for this command?')
      super
    end
  end

  # Base class for invalid value errors
  class InvalidValueError < Error; end

  # Raised when an invalid boolean value is encountered
  class InvalidBooleanValueError < InvalidValueError
    def initialize(value)
      super("expected 'true' or 'false', got '#{value}'")
    end
  end

  # Raised when an invalid integer value is encountered
  class InvalidIntegerValueError < InvalidValueError
    def initialize(value)
      super("expected integer, got '#{value}'")
    end
  end

  # Raised when an invalid float value is encountered
  class InvalidFloatValueError < InvalidValueError
    def initialize(value)
      super("expected float, got '#{value}'")
    end
  end
end
