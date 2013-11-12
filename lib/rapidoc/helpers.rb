module Rapidoc
  module Helpers

    # Get bootstrap label for a method
    def method_class( method )
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
  end
end