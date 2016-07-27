module MmReader
  class Converter
    def self.clear sqlite_file = MmReader::Connection.current_db
      FileUtils.rm sqlite_file if File.exists?(sqlite_file)
    end

    def initialize csv_dir
      @csv_dir = csv_dir
    end

    def to_sqlite sqlite_file = MmReader::Connection.current_db
      @db = MmReader::Connection.get sqlite_file
      @db.execute('PRAGMA journal_mode=OFF; PRAGMA synchronous=OFF; PRAGMA locking_mode = EXCLUSIVE; PRAGMA count_changes = OFF; PRAGMA cache_size=500000; PRAGMA temp_store = MEMORY; PRAGMA auto_vacuum = NONE;')
      @db.execute('BEGIN;')
      puts "import_blocks_ip4"
      import_blocks_ip4
      puts "import_blocks_ip6"
      import_blocks_ip6
      puts "import_locations_ru"
      import_locations_ru
      puts "index_data"
      index_data
      puts "drop_temp"
      drop_temp
      puts "Commit"
      @db.execute('COMMIT;')
    end

    def import_blocks_ip4
      import_csv "#{@csv_dir}/GeoLite2-City-Blocks-IPv4.csv", "tmp_ip4"
      
    end

    def import_blocks_ip6
      import_csv "#{@csv_dir}/GeoLite2-City-Blocks-IPv6.csv", "tmp_ip6"
    end

    def import_locations_ru
      import_csv "#{@csv_dir}/GeoLite2-City-Locations-ru.csv", "tmp_locations"
    end

    def drop_temp
      @db.execute("DROP TABLE tmp_ip4")
      @db.execute("DROP TABLE tmp_ip6")
      @db.execute("DROP TABLE tmp_locations")
    end

    def index_data
      @db.execute("
        CREATE TABLE ip4_index (
          network varchar(255), 
          postal_code varchar(10), 
          city varchar(255), 
          state varchar(255)
        );
      ")
      @db.execute("
        CREATE TABLE ip6_index (
          network varchar(255), 
          postal_code varchar(10), 
          city varchar(255), 
          state varchar(255)
        );
      ")

      @db.execute("
        INSERT INTO ip4_index (network, postal_code, city, state)
        SELECT tmp_ip4.network, tmp_ip4.postal_code, tmp_locations.city_name, tmp_locations.subdivision_1_name FROM tmp_ip4 LEFT JOIN tmp_locations ON tmp_ip4.geoname_id=tmp_locations.geoname_id;
      ")

      @db.execute("
        INSERT INTO ip6_index (network, postal_code, city, state)
        SELECT tmp_ip6.network, tmp_ip6.postal_code, tmp_locations.city_name, tmp_locations.subdivision_1_name FROM tmp_ip6 LEFT JOIN tmp_locations ON tmp_ip6.geoname_id=tmp_locations.geoname_id;
      ")
      @db.execute "CREATE INDEX postal_code4_idx ON ip4_index (postal_code);"
      @db.execute "CREATE INDEX postal_code6_idx ON ip6_index (postal_code);"

    end

    def import_csv from_file, to_table
      provider = prepare_data from_file
      columns = provider.transfer
      schema = provider.transfer
      @db.execute "CREATE TABLE #{to_table} (#{schema});"

      loop do
        stop = insert_bulk to_table, columns, provider
        break if stop
      end
    end

    def insert_bulk to_table, columns, provider, limit  = 10000
      begin
        stop = false
        data = []
        limit.times{ data << provider.transfer }
        stop
      rescue FiberError
        stop = true
      ensure
        @db.execute "INSERT INTO #{to_table} (#{columns}) VALUES #{data_mask_map(data)};", data
        stop
      end
    end

    def prepare_data from_file
      row_fiber = nil
      iterator = Fiber.new do
        header = nil
        CSV.foreach(from_file, col_sep: ',') do |row|
          row_fiber.transfer row
        end
      end

      row_fiber = Fiber.new do
        headers = iterator.transfer
        Fiber.yield headers.join(', ') # columns
        first_row = iterator.transfer
        schema = headers.map.with_index{ |col, index| "#{col} #{col_type(first_row[index])}" }.join(', ')
        Fiber.yield schema # schema

        Fiber.yield first_row # first_row

        loop do
          Fiber.yield iterator.transfer # other
        end
      end
    end

    TYPES = {
      String => 'varchar(255)',
      Fixnum => 'integer'
    }

    def col_type data
      TYPES[data.class] || TYPES[String]
    end

    def data_mask_map data
      row = Array.new(data.first.size, '?').join(', ')
      rows = ("(#{row}), " * data.size)
      rows.chomp!(', ')
      rows
    end
  end
end
