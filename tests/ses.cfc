component extends='testbox.system.BaseSpec' {

	function run() {

		describe( 'ses' , function() {

			beforeEach( function( currentSpec ) {
				service = new aws.ses(
					account = application.aws_settings.aws_accountid,
					secret = application.aws_settings.aws_secretkey,
					region = application.aws_settings.elb_region
				);
			});

			it( 'extends aws' , function() {

				expect( 
					service
				).toBeInstanceOf(
					'aws.aws'
				);

			});

			it( 'has an SES client stored' , function() {

				makePublic( service , 'getMyClient' , 'getMyClient' );

				actual = service.getMyClient();

				expect(
					actual.getClass().getName()
				).toBe(
					'com.amazonaws.services.simpleemail.AmazonSimpleEmailServiceClient'
				);

			});

			describe( 'getSendQuota()' , function() {

				it( 'returns the current users quota' , function() {

					actual = service.getSendQuota();

					expect( actual ).toBeStruct();

					expect( actual ).toHaveKey( 'Max24HourSend' );
					expect( actual ).toHaveKey( 'MaxSendRate' );
					expect( actual ).toHaveKey( 'SentLast24Hours' );

					expect( actual.Max24HourSend ).toBeNumeric();
					expect( actual.MaxSendRate ).toBeNumeric();
					expect( actual.SentLast24Hours ).toBeNumeric();

					expect( actual.Max24HourSend ).toBe( 50000 );
					expect( actual.MaxSendRate ).toBe( 14 );

				});

			});

			describe( 'listVerifiedEmailAddresses()' , function() {

				it( 'has only got the to and from addresses in Application' , function() {

					actual = service.listVerifiedEmailAddresses();

					expect( actual ).toInclude( application.aws_settings.ses_to );
					expect( actual ).toInclude( application.aws_settings.ses_from );

				});

			});

			describe( 'sendEmail()' , function() {

				it( 'can send am email without erroring' , function() {

					service.sendEmail(
						to = application.aws_settings.ses_to,
						from = application.aws_settings.ses_from,
						subject = 'lucee-aws test email '&GetTickCount(),
						body = 'This is just some plain text',
						format = 'plain'
					);

				});

			});

			describe( 'sendRawEmail()' , function() {

				it( 'can send am email without erroring' , function() {

					example_raw_email = 'Received: from smtp-out.example.com (123.45.67.89) by
in.example.com (87.65.43.210); Wed, 2 Mar 2011 11:39:39 -0800
From: '&application.aws_settings.ses_from&'
To: '&application.aws_settings.ses_to&'
Subject: lucee-aws raw test email '&GetTickCount()&'
Message-ID: <97DCB304-C529-4779-BEBC-FC8357FCC4D2@lucee-aws.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_003_97DCB304C5294779BEBCFC8357FCC4D2"

--_003_97DCB304C5294779BEBCFC8357FCC4D2
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

This is an email sent by the unit tester

--_003_97DCB304C5294779BEBCFC8357FCC4D2';

					service.sendRawEmail(
						data = example_raw_email
					);

				});

			});

			describe( 'verifyEmailAddress() and deleteVerifiedEmailAddress()' , function() {

				it( 'can verify an email address and then delete it' , function() {

					var test_email = GetTickCount()&'@lucee-aws.com';

					expect( service.listVerifiedEmailAddresses() ).notToInclude( test_email );

					service.verifyEmailAddress(
						email = test_email
					);

					expect( service.listVerifiedEmailAddresses() ).toInclude( test_email );

					service.deleteVerifiedEmailAddress(
						email = test_email
					);

					expect( service.listVerifiedEmailAddresses() ).notToInclude( test_email );

				});

				it( 'just silently does nothing for a nonexistant email' , function() {

					var test_email = 'is_not_verified@lucee-aws.com';

					expect( service.listVerifiedEmailAddresses() ).notToInclude( test_email );

					service.deleteVerifiedEmailAddress(
						email = test_email
					);

					expect( service.listVerifiedEmailAddresses() ).notToInclude( test_email );

				});

			});

		});

	}

}
