# frozen_string_literal: true

require_relative "test_helper"

class TypeTest < Minitest::Test
  def setup
    @type = OpeningHours::Type.new
  end

  def test_cast_nil_returns_empty_schedule
    schedule = @type.cast(nil)

    assert_instance_of Schedule, schedule
    refute schedule.open?(at: Time.new(2024, 1, 1, 12, 0, 0))
  end

  def test_cast_hash_returns_schedule
    schedule = @type.cast("mon" => ["09:00-17:00"])

    assert schedule.open?(at: Time.new(2024, 1, 1, 10, 0, 0))
  end

  def test_cast_schedule_returns_same_object
    schedule = Schedule.new(mon: ["09:00-17:00"])

    assert_same schedule, @type.cast(schedule)
  end

  def test_cast_hash_like_object_with_to_h
    value = Class.new do
      def initialize(hash)
        @hash = hash
      end

      def to_h
        @hash
      end
    end.new("mon" => ["09:00-17:00"])

    schedule = @type.cast(value)

    assert schedule.open?(at: Time.new(2024, 1, 1, 10, 0, 0))
  end

  def test_serialize_schedule_returns_hash
    schedule = Schedule.new(mon: ["09:00-17:00"])

    assert_equal ["09:00-17:00"], @type.serialize(schedule)[:mon]
  end

  def test_deserialize_hash_returns_schedule
    schedule = @type.deserialize("tue" => ["10:00-12:00"])

    assert schedule.open?(at: Time.new(2024, 1, 2, 11, 0, 0))
  end

  def test_changed_in_place_detects_differences
    refute @type.changed_in_place?({ "mon" => ["09:00-17:00"] }, { mon: ["09:00-17:00"] })
    assert @type.changed_in_place?({ "mon" => ["09:00-17:00"] }, { mon: ["10:00-17:00"] })
  end

  def test_changed_in_place_uses_schedule_value_equality
    old_value = Schedule.new(mon: ["09:00-17:00"])
    same_value = Schedule.new(mon: ["09:00-17:00"])
    different_value = Schedule.new(mon: ["10:00-17:00"])

    refute @type.changed_in_place?(old_value, same_value)
    assert @type.changed_in_place?(old_value, different_value)
  end

  def test_changed_in_place_detects_in_place_schedule_mutation
    schedule = Schedule.new(mon: ["09:00-17:00"])
    raw_old_value = @type.serialize(schedule)

    schedule.mon << TimeWindow["18:00-20:00"]

    assert @type.changed_in_place?(raw_old_value, schedule)
  end

  def test_invalid_cast_raises
    assert_raises(ArgumentError) { @type.cast(123) }
  end
end
