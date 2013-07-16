module Graphene
  class Style
    include Renderable

    attr_reader :selectors

    def initialize
      @selectors = []
    end

    def selector(name, *args)
      selector = selectors.detect{|s| s.selector == name.to_s }      

      if selector.nil?
        selector = Selector.new(name)
        selectors << selector
      end

      selector.hash_blob(*args)
      selector.instance_eval(&Proc.new) if block_given?
    end

    def method_missing(method, *args)
      if block_given?
        selector(method, *args, &Proc.new)
      else
        selector(method, *args)
      end
    end

    def to_css
      selectors.map(&:to_css).join
    end

    def render(canvas)
      canvas.definitions do
        canvas.style(to_css)
      end
    end
  end

  class Selector
    attr_reader :selector
    attr_reader :styles

    def initialize(selector)
      @selector = selector.to_s
      @styles = {}
    end

    def hash_blob(*args)
      hashes, args = args.partition{|a| a.is_a?(Hash)}
      hashes.each{|n,v| send(n,v)}
      send(args[0],args[1]) if args.size > 1
    end

    def method_missing(method, *args)
      style_name = method.to_s
      style_name.gsub!(/_/,'-')
      styles[style_name] = args.join(',')
    end

    def to_css
      "\n#{selector} {\n" +
        "\t" +
        styles.map{|name, value| "#{name}: #{value};"}.join("\n\t") +
      "\n}"
    end
  end
end
