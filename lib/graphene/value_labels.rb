module Graphene
  class ValueLabels
    include Renderable

    attr_accessor :layout_position, :formatter, :font_size, :color, :text_anchor, :font_weight, :horizontal_offset, :vertical_offset
    attr_reader :axis
    
    attr_accessor :preferred_width

    alias :colour  :color
    alias :colour= :color=

    def initialize(axis)
      @axis = axis
      @font_size = 14
      @font_weight = 'normal'
      @color = "000000"
      @preferred_width = nil
      @text_anchor = 'middle'
      @horizontal_offset = 0     # -ve to offset right and +ve to offset left
      @vertical_offset    = 0    # -ve to offset up and +ve to offset down
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
        (@value_labels.preferred_width ? @value_labels.preferred_width :  @value_labels.font_size * formatted_value(@value_labels.axis.calculated_max).to_s.length) if vertical?
      end

      def preferred_height
        @value_labels.font_size if horizontal?
      end
      
      def text_anchor
        @value_labels.text_anchor
      end

      def render(canvas, left, top, width, height)
        return if @value_labels.formatter.nil?

        if @value_labels.formatter.respond_to?(:call)
          formatter_proc = @value_labels.formatter
        else
          formatter_string = @value_labels.formatter
        end

        @value_labels.axis.enum_ticks do |value|
          formatted = if formatter_proc
            x = formatter_proc.call(value)
            x && x.to_s
          else
            formatter_string % value
          end

          if formatted && !formatted.empty?
            position = @point_mapper.value_to_point(@value_labels.axis.type, value, width, height)

            if vertical?
              anchor = @layout_position == :left ? "end" : nil
              left_offset = anchor == "end" ? width - 5 : 5
              left_offset += @value_labels.horizontal_offset

              canvas.text(left + left_offset, top + position + @value_labels.vertical_offset, formatted, :text_anchor => anchor, :alignment_baseline => text_anchor, :font_size => @value_labels.font_size, :fill_colour => @value_labels.color)
            else
              top_offset = true ? @value_labels.font_size : 0
              top_offset += @value_labels.vertical_offset

              formatted.split("\n").each_with_index do |term, index|
                canvas.text(left + position + @value_labels.horizontal_offset, top + top_offset + preferred_height * index, term, :text_anchor => text_anchor, :font_size => @value_labels.font_size, :font_weight => @value_labels.font_weight, :fill_colour => @value_labels.color)
              end
            end
          end
        end
      end

      private
      def formatted_value(value)
        if @value_labels.formatter.respond_to?(:call)
          @value_labels.formatter.call(value)
        else
          @value_labels.formatter % value
        end
      end
    end
  end
end
