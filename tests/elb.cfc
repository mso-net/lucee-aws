component extends='testbox.system.BaseSpec' {

	function run() {

		describe( 'route53' , function() {

			beforeEach( function( currentSpec ) {
				service = new aws.elb(
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

			it( 'has a ELB client stored' , function() {

				makePublic( service , 'getMyClient' , 'getMyClient' );

				actual = service.getMyClient();

				expect(
					actual.getClass().getName()
				).toBe(
					'com.amazonaws.services.elasticloadbalancing.AmazonElasticLoadBalancingClient'
				);

			});

			describe( 'getConfig()' , function() {

				it( 'returns expected values for a defined load balancer' , function() {

					actual = service.getConfig( 
						name = application.aws_settings.elb_name
					);

					expect( actual ).toHaveKey( 'CanonicalHostedZoneName' );
					expect( actual ).toHaveKey( 'CanonicalHostedZoneNameID' );
					expect( actual ).toHaveKey( 'DNSName' );
					expect( actual ).toHaveKey( 'LoadBalancerName' );
					
					expect( actual.CanonicalHostedZoneName ).toBeString();
					expect( actual.CanonicalHostedZoneNameID ).toBeString();
					expect( actual.DNSName ).toBeString();
					expect( actual.LoadBalancerName ).toBeString();

				});

				it( 'errors for a fake ELB' , function() {

					expect( function() {
						service.getConfig( 
							name = 'some-fake-load-balancer'
						);
					} ).toThrow( 'elb.nonexistant' );

				});

			});



		});

	}

}
