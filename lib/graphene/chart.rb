module Graphene
  class Chart
    include Graphene::Renderable::Padding

    attr_accessor :x_axis, :y_axis, :grid, :width, :height
    attr_writer :y2_axis, :legend, :heading
    attr_reader :views, :legend_position

    def initialize
      @x_axis = Axis.new(self, :x)
      @y_axis = Axis.new(self, :y)
      @grid = Grid.new(self)
      @views = []
      @width = 640
      @height = 480
      @legend_position = :top
      @styles = Style.new
    end

    def heading
      @heading ||= Text.new
    end

    def name=(value)
      heading.text = value
    end

    def style(*args)
      if args.empty?
        @styles.instance_eval(&Proc.new) if block_given?
        @styles
      else
        @styles.send(args.first, *args[1..-1])
      end
    end

    def y2_axis
      @y2_axis ||= Axis.new(self, :y2)
    end

    def y2_axis_presence
      @y2_axis
    end

    def legend
      @legend ||= Legend.new(self)
    end
    
    def legend_position=(value)
      legend # turn legends on
      @legend_position = value
    end

    def plot(dataset, options = {})
      line_options = {}
      line_options[:start] = options.delete(:start) if options.member?(:start)
      line_options[:step] = options.delete(:step) if options.member?(:step)

      Views::Line.new(dataset, line_options).tap do |line|
        options.each {|k, v| line.send("#{k}=", v)}
        @views << line
        yield line if block_given?
      end
    end

    def area(dataset, options = {})
      line_options = {}
      line_options[:start] = options.delete(:start) if options.member?(:start)
      line_options[:step] = options.delete(:step) if options.member?(:step)

      Views::Area.new(dataset, line_options).tap do |line|
        options.each {|k, v| line.send("#{k}=", v)}
        @views << line
        yield line if block_given?
      end
    end

    def histogram(dataset, start, step, options = {})
      Views::Histogram.new(dataset, start, step).tap do |histogram|
        options.each {|k, v| histogram.send("#{k}=", v)}
        @views << histogram
        yield histogram if block_given?
      end
    end

    def stacked_histogram(datasets, start, step, options = {})
      raise "datasets must be the same length!" unless datasets.all? {|dataset| dataset.length == datasets.first.length}
      last_dataset = nil
      datasets.each_with_index do |dataset, index|
        last_dataset = Views::Histogram.new(dataset, start, step, last_dataset).tap do |histogram|
          options.each do |k, v|
            v = v[index % v.size] if v.is_a?(Array)
            histogram.send("#{k}=", v)
          end
          @views << histogram
          yield histogram, index if block_given?
        end
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
      case @legend_position
      when :top    then box = Ybox.new(@legend.layout, box)
      when :bottom then box = Ybox.new(box, @legend.layout)
      when :left   then box = Xbox.new(@legend.layout, box)
      when :right  then box = Xbox.new(box, @legend.layout)
      end if @legend
      box = Ybox.new(@heading.layout, box) if @heading

      PaddedBox.new(box, @padding_left, @padding_top, @padding_right, @padding_bottom)
    end

    def internal_layout(point_mapper)
      box = layout_plot_area(point_mapper)
      box = layout_value_labels(box, point_mapper)
      layout_axis_labels(box, point_mapper)
    end

    def layout_plot_area(point_mapper)
      elements = [
        @grid.layout(point_mapper)
      ]

      elements.concat(views.collect {|c| c.layout(point_mapper)})

      # Ensure chart axis lines are in the foreground
      elements.concat([
        @x_axis.layout(point_mapper),
        @y_axis.layout(point_mapper)
      ])
      elements << @y2_axis.layout(point_mapper) if @y2_axis

      Zbox.new(*elements)
    end

    def layout_value_labels(box, point_mapper)
      if @x_axis.value_labels.formatter
        x_value_labels_layout = @x_axis.value_labels.layout(point_mapper, :bottom)
      end

      if @y_axis.value_labels.formatter
        y_value_labels_layout = @y_axis.value_labels.layout(point_mapper, :left)
      end

      if @y2_axis && @y2_axis.value_labels.formatter
        y2_value_labels_layout = @y2_axis.value_labels.layout(point_mapper, :right)
      end
      
      GridBox.new(
          [y_value_labels_layout, box                  , y2_value_labels_layout],
          [nil,                   x_value_labels_layout, nil                   ])
    end

    def layout_axis_labels(box, point_mapper)
      box = Xbox.new(
        @y_axis.label.layout(point_mapper),
        box,
        @y2_axis && @y2_axis.label.layout(point_mapper))
      box = Ybox.new(box, @x_axis.label.layout(point_mapper))
      box
    end

    def axis_positions
      [:bottom, :left]
    end

    def render_with_canvas(canvas, top, left)
      style.render(canvas)

      point_mapper = PointMapper.new(*axis_positions)
      point_mapper.charts << self
      point_mapper.x_axis_offset_in_units = views.collect {|view| view.respond_to?(:x_axis_padding_required_in_units) ? view.x_axis_padding_required_in_units : 0}.compact.max || 0

      layout(point_mapper).render(canvas, top, left, @width, @height)
      canvas
    end

    def to_svg
      render_with_canvas(Canvases::Svg.new(self), 0, 0).output
    end
  end
end
