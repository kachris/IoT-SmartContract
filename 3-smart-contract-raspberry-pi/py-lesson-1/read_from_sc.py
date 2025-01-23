from connect_to_bc import https_connection_to_blockchain
import load_json

w3 = https_connection_to_blockchain()

# smart contract address
contract_address = "0x84606F263db7B839d484d0991d789cC0e688748C"

# smart contract abi
contract_abi = load_json.load_contract_abi("simple_storage_abi.json")

# instantiate contract with address and abi
contract = w3.eth.contract(address=contract_address, abi=contract_abi)

# call getNumer() function from the samrt contract
stored_number = contract.functions.getNumber().call()

# print the result
print(stored_number)

