namespace :mm do
  task :create do
    raise "Вы должны указать путь к CSV базе MaxMind в переменной окружения MM_PATH" unless ENV["MM_PATH"]
    raise "Не верно указан путь к XML базе ФИАС в переменной окружения MM_PATH" unless File.exist? ENV["MM_PATH"]
    db = MmReader::Converter.new(ENV["MM_PATH"])
    db.to_sqlite
  end

  task :clear do
    MmReader::Converter.clear
  end
end