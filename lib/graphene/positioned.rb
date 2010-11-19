module Graphene
  module Positioned
    def orientation
      [:left, :right].include?(@layout_position) ? :vertical : :horizontal
    end

    def horizontal?
      orientation == :horizontal
    end

    def vertical?
      orientation == :vertical
    end
  end
end
