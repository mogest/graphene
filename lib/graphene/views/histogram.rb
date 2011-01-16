module Graphene
  module Views
    class Histogram < Base
      attr_reader :step, :start
      attr_accessor :stroke_colour, :stroke_opacity, :fill_colour, :fill_opacity, :marker
      attr_accessor :stroke_width

      def initialize(dataset, start, step)
        super()
        @dataset = dataset
        @start = start
        @step = step
        @stroke_colour = "purple"
        @fill_colour = "orange"
        @stroke_opacity = @fill_opacity = 1
        @stroke_width = 2
      end

      def push_watermark(watermark, type, comparitor)
        data = if type == :x
          [start, start + step * dataset.length]
        else
          dataset
        end

        data.each do |value|
          watermark = value if watermark.nil? || value.send(comparitor, watermark)
        end
        watermark
      end

      def layout(point_mapper)
        Renderer.new(self, point_mapper)
      end

      class Renderer
        def initialize(histogram, point_mapper)
          @histogram = histogram
          @point_mapper = point_mapper
        end

        def renderable_object
          @histogram
        end

        def preferred_width;  nil; end
        def preferred_height; nil; end

        def render(canvas, left, top, width, height)
          x1_value = @histogram.start
          @histogram.dataset.each_with_index do |y_value, index|
            x2_value = x1_value + @histogram.step

            left_offset, top_offset = @point_mapper.values_to_coordinates(@histogram.axis, x1_value, y_value < 0 ? 0 : y_value, width, height)
            right_offset, bottom_offset = @point_mapper.values_to_coordinates(@histogram.axis, x2_value, y_value < 0 ? y_value : 0, width, height)

            bar_width = right_offset - left_offset
            bar_height = bottom_offset - top_offset

            left_offset += left
            top_offset += top

            canvas.box(left_offset, top_offset, bar_width, bar_height,
              :stroke => @histogram.stroke_colour, :fill => @histogram.fill_colour, "fill-opacity" => @histogram.fill_opacity)

            x1_value = x2_value
          end
        end
      end

    end
  end
end
