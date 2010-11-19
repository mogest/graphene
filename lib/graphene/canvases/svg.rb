module Graphene
  module Canvases
    class Svg
      attr_reader :chart

      def initialize(chart)
        @chart = chart
        @builder = Builder::XmlMarkup.new(:indent => 2)
        @builder.instruct!
        @builder << '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">'
      end

      def output
        @builder << "</svg>"
      end

      def line(x1, y1, x2, y2, opts = {})
        @builder.line :x1 => x1, :y1 => y1, :x2 => x2, :y2 => y2,
          :stroke => opts[:stroke_colour],
          :class => opts[:class], :id => opts[:id]
      end

      def box(x, y, w, h, opts = {})
        @builder.rect :x => x, :y => y, :width => w, :height => h,
          :stroke => opts[:stroke_colour], :fill => opts[:fill_colour],
          :class => opts[:class], :id => opts[:id]
      end

      def text(x, y, text, opts = {})
        @builder.text text,
          {:x => x, :y => y,
          :class => opts[:class], :id => opts[:id], :width => opts[:width], :height => opts[:height], "text-anchor" => opts[:text_anchor],
          "font-size" => opts[:font_size],
          :fill => opts[:fill_colour]
        }.reject {|k, v| v.nil?}
      end

      def marker(x, y, marker, opts = {})
        @builder.circle :cx => x, :cy => y, :r => 2, :stroke => "#770000", :fill => "#ff0000"

        size = 6
        case marker && marker.upcase
        when 'X'
          @builder.line :x1 => x-size, :y1 => y-size, :x2 => x+size, :y2 => y+size, :stroke_width => 5, :stroke => "#000000"
          @builder.line :x1 => x-size, :y1 => y+size, :x2 => x+size, :y2 => y-size, :stroke_width => 5, :stroke => "#000000"
        when 'O'
          @builder.circle :cx => x, :cy => y, :r => size, :fill => "none", :stroke => "#000000", :stroke_width => 5
        end
      end
    end
  end
end
