# frozen_string_literal: true

module OpeningHours
  module Model
    def self.included(base)
      base.extend(ClassMethods)

      if base.respond_to?(:attribute)
        base.attribute(base.opening_hours_column, base.opening_hours_type)
      end
    end

    module ClassMethods
      def opening_hours_column(name = nil)
        if name.nil?
          return @opening_hours_column if defined?(@opening_hours_column)

          return superclass.opening_hours_column if superclass.respond_to?(:opening_hours_column)

          return :opening_hours
        end

        @opening_hours_column = name.to_sym

        if respond_to?(:attribute)
          attribute(@opening_hours_column, opening_hours_type)
        end

        @opening_hours_column
      end

      def opening_hours_type
        return @opening_hours_type if defined?(@opening_hours_type)

        @opening_hours_type = if superclass.respond_to?(:opening_hours_type)
          superclass.opening_hours_type
        else
          OpeningHours::Type.new
        end
      end
    end

    def define_hours(&block)
      raise ArgumentError, "define_hours requires a block" unless block

      OpeningHours::Schedule.build(&block).tap do |schedule|
        write_opening_hours_data(self.class.opening_hours_type.serialize(schedule))
      end
    end

    def open?(at: default_time)
      current_schedule.open?(at: apply_timezone(at))
    end

    private

    def current_schedule
      self.class.opening_hours_type.cast(read_opening_hours_data)
    end

    def opening_hours_column_name
      self.class.respond_to?(:opening_hours_column) ? self.class.opening_hours_column : :opening_hours
    end

    def read_opening_hours_data
      public_send(opening_hours_column_name)
    end

    def write_opening_hours_data(value)
      public_send(:"#{opening_hours_column_name}=", value)
    end

    def default_time
      Time.respond_to?(:current) ? Time.current : Time.now
    end

    def apply_timezone(time)
      return time unless respond_to?(:timezone)
      return time if timezone.nil? || timezone.to_s.strip.empty?
      return time unless time.respond_to?(:in_time_zone)

      time.in_time_zone(timezone)
    end
  end
end
