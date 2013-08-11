module Graphene
  module Views
    class Base
      include Renderable

      attr_reader :dataset
      attr_reader :axis
      attr_accessor :name

      def initialize
        @axis = :y
        @name = "Dataset"
      end

      def axis=(value)
        raise ArgumentError, "axis must be either :y or :y2" unless [:y, :y2].include?(value)
        @axis = value
      end

      def push_watermark(watermark, type, comparitor)
        watermark
      end

      def preferred_width;  nil; end
      def preferred_height; nil; end
    end
  end
end
