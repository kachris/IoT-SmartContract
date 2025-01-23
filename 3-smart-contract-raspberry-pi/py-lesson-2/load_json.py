import json

def load_contract_abi(abi_file_path):
    with open(abi_file_path, "r") as file:
        return json.load(file)