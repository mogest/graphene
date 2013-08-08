module Graphene
  class VerticalStack
    attr_reader :charts, :width
    
    def initialize
      @charts = []
      @width = 640
    end
    
    def width=(width)
      @width = width
      charts.each {|chart| chart.width = width}
    end
    
    def height
      charts.sum {|chart| chart.height}
    end
    
    def chart(new_chart = Chart.new)
      new_chart.width = @width
      charts << new_chart
      yield new_chart if block_given?
      new_chart
    end

    def render_with_canvas(canvas)
      charts.inject(0) do |top, chart|
        chart.render_with_canvas(canvas, 0, top)
        top + chart.height
      end
      canvas
    end

    def to_svg
      render_with_canvas(Canvases::Svg.new(self)).output
    end
  end
end
