# -*- encoding : utf-8 -*-
require "digest/md5"
# require 'carrierwave/processing/mini_magick'

class ChannelQrcode < CarrierWave::Uploader::Base

  ##
  # Image manipulator library:
  #
  include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  storage :file


  def root; File.join(Padrino.root,"public/"); end
  
  def store_dir
    'upload/channel_qrcode'
  end


  def cache_dir
    Padrino.root("tmp")
  end

  version :thumb do
    process :resize_to_fill => [320, 320]
  end

  version :big do
    process :resize_to_fill => [800, 800]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    "images/#{secure_token(16)}.png" if original_filename.present?
  end

  protected
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end

end
