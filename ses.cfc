component accessors=true extends='aws' {

	property name='myClient' type='com.amazonaws.services.lambda.AWSLambdaClient' getter=false setter=false;	

	public ses function init(
		required string account,
		required string secret,
		string region = 'eu-west-1'
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.myClient = CreateObject(
			'java',
			'com.amazonaws.services.simpleemail.AmazonSimpleEmailServiceClient'
		).init(
			getCredentials()
		);

		if (
			StructKeyExists( arguments , 'region' ) 
		) {
			setRegion( region = arguments.region );
		}

		return this;
	}

	public struct function getSendQuota() {

		var send_quota = getMyClient().getSendQuota();

		return {
			'Max24HourSend': send_quota.Max24HourSend,
			'MaxSendRate': send_quota.MaxSendRate,
			'SentLast24Hours': send_quota.SentLast24Hours
		};

	}

	public array function listVerifiedEmailAddresses() {

		return getMyClient()
			.listIdentities()
			.getIdentities();

	}

	public ses function verifyEmailAddress(
		required string email
	) {

		var verify_email = CreateObject(
			'java',
			'com.amazonaws.services.simpleemail.model.VerifyEmailIdentityRequest'
		)
			.init()
			.withEmailAddress( arguments.email );

		getMyClient().verifyEmailIdentity(
			verify_email
		);

		return this;
	}

	public ses function deleteVerifiedEmailAddress(
		required string email
	) {

		var delete_email = CreateObject(
			'java',
			'com.amazonaws.services.simpleemail.model.DeleteIdentityRequest'
		)
			.init()
			.withIdentity( arguments.email );

		getMyClient().deleteIdentity(
			delete_email
		);


		return this;
	}

}