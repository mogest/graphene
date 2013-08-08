module Graphene
  class Legend
    include Renderable

    attr_accessor :line_padding, :font_size, :box_colour, :width

    alias :box_color  :box_colour
    alias :box_color= :box_colour=

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
      width
    end

    def preferred_height
      @chart.views.length * (@font_size + @line_padding)
    end

    def render(canvas, left, top, width, height)
      line_height = @font_size + @line_padding

      @chart.views.reject {|view| view.respond_to?(:include_in_legend?) && !view.include_in_legend?}.each_with_index do |content, index|
        line_top = top + index * line_height
        canvas.box left, line_top, @font_size, @font_size, :stroke => content.stroke_colour, :fill => content.fill_colour || content.stroke_colour, :class => "legend"
        canvas.text left + @font_size * 1.5, line_top + @font_size * 0.9, content.name, :font_size => @font_size, :class => "legend"
      end
    end
  end
end
