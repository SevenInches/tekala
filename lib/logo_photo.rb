
# -*- encoding : utf-8 -*-
require "digest/md5"
# require 'carrierwave/processing/mini_magick'

class LogoPhoto < CarrierWave::Uploader::Base

  include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  storage :file
  
  def store_dir
    'upload/logo_photo'
  end

  def cache_dir
    Padrino.root("tmp")
  end

  version :thumb do
    process :resize_to_fill => [180, 180]
  end

  version :big do
    process :resize_to_fill => [502, 576]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    "images/#{secure_token(16)}.png" if original_filename.present?
    # {file.extension}
  end

  protected
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end

  ##
  # Override the filename of the uploaded files
  #
  # def filename
  #   "something.jpg" if original_filename
  # end
end
