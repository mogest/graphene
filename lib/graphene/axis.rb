module Graphene
  class Axis
    include Renderable

    attr_accessor :min, :max, :line_thickness
    attr_accessor :ticks, :tick_colour, :tick_opacity, :tick_thickness
    attr_writer :label, :value_labels, :grid_ticks
    attr_reader :chart, :type

    def initialize(chart, type)
      @chart = chart
      @value_labels = ValueLabels.new(self)

      @tick_colour = "#000099"
      @tick_opacity = 1
      @tick_thickness = 1

      @line_thickness = 2
      @type = type
    end

    def label
      @axis_label ||= AxisLabel.new(self)
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
        next if @type != :x && @type != view.axis
        watermark = view.push_watermark(watermark, @type, :<)
      end
      watermark
    end

    def calculated_max
      return max if max

      watermark = nil
      chart.views.each do |view|
        next if @type != :x && @type != view.axis
        watermark = view.push_watermark(watermark, @type, :>)
      end
      watermark
    end

    def layout(point_mapper)
      Renderer.new(self, point_mapper)
    end

    class Renderer
      include Positioned

      def initialize(axis, point_mapper)
        @axis = axis
        @point_mapper = point_mapper
        @layout_position = point_mapper.axis_positions[axis.type]
      end

      def renderable_object
        @axis
      end

      def preferred_width;  nil; end
      def preferred_height; nil; end

      def render(canvas, left, top, width, height)
        if @axis.type == :x
          offset = @point_mapper.value_to_point(:y, 0, width, height)
        else
          offset = case @layout_position
          when :bottom then height
          when :right then width
          else 0
          end
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

          canvas.path(instructions, :stroke => @axis.tick_colour, "stroke-opacity" => @axis.tick_opacity, "stroke-width" => @axis.tick_thickness, :class => "ticks")
        end

        opts = {:stroke_colour => "black", :class => "axis #{@axis.type}-axis", :stroke_width => @axis.line_thickness}
        if vertical?
          canvas.line(left + offset, top, left + offset, top + height, opts)
        else
          canvas.line(left, top + offset, left + width, top + offset, opts)
        end
      end
    end
  end
end
