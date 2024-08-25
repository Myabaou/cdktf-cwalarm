import { Construct } from "constructs";
import { App, TerraformStack } from "cdktf";
import { S3Backend } from 'cdktf';
import { AwsProvider } from "@cdktf/provider-aws/lib/provider";

import * as fs from 'fs';
import * as aws from '@cdktf/provider-aws';
import * as Papa from 'papaparse';


import { MetricAlarm } from './.gen/modules/metric_alarm' // Import the generated module;
import { TerraformConfigs } from './cw_configs'
import { CloudwatchConfigs } from './cw_configs'
import { CloudformationStack } from "@cdktf/provider-aws/lib/cloudformation-stack";

class MyStack extends TerraformStack {
  constructor(scope: Construct, id: string, cwConfigs: any) {
    super(scope, id);

    // define resources here
    // Define AWS provider
    const backend = TerraformConfigs.backend;
    new AwsProvider(this, 'aws', {
      region: backend.region, // Example: 'us-west-2'
      defaultTags: [{
        tags: {
          environment: process.env.ENV_ID || `${id}`,
          IaC: 'cdktf',

        }
      }]
    });

    // S3 backend configuration

    new S3Backend(this, {
      bucket: backend.bucket,
      key: `${id}/terraform.tfstate`,
      region: backend.region,
      encrypt: true,
    });

    // SNS Topic Create
    const snsSlack = new aws.snsTopic.SnsTopic(this, 'ToSlack', {
      name: 'AlertToSlack',
    });



    // IAM Role Create for Chatbot
    const chatbotIamRole = new aws.iamRole.IamRole(this, 'alert-to-slack', {
      name: 'alert-to-slack',
      assumeRolePolicy: JSON.stringify({
        Version: '2012-10-17',
        Statement: [{
          Effect: 'Allow',
          Principal: {
            Service: 'chatbot.amazonaws.com'
          },
          Action: 'sts:AssumeRole'
        }]
      })
    });


    // Chatbot for cloudformation YML 

    const slack = cwConfigs.slackConfig;
    // Terraform がChatbotに対応していないためCloudformaitonで作成
    new CloudformationStack(this, 'chatbot', {
      name: 'cloudformation-chatbot',
      templateBody: `
        Resources:
          SlackChannel:
            Type: AWS::Chatbot::SlackChannelConfiguration
            Properties:
              ConfigurationName: 'AWS-Alert'
              SlackChannelId: ${slack.SlackChannelId}
              SlackWorkspaceId: ${slack.SlackWorkspaceId}
              SnsTopicArns:
                - ${snsSlack.arn}
              IamRoleArn: ${chatbotIamRole.arn}
                `,
    });



    // Create a new MetricAlarm
    function createMetricAlarm(
      scope: Construct,
      key: string,
      namespace: string,
      statistic: string,
      threshold: number,
      metricName: string,
      comparisonOperator: string,
      dimensions: any,
      actionsEnabled: boolean,
      evaluationPeriods: number,
      period: string, // 5分間隔
      treatMissingData: string,
      alarmActionsEnabled: boolean = true,
      okActionsEnabled: boolean = true

    ) {
      return new MetricAlarm(scope, `${key}_alarm_${metricName}`, {
        alarmName: `${key}_alarm_${metricName}`,
        comparisonOperator: comparisonOperator,
        evaluationPeriods: evaluationPeriods,
        metricName: metricName,
        namespace: namespace,
        period: period,
        statistic: statistic,
        threshold: threshold,
        dimensions: dimensions,
        actionsEnabled: actionsEnabled,  // 通知を有効にする
        alarmDescription: `This metric monitors ${statistic} ${metricName}`,
        treatMissingData: treatMissingData,
        alarmActions: alarmActionsEnabled ? [snsSlack.arn] : [],
        okActions: okActionsEnabled ? [snsSlack.arn] : []
      });
    }


    // CSVファイルを読み込み、パースする関数
    function loadCsvConfigs(filePath: string): any[] {
      const csvData = fs.readFileSync(filePath, 'utf8');
      const results = Papa.parse(csvData, { header: true, dynamicTyping: true });
      return results.data;
    }


    const Alarms = loadCsvConfigs('./cloudwatch_configs.csv');

    for (const alarm of Alarms) {

      // Split the dimensions string into key-value pairs
      const pairs = alarm.dimensions.split(',').map((pair: string) => pair.trim().split(':') as [string, string]);
      // Create an object from the key-value pairs
      const alarmDimensions = Object.fromEntries(pairs.map(([key, value]: [string, string]) => [key.trim(), value.trim().replace(/"/g, '')]));

      createMetricAlarm(
        this,
        alarm.id,
        alarm.namespace, // ECS
        alarm.statistic,
        alarm.threshold,
        alarm.metricname, // CPU使用率
        alarm.comparisonOperator,
        alarmDimensions, //
        alarm.actionsEnabled,
        alarm.evaluationPeriods, //
        alarm.period,
        alarm.treatMissingData,
        alarm.alarmActionsEnabled,
        alarm.okActionsEnabled
      );
    }


  }
}

const app = new App();
new MyStack(app, "cloudwatch_alarm", CloudwatchConfigs);
app.synth();
