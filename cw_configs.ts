export const TerraformConfigs = {
	backend: {
		bucket: '<s3 bucket name>', // Example: 'my-terraform-state-bucket'
		region: 'ap-northeast-1', // Example: 'us-west-2'
	}
}

export const CloudwatchConfigs = {

	slackConfig: {
		SlackChannelId: 'CXXXXXXXX', // Slack Channel ID
		SlackWorkspaceId: 'TXXXXXXXXXX' // Slack Workspace ID
	},
};
