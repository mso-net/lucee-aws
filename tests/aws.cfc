component extends='testbox.system.BaseSpec' {

	function run() {

		describe( 'aws' , function() {

			beforeEach( function( currentSpec ) {
				service = new aws.aws(
					account = application.aws_settings.aws_accountid,
					secret = application.aws_settings.aws_secretkey
				);
			});

			it( 'can login and has a config object stored internally' , function() {

				makePublic( service , 'getCredentials' , 'getCredentials' );

				actual = service.getCredentials();

				expect(
					actual
				).toBeInstanceOf(
					'com.amazonaws.auth.BasicAWSCredentials'
				);

			});

			it( 'has regions stored' , function() {

				makePublic( service , 'getRegions' , 'getRegions' );

				actual = service.getRegions();

				expect(
					actual
				).toBeInstanceOf(
					'com.amazonaws.regions.Regions'
				);

			});

			it( 'can return eu-west-1' , function() {

				actual = service.getRegion(
					region = 'eu-west-1'
				);

				expect(
					actual.toString()
				).toBe(
					'EU_WEST_1'
				);

			});

			it( 'defaults to eu-west-1 because that is where I live' , function() {

				actual = service.getRegion();
				expected = service.getRegion(
					region = 'eu-west-1'
				);

				expect( actual.toString() ).toBe( expected.toString() );

			});

		});

	}
}
