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

					expect( actual ).toHaveKey( 'Max24HourSend' );
					expect( actual ).toHaveKey( 'MaxSendRate' );
					expect( actual ).toHaveKey( 'SentLast24Hours' );

					expect( actual.Max24HourSend ).toBeNumeric();
					expect( actual.MaxSendRate ).toBeNumeric();
					expect( actual.SentLast24Hours ).toBeNumeric();

					expect( actual.Max24HourSend ).toBe( 200 );
					expect( actual.MaxSendRate ).toBe( 1 );

				});

			});

			describe( 'listVerifiedEmailAddresses()' , function() {

				it( 'has only got the to and from addresses in Application' , function() {

					actual = service.listVerifiedEmailAddresses();

					expect( actual ).toHaveLength( 2 );

					expect( actual ).toContain( application.aws_settings.ses_to );
					expect( actual ).toContain( application.aws_settings.ses_from );

				});

			});

		});

	}

}
