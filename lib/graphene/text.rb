module Graphene
  class Text
    include Renderable

    attr_accessor :text, :font_size

    def initialize
      @text = ""
      @font_size = 24
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

    def render(canvas, top, left, width, height)
      canvas.text top, left, text, :font_size => @font_size
    end
  end
end
