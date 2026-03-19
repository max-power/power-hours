# frozen_string_literal: true

class TimeOfDayTest < Minitest::Test
  def test_parses_hour_only
    t = TimeOfDay["9"]
    assert_equal 9, t.hour
    assert_equal 0, t.min
    assert_equal "09:00", t.to_s
  end

  def test_parses_hour_and_minute
    t = TimeOfDay["9:5"]
    assert_equal 9, t.hour
    assert_equal 5, t.min
    assert_equal "09:05", t.to_s
  end

  def test_parses_padded_time
    t = TimeOfDay["09:30"]
    assert_equal 9, t.hour
    assert_equal 30, t.min
    assert_equal "09:30", t.to_s
  end

  def test_accepts_integer_like_input
    t = TimeOfDay[9]
    assert_equal "09:00", t.to_s
  end

  def test_accepts_time_object
    time = Time.new(2024, 1, 1, 14, 45)
    t = TimeOfDay[time]

    assert_equal 14, t.hour
    assert_equal 45, t.min
  end

  def test_returns_same_instance_if_already_time_of_day
    t = TimeOfDay["10:00"]
    assert_same t, TimeOfDay[t]
  end

  def test_comparison
    assert TimeOfDay["09:00"] < TimeOfDay["10:00"]
    assert TimeOfDay["10:00"] > TimeOfDay["09:00"]
    assert_equal TimeOfDay["09:00"], TimeOfDay["9"]
  end

  def test_comparison_with_coercion
    assert TimeOfDay["09:00"] < "10:00"
    assert TimeOfDay["10:00"] > "09:00"
  end

  def test_invalid_hour_raises
    assert_raises(ArgumentError) { TimeOfDay["24:00"] }
    assert_raises(ArgumentError) { TimeOfDay["-1:00"] }
  end

  def test_invalid_minute_raises
    assert_raises(ArgumentError) { TimeOfDay["10:60"] }
    assert_raises(ArgumentError) { TimeOfDay["10:-1"] }
  end

  def test_invalid_format_raises
    assert_raises(ArgumentError) { TimeOfDay["abc"] }
    assert_raises(ArgumentError) { TimeOfDay["9:"] }
    assert_raises(ArgumentError) { TimeOfDay["1:2:3"] }
  end

  def test_whitespace_is_ignored
    t = TimeOfDay["  9:5  "]
    assert_equal "09:05", t.to_s
  end

  def test_to_minutes
    t = TimeOfDay["01:30"]
    assert_equal 90, t.to_minutes
  end

  def test_midnight
    assert_equal "00:00", TimeOfDay["0"].to_s
  end

  def test_last_minute
    assert_equal "23:59", TimeOfDay["23:59"].to_s
  end
end
