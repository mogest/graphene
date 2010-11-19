module Graphene
  class PointMapper
    attr_reader :charts

    def initialize
      @charts = []
    end

    def x_value_to_point(x_value, width)
      calculate
      (x_value.to_f - @calculated_x_min.to_f) * width / @calculated_x_range
    end

    def x_point_to_value(x_point, width)
      calculate
      @calculated_x_min + x_point * @calculated_x_range / width
    end

    def y_value_to_point(y_value, height)
      calculate
      height - ((y_value - @calculated_y_min) * height / @calculated_y_range)
    end

    def y_point_to_value(y_point, height)
      calculate
      @calculated_y_min + (height - y_point) * @calculated_y_range / height
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
