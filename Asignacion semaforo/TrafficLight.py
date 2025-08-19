import time
import threading
import random

class TrafficLight:
    def __init__(self, name):
        self.name = name
        self.state = "RED"

    def set_state(self, new_state, duration=None):
        if self.state != new_state:
            if self.state == "RED" and new_state == "YELLOW":
                return

            print(f"\n{self.name.upper()}: {self.state} → {new_state}" +
                  (f" ({duration} seconds)" if duration else ""))
            self.state = new_state
            time.sleep(1)


class PedestrianSignal:
    def __init__(self, accessibility=False):
        self.state = "DON'T WALK"
        self.requested = False
        self.accessibility = accessibility

    def request_crossing(self):
        self.requested = True
        print("\nPEDESTRIAN: *Button Pressed*")

    def activate(self):
        walk_time = 60 if self.accessibility else 30
        print(f"\nPEDESTRIAN: {self.state} → WALK ({walk_time} seconds)")
        time.sleep(1)
        print("\nPEDESTRIAN: WALK → DON'T WALK")
        self.requested = False
        self.state = "DON'T WALK"


class TrafficController:
    def __init__(self, peak_hours=False, accessibility=False):
        self.main_light = TrafficLight("Main Road")
        self.side_light = TrafficLight("Side Road")
        self.pedestrian = PedestrianSignal(accessibility)
        self.peak_hours = peak_hours

    def run_cycle(self, cycle_number):
        if self.peak_hours:
            main_green_time = 90
        else:
            main_green_time = 60
        side_green_time = 40
        yellow_time = 5

        print(f"\n--- Cycle {cycle_number} | {'peak hour' if self.peak_hours else 'normal hours'} ---")

        self.main_light.set_state("GREEN", main_green_time)
        self.side_light.set_state("RED")
        time.sleep(1)

        self.main_light.set_state("YELLOW", yellow_time)
        time.sleep(1)

        self.main_light.set_state("RED")
        self.side_light.set_state("GREEN", side_green_time)

        interrupted = False
        for sec in range(side_green_time):
            time.sleep(0.1)
            if self.pedestrian.requested and sec >= 30:
                print(f"\n(Side Road green interrupted at {sec + 1} seconds for pedestrian)")
                self.side_light.set_state("YELLOW", yellow_time)
                time.sleep(1)
                self.side_light.set_state("RED")
                self.pedestrian.activate()
                interrupted = True
                break

        if not interrupted:
            self.side_light.set_state("YELLOW", yellow_time)
            time.sleep(1)
            self.side_light.set_state("RED")

    def start(self, cycles=2):
        print("\n=== TRAFFIC SIMULATION START ===\n")
        for i in range(1, cycles + 1):
            self.peak_hours = (i % 2 != 0)
            self.run_cycle(i)
        print("\n=== SIMULATION END ===\n")


controller = TrafficController(peak_hours=True, accessibility=True)

stop_event = threading.Event()

def random_pedestrians(stop_event, num_attempts=5, press_probability=0.3, max_delay=30):
    for _ in range(num_attempts):
        if stop_event.is_set():
            break
        time.sleep(random.uniform(0.1, max_delay))
        if random.random() < press_probability:
            controller.pedestrian.request_crossing()

ped_thread = threading.Thread(target=random_pedestrians, args=(stop_event, 50, 0.3, 15))
ped_thread.start()

controller.start(cycles=3)

stop_event.set()
ped_thread.join()