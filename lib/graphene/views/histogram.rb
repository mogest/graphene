module Graphene
  module Views
    class Histogram < Base
      attr_reader :step, :start, :stack_on, :stacked_dataset
      attr_accessor :stroke_colour, :stroke_opacity, :fill_colour, :fill_opacity
      attr_accessor :stroke_width, :bar_position
      attr_accessor :id_offset
      
      attr_accessor :gradient, :shadow      
      attr_accessor :bar_spacing, :bar_spacing_left, :bar_spacing_right
      attr_accessor :bar_labels
      
      attr_accessor :bar_class_name

      alias :stroke_color  :stroke_colour
      alias :stroke_color= :stroke_colour=
      alias :fill_color    :fill_colour
      alias :fill_color=   :fill_colour=

      def initialize(dataset, start, step, stack_on = nil)
        super()
        @dataset = dataset
        @start = start
        @step = step
        @stroke_colour = "purple"
        @fill_colour = "orange"
        @stroke_opacity = @fill_opacity = 1
        @stroke_width = 2
        @id_offset = 0
        @gradient = nil
        @shadow = nil
        @bar_spacing = 0
        @bar_spacing_right = 0
        @bar_spacing_left = 0
        @bar_labels = { :labels => [] }
        @bar_class_name = ''
        if @stack_on = stack_on
          @stacked_dataset = @dataset.each_with_index.collect {|value, index| (value || 0) + stack_on.stacked_dataset[index]}
        else
          @stacked_dataset = @dataset.collect {|value| (value || 0)}
        end
        @bar_position = :right
      end

      def push_watermark(watermark, type, comparitor)
        data = if type == :x
          [start, start + step * dataset.length]
        else
          stacked_dataset
        end

        data.each do |value|
          watermark = value if watermark.nil? || value.send(comparitor, watermark)
        end
        watermark
      end

      def layout(point_mapper)
        Renderer.new(self, point_mapper)
      end

      def x_axis_padding_required_in_units
        bar_position == :center ? step / 2.0 : 0
      end

      class Renderer
        def initialize(histogram, point_mapper)
          @histogram = histogram
          @point_mapper = point_mapper
        end

        def renderable_object
          @histogram
        end

        def preferred_width;  nil; end
        def preferred_height; nil; end

        def render(canvas, left, top, width, height)
          id_offset = @histogram.id_offset || 0

          canvas.group :id => "graphene_data" do
            x1_value = @histogram.start
            @histogram.stacked_dataset.each_with_index do |y_value, index|
              x2_value = x1_value + @histogram.step

              if @histogram.dataset[index]
                bottom_value = y_value - @histogram.dataset[index] # so 0 when not stacked
                left_offset, top_offset     = @point_mapper.values_to_coordinates(@histogram.axis, x1_value, y_value < bottom_value ? bottom_value : y_value, width, height)
                right_offset, bottom_offset = @point_mapper.values_to_coordinates(@histogram.axis, x2_value, y_value < bottom_value ? y_value : bottom_value, width, height)

                if @histogram.bar_position == :center
                  left_right_delta = right_offset - left_offset
                  left_offset -= left_right_delta / 2.0
                  right_offset -= left_right_delta / 2.0
                end
                
                bar_width = right_offset - left_offset
                bar_height = bottom_offset - top_offset

                left_offset += left
                top_offset += top

                # Gradients are a special sort of fill. You define'm first and then use them while drawing the bo (=bar).
                canvas.gradient("graphene_gradient_#{index + id_offset}", @histogram.gradient[:from_color] || 'yellow', @histogram.gradient[:to_color] || 'green') if @histogram.gradient
                # Shadows are defined once and used as a filter on the boxes (=bars).
                canvas.shadow("graphene_shadow_#{index + id_offset}", @histogram.shadow[:blur_factor] || 3, @histogram.shadow[:x_shift] || 2, @histogram.shadow[:y_shift] || 2) if @histogram.shadow
                filter = @histogram.shadow ? "url(#graphene_shadow_#{index + id_offset})" : nil

                # bar_spacing: some blank space between the bars; this differes from padding as bar_spacing only occurs left-right from a bar
                # The basic setup here is that we display half the bar_spacing first, then draw the bar, then the other half of the bar_spacing, so technically we draw 3 boxes
                # Keep in mind to adjust the left_offset and bar width when doing so
                half_bar_spacing = @histogram.bar_spacing / 2 

                if @histogram.bar_spacing > 0
                  canvas.box(left_offset, top_offset, half_bar_spacing, bar_height, "stroke-opacity" => 0, "fill-opacity" => 0)                 
                  left_offset += half_bar_spacing
                  bar_width   -= @histogram.bar_spacing
                end

                if @histogram.bar_spacing_left > 0
                  left_offset += @histogram.bar_spacing_left
                  bar_width   -= @histogram.bar_spacing_left
                  canvas.box(left_offset, top_offset, bar_width, bar_height, "stroke-opacity" => 0, "fill-opacity" => 0)                 
                end
                
                if @histogram.bar_spacing_right > 0
                  bar_width   -= @histogram.bar_spacing_right
                end
                
                # bar_labels: display some label on top of the bar
                # Some text to be drawn on top of the bar
                # For now only the font size can be set through the options
                if @histogram.bar_labels[:labels].size > 0
                  canvas.text(left_offset, top_offset-10, @histogram.bar_labels[:labels][index], {:font_size => @histogram.bar_labels[:font_size] || 9})
                end

                opacity = @histogram.fill_opacity
                opacity = opacity[index] if opacity.is_a?(Array)

                fill_colour = @histogram.fill_colour
                fill_colour = fill_colour[index] if fill_colour.is_a?(Array)
                
                # The actual bar
                canvas.box(left_offset, top_offset, bar_width, bar_height,
                  :id => "graphene_data_#{index + id_offset}",
                  :stroke => @histogram.stroke_colour, "stroke-opacity" => @histogram.stroke_opacity, "stroke-width" => @histogram.stroke_width,
                  :fill => @histogram.gradient ? "url(#graphene_gradient_#{index + id_offset})" : fill_colour, "fill-opacity" => opacity,
                  :filter => filter, :class => "graphene_bar #{@histogram.bar_class_name}")
                  
                # This is the second half of the bar_spacing boxes
                if @histogram.bar_spacing_right > 0
                  bar_width   -= @histogram.bar_spacing_right
                  canvas.box(left_offset, top_offset, bar_width, bar_height, "stroke-opacity" => 0, "fill-opacity" => 0)                 
                  left_offset += @histogram.bar_spacing_right
                end

                if @histogram.bar_spacing > 0
                  canvas.box(left_offset + bar_width, top_offset, half_bar_spacing, bar_height, "stroke-opacity" => 0, "fill-opacity" => 0) 
                  left_offset += half_bar_spacing
                end
              end
                
              x1_value = x2_value
            end
          end
        end
      end
    end
  end
end
