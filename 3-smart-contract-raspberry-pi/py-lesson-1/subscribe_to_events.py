import asyncio
from web3 import AsyncWeb3, WebSocketProvider
from eth_abi.abi import decode

WSS_URL = "wss://eth-sepolia.g.alchemy.com/v2/<KEY>" 

contract_address = "0x84606F263db7B839d484d0991d789cC0e688748C"

async def subscribe_to_number_set_event():

    try:
        async with AsyncWeb3(WebSocketProvider(WSS_URL)) as w3:
            number_set_event_topic = w3.keccak(text="NumberSet(uint256)")
            filter_params = {
                "address": contract_address,
                "topics": [number_set_event_topic],
            }

            subscription_id = await w3.eth.subscribe("logs", filter_params)
            print(f"Subscribing to NumberSet event for SimpleStorage at {subscription_id}")

            async for payload in w3.socket.process_subscriptions():
                result = payload["result"]
                stored_number = decode(["uint256"], result["topics"][1])[0]

                print(f"Event received: Stored Number: {stored_number}")

                await w3.eth.unsubscribe(subscription_id)
                print("Unsubscribed from NumberSet events.")
                return

    except Exception as e:
        print(f"Error during subscription: {e}")

if __name__ == "__main__":
    asyncio.run(subscribe_to_number_set_event())