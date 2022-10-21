FROM gitpod/workspace-full:latest

# Install helper tools
RUN brew update && brew upgrade && brew install \
    gawk coreutils pre-commit tfenv terraform-docs \
    tflint tfsec \
    && brew install --ignore-dependencies cdktf \
    && brew cleanup
RUN tfenv install latest && tfenv use latest
