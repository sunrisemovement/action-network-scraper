require 'dotenv'
require 'json'
require 'aws-sdk-s3'
require 'httparty'

require 'pry'
require 'rb-readline'

# Load environment variables (actionnetwork and S3)
Dotenv.load

# Query actionnetwork
response = HTTParty.get("https://actionnetwork.org/api/v2/forms/#{ENV['ACTIONNETWORK_FORM']}/", {
  headers: { 'OSDI-API-Token' => ENV['ACTIONNETWORK_KEY'] }
})
count = response['total_submissions']

# Copy to S3
s3 = Aws::S3::Client.new(
  access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  region: ENV['AWS_REGION']
)

s3.put_object(
  bucket: ENV['AWS_BUCKET'],
  acl: 'public-read',
  key: 'gnd-party-form-submission-count.json',
  body: JSON.dump({
    submission_count: count,
    updated_at: Time.now.to_s
  })
)
