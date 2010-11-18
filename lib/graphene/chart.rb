module Graphene
  class Chart
    attr_accessor :x_axis, :y_axis, :grid, :width, :height
    attr_writer :y2_axis, :legend, :heading
    attr_reader :contents

    def initialize
      @x_axis = Axis.new(self)
      @y_axis = Axis.new(self)
      @grid = Grid.new(self)
      @contents = []
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
      @y2_axis ||= Axis.new(self)
    end

    def legend
      @legend ||= Legend.new(self)
    end

    def plot(dataset, options = {})
      Line.new(dataset).tap do |line|
        options.each {|k, v| line.send(k, v)}
        @contents << line
      end
    end

    def histogram(dataset, step, options = {})
      Histogram.new(dataset, step).tap do |histogram|
        options.each {|k, v| histogram.send(k, v)}
        @contents << histogram
      end
    end

    def bar(dataset, options = {})
      Bar.new(dataset).tap do |bar|
        options.each {|k, v| bar.send(k, v)}
        @contents << bar
      end
    end

    def layout
      if contents.empty?
        raise LayoutError, "Cannot layout Chart before at least one plot/histogram/bar has been specified"
      end

      x_position, y_position, y2_position, content_position = if true
        [:bottom, :left, :right, :vertical]
      else
        [:left, :bottom, :top, :horizontal]
      end

      box = Zbox.new(@grid.layout, @x_axis.layout(x_position), *contents.collect {|c| c.layout(content_position)}).layout

      elements = [@y_axis.layout(y_position), box]
      elements << @y2_axis.layout(y2_position) if @y2_axis

      box = Xbox.new(*elements).layout
      box = Ybox.new(@legend.layout, box).layout if @legend
      box = Ybox.new(@heading.layout, box).layout if @heading
      box
    end

    def render_with_canvas(canvas)
      layout.render(canvas, 0, 0, @width, @height)
      canvas
    end

    def to_svg
      render_with_canvas(SvgCanvas.new(self)).output
    end
  end
end
