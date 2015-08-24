component extends='testbox.system.BaseSpec' {

	function run() {

		describe( 'ses' , function() {

			beforeEach( function( currentSpec ) {
				service = new aws.ses(
					account = application.aws_settings.aws_accountid,
					secret = application.aws_settings.aws_secretkey
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

				makePublic( service , 'getSESClient' , 'getSESClient' );

				actual = service.getSESClient();

				expect(
					actual.getClass().getName()
				).toBe(
					'com.amazonaws.services.simpleemail.AmazonSimpleEmailServiceClient'
				);

			});

		});

	}

}
