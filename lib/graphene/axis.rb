module Graphene
  class Axis
    include Renderable

    attr_accessor :min, :max, :line_thickness, :line_colour
    
    # number of ticks
    attr_accessor :ticks
    
    # spacing of ticks - would normally only need to set this OR \ticks
    attr_accessor :tick_spacing
    
    # position (in axis value units) of the first tick
    attr_accessor :tick_offset
    
    attr_accessor :tick_colour, :tick_opacity, :tick_thickness, :tick_length, :tick_position, :tick_values
    attr_writer :label, :value_labels, :grid_ticks
    attr_reader :chart, :type

    alias :tick_color  :tick_colour
    alias :tick_color= :tick_colour=
    alias :line_color  :line_colour
    alias :line_color= :line_colour=

    def initialize(chart, type)
      @chart = chart
      @value_labels = ValueLabels.new(self)

      @tick_offset = 0

      @tick_colour = "#000099"
      @tick_opacity = 1
      @tick_thickness = 1
      @tick_length = 4
      @tick_position = :center

      @line_colour = "black"
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
      watermark = 0 if @type != :x && (watermark.nil? || watermark > 0)
      watermark
    end

    def calculated_max
      return max if max

      watermark = nil
      chart.views.each do |view|
        next if @type != :x && @type != view.axis
        watermark = view.push_watermark(watermark, @type, :>)
      end
      watermark = 0 if @type != :x && (watermark.nil? || watermark < 0)
      watermark
    end

    def calculated_tick_spacing
      return tick_spacing if tick_spacing && tick_spacing > 0

      # range values could be integers, floats, decimals, rationals, dates, or times.  the difference
      # type, could therefore be integers, floats, decimals, or rationals, and we want to use the same
      # type for the spacing generally.  but we make a special case for discrete types: if the callers
      # had supplied integer values but the range does not divide evenly into the number of ticks, then
      # we need to use a decimal type to make the spacing work evenly.  there's no duck-typing
      # interface that can tell us whether the value type is discrete and so we have had to hard-code
      # the special case for those types.  note that some other conceptually discrete value types such
      # as dates have a non-discrete type (rational, in the case of dates) as the different type, and
      # so don't need such a workaround.
      calculated_range = calculated_max - calculated_min
      calculated_range = BigDecimal.new(calculated_range.to_s) if calculated_range.is_a?(Fixnum) || calculated_range.is_a?(Bignum)
      calculated_range/(ticks - 1) if ticks && ticks > 1
    end

    def enum_ticks
      if tick_values
        tick_values.each {|value| yield value}
      elsif spacing = calculated_tick_spacing
        value = calculated_min + tick_offset
        while value <= calculated_max
          yield value
          value += calculated_tick_spacing
          break if calculated_tick_spacing == 0   # prevent infinite loops
        end
      end
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

        if @axis.tick_length.respond_to?(:call)
          tick_length_proc = @axis.tick_length
        else
          tick_length_value = @axis.tick_length
        end

        instructions = []
        tick_position = @axis.tick_position
        if vertical?
          @axis.enum_ticks do |value|
            y = top + @point_mapper.value_to_point(:y, value, width, height)
            tick_length = tick_length_proc ? tick_length_proc.call(value) : tick_length_value

            left_offset = tick_position == :right ? 0 : -tick_length
            right_offset = tick_position == :left ? 0 : tick_length

            instructions << [:move,   left + offset + left_offset, y]
            instructions << [:lineto, left + offset + right_offset, y]
          end
        else
          @axis.enum_ticks do |value|
            x = left + @point_mapper.value_to_point(:x, value, width, height)
            tick_length = tick_length_proc ? tick_length_proc.call(value) : tick_length_value

            top_offset = tick_position == :bottom ? 0 : -tick_length
            bottom_offset = tick_position == :top ? 0 : tick_length

            instructions << [:move,   x, top + offset + top_offset]
            instructions << [:lineto, x, top + offset + bottom_offset]
          end
        end
        canvas.path(instructions, :stroke => @axis.tick_colour, "stroke-opacity" => @axis.tick_opacity, "stroke-width" => @axis.tick_thickness, :class => "ticks") unless instructions.empty?

        opts = {:stroke_colour => @axis.line_colour, :class => "axis #{@axis.type}-axis", :stroke_width => @axis.line_thickness}
        if vertical?
          canvas.line(left + offset, top, left + offset, top + height, opts)
        else
          canvas.line(left, top + offset, left + width, top + offset, opts)
        end
      end

      protected
      def formatted_value(value)
        if @axis.value_labels.formatter.respond_to?(:call)
          value = @axis.value_labels.formatter.call(value)
        else
          value = @axis.value_labels.formatter % value
        end
      end
    end
  end
end
