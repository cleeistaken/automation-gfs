#! /usr/bin/env python3
# Script to get the local IP of the system.
import socket
import json
print(json.dumps({"ip": socket.gethostbyname(socket.gethostname())}))
