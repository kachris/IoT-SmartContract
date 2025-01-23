from dotenv import load_dotenv
import os
from connect_to_bc import https_connection_to_blockchain
import load_json

load_dotenv()

# Address of the user that will make the transaction
MY_ADDRESS='YOUR-ADDRESS'
# Private key of the user that will make the transaction
MY_PRIVATE_KEY=os.getenv("MY_PRIVATE_KEY") # NEVER REVEAL THIS

w3 = https_connection_to_blockchain()

contract_address = "0x84606F263db7B839d484d0991d789cC0e688748C"
contract_abi = load_json.load_contract_abi("simple_storage_abi.json")
contract = w3.eth.contract(address=contract_address, abi=contract_abi)

# Check the previous number
prev_stored_number = contract.functions.getNumber().call()
print("Previous stored number: ", prev_stored_number)

# Build the transaction
# We call the function setNumber and we add as input the number 2 (you can change that)
transaction = contract.functions.setNumber(2).build_transaction({
    "from": MY_ADDRESS,
    "nonce": w3.eth.get_transaction_count(MY_ADDRESS), # The nonce is a unique number assigned to each transaction sent from an address.
    "gas": 200000, # Gas Limit: The maximum amount of gas you are willing to allow for this transaction
    "gasPrice": w3.to_wei("20", "gwei"), # Gas Price: The price (in wei) you are willing to pay per unit of gas.
})

# Sign the transaction
signed_tx = w3.eth.account.sign_transaction(transaction, MY_PRIVATE_KEY)

# Send the transaction
tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)

# Wait for the transaction receipt
receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

print(f"Transaction successful with hash: {w3.to_hex(tx_hash)}")
print("Number Changed")

# Check the new stored number
stored_number = contract.functions.getNumber().call()
print("New stored number: ", stored_number)