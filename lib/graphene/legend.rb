module Graphene
  class Legend
    include Renderable

    def initialize(chart)
      @chart = chart
      @line_padding = 8
      @font_size = 10
      @box_colour = "#000000"
    end

    def layout
      self
    end

    def preferred_width
      nil
    end

    def preferred_height
      @chart.contents.length * (@font_size + @line_padding)
    end

    def render(canvas, top, left, width, height)
      line_height = @font_size + @line_padding

      @chart.contents.each_with_index do |content, index|
        line_top = top + index * line_height
        canvas.filled_box left, line_top, @font_size, @font_size, @box_colour, content.fill_colour || content.stroke_colour
        canvas.text left + @font_size * 2, line_top, content.name, :font_size => @font_size
      end
    end
  end
end
