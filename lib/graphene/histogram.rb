class Graphene::Histogram
  attr_reader :dataset, :step

  def initialize(dataset, step)
    @dataset = dataset
    @step = step
  end
end
