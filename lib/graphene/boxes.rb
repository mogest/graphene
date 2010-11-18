module Graphene
  class Box
    include Renderable

    attr_reader :contents

    def initialize(*contents)
      @contents = contents
    end

    def layout
      self
    end

    def preferred_width
      all_preferred_widths.max if all_preferred_widths.all?
    end

    def preferred_height
      all_preferred_heights.max if all_preferred_heights.all?
    end

    protected
    def all_preferred_widths
      @all_preferred_widths ||= contents.collect do |c|
        if w = c.preferred_width
          w + c.renderable_object.padding_width
        end
      end
    end

    def all_preferred_heights
      @all_preferred_heights ||= contents.collect do |c|
        if h = c.preferred_height
          h + c.renderable_object.padding_height
        end
      end
    end

    def array_sum(array)
      array.inject(0) {|accumulator, element| element ? accumulator + element : accumulator}
    end
  end

  class Xbox < Box
    def preferred_width
      array_sum(all_preferred_widths) if all_preferred_widths.all?
    end

    def render(canvas, top, left, width, height)
      fixed_width = array_sum(all_preferred_widths)
      variable_count = all_preferred_widths.inject(0) {|count, w| w ? count : count + 1}
      variable_width = (width - fixed_width) / variable_count if variable_count > 0

      contents.each do |content|
        content.render(
          canvas,
          top + content.renderable_object.padding_top,
          left + content.renderable_object.padding_left,
          content.preferred_width || variable_width - content.renderable_object.padding_width,
          content.preferred_height || height - content.renderable_object.padding_height)

        left += (content.preferred_width || variable_width) + content.renderable_object.padding_width
      end
    end
  end

  class Ybox < Box
    def preferred_height
      array_sum(all_preferred_heights) if all_preferred_heights.all?
    end

    def render(canvas, top, left, width, height)
      fixed_height = array_sum(all_preferred_heights)
      variable_count = all_preferred_heights.inject(0) {|count, h| h ? count : count + 1}
      variable_height = (height - fixed_height) / variable_count if variable_count > 0

      contents.each do |content|
        content.render(
          canvas,
          top + content.renderable_object.padding_top,
          left + content.renderable_object.padding_left,
          content.preferred_width || width - content.renderable_object.padding_width,
          content.preferred_height || variable_height - content.renderable_object.padding_height)

        top += (content.preferred_height || variable_height) + content.renderable_object.padding_width
      end
    end
  end

  class Zbox < Box
    def render(canvas, top, left, width, height)

      contents.each do |content|
        content.render(
          canvas,
          top + content.renderable_object.padding_top,
          left + content.renderable_object.padding_left,
          content.preferred_width || width - content.renderable_object.padding_width,
          content.preferred_height || height - content.renderable_object.padding_height)
      end
    end
  end
end
