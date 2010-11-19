module Graphene
  class Grid
    include Renderable

    def initialize(chart)
      @chart = chart
      @stroke_colour = "#dddddd"
    end

    def layout
      self
    end

    # Expand to take available space
    def preferred_width;  nil; end
    def preferred_height; nil; end

    def render(canvas, left, top, width, height)
      canvas.box(left, top, width, 0.5, :class => "grid", :stroke_colour => @stroke_colour)
      canvas.box(left+25, top, 0.5, height, :class => "grid", :stroke_colour => @stroke_colour)
      canvas.box(left+50, top, 0.5, height, :class => "grid", :stroke_colour => @stroke_colour)
      canvas.box(left, top+25, width, 0.5, :class => "grid", :stroke_colour => @stroke_colour)
      canvas.box(left, top+50, width, 0.5, :class => "grid", :stroke_colour => @stroke_colour)
    end
  end
end
