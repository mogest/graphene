module Graphene
  module Views
    class Line < Base
      attr_accessor :stroke_colour, :fill_colour, :name, :marker

      def initialize(dataset)
        @dataset = dataset
        @stroke_colour = "red"
        @name = "Dataset"
        @marker = "x"
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
          last_x, last_y = nil

          sorted.each_with_index do |(x_value, y_value), index|
            x = left + @point_mapper.x_value_to_point(x_value, width)
            y = top + @point_mapper.y_value_to_point(y_value, height)

            canvas.marker(x, y, @line.marker, :class => "marker")

            if last_x
              canvas.line(last_x, last_y, x, y, :stroke_colour => "#999999")
            end

            last_x, last_y = x, y
          end
        end
      end
    end
  end
end
