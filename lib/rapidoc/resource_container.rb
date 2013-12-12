class ResourceContainer
  attr_reader :namespaces
  attr_reader :resources

  def initialize
    @namespaces = []
    @resources = []
  end

  def namespace(name)
    namespaces.detect { |n| n.name == name }
  end

  def add_namespace(name)
    ns = namespace(name)
    unless ns
      ns = NamespaceDoc.new(name, self)
      @namespaces.push(ns)
    end
    ns
  end

  def resource(name)
    resources.detect { |n| n.name == name }
  end

  def add_resource(name, info)
    res = resource(name)
    unless res
      res = ResourceDoc.new(name, info, self)
      resources.push(res)
    end
    res
  end

  def children
    namespaces + resources
  end

  def actions
    children.map(&:actions).flatten
  end

end