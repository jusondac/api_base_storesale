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
    
    controllers = ApplicationController.descendants.map(&:name)
    routes = Rails.application.routes.routes
  
    controllers.map do |controller|
      {
        controller: extract_controller_name(controller),
        params_method: fetch_params_method_name(controller),
        permitted_params: fetch_permitted_params(controller),
        additional_info: {
          controller_class: fetch_controller_class(controller),
          method_defined: method_defined?(controller),
          method_visibility: method_visibility(controller),
          routes: fetch_controller_routes(controller, routes)
        }
      }
    end
  end
  
  private
  
  # Extract the controller name from the full class name
  def extract_controller_name(controller)
    controller.split('::').last.gsub('sController', '').underscore
  end
  
  # Generate the params method name
  def fetch_params_method_name(controller)
    "#{extract_controller_name(controller)}_params".to_sym
  end
  
  # Fetch the permitted parameters for the controller
  def fetch_permitted_params(controller)
    controller_class = instantiate_controller(controller)
    params_method = fetch_params_method_name(controller)
  
    begin
      source_location = controller_class.method(params_method).source_location
      file_content = File.read(source_location[0])
      extract_permitted_params(file_content, source_location[1])
    rescue NameError
      "undefined"
    end
  end
  
  # Extract permitted parameters from the source file content
  def extract_permitted_params(file_content, start_line)
    lines = file_content.lines[start_line - 1, 10].join.gsub(/\s+/, ' ').strip
    lines.scan(/:(\w+)/).flatten.map(&:to_sym)
  end
  
  # Fetch the class of the controller
  def fetch_controller_class(controller)
    instantiate_controller(controller).class.name
  end
  
  # Instantiate the controller class
  def instantiate_controller(controller)
    controller.constantize.new
  end
  
  # Check if the params method is defined in the controller
  def method_defined?(controller)
    controller_class = instantiate_controller(controller)
    params_method = fetch_params_method_name(controller)
    controller_class.respond_to?(params_method)
  end
  
  # Determine the visibility of the params method
  def method_visibility(controller)
    controller_class = instantiate_controller(controller)
    params_method = fetch_params_method_name(controller)
    controller_class.private_methods.include?(params_method) ? "private" : "public"
  end
  
  # Fetch routes associated with the controller
  def fetch_controller_routes(controller, routes)
    controller_name = extract_controller_name(controller)
    
    controller_routes = routes.select do |route|
      route.defaults[:controller].to_s.include?(controller_name) && route.verb.present?
    end
    
    controller_routes.map do |route|
      {
        verb: route.verb,
        path: route.path.spec.to_s,
        action: route.defaults[:action]
      }
    end
  end
end
