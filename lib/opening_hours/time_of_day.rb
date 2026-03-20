module OpeningHours
  class TimeOfDay < Data.define(:hour, :min)
    include Comparable
    REGEX = /\A(\d{1,2})(?::(\d{1,2}))?\z/.freeze

    def self.[](input)
      case input
      when self then input
      when Time then new(hour: input.hour, min: input.min)
      else
        match = REGEX.match(input.to_s.strip)
        raise ArgumentError, "Invalid time: #{input.inspect}" unless match
        new(hour: match[1].to_i, min: (match[2] || 0).to_i)
      end
    end

    def initialize(hour: 0, min: 0)
      super
      raise ArgumentError unless hour.between?(0, 23)
      raise ArgumentError unless min.between?(0, 59)
    end

    def <=>(other)
      to_minutes <=> TimeOfDay[other].to_minutes
    end

    def to_minutes
      hour * 60 + min
    end

    def to_s
      format("%02d:%02d", hour, min)
    end
  end
end
