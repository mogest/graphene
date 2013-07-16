module Graphene
  module Canvases
    class Svg
      attr_reader :chart

      def initialize(chart)
        @chart = chart
        @builder = Builder::XmlMarkup.new(:indent => 2)
        @builder.instruct!
        @builder << %Q{<svg xmlns="http://www.w3.org/2000/svg" width="#{@chart.width}" height="#{@chart.height}">}
      end

      def output
        @builder << "</svg>"
      end

      def definitions
        @builder.defs { yield }
      end

      def clip_path(opts)
        @builder.clipPath(opts) { yield }
      end

      def group(opts)
        @builder.g(opts) { yield }
      end

      def style(css)
        @builder.style('type' => 'text/css') do
          @builder.cdata! css
        end
      end

      def gradient(id, from_color, to_color)
        @builder.defs do
          @builder.linearGradient :id => id, :x1 => "0%", :y1 => "0%", :x2 => "0%", :y2 => "100%", :spreadMethod => "pad" do
            @builder.stop :offset => "0%"   , 'stop-color' => from_color, 'stop-opacity' => "1"
            @builder.stop :offset => "100%" , 'stop-color' => to_color  , 'stop-opacity' => "1"
          end
        end
      end

      def shadow(id, blur_factor, x_shift, y_shift)
        @builder.defs do
          @builder.filter :id => id, :height => "130%" do
            @builder.feGaussianBlur :in => "SourceAlpha", 'stdDeviation' => blur_factor
            @builder.feOffset :dx => x_shift, :dy => y_shift, :result => 'offsetblur'
            @builder.feMerge do
              @builder.feMergeNode
              @builder.feMergeNode :in => 'SourceGraphic'
            end
          end
        end
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
          {
          :x => x, 
          :y => y,
          :class => opts[:class], 
          :id => opts[:id], 
          "text-anchor" => opts[:text_anchor],
          "font-size" => opts[:font_size] && "#{opts[:font_size]}px",
          "font-weight" => opts[:font_weight] || "normal",
          "alignment-baseline" => opts[:alignment_baseline],
          :fill => opts[:fill_colour],
          :transform => opts[:transform]
        }.reject {|k, v| v.nil?}
      end

      def marker(x, y, marker, opts = {})
        @builder.circle :cx => x, :cy => y, :r => 2, :stroke => "#770000", :fill => "#ff0000", :class => opts[:class]

        size = 6
        case marker && marker.upcase
        when 'X'
          @builder.line :x1 => x-size, :y1 => y-size, :x2 => x+size, :y2 => y+size, :stroke_width => 5, :stroke => "#000000", :class => opts[:class]
          @builder.line :x1 => x-size, :y1 => y+size, :x2 => x+size, :y2 => y-size, :stroke_width => 5, :stroke => "#000000", :class => opts[:class]
        when 'O'
          @builder.circle :cx => x, :cy => y, :r => size, :fill => "none", :stroke => "#000000", :stroke_width => 5, :class => opts[:class]
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
