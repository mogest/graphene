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

      x_position, y_position, y2_position, content_position = if true
        [:bottom, :left, :right, :vertical]
      else
        [:left, :bottom, :top, :horizontal]
      end

      elements = [
        @grid.layout,
        @x_axis.layout(point_mapper, x_position),
        @y_axis.layout(point_mapper, y_position)
      ]

      elements << @y2_axis.layout(point_mapper, y2_position) if @y2_axis

      elements.concat(views.collect {|c| c.layout(point_mapper, content_position)})

      box = Zbox.new(*elements)

      box = Ybox.new(box, @x_axis.label.layout(:bottom))
      box = Xbox.new(@y_axis.label.layout(:left), box)

      box = Ybox.new(@legend.layout, box) if @legend
      box = Ybox.new(@heading.layout, box) if @heading
      box
    end

    def render_with_canvas(canvas)
      point_mapper = PointMapper.new
      point_mapper.charts << self

      layout(point_mapper).render(canvas, 0, 0, @width, @height)
      canvas
    end

    def to_svg
      render_with_canvas(Canvases::Svg.new(self)).output
    end
  end
end
