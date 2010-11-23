module Graphene
  class AxisLabel
    include Renderable

    attr_accessor :name, :font_size, :axis

    def initialize(axis)
      @axis = axis
      @font_size = 16
    end

    def layout(point_mapper, position = nil)
      Renderer.new(self, point_mapper, position)
    end

    class Renderer
      include Positioned

      def initialize(label, point_mapper, position)
        @label = label
        @point_mapper = point_mapper
        @layout_position = position || point_mapper.send("#{@label.axis.type}_axis_position")
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

        opts = {:class => "axis-label", :font_size => @label.font_size}

        if vertical?
          top += (height - @label.font_size) / 2
        else
          left += width / 2
          opts[:text_anchor] = "middle"
        end

        if @layout_position == :left
          opts[:text_anchor] = "end"
          # Insert a small bit of padding here so it's not hard up against
          # the Y axis.
          left += width - @label.font_size / 2
        end

        canvas.text(left, top + @label.font_size, @label.name, opts)
      end
    end
  end
end
