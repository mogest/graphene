module Graphene
  class HorizontalChart < Chart
    def layout_value_labels(box, point_mapper)
      if @x_axis.value_labels.formatter
        x_value_labels_layout = @x_axis.value_labels.layout(point_mapper, :left)
      end

      if @y_axis.value_labels.formatter
        y_value_labels_layout = @y_axis.value_labels.layout(point_mapper, :top)
      end

      GridBox.new(
          [nil,                   y_value_labels_layout],
          [x_value_labels_layout, box                  ])
    end

    def layout_axis_labels(box, point_mapper)
      box = Ybox.new(@y_axis.label.layout(point_mapper), box)
      box = Xbox.new(@x_axis.label.layout(point_mapper), box)
      box
    end

    def axis_positions
      [:left, :top]
    end
  end
end
