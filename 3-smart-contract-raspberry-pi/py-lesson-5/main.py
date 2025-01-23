from os import path
from dotenv import load_dotenv
import os
import asyncio

import load_json
from https_connection_to_bc import https_connection_to_bc
from create_account import create_and_save_account  
from icr_synchronizer import synchronize_with_icr
from check_car_status import periodic_check_car_status
from unlock_car_by_message import handle_signing_for_unlock


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
    
    print("Fetch ICR data from event or already existing")
    # Synchronize with ICR Contract
    await synchronize_with_icr()
    load_dotenv(override=True)

    w3 = https_connection_to_bc()

    ICR_ADDRESS = os.getenv("ICR_ADDRESS")
    icr_abi = load_json.load_contract_abi("icr_abi.json")
    icr = w3.eth.contract(address=w3.to_checksum_address(ICR_ADDRESS), abi=icr_abi)

    rent_time = icr.functions.getRentTime().call()

    CAR_ID = int(os.getenv("CAR_ID"))
    # At the same time
        # Peridically check if car is occupied (and change status to available if needed)
        # Wait for a signed message from a user to unlock the car
    await asyncio.gather(
        periodic_check_car_status(rent_time, w3, icr, CAR_ID),
        handle_signing_for_unlock(w3, icr, CAR_ID)
    )

    

if __name__ == "__main__":
    asyncio.run(main())