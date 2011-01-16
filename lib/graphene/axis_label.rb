module Graphene
  class AxisLabel
    include Renderable

    attr_accessor :name, :font_size, :axis, :align_with_axis, :rotation

    def initialize(axis)
      @axis = axis
      @font_size = 16
      @align_with_axis = true
    end

    def layout(point_mapper, position = nil)
      Renderer.new(self, point_mapper, position)
    end

    class Renderer
      include Positioned

      def initialize(label, point_mapper, position)
        @label = label
        @point_mapper = point_mapper
        @layout_position = position || point_mapper.axis_positions[@label.axis.type]
        @rotation = @label.rotation || (@label.align_with_axis ^ horizontal? ? 270 : 0)
        @rotation_radians = @rotation * Math::PI / 180
      end

      def renderable_object
        @label
      end

      def preferred_width
        estimated_length(Math.cos(@rotation_radians)) if vertical?
      end

      def preferred_height
        estimated_length(Math.sin(@rotation_radians)) if horizontal?
      end

      def estimated_length(multiplier)
        @label.font_size * [multiplier * @label.name.to_s.length / 1.7, 1].max
      end

      def render(canvas, left, top, width, height)
        return unless @label.name
        canvas.box(left, top, width, height, :fill => "#000000", "fill-opacity" => 0.2, :stroke => "red")

        opts = {:class => "axis-label", :font_size => @label.font_size}

        if false&& vertical?
          top += (height - @label.font_size) / 2
        else
#          left += width / 2
#          opts[:text_anchor] = "middle"
        end
#        top += height / 2

        if false&& @layout_position == :left
          opts[:text_anchor] = "end"
          # Insert a small bit of padding here so it's not hard up against
          # the Y axis.
          left += width - @label.font_size / 2
        end

        top += height/2
        left += @label.font_size

        puts "rotation = #{@rotation}"
        canvas.box(left-2,top-2,4,4,:fill => "blue")
#        opts[:transform] = "rotate(#{@rotation} #{left} #{top})" unless @rotation == 0

        canvas.text(left, top, @label.name, opts)
      end
    end
  end
end
