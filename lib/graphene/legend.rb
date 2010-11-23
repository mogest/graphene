module Graphene
  class Legend
    include Renderable

    attr_accessor :line_padding, :font_size, :box_colour

    def initialize(chart)
      @chart = chart
      @line_padding = 8
      @font_size = 14
      @box_colour = "#000000"
    end

    def layout
      self
    end

    def preferred_width
      nil
    end

    def preferred_height
      @chart.views.length * (@font_size + @line_padding)
    end

    def render(canvas, left, top, width, height)
      line_height = @font_size + @line_padding

      @chart.views.each_with_index do |content, index|
        line_top = top + index * line_height
        canvas.box left, line_top, @font_size, @font_size * 1.2, :stroke => @box_colour, :fill => content.stroke_colour, :class => "legend"
        canvas.text left + @font_size * 1.5, line_top + @font_size, content.name, :font_size => @font_size, :class => "legend"
      end
    end
  end
end
