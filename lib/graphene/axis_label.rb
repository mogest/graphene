module Graphene
  class AxisLabel
    include Renderable

    attr_accessor :name, :font_size, :axis, :align_with_axis, :rotation, :font_weight

    def initialize(axis)
      @axis = axis
      @font_size = 16
      @font_weight = 'normal'
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
        @label.font_size * [multiplier * @label.name.to_s.length / 1.7, 1.2].max
      end

      def render(canvas, left, top, width, height)
        return unless @label.name
        # canvas.box(left, top, width, height, :fill => "#000000", "fill-opacity" => 0.2, :stroke => "red")

        opts = {:class => "axis-label", :font_size => @label.font_size, :font_weight => @label.font_weight}

        case @layout_position
        when :bottom
          left += width/2
          top  += height/1.2
          
        when :top
          left += width/2
          
        when :left
          left += @label.font_size
          top  += height/2
          
        when :right
          left += @label.font_size
          top  += height/2
        end

        # canvas.box(left-2,top-2,4,4,:fill => "blue")
        opts[:transform] = "rotate(#{@rotation} #{left} #{top})" unless @rotation == 0
        opts[:text_anchor] = "middle"
        
        canvas.text(left, top, @label.name, opts)
      end
    end
  end
end
