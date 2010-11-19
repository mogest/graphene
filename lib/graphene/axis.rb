module Graphene
  class Axis
    include Renderable

    attr_accessor :min, :max, :ticks, :layout_position, :line_thickness, :at_value
    attr_writer :label, :value_labels
    attr_reader :chart, :type

    def initialize(chart, type)
      @chart = chart
      @value_labels = ValueLabels.new
      @line_thickness = 2
      @type = type
      @at_value = 0 if type == :x
    end

    def label
      @axis_label ||= AxisLabel.new
    end

    def name=(value)
      label.name = value
    end

    def value_labels(*args, &block)
      @value_labels.formatter = block || args.first if args.any? || block
      @value_labels
    end

    def calculated_min
      return min if min

      watermark = nil
      chart.views.each do |view|
        view.dataset.each do |x, y|
          value = @type == :x ? x : y
          if watermark.nil? || value < watermark
            watermark = value
          end
        end
      end
      watermark
    end

    def calculated_max
      return max if max

      watermark = nil
      chart.views.each do |view|
        view.dataset.each do |x, y|
          value = @type == :x ? x : y
          if watermark.nil? || value > watermark
            watermark = value
          end
        end
      end
      watermark
    end

    def layout(point_mapper, default_position)
      position = @layout_position || default_position

      Zbox.new(Renderer.new(self, point_mapper, position), @value_labels.layout(position))
    end

    class Renderer
      include Positioned

      def initialize(axis, point_mapper, layout_position)
        @axis = axis
        @point_mapper = point_mapper
        @layout_position = layout_position
      end

      def renderable_object
        @axis
      end

      def preferred_width;  nil; end
      def preferred_height; nil; end

      def render(canvas, left, top, width, height)
        offset = if @axis.at_value
          @point_mapper.y_value_to_point(@axis.at_value, height)
        else
          0
        end
        puts "height = #{height}, offset = #{offset}"

        offset -= @axis.line_thickness / 2

        if vertical?
          canvas.box(left + offset, top, @axis.line_thickness, height, :class => "axis")
        else
          canvas.box(left, top + offset, width, @axis.line_thickness, :class => "axis")
        end
      end
    end
  end
end
