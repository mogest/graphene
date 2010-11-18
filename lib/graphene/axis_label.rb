module Graphene
  class AxisLabel
    include Renderable

    attr_accessor :name

    def initialize
    end

    def layout(default_rotation)
      Renderer.new(self, @rotation || default_rotation)
    end

    class Renderer
      def initialize(label, rotation)
        @label = label
        @rotation = rotation
      end

      def renderable_object
        @label
      end

      def preferred_width
        # TODO
      end

      def preferred_height
        # TODO
      end

      def render(canvas, top, left, width, height)
        return unless @label.name
        canvas.AXIS_LABEL_GOES_HERE(@label.name, @rotation, top, left, width, height)
      end
    end
  end
end
