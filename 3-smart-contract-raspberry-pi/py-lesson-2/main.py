from os import path
from dotenv import load_dotenv
import os
import asyncio

import load_json
from https_connection_to_bc import https_connection_to_bc # previously named connect_to_bc

async def main():
    # Load environment variables from .env
    load_dotenv(override=True)

    env_file = ".env"
    # Check if the .env file exists and has PUBLIC_ADDRESS and PRIVATE_KEY
    if not path.exists(env_file) or not os.getenv("MC_ADDRESS") or not os.getenv("MC_PRIVATE_KEY"):
        print("No account found. Creating a new Ethereum account...")
        # Create an address and private key
        create_and_save_account(env_file)
        load_dotenv(override=True)
    else:
        # If account already exists, load it
        MC_ADDRESS = os.getenv("MC_ADDRESS")
        print("Account already exists:")
        print(f"Public Address: {MC_ADDRESS}")
    # Synchronize with ICR Contract
        # At the same time
        # Peridically check if car is occupied (and change status to available if needed)
    # Wait for a signed message from a user to unlock the car
if __name__ == "__main__":