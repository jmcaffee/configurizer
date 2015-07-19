require 'spec_helper'

describe Configurizer do

  def spec_test_dir
    "tmp/spec"
  end

  def within_test_dir subdir = nil, delete_if_exist = true
    fail "block expected" unless block_given?

    test_dir = Pathname(spec_test_dir)
    unless subdir.nil?
      test_dir = test_dir + subdir
    end

    test_dir.rmtree if test_dir.exist? and delete_if_exist
    test_dir.mkpath

    FileUtils.cd test_dir do
      yield if block_given?
    end
  end


  it 'has a version number' do
    expect(Configurizer::VERSION).not_to be nil
  end

  before do
    module TestMod
      include Configurizer
    end
  end

  it 'extends another module when included' do
    expect(TestMod.respond_to?(:config_filename)).to eq(true)
    expect(TestMod.respond_to?(:"config_filename=")).to eq(true)
  end

  context '.config_filename= and .config_filename' do

    it 'sets and retrieves the configuration filename' do
      TestMod.config_filename = '.testmod'
      expect(TestMod.config_filename).to eq '.testmod'
    end
  end

  context 'create configuration object' do

    before do
      module TestMod
        include Configurizer

        self.config_filename = '.testmod'

        class Configurizer::Configuration
          attr_accessor :value_a
          attr_accessor :value_b
        end
      end
    end

    context '.configure' do

      it 'can be configured with a block' do
        TestMod.configure do |config|
          config.value_a = "Hello A"
          config.value_b = "Hello B"
        end

        expect(TestMod.configuration.value_a).to eq "Hello A"
        expect(TestMod.configuration.value_b).to eq "Hello B"
      end
    end

    context '.save_configuration' do

      it 'saves a configuration file' do
        within_test_dir "save_config" do
          TestMod.save_configuration
          expect(Pathname(".testmod").exist?).to eq true
        end
      end

      it 'saves configuration file to specified directory' do
        within_test_dir "save_config/a/deeper/dir" do
        end

        TestMod.save_configuration "#{spec_test_dir}/save_config/a/deeper/dir"
        expect(Pathname("#{spec_test_dir}/save_config/a/deeper/dir/.testmod").exist?).to eq true
      end
    end

    context '.load_configuration' do

      it 'loads a configuration' do
        TestMod.configure do |config|
          config.value_a = "Hello A"
          config.value_b = "Hello B"
        end

        within_test_dir "load_config" do
          TestMod.save_configuration

          # Clear out our settings now that the file is saved
          TestMod.configuration.value_a = nil
          TestMod.configuration.value_b = nil

          expect(TestMod.configuration.value_a).to eq nil
          expect(TestMod.configuration.value_b).to eq nil

          # Load the file and verify the settings are loaded
          TestMod.load_configuration

          expect(TestMod.configuration.value_a).to eq "Hello A"
          expect(TestMod.configuration.value_b).to eq "Hello B"
        end
      end

      it 'loads configuration file from specified directory' do
        TestMod.configure do |config|
          config.value_a = "Hello C"
          config.value_b = "Hello D"
        end

        within_test_dir "load_config/a/deeper/dir" do
          TestMod.save_configuration "."

          # Clear out our settings now that the file is saved
          TestMod.configuration.value_a = nil
          TestMod.configuration.value_b = nil

          expect(TestMod.configuration.value_a).to eq nil
          expect(TestMod.configuration.value_b).to eq nil
        end

        within_test_dir("load_config", false) do
          # Load the file and verify the settings are loaded
          TestMod.load_configuration "a/deeper/dir"

          expect(TestMod.configuration.value_a).to eq "Hello C"
          expect(TestMod.configuration.value_b).to eq "Hello D"
        end
      end

      it 'walks up the directory tree to find and load a configuration' do
        TestMod.configure do |config|
          config.value_a = "Hello E"
          config.value_b = "Hello F"
        end

        within_test_dir "load_config" do
          TestMod.save_configuration "."

          # Clear out our settings now that the file is saved
          TestMod.configuration.value_a = nil
          TestMod.configuration.value_b = nil

          expect(TestMod.configuration.value_a).to eq nil
          expect(TestMod.configuration.value_b).to eq nil
        end

        within_test_dir "load_config/subdira/subdirb" do
          # Load the file and verify the settings are loaded
          TestMod.load_configuration

          expect(TestMod.configuration.value_a).to eq "Hello E"
          expect(TestMod.configuration.value_b).to eq "Hello F"
        end
      end
    end
  end
end
