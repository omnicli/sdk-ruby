# frozen_string_literal: true

require_relative "omnicli/version"
require_relative "omnicli/errors"
require_relative "omnicli/parser"

# The OmniCli module provides functionality to build Omni commands in Ruby.
module OmniCli
  # Create a new parser instance and parse arguments
  #
  # @return [OpenStruct] parsed arguments
  # @raise [ArgListMissingError] if OMNI_ARG_LIST is not set
  # @raise [InvalidBooleanValueError] if a boolean value is invalid
  # @raise [InvalidIntegerValueError] if an integer value is invalid
  # @raise [InvalidFloatValueError] if a float value is invalid
  def self.parse!
    Parser.new.parse!
  end
end
