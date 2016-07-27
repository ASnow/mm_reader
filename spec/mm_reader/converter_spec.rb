require 'spec_helper'

describe MmReader::Converter  do
  let(:archive_path) { File.expand_path('../../support/files/csv', __FILE__) }

  before(:all) do
    MmReader::Connection.current_db = File.expand_path('../../support/files/test_converter_sqlite.db', __FILE__)
    described_class.clear
  end

  it 'creates index' do
    db = described_class.new(archive_path)
    db.to_sqlite
  end
end
