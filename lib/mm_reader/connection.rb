module MmReader
  class Connection
    class << self
      attr_accessor :current_db

      def get sqlite_file = MmReader::Connection.current_db
        raise "Необходимо указать путь к базе sqlite" if sqlite_file.nil?
        SQLite3::Database.new(sqlite_file)
      end
    end
  end
end
