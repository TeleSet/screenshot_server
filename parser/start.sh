#!/bin/bash

cd /opt/parser/

# python VENV
source venv/bin/activate
# python3 /opt/parser/main.py
ruby /opt/parser/main.rb
# VENV deactivate
deactivate
