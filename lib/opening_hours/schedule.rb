# frozen_string_literal: true

module OpeningHours
  class Schedule < Data.define(:sun, :mon, :tue, :wed, :thu, :fri, :sat)
    class << self
      def build(&block)
        return new unless block_given?

        builder = Builder.new
        builder.instance_eval(&block)
        builder.schedule
      end

      def from_hash(hash)
        new(**hash.to_h.transform_keys(&:to_sym))
      end
    end

    def initialize(mon: [], tue: [], wed: [], thu: [], fri: [], sat: [], sun: [])
      super(
        sun: normalize_day(sun),
        mon: normalize_day(mon),
        tue: normalize_day(tue),
        wed: normalize_day(wed),
        thu: normalize_day(thu),
        fri: normalize_day(fri),
        sat: normalize_day(sat)
      )
    end

    def open?(at: Time.now)
      current_time = at.strftime("%H:%M")
      windows_to_check(at).any? { |window| window.cover?(current_time) }
    end

    def to_h
      super.transform_values { |windows| windows.map(&:to_s) }
    end

    def as_json(options = nil)
      include_empty = options.is_a?(Hash) && options[:include_empty]
      include_empty ? to_h : to_h.reject { |_day, windows| windows.empty? }
    end

    private

    def normalize_day(values)
      Array(values).map { TimeWindow[it] }
    end

    # Check current day windows + previous day's overnight leftovers
    def windows_to_check(time)
      curr_day = members[time.wday]
      prev_day = members[(time.wday - 1) % 7]

      public_send(curr_day) + public_send(prev_day).select(&:overnight?)
    end
  end
end
