module Graphene
  class Axis
    include Renderable

    attr_accessor :min, :max, :ticks, :layout_position, :line_thickness
    attr_writer :label

    def initialize(chart)
      @chart = chart
      @value_labels = ValueLabels.new
      @line_thickness = 3
    end

    def label
      @axis_label ||= AxisLabel.new
    end

    def name=(value)
      label.name = value
    end

    def value_labels(*args, &block)
      if args.empty? && block.nil?
        @value_labels
      else
        @value_labels.label_maker = block
        @value_labels.label_format = args.first
      end
    end

    def layout(default_position)
      box = Zbox.new(Renderer.new(self, @layout_position || default_position), @value_labels.layout(default_position))

      if @axis_label
        box = case @layout_position || default_position
        when :left   then Xbox.new(@axis_label.layout(270), box)
        when :right  then Xbox.new(box, @axis_label.layout(90))
        when :top    then Ybox.new(@axis_label.layout(0), box)
        when :bottom then Ybox.new(box, @axis_label.layout(0))
        else raise ArgumentError, "Unknown layout position '#{default_position}'"
        end
      end

      box
    end

    class Renderer
      def initialize(axis, layout_position)
        @axis = axis
        @layout_position = layout_position
      end

      def renderable_object
        @axis
      end

      def preferred_width
        20 if [:left, :right].include?(@layout_position)
      end

      def preferred_height
        20 if [:top, :bottom].include?(@layout_position)
      end

      def render(canvas, top, left, width, height)
        canvas.AXIS_GOES_HERE(@layout_position, top, left, width, height)
      end
    end
  end
end
