# CipherSprint Challenge Solver

Write a program that solves the challenge returned by this API(<https://ciphersprint.pulley.com/>)
the first task will be returned by a GET request to /{your_email}

This Ruby script is designed to solve a series of progressively difficult encryption challenges from CipherSprint. It handles various encryption methods and provides a structured way to decode and solve each challenge.

## Features

- Handles multiple levels of encryption challenges.
- Supports decoding JSON arrays of ASCII values.
- Handles removal of non-hex characters.
- Adjusts ASCII values based on provided descriptions.
- Supports hex decoding, XOR decryption, and hex encoding.
- Decodes base64 encoded MessagePack data and unscrambles strings based on original positions.
- Attempts to handle SHA-256 hashed challenges with a dictionary attack.

## Prerequisites

- Ruby installed on your system.
- The following Ruby gems:
  - `json`
  - `base64`
  - `msgpack`
  - `digest`

Install the required gems using the following command:

```bash
gem install json base64 msgpack
```

## Run script

```bash
ruby pulley_challenge.rb
```

HAPPY CODING!
