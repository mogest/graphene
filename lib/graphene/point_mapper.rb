module Graphene
  class PointMapper
    attr_reader :charts, :x_axis_position, :y_axis_position, :x_orientation, :y_orientation

    POSITIONS = [:left, :top, :right, :bottom]
    ORIENTATION = {:left => :horizontal, :right => :horizontal, :top => :vertical, :bottom => :vertical}
    OPPOSITES = {:left => :right, :right => :left, :top => :bottom, :bottom => :top}

    def initialize(x_axis_position, y_axis_position)
      raise ArgumentError, "invalid x axis position" unless POSITIONS.include?(x_axis_position)
      raise ArgumentError, "invalid y axis position" unless POSITIONS.include?(y_axis_position)

      @x_axis_position = x_axis_position
      @y_axis_position = y_axis_position

      @x_orientation = ORIENTATION[x_axis_position]
      @y_orientation = ORIENTATION[y_axis_position]

      @horizontal = @x_orientation == :horizontal

      raise ArgumentError, "axes must intersect" if @x_orientation == @y_orientation

      @invert_x = [:right, :bottom].include?(y_axis_position)
      @invert_y = [:right, :bottom].include?(x_axis_position)

      @charts = []
    end

    def horizontal?
      @horizontal
    end

    def y2_axis_position
      OPPOSITES[y_axis_position]
    end

    def y2_orientation
      y_orientation
    end

    def point_to_value(type, point, width, height)
      method = {:x => :x_point_to_value, :y => :y_point_to_value}
      send(method[type], point, width, height)
    end

    def value_to_point(type, value, width, height)
      method = {:x => :x_value_to_point, :y => :y_value_to_point}
      send(method[type], value, width, height)
    end

    def values_to_coordinates(x_value, y_value, width, height)
      x_point = x_value_to_point(x_value, width, height)
      y_point = y_value_to_point(y_value, width, height)
      x_orientation == :horizontal ? [y_point, x_point] : [x_point, y_point]
    end

    def x_value_to_point(x_value, width, height)
      length = @horizontal ? height : width
      calculate
      point = (x_value.to_f - @calculated_x_min.to_f) * length / @calculated_x_range
      @invert_x ? length - point : point
    end

    def x_point_to_value(x_point, width, height)
      length = @horizontal ? height : width
      calculate
      x_point = length - x_point if @invert_x
      @calculated_x_min + x_point * @calculated_x_range / length
    end

    def y_value_to_point(y_value, width, height)
      length = @horizontal ? width : height
      calculate
      point = (y_value - @calculated_y_min) * length / @calculated_y_range
      @invert_y ? length - point : point
    end

    def y_point_to_value(y_point, width, height)
      length = @horizontal ? width : height
      calculate
      y_point = length - y_point if @invert_y
      @calculated_y_min + y_point * @calculated_y_range / length
    end

    protected
    def calculate
      return if @calculated
      @calculated = true

      @calculated_x_min = charts.collect {|chart| chart.x_axis.calculated_min}.compact.min
      @calculated_x_max = charts.collect {|chart| chart.x_axis.calculated_max}.compact.max
      @calculated_x_range = (@calculated_x_max) - (@calculated_x_min)

      @calculated_y_min = charts.collect {|chart| chart.y_axis.calculated_min}.compact.min
      @calculated_y_max = charts.collect {|chart| chart.y_axis.calculated_max}.compact.max
      @calculated_y_range = (@calculated_y_max || 0) - (@calculated_y_min || 0)
    end
  end
end
