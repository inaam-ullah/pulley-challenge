require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'msgpack'
require 'digest'

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

def decode_messagepack(base64_encoded_msgpack)
  messagepack_data = Base64.decode64(base64_encoded_msgpack)
  MessagePack.unpack(messagepack_data)
end

def unscramble_string(scrambled_string, positions)
  unscrambled_array = Array.new(scrambled_string.length)
  positions.each_with_index do |original_index, scrambled_index|
    unscrambled_array[original_index] = scrambled_string[scrambled_index]
  end
  unscrambled_array.join
end

def extract_number_from_description(description)
  if match = description.match(/added (-?\d+) to ASCII value/)
    match[1].to_i
  end
end

def extract_base64_messagepack(description)
  if match = description.match(/scrambled! original positions as base64 encoded messagepack: (.+)/)
    match[1]
  end
end

def hex_decode(hex_string)
  [hex_string].pack('H*')
end

def hex_encode(binary_data)
  binary_data.unpack1('H*')
end

def xor_decrypt(data, key)
  key_bytes = key.bytes.cycle
  data.bytes.map { |byte| (byte ^ key_bytes.next).chr }.join
end

def solve_challenge(challenge)
  encrypted_path = challenge['encrypted_path']
  next_uri = URI("https://ciphersprint.pulley.com/#{encrypted_path}")

  puts 'Getting Level 1 Challenge...'
  next_challenge = get_challenge(next_uri)
  return unless next_challenge

  puts 'Solving Level 1: Convert to a JSON array of ASCII values'
  encrypted_path = JSON.parse(next_challenge['encrypted_path'].gsub('task_', '')).map(&:chr).join

  puts 'Getting Level 2 Challenge...'
  next_uri = URI("https://ciphersprint.pulley.com/task_#{encrypted_path}")
  next_challenge = get_challenge(next_uri)
  return unless next_challenge

  puts 'Solving Level 2: Remove non-hex characters'
  encrypted_path = next_challenge['encrypted_path'].sub('task_', '').gsub(/[^0-9a-f]/i, '')

  puts 'Getting Level 3 Challenge...'
  next_uri = URI("https://ciphersprint.pulley.com/task_#{encrypted_path}")
  next_challenge = get_challenge(next_uri)
  return unless next_challenge

  ascii_value = extract_number_from_description(next_challenge['encryption_method'])
  puts "Solving Level 3: Adjust ASCII values by #{ascii_value}"
  encrypted_path = next_challenge['encrypted_path'].sub('task_', '').chars.map { |char| (char.ord - ascii_value).chr }.join

  puts 'Getting Level 4 Challenge...'
  next_uri = URI("https://ciphersprint.pulley.com/task_#{encrypted_path}")
  next_challenge = get_challenge(next_uri)
  return unless next_challenge

  puts 'Solving Level 4: Hex decode, XOR decrypt, hex encode again. key: secret'
  encrypted_path = next_challenge['encrypted_path'].sub('task_', '')

  # Hex decode the encrypted_path
  hex_decoded = hex_decode(encrypted_path)

  # Decrypt the hex decoded data using XOR with the key "secret"
  decrypted_data = xor_decrypt(hex_decoded, 'secret')

  # Re-encode the decrypted data into hex
  re_encoded_hex = hex_encode(decrypted_data)

  begin
    next_uri = URI("https://ciphersprint.pulley.com/task_#{re_encoded_hex}")
  rescue URI::InvalidURIError
    puts "Invalid URI generated from decrypted data: 'task_#{re_encoded_hex.inspect}'"
    return
  end

  puts 'Getting Level 5 Challenge...'
  next_challenge = get_challenge(next_uri)
  return unless next_challenge

  base64_encoded_msgpack = extract_base64_messagepack(next_challenge['encryption_method'])
  puts 'Solving Level 5: Unscramble string using positions from base64 encoded messagepack'

  positions = decode_messagepack(base64_encoded_msgpack)
  encrypted_path = unscramble_string(next_challenge['encrypted_path'].sub('task_', ''), positions)

  next_uri = URI("https://ciphersprint.pulley.com/task_#{encrypted_path}")

  # Getting Level 6 Challenge
  puts 'Getting Level 6 Challenge...'
  next_challenge = get_challenge(next_uri)
  return unless next_challenge

  if next_challenge['encryption_method'] == 'hashed with sha256, good luck'
    puts "Level 6 Challenge is a gimmick: #{next_challenge['hint']}"

    # Log the challenge details for review
    puts "Challenger: #{next_challenge['challenger']}"
    puts "Encrypted Path: #{next_challenge['encrypted_path']}"
    puts "Encryption Method: #{next_challenge['encryption_method']}"
    puts "Expires In: #{next_challenge['expires_in']}"
    puts "Hint: #{next_challenge['hint']}"
    puts "Instructions: #{next_challenge['instructions']}"
    puts "Level: #{next_challenge['level']}"

    # Attempt to "solve" the SHA-256 hash challenge by acknowledging it
    original_path = next_challenge['encrypted_path'].sub('task_', '')
    if Digest::SHA256.hexdigest(original_path) == encrypted_path.split('_')[1]
      puts "Match found! Original path: #{original_path}"
    else
      puts 'No match found. Unable to solve this challenge as expected.'
    end

    return
  end

  # Continue with the next levels if there are any...
  puts 'Getting Next Level Challenge...'
  next_challenge = get_challenge(next_uri)
  return unless next_challenge

  puts "Next challenge to solve: #{next_challenge}"
  # Implement the logic to solve the next challenge here
end

# Initialize the process with the first challenge URI
email = ENV['EMAIL']
base_uri = URI("https://ciphersprint.pulley.com/#{email}")

puts 'Getting Level 0 Challenge...'
challenge = get_challenge(base_uri)

if challenge
  puts 'Solving Level 0 Challenge...'
  solve_challenge(challenge)
end
