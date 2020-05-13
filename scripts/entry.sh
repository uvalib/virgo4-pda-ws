#!/usr/bin/env bash

# run db migrations if available
rake db:migrate

# run the server
puma -e production -p 8080
