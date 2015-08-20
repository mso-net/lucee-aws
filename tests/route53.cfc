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

			describe( 'isSubdomainAlreadyDefined()' , function() {

				beforeEach( function() {

					makePublic( service , 'isSubdomainAlreadyDefined' , 'isSubdomainAlreadyDefined' );

				});

				it( 'returns true for a defined subdomain' , function() {

					actual = service.isSubdomainAlreadyDefined( 
						domain = generateSubdomainName( 'exists' ) 
					);
					
					expect( actual ).toBeTrue();

				});


				it( 'returns true for a defined top level domain' , function() {

					actual = service.isSubdomainAlreadyDefined( 
						domain = application.aws_settings.route53_tld
					);
					
					expect( actual ).toBeTrue();

				});

				it( 'returns false for a fake subdomain' , function() {

					actual = service.isSubdomainAlreadyDefined( 
						domain = generateSubdomainName( 'missing' ) 
					);

					expect( actual ).toBeFalse();

				});

			});

			describe( 'linkSubdomainToELB() and deleteSubdomain()' , function() {

				beforeEach( function() {

					makePublic( service , 'isSubdomainAlreadyDefined' , 'isSubdomainAlreadyDefined' );

				});

				it( 'can alias a subdomain using supplied hostedZoneID and ELB target and then delete it' , function() {

					example_subdomain = generateSubdomainName( CreateUUID() );

					expect(
						service.isSubdomainAlreadyDefined( example_subdomain )
					).toBeFalse();

					service.linkSubdomainToELB(
						subdomain = example_subdomain,
						targetELBHostedZoneID = application.aws_settings.route53_alias_hostedzoneid,
						targetELB = application.aws_settings.route53_alias_target
					);

					expect(
						service.isSubdomainAlreadyDefined( example_subdomain )
					).toBeTrue();

					service.deleteSubdomain(
						subdomain = example_subdomain
					);

					expect(
						service.isSubdomainAlreadyDefined( example_subdomain )
					).toBeFalse();

				});

			});



		});

	}

	private string function generateSubdomainName(
		required string name
	) {
		return arguments.name&'.'&application.aws_settings.route53_tld;
	}
}
