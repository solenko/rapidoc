module Rapidoc

  ##
  # This module let generate index file and actions files from templates.
  #
  module TemplatesGenerator

    def generate_index_template( resources_doc )
      template = Template.new(gem_templates_dir('index.html.erb'), :info => OpenStruct.new(rapidoc_config), :resources => resources_doc)
      File.open( target_dir("index.html"), 'w' ) { |file| file.write template.result }
    end


    # Get bootstrap label for a method
    def get_method_label( method )
      case method
      when 'GET'
        'label label-info'
      when 'POST'
        'label label-success'
      when 'PUT'
        'label label-warning'
      when 'DELETE'
        'label label-important'
      else
        'label'
      end
    end

    def generate_actions_templates( resources_doc )
      resources_doc.each do |resource|
        if resource.actions_doc
          resource.actions_doc.each do |action_doc|
            if action_doc.has_controller_info
              create_action_template( get_action_template, action_doc )
            end
          end
        end
      end
    end

    def create_action_template( template, action_doc )
      result = template.call( :info => rapidoc_config, :action => action_doc )
      filename = actions_dir("#{action_doc.file}.html")
      dir_name = File.dirname(filename)
      FileUtils.mkdir_p dir_name unless File.directory?(dir_name)
      File.open( filename, 'w' ) { |file| file.write result }
    end

    def get_action_template
      template = IO.read( gem_templates_dir('action.html.hbs') )
      handlebars = Handlebars::Context.new
      handlebars.compile( template )
    end
  end

  class Template
    include Rapidoc::Helpers

    def initialize(file_name, bindings = {})
      @file_name = file_name
      bindings.each_pair do |key,value|
        singleton_class.send(:define_method, key) { value }
      end
    end

    def result
      template.result(get_binding)
    end

    private

    def get_binding
      binding
    end

    def template

      erb = ERB.new(IO.read(@file_name))
    end
  end
end
