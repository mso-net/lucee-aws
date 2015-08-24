component extends='testbox.system.BaseSpec' {

	function run() {

		describe( 'lambda' , function() {

			beforeEach( function( currentSpec ) {
				service = new aws.lambda(
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

			it( 'has a Lambda client stored' , function() {

				makePublic( service , 'getMyClient' , 'getMyClient' );

				actual = service.getMyClient();

				expect(
					actual.getClass().getName()
				).toBe(
					'com.amazonaws.services.lambda.AWSLambdaClient'
				);

			});

			describe( 'invoke()' , function() {

				it( 'returns expected response' , function() {

					payload = {
						'key1': CreateUUID(),
						'key2': CreateUUID(),
						'key3': CreateUUID()
					};

					actual = service.invoke( 
						method = application.aws_settings.lambda_method,
						payload = payload
					);

					expected = payload.key1&':'&payload.key2&'|'&payload.key3;

					expect( actual ).toBe( expected );

				});

			});

		});

	}

}
