
# -*- encoding : utf-8 -*-
require "digest/md5"
# require 'carrierwave/processing/mini_magick'

class MapPhoto < CarrierWave::Uploader::Base

  storage :qiniu

  def version_names
    %w( 220X178 320X240 480X320 )
  end

  def module_name 
    'avatar'
  end
  def extension_white_list
    %w( jpg jpeg gif png )
  end
end
