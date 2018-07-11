component accessors=true extends='aws' {

	property name='myClient' type='com.amazonaws.services.simpleemail.AmazonSimpleEmailServiceClient' getter=false setter=false;	

	public ses function init(
		string account,
		string secret,
		string region = 'eu-west-1'
	) {

		super.init(
			argumentCollection = arguments
		);


		variables.myClient = CreateAWSObject( 'services.simpleemail.AmazonSimpleEmailServiceClientBuilder' )
			.standard()
			.withCredentials( getCredentials() )
			.build();

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

		var verify_email = CreateAWSObject( 'services.simpleemail.model.VerifyEmailIdentityRequest' )
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

		var delete_email = CreateAWSObject( 'services.simpleemail.model.DeleteIdentityRequest' )
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

		var email_subject = CreateAWSObject( 'services.simpleemail.model.Content' ).init(
			arguments.subject
		);

		var email_body_content = CreateAWSObject( 'services.simpleemail.model.Content' ).init(
			arguments.body
		);

		var email_body = CreateAWSObject( 'services.simpleemail.model.Body' ).init();

		switch( arguments.format ) {
			case 'html':
				email_body.setHtml( email_body_content );
				break;
			case 'plain':
			default:
				email_body.setText( email_body_content );
				break;
		}

		var email_message = CreateAWSObject( 'services.simpleemail.model.Message' ).init(
			email_subject,
			email_body
		);


		var destination = CreateAWSObject( 'services.simpleemail.model.Destination' )
			.init()
			.withToAddresses( arguments.to.ListToArray( ';' ) );

		if (
			StructKeyExists( arguments , 'cc' )
		) {
			destination.setCcAddresses( arguments.cc.ListToArray( ';' ) );
		}

		if (
			StructKeyExists( arguments , 'bcc' )
		) {
			destination.setBccAddresses( arguments.bcc.ListToArray( ';' ) );
		}

		var send_email_request = CreateAWSObject( 'services.simpleemail.model.SendEmailRequest' )
			.init()
			.withDestination( destination )
			.withSource( arguments.from )
			.withMessage( email_message );

		getMyClient().sendEmail(
			send_email_request
		);

		return this;
	}

	public ses function sendRawEmail(
		required string data
	) {

		var email_message = CreateAWSObject( 'services.simpleemail.model.RawMessage' ).init(
			CreateObject(
				'java',
				'java.nio.charset.Charset'
			)
				.forName( 'UTF-8' )
				.newEncoder()
				.encode(
					CreateObject(
						'java',
						'java.nio.CharBuffer'
					).wrap(
						arguments.data
					)
				)
		);

		var send_raw_email_request = CreateAWSObject( 'services.simpleemail.model.SendRawEmailRequest' )
			.init()
			.withRawMessage( email_message );

		getMyClient().sendRawEmail(
			send_raw_email_request
		);

		return this;
	}

}
