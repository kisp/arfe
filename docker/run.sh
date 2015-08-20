#!/bin/bash

exec docker run -ti --rm -p 8000:8000 -p 127.0.0.1:4005:4005 ${1:-kisp/arfe}
