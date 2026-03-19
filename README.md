# Power Hours

Power Hours provides a small, explicit DSL for weekly opening-hours schedules.

It supports:
- multiple windows per day
- overnight windows (for example `22:00-02:00`)
- serialization to/from hashes
- optional model mixin helpers via `OpeningHours::Model`

## Installation

```bash
bundle add power-hours
```

or

```bash
gem install power-hours
```

## Usage

### Build a schedule

```ruby
require "opening_hours"

builder = OpeningHours::Builder.new
builder.mon "09:00".."12:00", "13:00".."17:00"
builder.fri "22:00".."02:00"

schedule = builder.schedule

schedule.open?(at: Time.new(2024, 1, 1, 10, 0, 0)) # => true (Monday)
schedule.open?(at: Time.new(2024, 1, 6, 1, 0, 0))  # => true (Saturday, from Friday overnight)
```

### Construct directly from hash data

```ruby
schedule = OpeningHours::Schedule.from_hash(
  "mon" => ["09:00-17:00"],
  "fri" => ["22:00-02:00"]
)
```

### Serialize for persistence

```ruby
schedule.to_h
# {
#   sun: [],
#   mon: ["09:00-17:00"],
#   tue: [],
#   wed: [],
#   thu: [],
#   fri: ["22:00-02:00"],
#   sat: []
# }
```

### Optional mixin for app models

```ruby
class Venue < ApplicationRecord
  include OpeningHours::Model
  # expects an `opening_hours` attribute (for example json/jsonb)
end

venue = Venue.new
venue.define_hours do
  mon "09:00".."17:00"
end

venue.open?(at: Time.new(2024, 1, 1, 10, 0, 0)) # => true
```

### Use a custom backing column

```ruby
class Venue < ApplicationRecord
  include OpeningHours::Model
  opening_hours_column :business_hours
end
```

### Use the value type directly

```ruby
class Venue < ApplicationRecord
  attribute :opening_hours, OpeningHours::Type.new
end
```

## Development

```bash
bin/setup
bundle exec rake test
bundle exec gem build power-hours.gemspec
```

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).
