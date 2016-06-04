# -*- encoding : utf-8 -*-
require "digest/md5"
# require 'carrierwave/processing/mini_magick'

class AdImage < CarrierWave::Uploader::Base

  ##
  # Image manipulator library:
  #
  include CarrierWave::RMagick
  # include CarrierWave::ImageScience
  include CarrierWave::MiniMagick

  # storage :qiniu
  ##
  # Storage type
  #
  storage :file
  # configure do |config|
  #   config.fog_credentials = {
  #     :provider              => 'XXX',
  #     :aws_access_key_id     => 'YOUR_ACCESS_KEY',
  #     :aws_secret_access_key => 'YOUR_SECRET_KEY'
  #   }
  #   config.fog_directory = 'YOUR_BUCKET'
  # end
  # storage :fog



  ## Manually set root
  def root; File.join(Padrino.root,"public/"); end

  ##
  # Directory where uploaded files will be stored (default is /public/uploads)
  #
  def store_dir
    'upload/ads'
  end

  ##
  # Directory where uploaded temp files will be stored (default is [root]/tmp)
  #
  def cache_dir
    Padrino.root("tmp")
  end

  ##
  # Default URL as a default if there hasn't been a file uploaded
  #
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Override the directory where uploaded files will be stored.
  # def store_dir
  #   "uploads/screenshots/#{model.id}"
  # end

  # process :convert => 'png'

  # # Create different versions of your uploaded files:
  version :thumb do
    process :resize_to_fill => [640, 320]
  end

  version :big do
    process :resize_to_fill => [800, 800]
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
