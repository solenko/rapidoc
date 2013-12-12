# encoding: utf-8

module Rapidoc

  ##
  # This class includes all info about a resource
  # To extract info from controller file uses ControllerExtractor
  # It includes an array of ActionDoc with each action information
  #
  class ResourceDoc
    attr_reader :name, :controller_file, :actions_doc

    attr_reader :actions, :extractor

    delegate :description, :to => :extractor

    ##
    # @param name [String] resource name
    # @param routes_doc [RoutesDoc] routes documentation
    #
    def initialize(name, route, parent)
      @name = name
      @route = route
      @controller = route.controller
      @parent = parent

      @actions = []

      @extractor = ControllerExtractor.instance(controller_file_name(@controller))
    end

    def add_action(name, route)
      @actions.push(ActionDoc.new(name, route, @extractor.action(name), self))
    end

    def html
      template = Template.new('resource.html.erb', :resource => self)
      template.result
    end

    ##
    # Names with '/' caracter produce problems in html ids
    #
    def simple_name
      [@parent.simple_name, self.name.parameterize].compact.join('_')
    end

    def parents
      @parent.parents + [@parent]
    end



    private

    def controller_file_name(controller)
      ActiveSupport::Dependencies.search_for_file("#{controller}_controller")
    end

    ##
    # Create description and actions_doc
    #
    def generate_info( routes_info )
      routes_info.map {|i| i[:controller]}.compact.uniq.each do |controller_name|
        next unless controller_exists?(controller_name)
        @description << controller_extractor(controller_name).description
      end

      routes_info.each do |route|
        next unless controller_exists?(route[:controller])
        @actions_doc << get_action_doc( route, controller_extractor(route[:controller]) )
      end
    end

    ##
    # @return [ControllerExtractor] extractor that allow read controller files
    # and extract action and resource info from them
    #
    def controller_extractor(controller)
      @extractors[controller] ||= ControllerExtractor.new(controller_file_name(controller))
    end

    def controller_exists?(controller_name)
      controller_file_name(controller_name)
    end

    ##
    # @return [Array] all the resource ActionDoc
    #
    def get_action_doc(route_info, extractor )
      controller_info = extractor.get_action_info( route_info[:action] )
      ActionDoc.new( route_info, controller_info, examples_dir )
    end
  end
end
