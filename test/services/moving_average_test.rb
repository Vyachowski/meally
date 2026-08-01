require "test_helper"

class MovingAverageTest < ActiveSupport::TestCase
  def m(date, value)
    Measurement.new(kind: "weight", measured_on: date, value: value)
  end

  test "full window averages all points" do
    on = Date.new(2026, 1, 7)
    ms = (1..7).map { |d| m(Date.new(2026, 1, d), 80 + d) } # values 81..87
    result = MovingAverage.new(ms).at(on)

    assert result.enough?
    assert_equal 7, result.count
    assert_in_delta 84.0, result.average, 0.001
  end

  test "gaps: averages only points present in the window" do
    on = Date.new(2026, 1, 7)
    ms = [m(Date.new(2026, 1, 1), 80), m(Date.new(2026, 1, 4), 82), m(Date.new(2026, 1, 7), 84)]
    result = MovingAverage.new(ms).at(on)

    assert result.enough?
    assert_equal 3, result.count
    assert_in_delta 82.0, result.average, 0.001
  end

  test "empty window is not enough" do
    result = MovingAverage.new([]).at(Date.new(2026, 1, 7))

    assert_not result.enough?
    assert_nil result.average
    assert_equal 0, result.count
  end

  test "single measurement is not enough" do
    ms = [m(Date.new(2026, 1, 7), 84)]
    result = MovingAverage.new(ms).at(Date.new(2026, 1, 7))

    assert_not result.enough?
    assert_equal 1, result.count
  end

  test "measurements outside the trailing window are excluded" do
    on = Date.new(2026, 1, 10) # window Jan 4..10
    ms = [m(Date.new(2026, 1, 1), 80), m(Date.new(2026, 1, 2), 81), m(Date.new(2026, 1, 3), 82)]
    result = MovingAverage.new(ms).at(on)

    assert_not result.enough?
    assert_equal 0, result.count
  end
end
