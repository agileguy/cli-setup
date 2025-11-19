FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl

RUN curl -sL https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/install.sh  | bash

RUN echo "*** FINISHED ***"
