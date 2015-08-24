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

	public ses function sendEmail(
		required string from,
		required string to,
		required string subject,
		required string body,
		string format = 'plain',
		string cc,
		string bcc
	) {

		var email_subject = CreateObject(
			'java',
			'com.amazonaws.services.simpleemail.model.Content'
		).init(
			arguments.subject
		);

		var email_body_content = CreateObject(
			'java',
			'com.amazonaws.services.simpleemail.model.Content'
		).init(
			arguments.body
		);

		var email_body = CreateObject(
			'java',
			'com.amazonaws.services.simpleemail.model.Body'
		).init();

		switch( arguments.format ) {
			case 'html':
				email_body.setHtml( email_body_content );
				break;
			case 'plain':
			default:
				email_body.setText( email_body_content );
				break;
		}

		var email_message = CreateObject( 
			'java',
			'com.amazonaws.services.simpleemail.model.Message'
		).init(
			email_subject,
			email_body
		);


		var destination = CreateObject(
			'java',
			'com.amazonaws.services.simpleemail.model.Destination'
		)
			.init()
			.withToAddresses( arguments.to.ListToArray( ',' ) );

		if (
			StructKeyExists( arguments , 'cc' )
		) {
			destination.setCcAddresses( arguments.cc.ListToArray( ',' ) );
		}

		if (
			StructKeyExists( arguments , 'bcc' )
		) {
			destination.setBccAddresses( arguments.bcc.ListToArray( ',' ) );
		}

		var send_email_request = CreateObject(
			'java',
			'com.amazonaws.services.simpleemail.model.SendEmailRequest'
		)
			.init()
			.withDestination( destination )
			.withSource( arguments.from )
			.withMessage( email_message );

		getMyClient().sendEmail(
			send_email_request
		);

		return this;
	}

}