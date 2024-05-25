export const TerraformConfigs = {
	backend: {
		bucket: 'cdktf-sample-terraform-state', // Example: 'my-terraform-state-bucket'
		region: 'ap-northeast-1', // Example: 'us-west-2'
	}
}

export const CloudwatchConfigs = {

	slackConfig: {
		SlackChannelId: 'C05F1SUFQ3Y', // Slack Channel ID
		SlackWorkspaceId: 'T0QJEJ4P9' // Slack Workspace ID
	},
};
