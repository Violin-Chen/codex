import subprocess
import time
import signal
import sys

COMMAND = ["get_stat", "-u", "y0085av3"]
INTERVAL = 20  # seconds

running = True

def handle_signal(signum, frame):
    global running
    running = False

signal.signal(signal.SIGINT, handle_signal)
signal.signal(signal.SIGTERM, handle_signal)

while running:
    try:
        subprocess.run(COMMAND, check=False)
    except Exception as exc:
        print(f"Failed to run {COMMAND}: {exc}", file=sys.stderr)
    for _ in range(INTERVAL):
        if not running:
            break
        time.sleep(1)

