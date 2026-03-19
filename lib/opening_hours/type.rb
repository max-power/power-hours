# frozen_string_literal: true

require "active_model"

module OpeningHours
  class Type < ActiveModel::Type::Value
    def type
      :opening_hours
    end

    def cast(value)
      coerce(value)
    end

    def serialize(value)
      coerce(value).as_json(include_empty: false)
    end

    def changed_in_place?(raw_old_value, new_value)
      deserialize(raw_old_value) != cast(new_value)
    end

    private

    def coerce(value)
      case value
      when nil
        OpeningHours::Schedule.new
      when OpeningHours::Schedule
        value
      when Hash
        OpeningHours::Schedule.from_hash(value)
      else
        if value.respond_to?(:to_h)
          hash = value.to_h
          return OpeningHours::Schedule.from_hash(hash) if hash.is_a?(Hash)
        end

        raise ArgumentError, "Cannot cast #{value.inspect} to OpeningHours::Schedule"
      end
    end
  end
end
