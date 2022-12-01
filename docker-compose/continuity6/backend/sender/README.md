## Sender tool

The objective of Sender tool is to transfer message files to input message MQ.
When the tool is started, it will first create a folder if not exists in **DATA_DIR** for each unit specificed in **UNITS**.

When a message file is put in ABC unit folder, then the message's unit will be set to ABC then sent to input message MQ.

### How to use it 

#### Technical requirements

- python 3.8 or higher

### Installation packages

Sender requires some packages before running 

```sh
pip3 install -r requirements.txt
```

### Configuration

The configuration of the tool is specified in the top of the tool (sender.py) as global variables

```python
MQ_REST_URL = "https://localhost:9443/ibmmq/rest/v1/messaging/"
MQ_USERNAME = "app"
MQ_PASSWORD = "passw0rd"
QUEUE_MANAGER = "QM1"
QUEUE = "DEV.QUEUE.1"
DATA_DIR = "../data"
UNITS = ["ANI_UNIT"]
```

Variable       |  description                                                           |
---------------|------------------------------------------------------------------------|
MQ_REST_URL    | MQ REST API URL                                                        |
MQ_USERNAME    | username of MQ REST API, make sure that the user has access to REST API|
MQ_PASSOWRD    | user password                                                          |
QUEUE_MANAGER  | queue manager                                                          |
DATA_DIR       | Path folder where sender is watching to retrieve data message          |
UNITS          | alert review units, sender creates subdirs with unit name in DATA_DIR  |

### Running

```sh
python3 sender.py
```
