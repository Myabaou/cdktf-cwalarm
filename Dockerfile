# Use an official Node.js runtime as a parent image
FROM node:22

# Set the working directory in the container to /app
WORKDIR /app

# Install CDK for Terraform globally
RUN npm install --global cdktf-cli

# AWS CLIのインストール
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
	rm -rf awscliv2.zip

# Terraformインストール (執筆時点での最新版を導入してます。バージョン一覧 => https://releases.hashicorp.com/terraform/)
ENV TERRAFORM_VERSION=1.9.1
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm64.zip && \
    unzip ./terraform_${TERRAFORM_VERSION}_linux_arm64.zip -d /usr/local/bin/ && \
    rm ./terraform_${TERRAFORM_VERSION}_linux_arm64.zip


# Run the application when the container launches
CMD ["cdktf", "--version"]