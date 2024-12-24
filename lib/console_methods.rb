# lib/console_methods.rb

module ConsoleMethods
  def find_controller(controller)
    controller = all_controller_names.find { |c| c[:controller].include?(controller) }
    return "Controller not found" unless controller
  
    # Define sections for better styling
    separator = "╒" + "═" * 50 + "╕\n"
    header = "  Controller Details\n"
    border = "╘" + "═" * 50 + "╛\n"
  
    # Controller info
    output = separator
    output += header
    output += separator
    output += "  Controller:       #{controller[:controller].capitalize}\n"
    output += "  Params method:    #{controller[:params_method]}\n"
    output += "  Permitted params: #{controller[:permitted_params].join(', ')}\n\n"
  
    # Additional info section
    output += "  Additional Info:\n"
    output += "    - Controller class: #{controller[:additional_info][:controller_class]}\n"
    output += "    - Method visibility: #{controller[:additional_info][:method_visibility]}\n"
  
    # Routes section
    output += "\n  Routes:\n"
    if controller[:additional_info][:routes].empty?
      output += "    No routes available.\n"
    else
      controller[:additional_info][:routes].each do |route|
        output += "    - #{route[:verb].ljust(6)} #{route[:path].ljust(30)} => #{route[:action]}\n"
      end
    end
  
    output += border
    puts output
  end
  
  
  def all_controller_names
    Rails.application.eager_load!
    controllers           = ApplicationController.descendants.map(&:name)
    routes                = Rails.application.routes.routes
    collected_controllers = []
    controllers.map do |controller|
      controller_class  = controller.constantize.new
      controller_name   = controller.split('::').last.gsub('sController', '').underscore
      params_method     = "#{controller_name}_params".to_sym
      source_location   = file_location = permitted_params = nil

      begin
        source_location   = controller_class.method(params_method).source_location
        file_location     = File.read(source_location[0]).lines[source_location[1] - 1, 10].join.gsub(/\s+/, ' ').strip
        permitted_params  = file_location.scan(/:(\w+)/).flatten.map(&:to_sym)
      rescue NameError
      # Handle the case where the method is not found
        source_location   = file_location = permitted_params = "undefined"
      end

      controller_routes   = routes.select do |route|
        (route.defaults[:controller]).to_s.include?(controller_name) && route.verb.present?
      end
      
      controller_routes   = controller_routes.map do |route|
        {
          verb: route.verb,
          path: route.path.spec.to_s,
          action: route.defaults[:action]
        }
      end

      collected_controllers << {
        controller: controller_name,
        params_method: params_method,
        permitted_params: permitted_params,
        additional_info: {
          controller_class: controller_class.class.name,
          method_defined: controller_class.respond_to?(params_method),
          method_visibility: controller_class.private_methods.include?(params_method) ? 'private' : 'public',
          routes: controller_routes
        }
      }
    end
    collected_controllers
  end
  
  private
  
  def fetch_permitted_params(controller_class, action)
    strong_params_method = "#{action}_params"
  
    if controller_class.private_instance_methods.include?(strong_params_method.to_sym)
      # Instantiate the controller to call the strong parameters method
      controller_instance = controller_class.new
      begin
        sample_params = ActionController::Parameters.new({ example: { key: "value" } })
        permitted = controller_instance.send(strong_params_method, sample_params)
        permitted.keys
      rescue StandardError => e
        "Error fetching permitted params: #{e.message}"
      end
    else
      "No strong parameters method defined for action '#{action}'"
    end
  end
end
