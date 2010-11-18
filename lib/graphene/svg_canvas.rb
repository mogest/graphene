class Graphene::SvgCanvas
  attr_reader :chart

  def initialize(chart)
    @chart = chart
  end

  def output
  end

  def box(x, y, w, h, stroke_colour)
  end

  def filled_box(x, y, w, h, stroke_colour, fill_colour)
  end

  def text(x, y, text, opts = {})
  end
end
