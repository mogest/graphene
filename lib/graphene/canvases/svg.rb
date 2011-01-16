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
          "stroke-width" => opts[:stroke_width] || 1,
          :class => opts[:class], :id => opts[:id]
      end

      def box(x, y, w, h, opts = {})
        @builder.rect opts.merge(:x => x, :y => y, :width => w, :height => h).reject {|k, v| v.nil?}
      end

      def text(x, y, text, opts = {})
        @builder.text text,
          {:x => x, :y => y,
          :class => opts[:class], :id => opts[:id], "text-anchor" => opts[:text_anchor],
          "font-size" => opts[:font_size] && "#{opts[:font_size]}px",
          "alignment-baseline" => opts[:alignment_baseline],
          :fill => opts[:fill_colour],
          :transform => opts[:transform]
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

      def path(instructions, opts = {})
        path = ""
        instructions.each do |command, *data|
          case command
          when :move
            path << "M#{data[0]} #{data[1]}"
          when :lineto
            path << "L#{data[0]} #{data[1]}"
          else
            raise ArgumentError, "invalid command #{command}"
          end
        end

        @builder.path opts.merge(:d => path)
      end
    end
  end
end
