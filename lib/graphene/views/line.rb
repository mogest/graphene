module Graphene
  module Views
    class Line < Base
      attr_accessor :stroke_colour, :stroke_opacity, :fill_colour, :fill_opacity, :name, :marker
      attr_accessor :stroke_width

      def initialize(dataset)
        @dataset = dataset
        @stroke_colour = "red"
        @name = "Dataset"
        @marker = "x"
        @stroke_opacity = @fill_opacity = 1
        @stroke_width = 2
      end

      def opacity=(value)
        @stroke_opacity = @fill_opacity = value
      end

      def layout(point_mapper, position)
        Renderer.new(self, point_mapper, position)
      end

      class Renderer
        def initialize(line, point_mapper, position)
          @line = line
          @point_mapper = point_mapper
          @position = position
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
            x = left + @point_mapper.x_value_to_point(x_value, width)
            y = top + @point_mapper.y_value_to_point(y_value, height)

            canvas.marker(x, y, @line.marker, :class => "marker")

            instructions << [instructions.empty? ? :move : :lineto, x, y]
          end

          canvas.path(instructions, :stroke => @line.stroke_colour, :fill => "none", "stroke-opacity" => @line.stroke_opacity, "stroke-width" => @line.stroke_width)

          if @line.fill_colour
            instructions << [:lineto, instructions.last[1], top + height]
            instructions << [:lineto, instructions.first[1], top + height]
            canvas.path(instructions, :stroke => "none", :fill => @line.fill_colour, "fill-opacity" => @line.fill_opacity)
          end
        end
      end
    end
  end
end
