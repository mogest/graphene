module Graphene
  module Views
    class Line < Base
      attr_accessor :stroke_colour, :stroke_opacity, :fill_colour, :fill_opacity, :name, :marker
      attr_accessor :stroke_width
      attr_reader :axis

      def initialize(dataset)
        @dataset = dataset
        @stroke_colour = "red"
        @name = "Dataset"
        @marker = "x"
        @stroke_opacity = @fill_opacity = 1
        @stroke_width = 2
        @axis = :y
      end

      def axis=(value)
        raise ArgumentError, "axis must be either :y or :y2" unless [:y, :y2].include?(value)
        @axis = value
      end

      def opacity=(value)
        @stroke_opacity = @fill_opacity = value
      end

      def layout(point_mapper)
        Renderer.new(self, point_mapper)
      end

      class Renderer
        def initialize(line, point_mapper)
          @line = line
          @point_mapper = point_mapper
        end

        def renderable_object
          @line
        end

        def preferred_width;  nil; end
        def preferred_height; nil; end

        def render(canvas, left, top, width, height)
          sorted = @line.dataset.to_a.sort_by(&:first)

          instructions = []
          sorted.each_with_index do |(x_value, y_value), index|
            left_offset, top_offset = @point_mapper.values_to_coordinates(@line.axis, x_value, y_value, width, height)

            left_offset += left
            top_offset += top

            canvas.marker(left_offset, top_offset, @line.marker, :class => "marker")

            instructions << [instructions.empty? ? :move : :lineto, left_offset, top_offset]
          end

          canvas.path(instructions, :stroke => @line.stroke_colour, :fill => "none", "stroke-opacity" => @line.stroke_opacity, "stroke-width" => @line.stroke_width)

          if @line.fill_colour
            x_value, y_value = sorted.last
            left_offset, top_offset = @point_mapper.values_to_coordinates(@line.axis, x_value, 0, width, height)
            instructions << [:lineto, left + left_offset, top + top_offset]

            x_value, y_value = sorted.first
            left_offset, top_offset = @point_mapper.values_to_coordinates(@line.axis, x_value, 0, width, height)
            instructions << [:lineto, left + left_offset, top + top_offset]

            canvas.path(instructions, :stroke => "none", :fill => @line.fill_colour, "fill-opacity" => @line.fill_opacity)
          end
        end
      end
    end
  end
end
