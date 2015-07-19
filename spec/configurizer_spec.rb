require 'spec_helper'

describe Configurizer do
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
      #within_test_dir do
      #end
    end
  end
end
