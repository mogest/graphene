module Graphene
  class Grid
    include Renderable

    attr_accessor :colour, :opacity, :thickness, :fill_colour, :fill_opacity

    def initialize(chart)
      @chart = chart
      @colour = "#dddddd"
      @opacity = 1
      @thickness = 1
      @fill_opacity = 1
    end

    def layout(point_mapper)
      @point_mapper = point_mapper
      self
    end

    # Expand to take available space
    def preferred_width;  nil; end
    def preferred_height; nil; end

    def render(canvas, left, top, width, height)
      x_ticks = @chart.x_axis.grid_ticks
      y_ticks = @chart.y_axis.grid_ticks

      if @fill_colour
        canvas.box(left, top, width, height, :fill => @fill_colour, "fill-opacity" => @fill_opacity)
      end

      instructions = []

      [[:x, x_ticks], [:y, y_ticks]].select {|a,b| b && b > 0}.each do |axis, ticks|
        if (axis == :x) == @point_mapper.horizontal?
          dy = height / BigDecimal.new((ticks - 1).to_s)
          ticks.times do |cy|
            y = top + cy * dy
            instructions << [:move, left, y]
            instructions << [:lineto, left + width, y]
          end
        else
          dx = width / BigDecimal.new((ticks - 1).to_s)
          ticks.times do |cx|
            x = left + cx * dx
            instructions << [:move, x, top]
            instructions << [:lineto, x, top + height]
          end
        end
      end

      if instructions.any?
        canvas.path(instructions, :stroke => @colour, "stroke-opacity" => @opacity, "stroke-thickness" => @thickness)
      end
    end
  end
end
