module Graphene
  class Line
    include Renderable

    attr_reader :dataset
    attr_accessor :stroke_colour, :fill_colour, :name

    def initialize(dataset)
      @dataset = dataset
      @stroke_colour = "red"
      @name = "Dataset"
    end

    def layout(position)
      Renderer.new(self, position)
    end

    class Renderer
      def initialize(line, position)
        @line = line
        @position = position
      end

      def renderable_object
        @line
      end

      def preferred_width;  nil; end
      def preferred_height; nil; end

      def render(canvas, top, left, width, height)
        canvas.LINE_GRAPH_GOES_HERE(top,left,width,height)
      end
    end
  end
end
