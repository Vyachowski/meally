# Computes SVG coordinates for the weight chart (E1.5): raw points + moving-average line.
# viewBox is fixed; the <svg> scales responsively via width:100%.
class WeightChart
  Point = Data.define(:x, :y, :value, :on)

  WIDTH = 320
  HEIGHT = 160
  PAD = 24

  def initialize(measurements)
    @measurements = measurements.sort_by(&:measured_on)
    @average = @measurements.filter_map do |m|
      avg = MovingAverage.new(@measurements).at(m.measured_on).average
      [m.measured_on, avg] if avg
    end
    compute_domain
  end

  def points?
    @measurements.any?
  end

  def raw_points
    @measurements.map { |m| point(m.measured_on, m.value) }
  end

  def average_points
    @average.map { |(on, value)| point(on, value) }
  end

  private

  def compute_domain
    return if @measurements.empty?

    dates = @measurements.map(&:measured_on)
    values = @measurements.map(&:value) + @average.map { |(_, v)| v }

    @date_min = dates.min
    @date_span = [(dates.max - @date_min).to_i, 1].max
    @value_min = values.min || 0
    value_max = values.max || 0
    @value_span = [(value_max - @value_min), 1].max
  end

  def point(on, value)
    x = PAD + ((on - @date_min).to_f / @date_span) * (WIDTH - 2 * PAD)
    y = PAD + ((@value_span - (value - @value_min)).to_f / @value_span) * (HEIGHT - 2 * PAD)
    Point.new(x: x.round(1), y: y.round(1), value: value, on: on)
  end
end
