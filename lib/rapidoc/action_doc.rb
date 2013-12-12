# encoding: utf-8

require 'rapidoc/http_response'
require 'json'

module Rapidoc

  ##
  # This class save information about action of resource.
  #
  class ActionDoc
    attr_reader :name, :route, :doc, :example_req, :example_res

    delegate :verb, :path, :to => :route

    # :resource, :urls, :action, :action_method, :description,


      # :response_formats, :authentication, :params, :file, :http_responses,
      # :errors, :example_res, :example_req

    ##
    # @param resource [String] resource name
    # @param action_info [Hash] action info extracted from controller file
    # @param urls [Array] all urls that call this method
    #
    def initialize(name, route, doc, parent)
      @name             = name
      @action_method    = route.verb || '-----'
      @controller       = route.controller
      @doc              = doc || {}
      @route = route
      @parent = parent

      puts " - Generating #{@action} action documentation..." if trace?

#      add_controller_info( controller_info ) if controller_info
      load_examples
#      load_params_errors if default_errors? @action and @params
    end

    def params
      doc["params"]
    end

    def errors
      Array(doc["errors"])
    end


    def http_responses
      get_http_responses doc["http_responses"]
    end

    def description
      doc['description']
    end

    def response_formats
      doc["response_formats"] || default_response_formats
    end


    def authentication
      get_authentication doc['authentication_required']
    end

    def resource
      @parent
    end

    def html
      template = Template.new('action.html.erb', :info => rapidoc_config, :action => self )
      template.result
    end

    def file_name
      [@parent.simple_name, name].join('_')
    end

    def has_controller_info
      @controller_info ? true : false
    end

    def parents
      @parent.parents + [@parent]
    end

    private

    def examples_path
      Rails.root.join(examples_dir_from_config_file, *(parents.map(&:name).compact.map(&:downcase)))
    end

    def add_controller_info( controller_info )
      puts "  + Adding info from controller..." if trace?
      @description      = controller_info["description"]
      @response_formats = default_response_formats || controller_info["response_formats"]
      @http_responses   = get_http_responses controller_info["http_responses"]
      @errors           = controller_info["errors"] ? controller_info["errors"].dup : []
      @authentication   = get_authentication controller_info["authentication_required"]
      @controller_info  = true
    end

    def get_authentication( required_authentication )
      if [ true, false ].include? required_authentication 
        required_authentication
      else
        default_authentication
      end
    end

    def get_http_responses codes
      Array(codes).map{ |c| HttpResponse.new c }
    end

    def load_examples
      # return unless File.directory?(examples_path)
      load_request examples_path
      load_response examples_path
    end

    def load_params_errors
      params.each do |param|
        @errors << get_error_info( param["name"], "required" ) if param["required"]
        @errors << get_error_info( param["name"], "inclusion" ) if param["inclusion"]
      end
    end

    def load_request( examples_route )
      file = File.join(examples_route, name + '_request.json')
      puts "request"
      puts examples_route
      puts file
      return unless File.exists?( file )
      puts "  + Loading request examples..." if trace?
      File.open( file ){ |f| @example_req = JSON.pretty_generate( JSON.parse(f.read) ) }
    end

    def load_response( examples_route )
      file = File.join(examples_route, name + '_response.json')
      return unless File.exists?( file )
      puts "  + Loading response examples..." if trace?

      begin
        File.open( file ){ |f| @example_res = JSON.pretty_generate( JSON.parse(f.read) ) }
      rescue JSON::ParserError => e
        @example_res = File.read file
      end

    end
  end
end
