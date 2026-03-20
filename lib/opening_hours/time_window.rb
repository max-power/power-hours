# frozen_string_literal: true

module OpeningHours
  class TimeWindow < Data.define(:opens, :closes)
    include Comparable

    def self.[](input)
      case input
      in TimeWindow => tw
        tw
      in Range => r
        new(r.begin, r.end)
      in [opens, closes]
        new(opens, closes)
      in String => s if s.include?("-")
        new(*s.split("-", 2))
      else
        raise ArgumentError, "Cannot build TimeWindow from #{input.inspect}"
      end
    end

    def initialize(opens:, closes:)
      opens  = TimeOfDay[opens]
      closes = TimeOfDay[closes]
      super
    end

    def to_a = deconstruct
    def to_s = deconstruct.uniq.join("-")

    def overnight?
      closes < opens
    end

    def cover?(value)
      time = TimeOfDay[value]

      if overnight?
        time >= opens || time <= closes
      else
        time >= opens && time <= closes
      end
    end

    def <=>(other)
      opens <=> TimeWindow[other].opens
    end
  end
end
