module Graphene
  class ValueLabels
    include Renderable

    attr_accessor :layout_position

    def initialize
    end

    def layout(position)
      Renderer.new(self, @layout_position || position)
    end

    class Renderer
      def initialize(value_labels, layout_position)
        @value_labels = value_labels
        @layout_position = layout_position
      end

      def renderable_object
        @value_labels
      end

      def preferred_width
        20 if [:left, :right].include?(@layout_position)
      end

      def preferred_height
        20 if [:top, :bottom].include?(@layout_position)
      end

      def render(canvas, top, left, width, height)
        canvas.VALUE_LABELS_GO_HERE(@layout_position, top, left, width, height)
      end
    end
  end
end
