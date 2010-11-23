module Graphene
  class Chart
    attr_accessor :x_axis, :y_axis, :grid, :width, :height
    attr_writer :y2_axis, :legend, :heading
    attr_reader :views

    def initialize
      @x_axis = Axis.new(self, :x)
      @y_axis = Axis.new(self, :y)
      @grid = Grid.new(self)
      @views = []
      @width = 640
      @height = 480
    end

    def heading
      @heading ||= Text.new
    end

    def name=(value)
      heading.text = value
    end

    def y2_axis
      @y2_axis ||= Axis.new(self, :y2)
    end

    def legend
      @legend ||= Legend.new(self)
    end

    def plot(dataset, options = {})
      Views::Line.new(dataset).tap do |line|
        options.each {|k, v| line.send(k, v)}
        @views << line
        yield line if block_given?
      end
    end

    def histogram(dataset, step, options = {})
      Views::Histogram.new(dataset, step).tap do |histogram|
        options.each {|k, v| histogram.send(k, v)}
        @views << histogram
      end
    end

    def bar(dataset, options = {})
      Views::Bar.new(dataset).tap do |bar|
        options.each {|k, v| bar.send(k, v)}
        @views << bar
      end
    end

    def layout(point_mapper)
      if views.empty?
        raise LayoutError, "Cannot layout Chart before at least one plot/histogram/bar has been specified"
      end

      box = internal_layout(point_mapper)
      box = Ybox.new(@legend.layout, box) if @legend
      box = Ybox.new(@heading.layout, box) if @heading
      box
    end

    def internal_layout(point_mapper)
      box = layout_plot_area(point_mapper)
      box = layout_value_labels(box, point_mapper)
      layout_axis_labels(box, point_mapper)
    end

    def layout_plot_area(point_mapper)
      elements = [
        @grid.layout(point_mapper),
        @x_axis.layout(point_mapper),
        @y_axis.layout(point_mapper)
      ]

      elements << @y2_axis.layout(point_mapper) if @y2_axis

      elements.concat(views.collect {|c| c.layout(point_mapper)})

      Zbox.new(*elements)
    end

    def layout_value_labels(box, point_mapper)
      if @x_axis.value_labels.formatter
        x_value_labels_layout = @x_axis.value_labels.layout(point_mapper, :bottom)
      end

      if @y_axis.value_labels.formatter
        y_value_labels_layout = @y_axis.value_labels.layout(point_mapper, :left)
      end

      GridBox.new(
          [y_value_labels_layout, box                  ],
          [nil,                   x_value_labels_layout])
    end

    def layout_axis_labels(box, point_mapper)
      box = Ybox.new(box, @x_axis.label.layout(point_mapper))
      box = Xbox.new(@y_axis.label.layout(point_mapper), box)
      box
    end

    def render_with_canvas(canvas)
      point_mapper = PointMapper.new(*axis_positions)
      point_mapper.charts << self

      layout(point_mapper).render(canvas, 0, 0, @width, @height)
      canvas
    end

    def axis_positions
      [:bottom, :left]
    end

    def to_svg
      render_with_canvas(Canvases::Svg.new(self)).output
    end
  end
end
