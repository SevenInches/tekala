# -*- encoding : utf-8 -*-
# Defines our constants
RACK_ENV = ENV['RACK_ENV'] ||= 'development'  unless defined?(RACK_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)
TEST = '123456'

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, RACK_ENV)

require File.join(PADRINO_ROOT, 'config', 'workers.rb')

##
# ## Enable devel logging
#
# Padrino::Logger::Config[:development][:log_level]  = :devel
# Padrino::Logger::Config[:development][:log_static] = true
#
# ## Configure your I18n
#
# I18n.default_locale = :en
# I18n.enforce_available_locales = false
#
# ## Configure your HTML5 data helpers
#
# Padrino::Helpers::TagHelpers::DATA_ATTRIBUTES.push(:dialog)
# text_field :foo, :dialog => true
# Generates: <input type="text" data-dialog="true" name="foo" />
#
# ## Add helpers to mailer
#
# Mail::Message.class_eval do
#   include Padrino::Helpers::NumberHelpers
#   include Padrino::Helpers::TranslationHelpers
# end

##
# Add your before (RE)load hooks here
#
Qiniu.establish_connection! :access_key => '9WVKGJnvlLpWPLMjOSEcjZr0v6i6_q-j1ijzuUXf',
							:secret_key => 'aNONeq-rGH6l0BRAHH012Uf3MTDAxWxWGCKXGQtF'
							

Padrino.before_load do
  require 'will_paginate'
  require 'will_paginate/data_mapper'
  require 'will_paginate/view_helpers/sinatra'
  require 'net/https'
  require 'uri'
  require 'rest-client'
  include WillPaginate::Sinatra::Helpers
  I18n.default_locale = :zh_cn
  WillPaginate.per_page = 20
end

##
# Add your after (RE)load hooks here
#
Padrino.after_load do
  DataMapper.finalize
end

Padrino.load!
