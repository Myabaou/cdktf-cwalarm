# cdktf-cwalarm

CDK For Terraform By Cloudwatch Alarm

## 前提条件

- ChatbotとSlackが連動済みであること
<https://aws.amazon.com/jp/builders-flash/202006/slack-chatbot/?awsf.filter-name=*all>
- Terraform Stateを保存するS3 Bucketが作成済みであること
- aws-vaultがインストールされていること
  Makefile内の`_AWSPROFILE=aws-sample` を自身のプロファイルに変更すること

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

- Create Slack Config File
buckerの値は予め作成してあるS3 Bucketを指定する。
SlackのChannel IDとWorkspace IDを設定する

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

## 反映

- DryRun

```sh
make diff
```

- Apply

```sh
make deploy
```

## Terraform での実行

引数にTF=trueを指定することで、terraformコマンドを実行することができる。

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

```sh
make destroy
```

## HCL への変換

CDK for TerraformのVerisonが20以上であればHCL形式で出力することが可能です。

```sh
make "synth --hcl"
```

`cdktf.out/stacks/cloudwatch_alarm/cdk.tf` にHCL形式のファイルが出力されます。
