module Graphene
  class Axis
    include Renderable

    attr_accessor :min, :max, :ticks, :layout_position, :line_thickness, :at_value
    attr_writer :label, :value_labels, :grid_ticks
    attr_reader :chart, :type

    def initialize(chart, type)
      @chart = chart
      @value_labels = ValueLabels.new(self)
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

    def grid_ticks
      @grid_ticks || @ticks
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
      Renderer.new(self, point_mapper, @layout_position || default_position)
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

        ticks = @axis.ticks

        if ticks && ticks > 1
          instructions = []

          if vertical?
            tick_space = height / BigDecimal.new((ticks - 1).to_s)
            ticks.times do |tick|
              y = top + tick * tick_space
              instructions << [:move, left + offset - 4, y]
              instructions << [:lineto, left + offset + 4, y]
            end
          else
            tick_space = width / BigDecimal.new((ticks - 1).to_s)
            ticks.times do |tick|
              x = left + tick * tick_space
              instructions << [:move, x, top + offset - 4]
              instructions << [:lineto, x, top + offset + 4]
            end
          end

          canvas.path(instructions, :stroke => "#000099")
        end

        if vertical?
          canvas.line(left + offset, top, left + offset, top + height, :stroke_colour => "black", :class => "axis", :stroke_width => @axis.line_thickness)
        else
          canvas.line(left, top + offset, left + width, top + offset, :stroke_colour => "black", :class => "axis", :stroke_width => @axis.line_thickness)
        end
      end
    end
  end
end
