import os
from web3 import AsyncWeb3, WebSocketProvider
from eth_abi.abi import decode
from dotenv import load_dotenv, set_key
import load_json


# Load environment variables from .env file
load_dotenv()

# WebSocket RPC URL
WSS_URL = os.getenv("WSS_URL") 
# ICR Factory Address
FACTORY_ADDRESS = os.getenv("FACTORY_ADDRESS")
# ICR Factory ABI
factory_abi = load_json.load_contract_abi("factory_abi.json")
# ICR ABI
icr_abi = load_json.load_contract_abi("icr_abi.json")

def check_if_icr_info_exist(env_file):
    print("Checking if ICR info exists")
    existing_icr_address = os.getenv("ICR_ADDRESS")
    existing_car_id = os.getenv("CAR_ID")

    if existing_icr_address and existing_car_id:
        print(f"ICR Address and Car ID already exist in .env: {existing_icr_address}, {existing_car_id}")
        return True

    return False

async def subscribe_to_car_registered_event(w3, mc_address, env_file=".env"):
    print("ICR Address is the zero address. We will subscribe to Car Register To ICR event.")
    try:        
        car_registered_event_topic = w3.keccak(text="CarRegisteredToICR(address,uint256,address)") # topic we want to subscribe to
        filter_params = { 
            "address": FACTORY_ADDRESS,
            "topics": [car_registered_event_topic],
        } # Parameters of the filter 
        subscription_id = await w3.eth.subscribe("logs", filter_params) # create subscription
        print(f"Subscribing to CarRegisteredToICR event for ICRFactory at {subscription_id}")

        async for payload in w3.socket.process_subscriptions(): # get the payload
            result = payload["result"] 

            _icr_address = decode(["address"], result["topics"][1])[0] # ICR Address
            _car_id = decode(["uint256"], result["topics"][2])[0] # Car ID
            _mc = decode(["address"], result["topics"][3])[0] # Microcontroller Address

            #_icr_address = decode(["address"], bytes.fromhex(result["topics"][1][2:]))[0]
            #_car_id = decode(["uint256"], bytes.fromhex(result["topics"][2][2:]))[0]
            #_mc = decode(["address"], bytes.fromhex(result["topics"][3][2:]))[0]


            print(f"Event received: ICR Address: {_icr_address}, Car ID: {_car_id}, Microcontroller Address: {_mc}")

            if _mc.lower() == mc_address.lower():
                set_key(env_file, "ICR_ADDRESS", _icr_address)
                set_key(env_file, "CAR_ID", str(_car_id))
                print(f"Match found! Stored ICR Address: {_icr_address}, Car ID: {_car_id}")

                # Stop subscribing to CarRegisteredToICR events
                await w3.eth.unsubscribe(subscription_id)
                print("Unsubscribed from CarRegisteredToICR events.")
                return
    except Exception as e:
        print(f"Error during subscription: {e}")

async def find_matching_car(icr, mc_address, next_car_id, env_file=".env"):
    print("Check each car to find the match")
    for i in range(next_car_id):
        car = await icr.functions.getCar(i).call()
        mc = car[0]  # First element of the tuple is the microcontroller address
        if mc.lower() == mc_address.lower():
            set_key(env_file, "CAR_ID", str(i))
            print(f"Car found: ID {i} with Microcontroller {mc_address}")
            return True  # Return True when a matching car is found
    return False  # Return False if no matching car is found

async def get_next_car_id(icr):
    print('Retrieving next car ID')
    next_car_id = await icr.functions.getNextCarId().call()
    if next_car_id == 0:
        print("No cars registered in the ICR contract.")
        return 0
    return next_car_id


async def search_for_icr_info(w3, env_file, mc_address, factory_address, factory_abi, icr_abi):

    print("Check factory for matching ICR")

    # Interact with the factory contract
    factory = w3.eth.contract(address=w3.to_checksum_address(factory_address), abi=factory_abi)
    icr_address = await factory.functions.getMcToIcr(mc_address).call()

    # Check if the ICR address is not the zero address
    zero_address = "0x0000000000000000000000000000000000000000"
    if icr_address.lower() == zero_address:
        print("Matching ICR Address not found.")
        return False

    # ICR address found
    print(f"ICR Address found: {icr_address}")
    print("Storing address to env")
    set_key(env_file, "ICR_ADDRESS", icr_address) # store the address of ICR

    # Interact with the ICR contract
    icr = w3.eth.contract(address=w3.to_checksum_address(icr_address), abi=icr_abi)
    next_car_id = await get_next_car_id(icr)
    if next_car_id == 0:
        return False

    # Find matching car
    found = await find_matching_car(icr, mc_address, next_car_id, env_file)
    if not found:
        print("No matching car found in the ICR contract.")
    return found


async def fetch_icr_info_or_subscribe(w3, env_file=".env"):
    MC_ADDRESS = os.getenv("MC_ADDRESS")
    if check_if_icr_info_exist(env_file): # Check if ICR_ADDRESS and CAR_ID are already set
        print("ICR exists, continueing")
        return  # Exit if ICR_ADDRESS and CAR_ID are already set
    print("ICR info do not exist")
    print("Try to find matching ICR")
    try:
        # Process the ICR contract
        found = await search_for_icr_info( # Check if ICR_ADDRESS and CAR_ID are already stored in an ICR cotnract
            w3,
            env_file,
            MC_ADDRESS,
            FACTORY_ADDRESS,
            factory_abi,
            icr_abi
        )
        if not found:
            print("No matching car found.")
            # Call the function for subscribing to events
            await subscribe_to_car_registered_event(w3, MC_ADDRESS, env_file)

    except Exception as e:
        print(f"Error occurred: {e}")



async def synchronize_with_icr():
    print("Opening Async Web3")
    try:
        async with AsyncWeb3(WebSocketProvider(WSS_URL)) as w3:
            await fetch_icr_info_or_subscribe(w3)
    except Exception as e:
        print(f"Error during WebSocket connection: {e}")

