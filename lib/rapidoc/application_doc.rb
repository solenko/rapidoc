module Rapidoc
  class ApplicationDoc < ResourceContainer

    def add_route(route)
      namespaces = route.controller.classify.split('::')
      resource_name = namespaces.pop
      namespace = self
      namespaces.each do |ns|
        namespace = namespace.add_namespace(ns)
      end
      resource = namespace.add_resource(resource_name, route)
      resource.add_action route.action, route


    end

    def html
      template = Template.new('index.html.erb', :info => OpenStruct.new(rapidoc_config), :application_doc => self)
      template.result
    end

    def simple_name
      nil
    end

    def parents
      []
    end

    def name
      nil
    end
  end
end
