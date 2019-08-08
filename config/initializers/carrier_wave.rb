CarrierWave.configure do |config|
  if Rails.env.staging? || Rails.env.production?
    config.storage = :fog
    config.fog_credentials = {
      :provider               => 'AWS',                        # required
      :aws_access_key_id      => ENV[:aws_access_key_id],                        # required
      :aws_secret_access_key  => ENV[:aws_secret_access_key],                        # required
      :region                 => 'us-west-1',                  # optional, defaults to 'us-east-1'
      :host                   => 's3.example.com',             # optional, defaults to nil
      :endpoint               => 'https://s3.example.com:8080' # optional, defaults to nil
    }
    config.fog_directory  = 'myflix-app-videos'                     # required
  else
    config.storage = :file
    config.enable_processing = Rails.env.development?
  end
end
