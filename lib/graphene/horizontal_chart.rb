module Graphene
  class HorizontalChart < Chart
    def layout_value_labels(box, point_mapper)
      if @x_axis.value_labels.formatter
        x_value_labels_layout = @x_axis.value_labels.layout(point_mapper, :left)
      end

      if @y_axis.value_labels.formatter
        y_value_labels_layout = @y_axis.value_labels.layout(point_mapper, :top)
      end

      if @y2_axis && @y2_axis.value_labels.formatter
        y2_value_labels_layout = @y2_axis.value_labels.layout(point_mapper, :bottom)
      end

      GridBox.new(
          [nil,                   y_value_labels_layout ],
          [x_value_labels_layout, box                   ],
          [nil,                   y2_value_labels_layout])
    end

    def layout_axis_labels(box, point_mapper)
      box = Ybox.new(@y_axis.label.layout(point_mapper), box, @y2_axis && @y2_axis.label.layout(point_mapper))
      Xbox.new(@x_axis.label.layout(point_mapper), box)
    end

    def axis_positions
      [:left, :top]
    end
  end
end
