module Tekala
  class Future < Padrino::Application
    register Padrino::Mailer
    register Padrino::Helpers
    enable  :sessions
    Rabl.register!
  end
end