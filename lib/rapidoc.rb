require 'handlebars'
require "rapidoc/config"
require "rapidoc/resource_container"
require "rapidoc/application_doc"
require "rapidoc/namespace_doc"
require "rapidoc/version"
require "tasks/railtie.rb"
require "rapidoc/routes_doc"
require "rapidoc/resource_doc"
require "rapidoc/action_doc"
require "rapidoc/controller_extractor"
require "rapidoc/resources_extractor"
require "rapidoc/param_errors"
require "rapidoc/helpers"
require "rapidoc/templates_generator"
require "rapidoc/yaml_parser"


module Rapidoc

  include Config
  include ResourcesExtractor
  include TemplatesGenerator
  include ParamErrors
  include YamlParser

  METHODS = [ "GET", "PUT", "DELETE", "POST" ]

  def create_structure
    # should be done in this order
    FileUtils.mkdir target_dir unless File.directory? target_dir
    FileUtils.mkdir actions_dir unless File.directory? actions_dir
    FileUtils.cp_r GEM_CONFIG_DIR + "/.", config_dir unless File.directory? config_dir
    FileUtils.cp_r GEM_ASSETS_DIR, target_dir
    FileUtils.mkdir examples_dir unless File.directory? examples_dir
  end

  def remove_structure
    remove_doc
    remove_config
  end

  def remove_config
    FileUtils.rm_r config_dir if File.directory? config_dir
  end

  def remove_doc
    FileUtils.rm_r target_dir if File.directory? target_dir
  end

  def reset_structure
    remove_structure
    create_structure
  end

  def remove_examples
    FileUtils.rm_r examples_dir if File.directory? examples_dir
  end

  def generate_doc
    doc = ApplicationDoc.new

    routes_list.each do |route|
      doc.add_route(route)
    end

    generate_index_template( doc )
    generate_actions_templates( doc )
  end

  def routes_list
    Rails.application.routes.routes.collect do |route|
      ActionDispatch::Routing::RouteWrapper.new(route)
    end.reject do |route|
      route.internal?
    end
  end

end
