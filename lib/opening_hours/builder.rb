# frozen_string_literal: true

module OpeningHours
  class Builder
    attr_reader :schedule

    def self.build(&block)
      builder = new
      builder.instance_eval(&block)
      builder.schedule
    end

    def initialize
      @schedule = Schedule.new
    end

    Schedule.members.each do |day|
      define_method(day) do |*ranges|
        windows = ranges.map { |range| TimeWindow[range] }
        @schedule = @schedule.with(day => windows)
      end
    end
  end
end
