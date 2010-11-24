module Graphene
  class PointMapper
    attr_reader :charts, :axis_positions, :orientations

    POSITIONS = [:left, :top, :right, :bottom]
    ORIENTATION = {:left => :horizontal, :right => :horizontal, :top => :vertical, :bottom => :vertical}
    OPPOSITES = {:left => :right, :right => :left, :top => :bottom, :bottom => :top}

    def initialize(x_axis_position, y_axis_position)
      raise ArgumentError, "invalid x axis position" unless POSITIONS.include?(x_axis_position)
      raise ArgumentError, "invalid y axis position" unless POSITIONS.include?(y_axis_position)

      @axis_positions = {:x => x_axis_position, :y => y_axis_position, :y2 => OPPOSITES[y_axis_position]}
      @orientations   = {}
      @axis_positions.each {|axis, position| @orientations[axis] = ORIENTATION[position]}

      @horizontal = @orientations[:x] == :horizontal

      raise ArgumentError, "axes must intersect" if @orientations[:x] == @orientations[:y]

      @invert = {
        :x => [:right, :bottom].include?(y_axis_position),
        :y => [:right, :bottom].include?(x_axis_position)}

      @invert[:y2] = @invert[:y]

      @charts = []
    end

    def horizontal?
      @horizontal
    end

    def point_to_value(type, point, width, height)
      calculate
      length = @orientations[type] == :horizontal ? height : width
      point = length - point if @invert[type]
      @calculated_min[type] + point * @calculated_range[type] / length
    end

    def value_to_point(type, value, width, height)
      calculate

      if type == :x
        value = value.to_f
        min = @calculated_min[type].to_f
      else
        min = @calculated_min[type]
      end

      length = @orientations[type] == :horizontal ? height : width
      point = (value - min) * length / @calculated_range[type]
      @invert[type] ? length - point : point
    end

    def values_to_coordinates(y_axis, x_value, y_value, width, height)
      x_point = value_to_point(:x, x_value, width, height)
      y_point = value_to_point(y_axis, y_value, width, height)
      @orientations[:x] == :horizontal ? [y_point, x_point] : [x_point, y_point]
    end

    protected
    def calculate
      return if @calculated
      @calculated = true

      @calculated_min = {
        :x => charts.collect {|chart| chart.x_axis.calculated_min}.compact.min,
        :y => charts.collect {|chart| chart.y_axis.calculated_min}.compact.min}

      @calculated_max = {
        :x => charts.collect {|chart| chart.x_axis.calculated_max}.compact.max,
        :y => charts.collect {|chart| chart.y_axis.calculated_max}.compact.max}

      if charts.any? {|chart| chart.y2_axis_presence}
        @calculated_min[:y2] = charts.collect {|chart| chart.y2_axis.calculated_min}.compact.min
        @calculated_max[:y2] = charts.collect {|chart| chart.y2_axis.calculated_max}.compact.max
      end

      @calculated_range = {}
      @calculated_min.keys.each do |axis|
        @calculated_range[axis] = @calculated_max[axis] - @calculated_min[axis]
      end
    end
  end
end
