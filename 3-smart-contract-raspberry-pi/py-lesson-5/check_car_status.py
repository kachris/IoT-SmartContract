import asyncio
from change_car_status import change_car_status

lock = asyncio.Lock()

async def check_car_status(w3, icr, car_id) :
    async with lock:
        print("Checking car status")
        car = icr.functions.getCar(car_id).call() # Get the car
        status = car[2] # Get the status of the car
        if status == 2: # Check if status is OCCUPIED -> From the Enum Status {0:UNAVAILABLE, 1:AVAILABLE, 2:OCCUPIED}
            print("Car status is Occupied. Enabling Change Car Status")
            await change_car_status(w3, icr, car_id) # Call the change car status
            return True
        else:
            print("Car is not Occupied")
            return False

async def periodic_check_car_status(rent_time, w3, icr, car_id):
    interval = rent_time/2 # calculate the time per check
    while True:
        if await check_car_status(w3, icr, car_id): # check if status needs update
            continue
        else:
            await asyncio.sleep(interval) # sleep 
