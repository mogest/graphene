module Graphene
  Error = Class.new(StandardError)
  LayoutError = Class.new(Error)

  def self.svg
    chart = Graphene::Chart.new
    yield chart
    chart.to_svg
  end
end

require 'graphene/renderable'
require 'graphene/boxes'

require 'graphene/axis'
require 'graphene/axis_label'
require 'graphene/bar'
require 'graphene/chart'
require 'graphene/grid'
require 'graphene/histogram'
require 'graphene/legend'
require 'graphene/line'
require 'graphene/stacked'
require 'graphene/text'
require 'graphene/value_labels'

require 'graphene/debug_canvas'
require 'graphene/svg_canvas'
