# MmReader

Адаптер для работы с базой MaxMind

## Установка

Добавить в Gemfile:

```ruby
gem 'mm_reader'
```

Запустить:

    $ bundle

Установать путь к будующему файлу базы sql.

```
  # config/initializer/mm_reader.db

  require 'mm_reader'
  MmReader::Connection.current_db = 'path to sqlite.db'
```

Выполнить задачу на генерацию базы:

    $ rake mm:create MM_PATH='path/to/csv/dir'

## Использование

Запросы к базе.

```
  MmReader.find(123000, 'Москва', 'Московская область') # => ['10.0.0.0', '10.0.0.1', ...]
```


## Удаление базы

Выполнить задачу на удаление базы:

    $ rake mm:clear


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mm_reader.

