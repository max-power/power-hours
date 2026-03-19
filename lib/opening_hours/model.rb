# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/time"

module OpeningHours
  module Model
    extend ActiveSupport::Concern

    included do
      class_attribute :opening_hours_column_name, instance_accessor: false, default: :opening_hours
      register_opening_hours_attribute!
      delegate :opening_hours_column, to: :class
    end

    class_methods do
      def opening_hours_column(name = nil)
        unless name.nil?
          self.opening_hours_column_name = name.to_sym
          register_opening_hours_attribute!
        end

        opening_hours_column_name
      end

      private

      def register_opening_hours_attribute!
        attribute(opening_hours_column_name, OpeningHours::Type.new, default: -> { OpeningHours::Schedule.new })
      end
    end

    def define_hours(&block)
      OpeningHours::Schedule.build(&block).tap do |schedule|
        public_send(:"#{opening_hours_column}=", schedule)
      end
    end

    def open?(at: Time.current)
      zone = respond_to?(:timezone) ? timezone.presence : nil
      public_send(opening_hours_column).open?(at: zone ? at.in_time_zone(zone) : at)
    end
  end
end
