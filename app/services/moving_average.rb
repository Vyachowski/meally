# Trailing N-day moving average over a collection of measurements.
# Each measurement must respond to #measured_on (Date) and #value (Numeric).
# Fewer than `min_points` in the window is treated as "not enough data" (E1.4.2).
class MovingAverage
  WINDOW_DAYS = 7
  MIN_POINTS = 3

  Result = Data.define(:average, :count) do
    def enough?
      !average.nil?
    end
  end

  def initialize(measurements, window_days: WINDOW_DAYS, min_points: MIN_POINTS)
    @measurements = measurements
    @window_days = window_days
    @min_points = min_points
  end

  # Average of measurements falling in (on - window + 1 .. on), inclusive.
  def at(on = Date.current)
    window = (on - (@window_days - 1))..on
    values = @measurements.filter_map { |m| m.value if window.cover?(m.measured_on) }

    return Result.new(average: nil, count: values.size) if values.size < @min_points

    Result.new(average: values.sum / values.size, count: values.size)
  end
end
