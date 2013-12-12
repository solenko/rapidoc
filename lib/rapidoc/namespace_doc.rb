module Rapidoc
  class NamespaceDoc < ResourceContainer
    attr_accessor :name

    def initialize(name, parent)
      super()
      @name = name
      @parent = parent
    end

    def html
      template = Template.new('namespace.html.erb', :namespace => self)
      template.result
    end

    def simple_name
      [@parent.simple_name, self.name.parameterize].compact.join('_')
    end

    def parents
      @parent.parents + [@parent]
    end
  end
end