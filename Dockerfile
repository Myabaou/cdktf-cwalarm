# Use an official Node.js runtime as a parent image
FROM node:20

# Set the working directory in the container to /app
WORKDIR /app

# Copy package.json and package-lock.json into the working directory
COPY package*.json ./

# Install CDK for Terraform globally
RUN npm install --global cdktf-cli

# Install any needed packages specified in package.json
RUN npm install

# Copy the rest of the working directory contents into the container
COPY . .

# AWS CLIのインストール
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
	rm -rf awscliv2.zip

# aws-vaultのインストール
RUN wget https://github.com/99designs/aws-vault/releases/download/v7.2.0/aws-vault-linux-arm64 && \
    chmod +x aws-vault-linux-arm64 && \
    mv aws-vault-linux-arm64 /usr/local/bin/aws-vault


# Terraformインストール (執筆時点での最新版を導入してます。バージョン一覧 => https://releases.hashicorp.com/terraform/)
RUN wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_arm64.zip && \
    unzip ./terraform_1.5.7_linux_arm64.zip -d /usr/local/bin/ && \
    rm ./terraform_1.5.7_linux_arm64.zip

# aws-vaultのバックエンドをファイルに設定
ENV AWS_VAULT_BACKEND=file


# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run the application when the container launches
CMD ["cdktf", "--version"]