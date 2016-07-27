require "mm_reader/version"
require 'sqlite3'
require 'csv'
require 'ipaddr'
require 'pry'
require 'fiber'

module MmReader
  # Your code goes here...
  def self.find(postal_code = nil, city = nil, state = nil)
    MmReader::Query.new(postal_code, city, state).result
  end
end

require "mm_reader/connection"
require "mm_reader/converter"
require "mm_reader/query"
