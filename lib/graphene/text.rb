module Graphene
  class Text
    include Renderable

    attr_accessor :text, :font_size, :text_align, :color

    def initialize
      @text = ""
      @font_size = 48
      @padding_bottom = 16
      @text_align = :center
      @color = "#000000"
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
      opts = {:font_size => @font_size, :fill_colour => @color}

      case @text_align.to_s
      when 'center'
        left += width / 2
        opts[:text_anchor] = "middle"
      when 'right'
        left += width
        opts[:text_anchor] = "end"
      end

      canvas.text left, top + @font_size, text, opts
    end
  end
end
