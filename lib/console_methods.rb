# lib/console_methods.rb

module ConsoleMethods
  def find_controller(controller_name)
    # Input validation
    raise ArgumentError, "Controller name cannot be empty" if controller_name.nil? || controller_name.empty?
    
    # Find controller with case-insensitive matching
    controller = all_controller_names.find do |c| 
      c[:controller].downcase.include?(controller_name.downcase)
    end
    
    return "Controller not found: #{controller_name}" unless controller
  
    # Helper method for consistent section formatting
    def format_section(title, content)
      separator = "-" * [title.length, 20].max
      "\n#{title}\n#{separator}\n#{content}"
    end
  
    # Helper method for formatting key-value pairs
    def format_pair(key, value, indent = 0)
      spacing = " " * indent
      "#{spacing}#{key.to_s.ljust(20)}: #{value}"
    end
  
    # Build output sections
    controller_info = [
      format_pair("Controller", controller[:controller].capitalize),
      format_pair("Params method", controller[:params_method]),
      format_pair("Permitted params", "[#{controller[:permitted_params].keys.map { |key| ":#{key}" }.join(', ')}]")
    ].join("\n")
  
    # Format JSON structure with proper indentation
    json_structure = JSON.pretty_generate(controller[:permitted_params])
    controller_info += "\n\nJSON Structure:\n#{json_structure}"
  
    additional_info = [
      format_pair("Controller class", controller[:additional_info][:controller_class]),
      format_pair("Method visibility", controller[:additional_info][:method_visibility])
    ].join("\n")
  
    # Format routes section
    routes_content = if controller[:additional_info][:routes].empty?
      "    No routes available."
    else
      controller[:additional_info][:routes].map do |route|
        format_pair(route[:verb], "#{route[:path].ljust(30)} => #{route[:action]}", 2)
      end.join("\n")
    end
  
    # Combine all sections
    output = [
      format_section("Controller Information", controller_info),
      format_section("Additional Information", additional_info),
      format_section("Routes", routes_content)
    ].join("\n")
  
    # Print with color if available
    if defined?(Rainbow) || defined?(ColorizedString)
      # Use color gems if available
      puts output.to_s.green
    else
      puts output
    end
  rescue StandardError => e
    puts "Error: #{e.message}"
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
    permit_match = lines.match(/\.permit\((.*?)\)/)
    return {} unless permit_match
  
    permitted_params = permit_match[1]
    parse_permitted_params(permitted_params)
  end

  def parse_permitted_params(params_string)
    params = {}
    nested_params_regex = /(\w+):\s?\[(.*?)\]/

    # Extract flat parameters
    params_string.scan(/:(\w+)/).each do |match|
      params[match[0]] = '<your_value>'
    end

    # Extract nested parameters
    params_string.scan(nested_params_regex).each do |key, nested_fields|
      params[key] = nested_fields.split(', ').each_with_object({}) do |field, nested_hash|
        nested_hash[field.gsub(':', '').strip] = '<your_value>'
      end
    end

    params
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
