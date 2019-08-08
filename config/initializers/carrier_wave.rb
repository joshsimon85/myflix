CarrierWave.configure do |config|
  if Rails.env.staging? || Rails.env.production?
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => ENV['aws_access_key_id'],
      :aws_secret_access_key  => ENV['aws_secret_access_key'],
    }
    config.storage = :fog
    config.fog_directory  = 'myflix-app-videos'
  else
    config.storage = :file
    config.enable_processing = Rails.env.development?
  end
end
