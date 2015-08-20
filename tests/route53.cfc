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

			describe( 'getHostedZoneForDomain()' , function() {

				beforeEach( function() {

					makePublic( service , 'getHostedZoneForDomain' , 'getHostedZoneForDomain' );

				});


				it( 'returns true for a defined top level domain' , function() {

					actual = service.getHostedZoneForDomain( 
						domain = application.aws_settings.route53_tld
					);
					
					expect(
						actual.getClass().getName()
					).toBe(
						'com.amazonaws.services.route53.model.HostedZone'
					);

				});

				it( 'errors for a fake domain' , function() {

					expect( function() {
						service.getHostedZoneForDomain( 
							domain = 'some-fake-domain.com'
						);
					} ).toThrow( 'route53.domain.nonexistant' );

				});

			});

			describe( 'addAliasSubdomain() and deleteAliasSubdomain()' , function() {

				beforeEach( function() {

					makePublic( service , 'getHostedZoneForDomain' , 'getHostedZoneForDomain' );

				});

				it( 'can alias a subdomain using supplied hostedZoneID and ELB target and then delete it' , function() {

					var count_resources = function() {
						return service.getHostedZoneForDomain( 
								domain = application.aws_settings.route53_tld
							)
							.getResourceRecordSetCount();
					};

					initial_number_of_resource_records = count_resources();

					example_subdomain = generateSubdomainName( CreateUUID() );

					service.addAliasSubdomain(
						subdomain = example_subdomain,
						targetELBHostedZoneID = application.aws_settings.route53_alias_hostedzoneid,
						targetELB = application.aws_settings.route53_alias_target
					);

					expect(
						count_resources()
					).toBe(
						initial_number_of_resource_records + 1
					);

					service.deleteAliasSubdomain(
						subdomain = example_subdomain,
						targetELBHostedZoneID = application.aws_settings.route53_alias_hostedzoneid,
						targetELB = application.aws_settings.route53_alias_target
					);

					expect(
						count_resources()
					).toBe(
						initial_number_of_resource_records
					);

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
