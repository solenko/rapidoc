# encoding: utf-8

module Rapidoc

  ##
  # This class let us manage resources and actions extracted from 'rake routes'
  #
  class RoutesDoc
    def initialize
      @resources_routes = {}
    end

    def add_route( route )
      info = {
          name:   route.name,
          verb:   route.verb,
          path:   route.path,
          reqs:   route.reqs,
          regexp: route.json_regexp,
          controller: route.controller,
          action: route.action
      }
      add_resource_route( info[:controller].classify, info)
    end

    def get_resources_names
      @resources_routes.keys.sort
    end

    def get_resource_actions_names( resource )
      @resources_routes[resource.to_sym].map{ |route| route[:action] }.uniq
    end

    def get_actions_route_info( resource )
      get_resource_actions_names( resource ).map do |action|
        get_action_route_info( resource, action )
      end
    end

    def get_action_route_info( resource, action )
      urls = []
      controllers = []
      methods = []

      # compact and generate action info from all routes info of resource
      action_route = @resources_routes[resource.to_sym].detect { |route| route[:action] == action.to_s }
      return {
        resource: resource.to_s,
        action: action.to_s,
        method: action_route[:method],
        urls: action_route[:url],
        controller: action_route[:controller]
      }
    end

    private

    ##
    # Add new route info to resource routes array with correct format
    #
    def add_resource_route( resource, info)
      @resources_routes[resource.to_sym] ||= []
      @resources_routes[resource.to_sym].push( info )
    end


    ##
    # Extract resource name from url
    #
    def get_resource_name( url )
      new_url = url.gsub( '(.:format)', '' )

      return $1 if new_url =~ /\/(\w+)\/:id$/         # /users/:id (users)
      return $1 if new_url =~ /\/(\w+)\/:id\/edit$/   # /users/:id/edit (users)
      return $1 if new_url =~ /^\/(\w+)$/             # /users  (users)
      return $1 if new_url =~ /\/:\w*id\/(\w+)$/      # /users/:id/images (images)
      return $1 if new_url =~ /\/:\w*id\/(\w+)\/\w+$/ # /users/:id/config/edit (users)
      return $1 if new_url =~ /^\/(\w+)\/\w+$/        # /users/edit (users)
      return $1 if new_url =~ /\/(\w+)\/\w+\/\w+$/    # /users/password/edit (users)
      return url
    end
  end
end
