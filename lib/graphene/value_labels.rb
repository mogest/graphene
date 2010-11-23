module Graphene
  class ValueLabels
    include Renderable

    attr_accessor :layout_position, :formatter
    attr_reader :axis

    def initialize(axis)
      @axis = axis
    end

    def layout(point_mapper, position)
      Renderer.new(self, point_mapper, @layout_position || position)
    end

    class Renderer
      include Positioned

      def initialize(value_labels, point_mapper, layout_position)
        @value_labels = value_labels
        @point_mapper = point_mapper
        @layout_position = layout_position
      end

      def renderable_object
        @value_labels
      end

      def preferred_width
        40 if vertical?
      end

      def preferred_height
        20 if horizontal?
      end

      def render(canvas, left, top, width, height)
        return if @value_labels.formatter.nil?

        if @value_labels.formatter.respond_to?(:call)
          formatter_proc = @value_labels.formatter
        else
          formatter_string = @value_labels.formatter
        end

        ticks = @value_labels.axis.ticks
        return unless ticks && ticks > 1

        if vertical?
          tick_space = height / BigDecimal.new((ticks - 1).to_s)
          ticks.times do |tick|
            y = top + tick * tick_space

            value = @point_mapper.y_point_to_value(y - top, height)
            value = if formatter_proc
              formatter_proc.call(value)
            else
              formatter_string % value
            end

            canvas.text(left + width - 5, y, value, :text_anchor => "end", :alignment_baseline => "middle")
          end
        else
          tick_space = width / BigDecimal.new((ticks - 1).to_s)
          ticks.times do |tick|
            x = left + tick * tick_space

            value = @point_mapper.x_point_to_value(x - left, width)
            value = if formatter_proc
              formatter_proc.call(value)
            else
              formatter_string % value
            end

            canvas.text(x, top + height, value, :text_anchor => "middle")
          end
        end
      end
    end
  end
end
