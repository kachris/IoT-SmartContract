import asyncio
from eth_account.messages import encode_defunct

lock = asyncio.Lock()

message = "Unlock Car"
message_hash = encode_defunct(text=message)


async def unlock_car():
    async with lock:
        try:
            print("Car is unlocked for 60 seconds")
            await asyncio.sleep(60)  # Wait for 60 seconds
        except asyncio.CancelledError:
            print("Unlocking was interrupted before 60 seconds.")
        finally:
            print("Car is locked again.")

def check_if_user_is_current_renter(user_address, icr, car_id):
    print(f"Checking if user {user_address} is current renter")
    car = icr.functions.getCar(car_id).call()
    current_renter = car[4]
    if current_renter.lower() == user_address.lower():
        print(f"User {user_address} is current renter")
        return True
    print(f"User {user_address} is not current renter")
    return False

async def handle_signing_for_unlock(w3, icr, car_id):
    while True:
        # Use asyncio.to_thread to handle blocking input call
        user_input = await asyncio.to_thread(input, "Enter your Message: ")
        # Turn user input into bytes
        data_user_input = bytes(user_input, "utf-8").decode("unicode_escape").encode("latin1")
        try:  
            # Extract wallet address using the message and the signature
            user_address = w3.eth.account.recover_message(message_hash, signature=data_user_input)
            print(f"User {user_address} trying to unlock the car")
            if check_if_user_is_current_renter(user_address, icr, car_id):
                await unlock_car()
        except Exception as e:
            print(f"Error: {e}")
