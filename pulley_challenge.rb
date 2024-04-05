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

def extract_number_from_description(description)
  if match = description.match(/added (-?\d+) to ASCII value/)
    return match[1].to_i
  end
  nil
end

def hex_decode(hex_string)
  [hex_string].pack('H*')
end

def xor_decrypt(data, key)
  key_bytes = key.bytes.cycle
  data.bytes.map { |byte| (byte ^ key_bytes.next).chr }.join
end

def solve_challenge(challenge)
  # Since the first challenge did not require a real solution, move to the next step.
  encrypted_path = challenge['encrypted_path']
  next_uri = URI("https://ciphersprint.pulley.com/#{encrypted_path}")  # Base URL updated.

  puts "Getting 1 Level Challenge................................................................"
  next_challenge = get_challenge(next_uri)

  puts "Solving Level 1: Converted to a JSON array of ASCII values"
    # Decode the JSON array of ASCII values to a string.
  encrypted_path = JSON.parse(next_challenge['encrypted_path'].gsub('task_', '')).map { |ascii| ascii.chr }.join

  puts "Getting 2 Level Challenge................................................................"
  next_uri = URI("https://ciphersprint.pulley.com/task_#{encrypted_path}")
  next_challenge = get_challenge(next_uri)# Base URL updated.

  puts 'Solving Leve 2: inserted some non-hex characters'
  encrypted_path = next_challenge['encrypted_path'].sub('task_', '').gsub(/[^0-9a-f]/i, '')
  # Here you will add logic to solve the next challenge based on its content.
  puts "Next challenge to solve: #{next_challenge}"
  # This is a placeholder. You need to implement actual solution logic.

  puts "Getting Level 3 Challenge................................................................"
  next_uri = URI("https://ciphersprint.pulley.com/task_#{encrypted_path}")
  next_challenge = get_challenge(next_uri)# Base URL updated.

  ascii_value = extract_number_from_description(next_challenge['encryption_method'])
  puts "Solving Leve 3: Added #{ascii_value} to ASCII value of each character"
  encrypted_path = next_challenge['encrypted_path'].sub('task_', '').chars.map { |char| (char.ord - ascii_value).chr }.join

  puts "Getting Level 4 Challenge................................................................"
  next_uri = URI("https://ciphersprint.pulley.com/task_#{encrypted_path}")
  next_challenge = get_challenge(next_uri)# Base URL updated.

  puts "Solving Leve 4: hex decoded, encrypted with XOR, hex encoded again. key: secret"
  encrypted_path = next_challenge['encrypted_path'].sub('task_', '')
  hex_decoded = hex_decode(encrypted_path)
  decrypted_data = xor_decrypt(hex_decoded, "secret")

  puts "Getting Level 5 Challenge................................................................"
  next_uri = URI("https://ciphersprint.pulley.com/#{decrypted_data}")
  next_challenge = get_challenge(next_uri)# Base URL updated.
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
