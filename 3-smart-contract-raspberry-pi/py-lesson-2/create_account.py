from eth_account import Account
from dotenv import load_dotenv, set_key

# Load existing environment variables
load_dotenv()

def create_and_save_account(env_file=".env"):

    # Create a new Ethereum account
    account = Account.create()
    public_address = account.address
    private_key = account.key.hex()

    print("New Ethereum account created:")
    print(f"Public Address: {public_address}")
    # print(f"Private Key: {private_key}") # NEVER DO THIS <<------

    # Save the account to the .env file
    set_key(env_file, "MC_ADDRESS", public_address)
    set_key(env_file, "MC_PRIVATE_KEY", private_key)

    print(f"Account saved to {env_file}. Keep this file secure!")
    # return public_address, private_key


if __name__ == "__main__":
    env_file = ".env"  # Define the .env file location
    create_and_save_account(env_file)
