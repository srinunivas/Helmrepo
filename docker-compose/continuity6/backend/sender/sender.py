##### CONFIGURATION OF MQ REST API #####
import os

import requests
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)



MQ_REST_URL = "https://localhost:9443/ibmmq/rest/v1/messaging/"
MQ_USERNAME = "app"
MQ_PASSWORD = "passw0rd"
QUEUE_MANAGER = "QM1"
QUEUE = "DEV.QUEUE.1"
DATA_DIR = "../data"
UNITS = ["ANI_UNIT", "SWIFT","SIC"]

FULL_REST_MSG_URL = f"{MQ_REST_URL}/qmgr/{QUEUE_MANAGER}/queue/{QUEUE}/message"


class Watcher:
     def __init__(self):
          self.observer= Observer()
          self.observers = []
     def run(self):
          for unit in UNITS:
               event_handler = Handler(unit)
               dir_watched = f"{DATA_DIR}/{unit}"
               if not os.path.exists(dir_watched):
                    os.mkdir(dir_watched)
               print(f"listening on '{dir_watched}' directory...")
               self.observer.schedule(event_handler, dir_watched)
               self.observers.append(self.observer)
          
          self.observer.start()
          try:
               while True:
                    time.sleep(1)
          except KeyboardInterrupt as e:
               print("Stopping gracefully...")
               for observer in self.observers:
                  observer.unschedule_all()
                  observer.stop()
          for observer in self.observers:
               observer.join()


class Handler(FileSystemEventHandler):
     def __init__(self, unit):
          self.unit = unit
     
     def on_created(self, event):
          if event.is_directory:
               return None
          print(f"new file found {event.src_path}")
          response = send_msg(event.src_path, self.unit)
          if response.status_code >=200 and response.status_code < 300:
               print(f"message has been sent with sucess: {response.status_code}")
               os.remove(event.src_path)
          else:
               print(f"Failed to send the message for unit: {self.unit}")
               print(f"Status: {response.status_code}")
               print(f"reason: {response.text}")



def send_msg(file, unit):
     message = open(file,mode='r')
     data = message.read()
     len_unit = len(unit)
     data = data[:324]+unit+(' '*(15-len_unit))+data[324+15:]
     return requests.post(FULL_REST_MSG_URL, auth=(MQ_USERNAME,MQ_PASSWORD), data=data, verify=False, headers= {
          'ibm-mq-rest-csrf-token':  'blank',
          'Content-Type': 'text/plain;charset=utf-8'
     })
def printbanner():
     banner_file="banner.txt"
     if os.path.exists(banner_file):
          f = open(banner_file)
          banner = f.read()
          print(banner)
          print()
if __name__ == '__main__':
     printbanner()
     w = Watcher()
     w.run()