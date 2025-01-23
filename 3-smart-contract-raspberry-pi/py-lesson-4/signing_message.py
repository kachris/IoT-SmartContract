from web3 import Web3
from eth_account.messages import encode_defunct
import os
from dotenv import load_dotenv 

load_dotenv(override=True)

HTTPS_URL = os.getenv("HTTPS_URL")
# Connect to a Web3 provider
w3 = Web3(Web3.HTTPProvider(HTTPS_URL))

# Private key of the signers
OWNERS_PRIVATE_KEY = os.getenv("OWNERS_PRIVATE_KEY")
USERS_PRIVATE_KEY = os.getenv("USERS_PRIVATE_KEY")

# Message to sign
message = "Unlock Car"
# Hash the message 
message_hash = encode_defunct(text=message)

# Sign the hashed message
owners_signed_message = w3.eth.account.sign_message(
    message_hash, private_key=OWNERS_PRIVATE_KEY
)
owner_address = w3.eth.account.recover_message(message_hash, signature=owners_signed_message.signature)

users_signed_message = w3.eth.account.sign_message(
    message_hash, private_key=USERS_PRIVATE_KEY
)
users_address = w3.eth.account.recover_message(message_hash, signature=users_signed_message.signature)

# Print the signature components
print("Owner's signed message signature: ", owners_signed_message.signature)
print("Owner's address: ", owner_address)

print("Users's signed message signature: ", users_signed_message.signature)
print("Users's address: ", users_address)