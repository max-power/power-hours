module OpeningHours
  require_relative "opening_hours/version"
  require_relative "opening_hours/time_of_day"
  require_relative "opening_hours/time_window"
  require_relative "opening_hours/schedule"
  require_relative "opening_hours/builder"
  autoload :Type,  "opening_hours/type"
  autoload :Model, "opening_hours/model"
end
