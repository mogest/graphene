module Graphene
  module Views
    class Line < Base
      attr_accessor :stroke_colour, :stroke_opacity, :fill_colour, :fill_opacity, :marker
      attr_accessor :stroke_width
      
      alias :stroke_color  :stroke_colour
      alias :stroke_color= :stroke_colour=
      alias :fill_color    :fill_colour
      alias :fill_color=   :fill_colour=

      def initialize(dataset, opts = {})
        super()

        opts.stringify_keys!
        if (opts.keys - %w(start step)).any?
          raise ArgumentError, "Unrecognised option passed into Graphene::Views::Line.initialize"
        end

        if x_value = opts["start"]
          step = opts["step"] || 1
          @dataset = new_dataset = []
          dataset.each do |y_value|
            new_dataset << [x_value, y_value] if y_value
            x_value += step
          end
        else
          @dataset = dataset
        end

        @stroke_colour = "red"
        @marker = "x"
        @stroke_opacity = @fill_opacity = 1
        @stroke_width = 2
      end

      def push_watermark(watermark, type, comparitor)
        dataset.each do |x, y|
          value = type == :x ? x : y
          watermark = value if value && (watermark.nil? || value.send(comparitor, watermark))
        end
        watermark
      end

      def opacity=(value)
        @stroke_opacity = @fill_opacity = value
      end

      def layout(point_mapper)
        Renderer.new(self, point_mapper)
      end

      class Renderer
        def initialize(line, point_mapper)
          @line = line
          @point_mapper = point_mapper
        end

        def renderable_object
          @line
        end

        def preferred_width;  nil; end
        def preferred_height; nil; end

        def interpolate_between(point1, point2, x)
          y = point1[:y] + ((x - point1[:x]) * point2[:y] - (x - point1[:x]) * point1[:y]) / (point2[:x] - point1[:x])
          point2.merge({:y => y, :x => x})
        end

        def render(canvas, left, top, width, height)
          index_for_sorting = 0
          sorted = @line.dataset.to_a.sort_by {|k, v| [k, index_for_sorting += 1]} # see http://bugs.ruby-lang.org/issues/1089#note-10

          instructions = []
          markers = []
          points = []
          last_point = nil

          sorted.each_with_index do |(x_value, y_value), index|
            left_offset, top_offset = @point_mapper.values_to_coordinates(@line.axis, x_value, y_value, width, height)

            left_offset += left
            top_offset += top

            point = { :x => left_offset, :y => top_offset, :x_value => x_value, :y_value => y_value }

            if left_offset < left
              # off the start of the screen
              last_point = point
              next
            end
            if last_point
              last_point = interpolate_between(last_point, point, left)
              points << last_point
              markers << [last_point[:x], last_point[:y], @line.marker, {:class => "marker"}] if @line.marker
              instructions << [instructions.empty? ? :move : :lineto, last_point[:x], last_point[:y]]
              last_point = nil
            end
            if left_offset > left + width && points.size > 0
              # off the end of the screen
              point = interpolate_between(points[-1], point, left + width)
              points << point
              markers << [point[:x], point[:y], @line.marker, {:class => "marker"}] if @line.marker
              instructions << [instructions.empty? ? :move : :lineto, point[:x], point[:y]]
              break
            end
            points << point
            markers << [point[:x], point[:y], @line.marker, {:class => "marker"}] if @line.marker
            instructions << [instructions.empty? ? :move : :lineto, point[:x], point[:y]]
          end

          canvas.definitions do
            canvas.clip_path(:id => "line-clip-#{object_id}") do
              canvas.box(left, top, width, height)
            end
          end

          canvas.group({:'data-name' => @line.name, :'data-type' => 'line', :'data-left' => left, :'data-top' => top, :'data-width' => width, :'data-height' => height, :'data-data' => points.to_json, :style => "clip-path: url(#line-clip-#{object_id});"}) do
            if instructions.present?
              canvas.path(instructions, :stroke => @line.stroke_colour, :fill => "none", "stroke-opacity" => @line.stroke_opacity, "stroke-width" => @line.stroke_width)
            end

            if @line.fill_colour
              x_value, y_value = sorted.last
              left_offset, top_offset = @point_mapper.values_to_coordinates(@line.axis, x_value, 0, width, height)
              instructions << [:lineto, left + left_offset, top + top_offset]

              x_value, y_value = sorted.first
              left_offset, top_offset = @point_mapper.values_to_coordinates(@line.axis, x_value, 0, width, height)
              instructions << [:lineto, left + left_offset, top + top_offset]

              canvas.path(instructions, :stroke => "none", :fill => @line.fill_colour, "fill-opacity" => @line.fill_opacity)
            end

            markers.each do |args|
              canvas.marker(*args)
            end
          end
        end
      end
    end
  end
end
