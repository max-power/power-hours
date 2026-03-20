# frozen_string_literal: true

class ScheduleTest < Minitest::Test
  def test_build_creates_schedule_via_dsl
    schedule = Schedule.build do
      mon "09:00".."12:00", "13:00".."17:00"
      fri "22:00".."02:00"
    end

    assert schedule.open?(at: Time.new(2024, 1, 1, 10, 0, 0)) # Monday
    assert schedule.open?(at: Time.new(2024, 1, 6, 1, 0, 0))  # Saturday (Friday overnight)
  end

  def test_build_without_block_returns_blank_schedule
    assert_equal Schedule.new, Schedule.build
  end

  def test_build_from_hash_normalizes_string_keys
    schedule = Schedule.build(
      "mon" => ["09:00-17:00"]
    )

    assert schedule.open?(at: Time.new(2024, 1, 1, 10, 0, 0)) # Monday
  end

  def test_build_prefers_block_when_hash_and_block_are_provided
    schedule = Schedule.build({ mon: ["09:00-17:00"] }) do
      tue "10:00".."12:00"
    end

    refute schedule.open?(at: Time.new(2024, 1, 1, 10, 0, 0)) # Monday
    assert schedule.open?(at: Time.new(2024, 1, 2, 11, 0, 0)) # Tuesday
  end

  def test_normalize_day_sorts_windows_by_open_time
    schedule = Schedule.new(
      mon: ["13:00-17:00", "09:00-12:00", "18:00-20:00"]
    )

    assert_equal ["09:00-12:00", "13:00-17:00", "18:00-20:00"], schedule.mon.map(&:to_s)
  end

  def test_day_arrays_are_immutable
    schedule = Schedule.new(mon: ["09:00-17:00"])

    assert schedule.mon.frozen?
    assert_raises(FrozenError) { schedule.mon << TimeWindow["18:00-20:00"] }
  end

  def test_day_arrays_are_immutable_when_built_via_dsl
    schedule = Schedule.build do
      mon "09:00".."17:00"
    end

    assert schedule.mon.frozen?
    assert_raises(FrozenError) { schedule.mon << TimeWindow["18:00-20:00"] }
  end

  def test_open_during_same_day_window
    schedule = Schedule.new(
      mon: ["09:00-17:00"]
    )

    at = Time.new(2024, 1, 1, 10, 0, 0) # Monday
    assert schedule.open?(at: at)
  end

  def test_closed_before_same_day_window
    schedule = Schedule.new(
      mon: ["09:00-17:00"]
    )

    at = Time.new(2024, 1, 1, 8, 59, 0) # Monday
    refute schedule.open?(at: at)
  end

  def test_closed_after_same_day_window
    schedule = Schedule.new(
      mon: ["09:00-17:00"]
    )

    at = Time.new(2024, 1, 1, 17, 1, 0) # Monday
    refute schedule.open?(at: at)
  end

  def test_open_at_window_boundaries
    schedule = Schedule.new(
      mon: ["09:00-17:00"]
    )

    assert schedule.open?(at: Time.new(2024, 1, 1, 9, 0, 0))   # Monday
    assert schedule.open?(at: Time.new(2024, 1, 1, 17, 0, 0))  # Monday
  end

  def test_open_during_previous_days_overnight_window
    schedule = Schedule.new(
      mon: ["22:00-02:00"]
    )

    at = Time.new(2024, 1, 2, 1, 0, 0) # Tuesday 01:00
    assert schedule.open?(at: at)
  end

  def test_closed_after_previous_days_overnight_window_ends
    schedule = Schedule.new(
      mon: ["22:00-02:00"]
    )

    at = Time.new(2024, 1, 2, 2, 1, 0) # Tuesday 02:01
    refute schedule.open?(at: at)
  end

  def test_open_during_current_days_overnight_window_before_midnight
    schedule = Schedule.new(
      mon: ["22:00-02:00"]
    )

    at = Time.new(2024, 1, 1, 23, 0, 0) # Monday 23:00
    assert schedule.open?(at: at)
  end

  def test_does_not_use_previous_days_non_overnight_windows
    schedule = Schedule.new(
      mon: ["09:00-17:00"]
    )

    at = Time.new(2024, 1, 2, 10, 0, 0) # Tuesday
    refute schedule.open?(at: at)
  end

  def test_sunday_to_monday_wraparound_for_overnight_window
    schedule = Schedule.new(
      sun: ["22:00-02:00"]
    )

    at = Time.new(2024, 1, 1, 1, 0, 0) # Monday 01:00
    assert schedule.open?(at: at)
  end

  def test_multiple_windows_in_a_day
    schedule = Schedule.new(
      mon: ["09:00-12:00", "13:00-17:00"]
    )

    assert schedule.open?(at: Time.new(2024, 1, 1, 10, 0, 0))  # Monday
    refute schedule.open?(at: Time.new(2024, 1, 1, 12, 30, 0)) # Monday
    assert schedule.open?(at: Time.new(2024, 1, 1, 14, 0, 0))  # Monday
  end

  def test_accepts_mixed_time_window_input_shapes
    schedule = Schedule.new(
      mon: [
        ["09:00", "12:00"],
        "13:00-17:00",
        TimeWindow["18:00-20:00"]
      ]
    )

    assert schedule.open?(at: Time.new(2024, 1, 1, 10, 0, 0)) # Monday
    assert schedule.open?(at: Time.new(2024, 1, 1, 14, 0, 0)) # Monday
    assert schedule.open?(at: Time.new(2024, 1, 1, 19, 0, 0)) # Monday
    refute schedule.open?(at: Time.new(2024, 1, 1, 12, 30, 0)) # Monday
  end

  def test_empty_schedule_is_closed
    schedule = Schedule.new

    refute schedule.open?(at: Time.new(2024, 1, 1, 12, 0, 0))
  end

  def test_open_without_at_uses_current_time_without_raising
    schedule = Schedule.new

    refute schedule.open?
  end

  def test_open_at_end_of_previous_days_overnight_window
    schedule = Schedule.new(
      mon: ["22:00-02:00"]
    )

    at = Time.new(2024, 1, 2, 2, 0, 0) # Tuesday 02:00
    assert schedule.open?(at: at)
  end

  def test_to_h_serializes_windows_as_strings
    schedule = Schedule.new(
      mon: ["09:00-17:00"],
      tue: [["10:00", "12:00"]]
    )

    assert_equal(
      {
        sun: [],
        mon: ["09:00-17:00"],
        tue: ["10:00-12:00"],
        wed: [],
        thu: [],
        fri: [],
        sat: []
      },
      schedule.to_h
    )
  end

  def test_as_json_excludes_empty_days_by_default
    schedule = Schedule.new(
      mon: ["09:00-17:00"]
    )

    assert_equal(
      {
        mon: ["09:00-17:00"]
      },
      schedule.as_json
    )
  end

  def test_as_json_can_include_empty_days
    schedule = Schedule.new(
      mon: ["09:00-17:00"]
    )

    assert_equal(
      {
        sun: [],
        mon: ["09:00-17:00"],
        tue: [],
        wed: [],
        thu: [],
        fri: [],
        sat: []
      },
      schedule.as_json(include_empty: true)
    )
  end

  def test_to_s_excludes_empty_days_by_default
    schedule = Schedule.new(
      mon: ["09:00-17:00"],
      fri: ["22:00-02:00"]
    )

    assert_equal("MON: 09:00-17:00\nFRI: 22:00-02:00", schedule.to_s)
  end

  def test_to_s_can_include_empty_days
    schedule = Schedule.new(
      mon: ["09:00-17:00"]
    )

    assert_equal(
      "SUN: \nMON: 09:00-17:00\nTUE: \nWED: \nTHU: \nFRI: \nSAT: ",
      schedule.to_s(true)
    )
  end
end
