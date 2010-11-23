module Graphene
  class HorizontalChart < Chart
    def layout_value_labels(box, point_mapper)
      if @x_axis.value_labels.formatter
        x_value_labels_layout = @x_axis.value_labels.layout(point_mapper, :left)
      end

      if @y_axis.value_labels.formatter
        y_value_labels_layout = @y_axis.value_labels.layout(point_mapper, :bottom)
      end

      GridBox.new(
          [x_value_labels_layout, box                  ],
          [nil,                   y_value_labels_layout])
    end

    def layout_axis_labels(box, point_mapper)
      box = Ybox.new(box, @y_axis.label.layout(point_mapper))
      box = Xbox.new(@x_axis.label.layout(point_mapper), box)
      box
    end

    def axis_positions
      [:left, :bottom]
    end
  end
end
