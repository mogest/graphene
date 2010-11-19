module Graphene
  module Views
    class Histogram
      attr_reader :step

      def initialize(dataset, step)
        @dataset = dataset
        @step = step
      end
    end
  end
end
