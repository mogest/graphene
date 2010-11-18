module Graphene
  class DebugCanvas
    attr_reader :chart

    def initialize(chart)
      @chart = chart
      @tree = []
    end

    def method_missing(method, *args)
      @tree << "#{method} #{args.inspect}"
    end

    def output
      @tree
    end
  end
end
