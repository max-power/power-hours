# frozen_string_literal: true

module OpeningHours
  module TypeBehavior
    def type
      :opening_hours
    end

    def cast(value)
      coerce(value)
    end

    def deserialize(value)
      coerce(value)
    end

    def serialize(value)
      coerce(value).to_h
    end

    def changed_in_place?(raw_old_value, new_value)
      deserialize(raw_old_value).to_h != cast(new_value).to_h
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

  if defined?(::ActiveModel::Type::Value)
    class Type < ::ActiveModel::Type::Value
      include TypeBehavior
    end
  else
    class Type
      include TypeBehavior
    end
  end
end
