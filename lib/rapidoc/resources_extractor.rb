require 'vendor/action_dispatch/routing/inspector' if ActiveSupport::VERSION::MAJOR < 4

module Rapidoc

  ##
  # This module get resources info.
  #
  # Info of each route include:
  # - method
  # - action
  # - url
  # - controller_file
  #
  module ResourcesExtractor

    ##
    # Reads 'rake routes' output and gets the routes info
    # @return [RoutesDoc] class with routes info
    #
    def get_routes_doc
      routes_doc = ApplicationDoc.new

      routes = Rails.application.routes.routes.collect do |route|
        ActionDispatch::Routing::RouteWrapper.new(route)
      end.reject do |route|
        route.internal?
      end

      routes.each do |entry|
        routes_doc.add_route( entry )
      end

      routes_doc
    end

    ##
    # Create new ResourceDoc for each resource extracted from RoutesDoc
    # @return [Array] ResourceDoc array
    #
    def get_resources
      routes_doc = get_routes_doc
      resources_names = routes_doc.get_resources_names - resources_black_list

      resources_names.map do |resource|
        puts "Generating #{resource} documentation..." if trace?
        ResourceDoc.new( resource, routes_doc.get_actions_route_info( resource ) )
      end
    end
  end
end
