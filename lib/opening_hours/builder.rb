# frozen_string_literal: true

module OpeningHours
  class Builder
    attr_reader :schedule

    def initialize
      @schedule = Schedule.new
    end

    Schedule.members.each do |day|
      define_method(day) do |*ranges|
        windows = ranges.map { |range| TimeWindow[range] }.freeze
        @schedule = @schedule.with(day => windows)
      end
    end
  end
end
