require Rails.root.join('lib', 'console_methods')

Rails.application.config.after_initialize do
  include ConsoleMethods if defined?(Rails::Console)
end