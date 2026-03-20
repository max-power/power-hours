# frozen_string_literal: true

require "active_model"
require "json"

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
      in nil
        OpeningHours::Schedule.new
      in OpeningHours::Schedule => schedule
        schedule
      in Hash => hash
        OpeningHours::Schedule.build(hash)
      in String => string if (hash = hash_from_json_string(string))
        OpeningHours::Schedule.build(hash)
      in candidate if (hash = hash_from(candidate))
        OpeningHours::Schedule.build(hash)
      else
        raise ArgumentError, "Cannot cast #{value.inspect} to OpeningHours::Schedule"
      end
    end

    def hash_from(value)
      return unless value.respond_to?(:to_h)

      hash = value.to_h
      hash if hash.is_a?(Hash)
    end

    def hash_from_json_string(value)
      parsed = JSON.parse(value)
      parsed if parsed.is_a?(Hash)
    rescue JSON::ParserError
      nil
    end
  end
end
