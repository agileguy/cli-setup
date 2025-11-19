FROM ubuntu:latest

RUN echo "*** STARTED ***"

RUN apt-get update && apt-get install -y curl

RUN curl -o install.sh https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/install.sh
RUN chmod +x install.sh
RUN install.sh

RUN echo "*** FINISHED ***"
