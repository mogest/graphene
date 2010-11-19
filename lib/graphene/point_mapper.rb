module Graphene
  class PointMapper
    attr_reader :charts

    def initialize
      @charts = []
    end

    def x_value_to_point(x_value, width)
      calculate
      (x_value.to_f - @calculated_x_min) * width / @calculated_x_range
    end

    def y_value_to_point(y_value, height)
      calculate
      height - ((y_value - @calculated_y_min) * height / @calculated_y_range)
    end

    protected
    def calculate
      return if @calculated
      @calculated = true

      @calculated_x_min = charts.collect {|chart| chart.x_axis.calculated_min}.compact.min.to_f
      @calculated_x_max = charts.collect {|chart| chart.x_axis.calculated_max}.compact.max.to_f
      @calculated_x_range = (@calculated_x_max || 0) - (@calculated_x_min || 0)

      @calculated_y_min = charts.collect {|chart| chart.y_axis.calculated_min}.compact.min
      @calculated_y_max = charts.collect {|chart| chart.y_axis.calculated_max}.compact.max
      @calculated_y_range = (@calculated_y_max || 0) - (@calculated_y_min || 0)
    end
  end
end
