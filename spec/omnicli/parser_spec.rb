# frozen_string_literal: true

require "omnicli"

RSpec.describe OmniCli::Parser do
  let(:env) { {} }
  let(:original_env) { ENV.to_h }

  before do
    ENV.clear
    env.each { |k, v| ENV[k] = v }
  end

  after do
    ENV.clear
    original_env.each { |k, v| ENV[k] = v }
  end

  describe ".parse!" do
    context "when OMNI_ARG_LIST is not set" do
      it "raises ArgListMissingError with correct message" do
        expect { described_class.new.parse! }.to raise_error(OmniCli::ArgListMissingError) do |error|
          expect(error.message).to include('Are you sure "argparser: true" is set for this command?')
        end
      end
    end

    context "when OMNI_ARG_LIST is empty" do
      let(:env) { { "OMNI_ARG_LIST" => "" } }

      it "returns empty hash" do
        expect(described_class.new.parse!).to be_empty
      end
    end

    context "with string arguments" do
      let(:env) do
        {
          "OMNI_ARG_LIST" => "test1 test2",
          "OMNI_ARG_TEST1_TYPE" => "str",
          "OMNI_ARG_TEST1_VALUE" => "value",
          "OMNI_ARG_TEST2_TYPE" => "str"
          # Deliberately not setting TEST2_VALUE
        }
      end

      it "handles string arguments with proper defaults" do
        args = described_class.new.parse!
        expect(args[:test1]).to eq("value")
        expect(args[:test2]).to eq("") # Empty string is default for str type
      end
    end

    context "with non-string arguments" do
      let(:env) do
        {
          "OMNI_ARG_LIST" => "num1 num2",
          "OMNI_ARG_NUM1_TYPE" => "int",
          "OMNI_ARG_NUM1_VALUE" => "42",
          "OMNI_ARG_NUM2_TYPE" => "int"
          # Deliberately not setting NUM2_VALUE
        }
      end

      it "handles non-string arguments with nil defaults" do
        args = described_class.new.parse!
        expect(args[:num1]).to eq(42)
        expect(args[:num2]).to be_nil
      end
    end

    context "with array handling" do
      let(:env) do
        {
          "OMNI_ARG_LIST" => "numbers",
          "OMNI_ARG_NUMBERS_TYPE" => "int/3",
          "OMNI_ARG_NUMBERS_VALUE_0" => "1",
          # Deliberately skipping VALUE_1
          "OMNI_ARG_NUMBERS_VALUE_2" => "3"
        }
      end

      it "handles arrays with proper sizing and nil values" do
        args = described_class.new.parse!
        expect(args[:numbers]).to eq([1, nil, 3])
      end
    end

    context "with boolean arrays" do
      let(:env) do
        {
          "OMNI_ARG_LIST" => "flags",
          "OMNI_ARG_FLAGS_TYPE" => "bool/3",
          "OMNI_ARG_FLAGS_VALUE_0" => "true",
          # Deliberately skipping VALUE_1
          "OMNI_ARG_FLAGS_VALUE_2" => "false"
        }
      end

      it "handles boolean arrays with proper defaults" do
        args = described_class.new.parse!
        expect(args[:flags]).to eq([true, nil, false])
      end
    end

    context "with float arrays" do
      let(:env) do
        {
          "OMNI_ARG_LIST" => "floats",
          "OMNI_ARG_FLOATS_TYPE" => "float/4",
          "OMNI_ARG_FLOATS_VALUE_0" => "1.1",
          # Deliberately skipping VALUE_1
          "OMNI_ARG_FLOATS_VALUE_2" => "3.3",
          "OMNI_ARG_FLOATS_VALUE_3" => "4"
        }
      end

      it "handles float arrays with proper defaults" do
        args = described_class.new.parse!
        expect(args[:floats]).to eq([1.1, nil, 3.3, 4.0])
      end
    end

    context "with string arrays" do
      let(:env) do
        {
          "OMNI_ARG_LIST" => "words",
          "OMNI_ARG_WORDS_TYPE" => "str/3",
          "OMNI_ARG_WORDS_VALUE_0" => "hello",
          # Deliberately skipping VALUE_1
          "OMNI_ARG_WORDS_VALUE_2" => "world"
        }
      end

      it "handles string arrays with proper defaults" do
        args = described_class.new.parse!
        expect(args[:words]).to eq(["hello", "", "world"])
      end
    end

    context "with grouped occurrences" do
      let(:env) do
        {
          "OMNI_ARG_LIST" => "words",
          "OMNI_ARG_WORDS_TYPE" => "str/3/3",
          "OMNI_ARG_WORDS_TYPE_0" => "str/2",
          "OMNI_ARG_WORDS_VALUE_0_0" => "hello",
          "OMNI_ARG_WORDS_VALUE_0_1" => "world",
          "OMNI_ARG_WORDS_TYPE_1" => "str/1",
          "OMNI_ARG_WORDS_VALUE_1_0" => "foo",
          "OMNI_ARG_WORDS_TYPE_2" => "str/3",
          "OMNI_ARG_WORDS_VALUE_2_0" => "bob",
          "OMNI_ARG_WORDS_VALUE_2_1" => "alice",
          "OMNI_ARG_WORDS_VALUE_2_2" => "eve"
        }
      end

      it "handles grouped occurrences with proper nesting" do
        args = described_class.new.parse!
        expect(args[:words]).to eq([%w[hello world], %w[foo], %w[bob alice eve]])
      end
    end

    context "with boolean values" do
      let(:test_cases) do
        {
          "flag1" => ["true", true],
          "flag2" => ["false", false],
          "flag3" => ["True", true],
          "flag4" => ["False", false],
          "flag5" => ["tRuE", true],
          "flag6" => ["fAlSe", false]
        }
      end

      let(:env) do
        env = { "OMNI_ARG_LIST" => test_cases.keys.join(" ") }
        test_cases.each do |flag, (value, _)|
          env["OMNI_ARG_#{flag.upcase}_TYPE"] = "bool"
          env["OMNI_ARG_#{flag.upcase}_VALUE"] = value
        end
        env
      end

      it "handles boolean values correctly regardless of case" do
        args = described_class.new.parse!
        test_cases.each do |flag, (_, expected)|
          expect(args[flag.downcase.to_sym]).to be(expected)
        end
      end
    end

    context "with missing type" do
      let(:env) { { "OMNI_ARG_LIST" => "test" } }

      it "sets nil for arguments without a type definition" do
        args = described_class.new.parse!
        expect(args[:test]).to be_nil
      end
    end

    context "with numeric types" do
      let(:env) do
        {
          "OMNI_ARG_LIST" => "int_val float_val",
          "OMNI_ARG_INT_VAL_TYPE" => "int",
          "OMNI_ARG_INT_VAL_VALUE" => "42",
          "OMNI_ARG_FLOAT_VAL_TYPE" => "float",
          "OMNI_ARG_FLOAT_VAL_VALUE" => "3.14"
        }
      end

      it "handles numeric types correctly" do
        args = described_class.new.parse!
        expect(args[:int_val]).to eq(42)
        expect(args[:int_val]).to be_a(Integer)
        expect(args[:float_val]).to eq(3.14)
        expect(args[:float_val]).to be_a(Float)
      end
    end

    context "with case sensitivity" do
      let(:env) do
        {
          "OMNI_ARG_LIST" => "TestArg UPPER_ARG lower_arg",
          "OMNI_ARG_TESTARG_TYPE" => "str",
          "OMNI_ARG_TESTARG_VALUE" => "test",
          "OMNI_ARG_UPPER_ARG_TYPE" => "str",
          "OMNI_ARG_UPPER_ARG_VALUE" => "upper",
          "OMNI_ARG_LOWER_ARG_TYPE" => "str",
          "OMNI_ARG_LOWER_ARG_VALUE" => "lower"
        }
      end

      it "converts all keys to lowercase symbols" do
        args = described_class.new.parse!
        expect(args[:testarg]).to eq("test")
        expect(args[:upper_arg]).to eq("upper")
        expect(args[:lower_arg]).to eq("lower")

        expect(args.keys).to all(be_a(Symbol))
        expect(args.keys.map(&:to_s)).to all(match(/^[a-z]/))
      end
    end

    context "with invalid values" do
      context "when integer value is invalid" do
        let(:env) do
          {
            "OMNI_ARG_LIST" => "number",
            "OMNI_ARG_NUMBER_TYPE" => "int",
            "OMNI_ARG_NUMBER_VALUE" => "not_a_number"
          }
        end

        it "raises InvalidIntegerValueError" do
          expect { described_class.new.parse! }.to raise_error(OmniCli::InvalidIntegerValueError)
        end
      end

      context "when float value is invalid" do
        let(:env) do
          {
            "OMNI_ARG_LIST" => "number",
            "OMNI_ARG_NUMBER_TYPE" => "float",
            "OMNI_ARG_NUMBER_VALUE" => "not_a_number"
          }
        end

        it "raises InvalidFloatValueError" do
          expect { described_class.new.parse! }.to raise_error(OmniCli::InvalidFloatValueError)
        end
      end

      context "when boolean value is invalid" do
        let(:env) do
          {
            "OMNI_ARG_LIST" => "flag",
            "OMNI_ARG_FLAG_TYPE" => "bool",
            "OMNI_ARG_FLAG_VALUE" => "not_a_boolean"
          }
        end

        it "raises InvalidBooleanValueError" do
          expect { described_class.new.parse! }.to raise_error(OmniCli::InvalidBooleanValueError)
        end
      end
    end
  end
end
