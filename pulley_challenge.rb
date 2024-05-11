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

def solve_challenge(challenge)
  # Since the first challenge did not require a real solution, move to the next step.
  encrypted_path = challenge['encrypted_path']
  next_uri = URI("https://ciphersprint.pulley.com/#{encrypted_path}")  # Base URL updated.

  # Here you will add logic to solve the next challenge based on its content.
  puts "Next challenge to solve: #{next_challenge}"
  # This is a placeholder. You need to implement actual solution logic.
end

# Initialize the process with the first challenge URI
email = ENV['EMAIL']
base_uri = URI("https://ciphersprint.pulley.com/#{email}")  # Base URL and email updated.

puts 'Getting Level 0 Challenge................................................................'

challenge = get_challenge(base_uri)

if challenge
  puts 'Solving Level 0 Challenge................................................................'
  solve_challenge(challenge)
end
