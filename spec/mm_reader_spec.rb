require 'spec_helper'

describe MmReader do
  it 'has a version number' do
    expect(MmReader::VERSION).not_to be nil
  end

  describe '.find' do

    shared_examples "find ip array" do |args, result|
      before(:all) do
        MmReader::Connection.current_db = File.expand_path('../support/files/test_find_sqlite.db', __FILE__)
        MmReader::Converter.clear
        db = MmReader::Converter.new(File.expand_path('../support/files/csv', __FILE__))
        db.to_sqlite
      end

      it "uses the given parameter" do
        expect(described_class.find(*args)).to eq(result)
      end
    end

    include_examples "find ip array", [],[]
    include_examples "find ip array", [11111], IPAddr.new('1.0.0.0/24').to_range.map(&:to_s)
    include_examples "find ip array", [12345], []
    include_examples "find ip array", [12345, 'Могадишо'], [IPAddr.new('1.0.0.0/24'), IPAddr.new('1.0.4.0/22')].map{ |r| r.to_range.map(&:to_s) }.flatten
    include_examples "find ip array", [12345, 'Rio'], []
    include_examples "find ip array", [12345, 'Rio', 'TestState'], [IPAddr.new('1.0.1.0/24'), IPAddr.new('1.0.2.0/23')].map{ |r| r.to_range.map(&:to_s) }.flatten
  end
end
