module Tekala
  class Master < Padrino::Application
    register Padrino::Mailer
    register Padrino::Helpers

    ##
    # Application configuration options
    #
    # set :raise_errors, true         # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true          # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true      # Shows a stack trace in browser (default for development)
    # set :logging, true              # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, "foo/bar"   # Location for static assets (default root/public)
    # set :reload, false              # Reload application files (default in development)
    # set :default_builder, "foo"     # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, "bar"         # Set path for I18n translations (default your_app/locales)
    # disable :sessions               # Disabled sessions by default (enable if needed)
    # disable :flash                  # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout              # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    enable :sessions            #使用sessions
    disable :store_location

    # Custom error management
    error(403) { @title = "Error 403"; render('errors/403', :layouts => :error) }
    error(404) { @title = "Error 404"; render('errors/404', :layouts => :error) }
    error(500) { @title = "Error 500"; render('errors/500', :layouts => :error) }
  end
end
