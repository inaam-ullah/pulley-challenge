require 'net/http'
require 'uri'
require 'json'

def get_challenge(uri)
  response = Net::HTTP.get_response(uri)
  if response.is_a?(Net::HTTPSuccess)
    challenge = JSON.parse(response.body)
    puts "Challenge received: #{challenge}"
    challenge
  else
    puts "Failed to get challenge: #{response.message}"
    nil
  end
end

# Initialize the process with the first challenge URI
email = ENV['EMAIL']
base_uri = URI("https://ciphersprint.pulley.com/#{email}")  # Base URL and email updated.

puts 'Getting 0 Level Challenge................................................................'

get_challenge(base_uri)
