module Graphene
  Error = Class.new(StandardError)
  LayoutError = Class.new(Error)

  def self.svg
    chart = Graphene::Chart.new
    yield chart
    chart.to_svg
  end
  
  def self.chart
    chart = Graphene::Chart.new
    yield chart if block_given?
    chart
  end
  
  def self.vertical_stack
    stack = Graphene::VerticalStack.new
    yield stack if block_given?
    stack
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
require 'graphene/style'

require 'graphene/chart'
require 'graphene/horizontal_chart'
require 'graphene/vertical_stack'

require 'graphene/views'
require 'graphene/canvases'
