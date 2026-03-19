# frozen_string_literal: true

class BuilderTest < Minitest::Test
  def test_starts_with_empty_schedule
    builder = Builder.new

    assert_equal Schedule.new, builder.schedule
  end

  def test_sets_single_window_for_a_day
    builder = Builder.new

    builder.mon("09:00".."17:00")

    assert_equal [TimeWindow["09:00".."17:00"]], builder.schedule.mon
  end

  def test_sets_multiple_windows_for_a_day
    builder = Builder.new

    builder.mon("08:00".."12:00", "14:00".."18:00")

    assert_equal(
      [
        TimeWindow["08:00".."12:00"],
        TimeWindow["14:00".."18:00"]
      ],
      builder.schedule.mon
    )
  end

  def test_accepts_mixed_time_window_input_shapes
    builder = Builder.new

    builder.mon(
      ["08:00", "12:00"],
      "14:00-18:00",
      TimeWindow["19:00-21:00"]
    )

    assert_equal(
      [
        TimeWindow[["08:00", "12:00"]],
        TimeWindow["14:00-18:00"],
        TimeWindow["19:00-21:00"]
      ],
      builder.schedule.mon
    )
  end

  def test_sets_correct_day_without_affecting_other_days
    builder = Builder.new

    builder.tue("10:00".."16:00")

    assert_equal [], builder.schedule.mon
    assert_equal [TimeWindow["10:00".."16:00"]], builder.schedule.tue
    assert_equal [], builder.schedule.wed
  end

  def test_multiple_day_methods_build_up_schedule
    builder = Builder.new

    builder.mon("09:00".."17:00")
    builder.tue("10:00".."18:00")

    assert_equal [TimeWindow["09:00".."17:00"]], builder.schedule.mon
    assert_equal [TimeWindow["10:00".."18:00"]], builder.schedule.tue
  end

  def test_repeated_call_for_same_day_replaces_existing_windows
    builder = Builder.new

    builder.mon("08:00".."12:00")
    builder.mon("14:00".."18:00")

    assert_equal [TimeWindow["14:00".."18:00"]], builder.schedule.mon
  end

  def test_day_method_accepts_no_ranges_and_clears_the_day
    builder = Builder.new

    builder.mon("08:00".."12:00")
    builder.mon

    assert_equal [], builder.schedule.mon
  end

  def test_schedule_remains_a_schedule_instance_after_updates
    builder = Builder.new

    builder.mon("09:00".."17:00")

    assert_instance_of Schedule, builder.schedule
  end
end
