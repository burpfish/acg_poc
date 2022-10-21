FROM gitpod/workspace-full:latest

ARG AWS_CLI_V2_URL='https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip'

# Install tools as the gitpod user
USER gitpod
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install helper tools
RUN brew update && brew upgrade && brew install \
    gawk coreutils pre-commit tfenv terraform-docs \
    tflint tfsec instrumenta/instrumenta/conftest \
    && brew install --ignore-dependencies cdktf \
    && brew cleanup
RUN tfenv install latest && tfenv use latest

RUN mv $(which aws) /usr/local/bin/awscliv1 && \
  curl "${AWS_CLI_V2_URL}" -o "/tmp/awscliv2.zip" && \
  unzip /tmp/awscliv2.zip -d /tmp && \
  /tmp/aws/install
  
COPY .gitpod.bashrc /home/gitpod/.bashrc.d/custom

# Give back control
USER root

#  and revert back to default shell
#  otherwise adding Gitpod Layer will fail
SHELL ["/bin/sh", "-c"]
