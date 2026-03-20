# frozen_string_literal: true

class TimeWindowTest < Minitest::Test
  def test_build_from_array
    w = TimeWindow[["09:00", "17:00"]]

    assert_equal "09:00", w.opens.to_s
    assert_equal "17:00", w.closes.to_s
  end

  def test_build_from_string_range
    w = TimeWindow["09:00-17:00"]

    assert_equal "09:00", w.opens.to_s
    assert_equal "17:00", w.closes.to_s
  end

  def test_build_from_range
    w = TimeWindow["09:00".."17:00"]

    assert_equal "09:00", w.opens.to_s
    assert_equal "17:00", w.closes.to_s
  end

  def test_returns_same_instance
    w = TimeWindow["09:00-17:00"]
    assert_same w, TimeWindow[w]
  end

  def test_overnight_false
    w = TimeWindow["09:00-17:00"]
    refute w.overnight?
  end

  def test_overnight_true
    w = TimeWindow["22:00-02:00"]
    assert w.overnight?
  end

  # --- cover? (normal window) ---

  def test_cover_inside_normal_window
    w = TimeWindow["09:00-17:00"]

    assert w.cover?("12:00")
  end

  def test_cover_outside_normal_window
    w = TimeWindow["09:00-17:00"]

    refute w.cover?("08:59")
    refute w.cover?("17:01")
  end

  def test_cover_boundary_normal_window
    w = TimeWindow["09:00-17:00"]

    assert w.cover?("09:00")
    assert w.cover?("17:00")
  end

  # --- cover? (overnight window) ---

  def test_cover_inside_overnight_evening
    w = TimeWindow["22:00-02:00"]

    assert w.cover?("23:00")
  end

  def test_cover_inside_overnight_morning
    w = TimeWindow["22:00-02:00"]

    assert w.cover?("01:00")
  end

  def test_cover_outside_overnight
    w = TimeWindow["22:00-02:00"]

    refute w.cover?("21:59")
    refute w.cover?("02:01")
    refute w.cover?("12:00")
  end

  def test_cover_boundary_overnight
    w = TimeWindow["22:00-02:00"]

    assert w.cover?("22:00")
    assert w.cover?("02:00")
  end

  # --- coercion ---

  def test_cover_accepts_time_of_day
    w = TimeWindow["09:00-17:00"]

    assert w.cover?(TimeOfDay["10:00"])
  end

  def test_cover_accepts_time
    w = TimeWindow["09:00-17:00"]

    t = Time.new(2024, 1, 1, 10, 0)
    assert w.cover?(t)
  end

  # --- invalid input ---

  def test_invalid_input_raises
    assert_raises(ArgumentError) { TimeWindow[123] }
    assert_raises(ArgumentError) { TimeWindow["invalid"] }
  end

  def test_midnight_edge_case
    w = TimeWindow["23:00-00:00"]

    assert w.cover?("23:30")
    assert w.cover?("00:00")
    refute w.cover?("00:01")
  end

  def test_compare_orders_by_open_time
    windows = [
      TimeWindow["13:00-17:00"],
      TimeWindow["09:00-12:00"],
      TimeWindow["18:00-20:00"]
    ]

    assert_equal(
      ["09:00-12:00", "13:00-17:00", "18:00-20:00"],
      windows.sort.map(&:to_s)
    )
  end
end
