module Graphene
  Error = Class.new(StandardError)
  LayoutError = Class.new(Error)

  def self.svg
    chart = Graphene::Chart.new
    yield chart
    chart.to_svg
  end
end

require 'rubygems'

gem 'builder'
require 'builder'
require 'bigdecimal'

require 'graphene/renderable'
require 'graphene/positioned'
require 'graphene/boxes'

require 'graphene/axis'
require 'graphene/axis_label'
require 'graphene/grid'
require 'graphene/legend'
require 'graphene/text'
require 'graphene/value_labels'
require 'graphene/point_mapper'

require 'graphene/chart'
require 'graphene/horizontal_chart'

require 'graphene/views'
require 'graphene/canvases'
