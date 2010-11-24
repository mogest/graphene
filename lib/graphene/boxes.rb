module Graphene
  class Box
    include Renderable

    attr_reader :components, :fixed_width, :fixed_height, :variable_width_count, :variable_height_count

    def initialize(*components)
      @components = components.compact

      @fixed_width = x_dimensions.inject(0) {|a, c| a + (c || 0)}
      @fixed_height = y_dimensions.inject(0) {|a, c| a + (c || 0)}

      @variable_width_count = x_dimensions.inject(0) {|count, d| d ? count : count + 1}
      @variable_height_count = y_dimensions.inject(0) {|count, d| d ? count : count + 1}
    end

    def preferred_width
      x_dimensions.max if x_dimensions.all?
    end

    def preferred_height
      y_dimensions.max if y_dimensions.all?
    end

    protected
    def cell_dimensions
      @cell_dimensions ||= cell_dimensions_recursive(components)
    end

    def cell_dimensions_recursive(array)
      array.collect do |c|
        if c.nil?
          [0, 0]
        elsif c.is_a?(Array)
          cell_dimensions_recursive(c)
        else
          w = c.preferred_width
          h = c.preferred_height
          [w && w + c.renderable_object.padding_width, h && h + c.renderable_object.padding_height]
        end
      end
    end

    def x_dimensions
      @x_dimensions ||= cell_dimensions.collect {|c| c[0]}
    end

    def y_dimensions
      @y_dimensions ||= cell_dimensions.collect {|c| c[1]}
    end

    def variable_width(total_width)
      (total_width - fixed_width) / variable_width_count if variable_width_count > 0
    end

    def variable_height(total_height)
      (total_height - fixed_height) / variable_height_count if variable_height_count > 0
    end

    def array_sum(array)
      array.inject(0) {|accumulator, element| element ? accumulator + element : accumulator}
    end
  end

  class Xbox < Box
    def preferred_width
      array_sum(x_dimensions) if x_dimensions.all?
    end

    def render(canvas, left, top, width, height)
      components.each do |component|
        component.render(
          canvas,
          left + component.renderable_object.padding_left,
          top + component.renderable_object.padding_top,
          component.preferred_width || variable_width(width) - component.renderable_object.padding_width,
          component.preferred_height || height - component.renderable_object.padding_height)

        left += (component.preferred_width || variable_width(width)) + component.renderable_object.padding_width
      end
    end
  end

  class Ybox < Box
    def preferred_height
      array_sum(y_dimensions) if y_dimensions.all?
    end

    def render(canvas, left, top, width, height)
      components.each do |component|
        component.render(
          canvas,
          left + component.renderable_object.padding_left,
          top + component.renderable_object.padding_top,
          component.preferred_width || width - component.renderable_object.padding_width,
          component.preferred_height || variable_height(height) - component.renderable_object.padding_height)

        top += (component.preferred_height || variable_height(height)) + component.renderable_object.padding_height
      end
    end
  end

  class Zbox < Box
    def render(canvas, left, top, width, height)
      components.each do |component|
        component.render(
          canvas,
          left + component.renderable_object.padding_left,
          top + component.renderable_object.padding_top,
          component.preferred_width || width - component.renderable_object.padding_width,
          component.preferred_height || height - component.renderable_object.padding_height)
      end
    end
  end

  class GridBox < Box
    def preferred_width
      array_sum(x_dimensions) if x_dimensions.all?
    end

    def preferred_height
      array_sum(y_dimensions) if y_dimensions.all?
    end

    def render(canvas, left, top, width, height)
      components.each_with_index do |component_line, row|
        left_cursor = left

        component_line.each_with_index do |component, column|
          if component
            component.render(
              canvas,
              left_cursor + component.renderable_object.padding_left,
              top + component.renderable_object.padding_top,
              component.preferred_width || variable_width(width) - component.renderable_object.padding_width,
              component.preferred_height || variable_height(height) - component.renderable_object.padding_height)
          end

          left_cursor += x_dimensions[column] || variable_width(width)
        end

        top += y_dimensions[row] || variable_height(height)
      end
    end

    protected
    def x_dimensions
      @x_dimensions ||= cell_dimensions.transpose.collect do |column|
        widths = column.collect {|w, h| w}
        widths.max if widths.all?
      end
    end

    def y_dimensions
      @y_dimensions ||= cell_dimensions.collect do |row|
        heights = row.collect {|w, h| h}
        heights.max if heights.all?
      end
    end
  end
end
