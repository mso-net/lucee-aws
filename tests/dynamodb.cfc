component extends='testbox.system.BaseSpec' {

	function run() {

		describe( 'dynamodb' , function() {

			beforeEach( function( currentSpec ) {
				service = new aws.dynamodb(
					account = application.aws_settings.aws_accountid,
					secret = application.aws_settings.aws_secretkey,
					region = 'eu-west-1'
				);
			});

			it( 'extends aws' , function() {

				expect( 
					service
				).toBeInstanceOf(
					'aws.aws'
				);

			});


			it( 'has a dynamodb client stored' , function() {

				makePublic( service , 'getDynamodbClient' , 'getDynamodbClient' );

				actual = service.getDynamodbClient();

				expect(
					actual
				).toBeInstanceOf(
					'com.amazonaws.services.dynamodbv2.AmazonDynamoDBClient'
				);

			});


			it( 'has a dynamodb service stored' , function() {

				makePublic( service , 'getDynamodb' , 'getDynamodb' );

				actual = service.getDynamodb();

				expect(
					actual
				).toBeInstanceOf(
					'com.amazonaws.services.dynamodbv2.document.DynamoDB'
				);

			});

			describe( 'getTable()' , function() {

				beforeEach( function( currentSpec ) {
					makePublic( service , 'getTable' , 'getTable' );
				});

				it( 'can get a table' , function() {

					actual = service.getTable(
						application.aws_settings.dynamodb_table
					);

					expect( 
						actual 
					).toBeInstanceOf(
						'com.amazonaws.services.dynamodbv2.document.Table'
					);
				});

				it( 'throws an error for a nonexistant table' , function() {

					expect( function() {

						service.getTable(
							'i-do-not-exist'
						);

					}).toThrow(
						'com.amazonaws.services.dynamodbv2.model.ResourceNotFoundException'
					);

				});

				it( 'caches requested tables' , function() {

					makePublic( service , 'getTables' , 'getTables' );

					before = service.getTables();

					expect( before ).toBe( {} );

					service.getTable(
						application.aws_settings.dynamodb_table
					);

					actual = service.getTables();

					expect( 
						actual 
					).toHaveKey(
						application.aws_settings.dynamodb_table
					);

					expect( 
						actual[application.aws_settings.dynamodb_table]
					).toBeInstanceOf(
						'com.amazonaws.services.dynamodbv2.document.Table'
					);

				});


			});

			describe( 'getItem()' , function() {

				it( 'can get the expected structure for the mso test environment' , function() {

					actual = service.getItem(
						table = application.aws_settings.dynamodb_table,
						key = 'domain',
						value = 'www.mso.net'
					);

					expected = {
						'domain': 'www.mso.net',
						'environment': 'test'
					};

					expect ( actual ).toBe( expected );

				});

				it( 'can get a structure for the mso base config' , function() {

					actual = service.getItem(
						table = application.aws_settings.dynamodb_table,
						key = 'id',
						value = 'mso',
						key2 = 'environment',
						value2 = 'base'
					);
					
					expect ( actual.id ).toBe( 'mso' );
					expect( actual.environment ).toBe( 'base' );

				});



				it( 'returns an empty structure for a nonexistant record' , function() {

					expect( function() {

						service.getItem(
							table = application.aws_settings.dynamodb_table,
							key = 'domain',
							value = GetTickCount()
						);

					}).toThrow(
						'com.amazonaws.AmazonServiceException'
					);

				});


			});

		});


	}
}
