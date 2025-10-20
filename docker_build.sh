#!/bin/bash

docker buildx build -f Dockerfile \
  --output type=local,dest=. \
  --progress=plain \
  .
