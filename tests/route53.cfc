component extends='testbox.system.BaseSpec' {

	function run() {

		describe( 'route53' , function() {

			beforeEach( function( currentSpec ) {
				service = new aws.route53(
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

			it( 'has a Route53 client stored' , function() {

				makePublic( service , 'getRoute53Client' , 'getRoute53Client' );

				actual = service.getRoute53Client();

				expect(
					actual.getClass().getName()
				).toBe(
					'com.amazonaws.services.route53.AmazonRoute53Client'
				);

			});

		});

	}
}
