# cdktf-cwalarm

This is a Cloudwatch Alarm module using CDK for Terraform.

## Prerequisites

- Chatbot and Slack are already integrated. For more details, refer to this [guide](https://aws.amazon.com/jp/builders-flash/202006/slack-chatbot/?awsf.filter-name=*all).
- An S3 Bucket for storing Terraform State is already created. This bucket is used to store the state of your infrastructure so that Terraform can plan and make changes accordingly.
- aws-vault is installed. This is a tool to securely store and access AWS credentials in a development environment. You need to change `_AWSPROFILE=aws-sample` in the Makefile to your own profile.

## SetUp

- node module install

```sh
make install
```

- terraform module install

```sh
make get
```

## Cloudwatch Alarm Configure

- Create a Slack Config File.
Specify the value of the bucket as the pre-created S3 Bucket. Set the Channel ID and Workspace ID of Slack.

```cw_configs.ts
export const TerraformConfigs = {
 backend: {
  bucket: '<S3 Bucket Name>', // Example: 'my-terraform-state-bucket'
  region: 'ap-northeast-1', // Example: 'us-west-2'
 }
}

export const CloudwatchConfigs = {

 slackConfig: {
  SlackChannelId: 'CXXXXXXXX', // Slack Channel ID
  SlackWorkspaceId: 'TXXXXXX' // Slack Workspace ID
 },
};

```

## Apply Changes

- DryRun: This command will show you what changes Terraform will apply without actually applying the

```sh
make diff
```

- Apply: This command applies the changes.

```sh
make deploy
```

## Execution with Terraform

By specifying TF=true as an argument, you can execute the terraform command.

```sh
make _TF=true "state list"
```

- Output

```sh
[INFO]: AWS SSO aws-sample Authentication successful!
[CMD]:  aws-vault exec aws-sample -- terraform -chdir=cdktf.out/stacks/cloudwatch_alarm state list
aws_cloudformation_stack.chatbot
aws_iam_role.alert-to-slack
aws_sns_topic.ToSlack
module.ec2_Maximum_alarm_CPUUtilization.aws_cloudwatch_metric_alarm.this[0]
```

## Destroy

This command will destroy all resources created by Terraform.

```sh
make destroy
```

## Conversion to HCL

If the version of CDK for Terraform is 0.20 or above, it is possible to output in HCL format.

```sh
make "synth --hcl"
```

The HCL format file will be output to `cdktf.out/stacks/cloudwatch_alarm/cdk.tf`.

## Docker Execution

- Build

```sh
make build
```

- Docker cdk for Terraform Execution

```sh
make _EXEC=docker diff
```

- Docker Execution

```sh
docker compose run cdk-tf ls
```

```sh
docker compose run -e AWS_PROFILE=aws-sample cdk-tf cdktf diff
```

- Execution of cdktf (deprecated)

```sh
docker compose run cdk-tf make diff
```

```log
Opening the SSO authorization page in your default browser (use Ctrl-C to abort)
https://device.sso.ap-northeast-1.amazonaws.com/?user_code=SXXX-XXXX
Enter passphrase to unlock "/root/.awsvault/keys/":
```

When asked, open the output URL in your browser and allow it. For the password, enter the aws-vault password.

- Execution of Terraform

```sh
docker compose run -e AWS_PROFILE=aws-sample cdk-tf /bin/sh -c "terraform -chdir='cdktf.out/stacks/cloudwatch_alarm' init && terraform -chdir='cdktf.out/stacks/cloudwatch_alarm' plan"
```

## Finch Execution

```sh
make _EXEC=finch build
```

```sh
make _EXEC=finch diff
```

- Version Check

```sh
make _EXEC=finch "\-\-version"
```
