# frozen_string_literal: true

module OmniCli
  # Read version from VERSION file, or default to 0.0.0-unreleased
  VERSION = if File.exist?(File.expand_path("VERSION", __dir__))
              File.read(File.expand_path("VERSION", __dir__)).strip
            else
              "0.0.0-unreleased"
            end
end
