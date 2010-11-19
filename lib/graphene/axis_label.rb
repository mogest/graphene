module Graphene
  class AxisLabel
    include Renderable

    attr_accessor :name, :font_size

    def initialize
      @font_size = 16
    end

    def layout(position)
      Renderer.new(self, position)
    end

    class Renderer
      include Positioned

      def initialize(label, position)
        @label = label
        @layout_position = position
      end

      def renderable_object
        @label
      end

      def preferred_width
        @label.font_size * (@label.name || "").length / 1.5 if vertical?
      end

      def preferred_height
        @label.font_size if horizontal?
      end

      def render(canvas, left, top, width, height)
        return unless @label.name

        case @layout_position
        when :bottom
          top += 20
        when :left, :right
          top += (height - @label.font_size) / 2
        end

        opts = {:class => "axis-label", :font_size => @label.font_size}
        if vertical?
          opts[:height] = height
        else
          opts[:width] = width
        end

        canvas.text(left, top + @label.font_size, @label.name, opts)
      end
    end
  end
end
