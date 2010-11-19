module Graphene
  module Views
    class Base
      include Renderable

      attr_reader :dataset
    end
  end
end
