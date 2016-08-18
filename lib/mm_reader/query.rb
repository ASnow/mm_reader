module MmReader
  class Query
    attr_accessor :postal, :city, :state

    def initialize postal, city, state
      @postal = postal
      @city = city
      @state = state
    end

    def query_result
      db = MmReader::Connection.get
      result = db.execute('SELECT DISTINCT network FROM ip4_index WHERE postal_code = ?', [@postal])
      return result if result.size > 0

      state = "%#{@state}%"
      result = db.execute('SELECT DISTINCT network FROM ip4_index WHERE city = ? and state like ?', [@city, state])
      return result if result.size > 0

      result = db.execute('SELECT DISTINCT network FROM ip4_index WHERE city = ?', [@city])
      return result if result.size > 0

      result = db.execute('SELECT DISTINCT network FROM ip4_index WHERE state like ?', [state])
      return result if result.size > 0

      return []
    end
    def result
      query_result.flatten.map{ |mask| IPAddr.new(mask).to_range.map(&:to_s) }.flatten
    end

  end
end
