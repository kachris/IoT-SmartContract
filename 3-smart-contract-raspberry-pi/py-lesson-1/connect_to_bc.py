from web3 import Web3

def https_connection_to_blockchain():

    # Find a URL
    HTTPS_URL = "https://eth-sepolia.g.alchemy.com/v2/<KEY>"
    
    try:
        # Create a Web3 connection
        web3 = Web3(Web3.HTTPProvider(HTTPS_URL))
        
        # Check if connected
        if web3.is_connected():
            print("Connected to the Sepolia testnet successfully!")
            print(f"Chain ID: {web3.eth.chain_id}")
            return web3
        else:
            print("Failed to connect to the Sepolia testnet.")
            return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

if __name__ == "__main__":
    web3_instance = https_connection_to_blockchain()