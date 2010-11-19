module Graphene
  class Text
    include Renderable

    attr_accessor :text, :font_size

    def initialize
      @text = ""
      @font_size = 48
      @padding_bottom = 16
    end

    def layout
      self
    end

    def preferred_width
      nil
    end

    def preferred_height
      @font_size
    end

    def render(canvas, left, top, width, height)
      canvas.text left, top + @font_size, text, :font_size => @font_size, :fill_colour => "#000000"
    end
  end
end
