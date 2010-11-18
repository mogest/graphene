module Graphene::Renderable
  def self.included(base)
    [:padding_left, :padding_top, :padding_right, :padding_bottom].each do |method|
      base.send :attr_writer, method
      base.send :define_method, method do
        instance_variable_get("@#{method}") || 0
      end
    end
  end

  def padding=(a, b=nil, c=nil, d=nil)
    @padding_top, @padding_right, @padding_bottom, @padding_left = if d
      [a, b, c, d]
    elsif c
      [a, b, c, b]
    elsif b
      [a, b, a, b]
    else
      [a, a, a, a]
    end
  end

  def padding_width
    padding_left + padding_right
  end

  def padding_height
    padding_top + padding_bottom
  end

  def renderable_object
    self
  end
end
