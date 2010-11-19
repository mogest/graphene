module Graphene
  class Grid
    include Renderable

    def initialize(chart)
      @chart = chart
      @stroke_colour = "#dddddd"
    end

    def layout(rotated)
      @rotated = rotated
      self
    end

    # Expand to take available space
    def preferred_width;  nil; end
    def preferred_height; nil; end

    def render(canvas, left, top, width, height)
      x_ticks = @chart.x_axis.grid_ticks
      y_ticks = @chart.y_axis.grid_ticks

      instructions = []

      [[:x, x_ticks], [:y, y_ticks]].select {|a,b| b && b > 0}.each do |axis, ticks|
        if (axis == :x) == !!@rotated
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
        canvas.path(instructions, :stroke => "#dddddd")
      end
    end
  end
end
