module OpeningHours
  class TimeOfDay
    include Comparable
    REGEX = /\A(\d{1,2})(?::(\d{1,2}))?\z/.freeze

    def self.[](input)
      input.is_a?(self) ? input : new(input)
    end

    attr_reader :hour, :min

    def initialize(input)
      case input
      in Time
        @hour = input.hour
        @min  = input.min
      else
        @hour, @min = parse(input)
      end

      validate!
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

    private

    def parse(input)
      match = REGEX.match(input.to_s.strip)
      raise ArgumentError, "Invalid time: #{input.inspect}" unless match

      [match[1].to_i, (match[2] || 0).to_i]
    end

    def validate!
      raise ArgumentError unless hour.between?(0, 23)
      raise ArgumentError unless min.between?(0, 59)
    end
  end
end
