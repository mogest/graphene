module Graphene
  class ValueLabels
    include Renderable

    attr_accessor :layout_position, :formatter, :font_size
    attr_reader :axis

    def initialize(axis)
      @axis = axis
      @font_size = 14
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
        @value_labels.font_size * 1.5 if horizontal?
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

            value = @point_mapper.point_to_value(@value_labels.axis.type, y - top, width, height)
            value = if formatter_proc
              formatter_proc.call(value)
            else
              formatter_string % value
            end

            anchor = @layout_position == :left ? "end" : nil
            left_offset = anchor == "end" ? width - 5 : 0

            canvas.text(left + left_offset, y, value, :text_anchor => anchor, :alignment_baseline => "middle", :font_size => @value_labels.font_size)
          end
        else
          tick_space = width / BigDecimal.new((ticks - 1).to_s)
          ticks.times do |tick|
            x = left + tick * tick_space

            value = @point_mapper.point_to_value(@value_labels.axis.type, x - left, width, height)
            value = if formatter_proc
              formatter_proc.call(value)
            else
              formatter_string % value
            end

            top_offset = true ? @value_labels.font_size : 0

            canvas.text(x, top + top_offset, value, :text_anchor => "middle", :font_size => @value_labels.font_size)
          end
        end
      end
    end
  end
end
