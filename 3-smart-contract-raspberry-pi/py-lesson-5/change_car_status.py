import os
import asyncio


def get_remaining_time(w3, icr, car_id):
    car = icr.functions.getCar(car_id).call() # Get the car
    time_of_last_rent = car[3] # From the car get the time where the car was rented
    rent_time = icr.functions.getRentTime().call() # Get the renting time 
    time_to_change_status = time_of_last_rent + rent_time # Calculate the time the staus of the car should change
    current_block_timestamp = w3.eth.get_block('latest')['timestamp'] # Get the timestamp of the last block
    remaining_time = time_to_change_status - current_block_timestamp # Calculate the time the microcontroller should wait
    return remaining_time # Return the time in seconds

async def change_car_status(w3, icr, car_id):

    MC_ADDRESS=os.getenv("MC_ADDRESS")
    MC_PRIVATE_KEY=os.getenv("MC_PRIVATE_KEY")

    remaining_time = get_remaining_time(w3, icr, car_id) # Get the waiting time before making the transaction
    if remaining_time > 0:
        print(f"Waiting {remaining_time + 120} seconds") 
        await asyncio.sleep(remaining_time + 120) # Wait for waiting time plus 2 minutes
        # 2 minutes ensure that the block with the correct time has been created
    else:
        print("Renting time is over.")
    print("Starting transaction to change car's status")
    # Build the transaction
    transaction = icr.functions.changeCarStatusMc(car_id).build_transaction({
        "from": MC_ADDRESS,
        "nonce": w3.eth.get_transaction_count(MC_ADDRESS),
        "gas": 200000,
        "gasPrice": w3.to_wei("20", "gwei"),
    })

    # Sign the transaction
    signed_tx = w3.eth.account.sign_transaction(transaction, MC_PRIVATE_KEY)

    # Send the transaction
    tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)

    # Wait for the transaction receipt
    receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    print(f"Transaction successful with hash: {w3.to_hex(tx_hash)}")
    print("Status Changed")
