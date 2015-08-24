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

			describe( 'getHostedZone()' , function() {

				beforeEach( function() {

					makePublic( service , 'getHostedZone' , 'getHostedZone' );

				});


				it( 'returns hosted zone object for a defined top level domain' , function() {

					actual = service.getHostedZone( 
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
						service.getHostedZone( 
							domain = 'some-fake-domain.com'
						);
					} ).toThrow( 'route53.domain.nonexistant' );

				});

			});


			describe( 'getHostedZoneID()' , function() {

				beforeEach( function() {

					makePublic( service , 'getHostedZoneID' , 'getHostedZoneID' );

				});


				it( 'returns string hosted zone ID for known domain' , function() {

					actual = service.getHostedZoneID( 
						domain = application.aws_settings.route53_tld
					);
					
					expect( actual ).toBeString();
					expect( actual ).toHaveLength( 13 );

				});

				it( 'errors for a fake domain' , function() {

					expect( function() {
						service.getHostedZoneID( 
							domain = 'some-fake-domain.com'
						);
					} ).toThrow( 'route53.domain.nonexistant' );

				});

			});


			describe( 'getResourceRecordForSubdomain()' , function() {

				beforeEach( function() {

					makePublic( service , 'getResourceRecordForSubdomain' , 'getResourceRecordForSubdomain' );

				});


				it( 'returns hosted zone object for a defined subdomain' , function() {

					actual = service.getResourceRecordForSubdomain( 
						subdomain = generateSubdomainName( 'exists' )
					);
					
					expect(
						actual.getClass().getName()
					).toBe(
						'com.amazonaws.services.route53.model.ResourceRecordSet'
					);

				});

				it( 'errors for a fake subdomain' , function() {

					expect( function() {
						service.getResourceRecordForSubdomain( 
							subdomain = generateSubdomainName( 'does-not-exist' )
						);
					} ).toThrow( 'route53.subdomain.nonexistant' );

				});

				it( 'errors for a fake domain' , function() {

					expect( function() {
						service.getResourceRecordForSubdomain( 
							subdomain = 'i.really-dont-exist.com'
						);
					} ).toThrow( 'route53.domain.nonexistant' );

				});

			});

			describe( 'isThereAHostedZoneForThisDomain()' , function() {

				it( 'returns true for a defined top level domain' , function() {

					expect(
						service.isThereAHostedZoneForThisDomain( 
							domain = application.aws_settings.route53_tld
						)
					).toBeTrue();

				});

				it( 'returns false for a fake domain' , function() {

					expect(
						service.isThereAHostedZoneForThisDomain( 
							domain = 'some-fake-domain.com'
						)
					).toBeFalse();

				});

			});

			describe( 'isThereAResourceRecordForThisSubdomain()' , function() {

				it( 'returns true for a defined subdomain' , function() {

					expect(
						service.isThereAResourceRecordForThisSubdomain( 
							subdomain = generateSubdomainName( 'exists' )
						)
					).toBeTrue();

				});

				it( 'returns false for a fake domain' , function() {

					expect(
						service.isThereAResourceRecordForThisSubdomain( 
							subdomain = generateSubdomainName( 'does-not-exist' )
						)
					).toBeFalse();

				});

			});

			describe( 'addAliasSubdomain() and deleteSubdomain()' , function() {

				it( 'can alias a subdomain using supplied hostedZoneID and ELB target and then delete it' , function() {

					example_subdomain = generateSubdomainName( CreateUUID() );

					expect(
						service.isThereAResourceRecordForThisSubdomain( subdomain = example_subdomain )
					).toBeFalse();

					service.addAliasSubdomain(
						subdomain = example_subdomain,
						elb_region = application.aws_settings.elb_region,
						elb_name = application.aws_settings.elb_name
					);

					expect(
						service.isThereAResourceRecordForThisSubdomain( subdomain = example_subdomain )
					).toBeTrue();

					service.deleteSubdomain(
						subdomain = example_subdomain
					);

					expect(
						service.isThereAResourceRecordForThisSubdomain( subdomain = example_subdomain )
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
