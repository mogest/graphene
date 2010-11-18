module Graphene
  class Grid
    include Renderable

    def initialize(chart)
      @chart = chart
    end

    def layout
      self
    end

    # Expand to take available space
    def preferred_width;  nil; end
    def preferred_height; nil; end

    def render(canvas, top, left, width, height)
      canvas.GRID_GOES_HERE(top, left, width, height)
    end
  end
end
