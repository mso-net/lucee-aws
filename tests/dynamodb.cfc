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
					actual.getClass().getName()
				).toBe(
					'com.amazonaws.services.dynamodbv2.AmazonDynamoDBClient'
				);

			});


			it( 'has a dynamodb service stored' , function() {

				makePublic( service , 'getDynamodb' , 'getDynamodb' );

				actual = service.getDynamodb();

				expect(
					actual.getClass().getName()
				).toBe(
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
						actual.getClass().getName()
					).toBe(
						'com.amazonaws.services.dynamodbv2.document.Table'
					);
				});

				it( 'throws an error for a nonexistant table' , function() {

					expect( function() {

						service.getTable(
							'i-do-not-exist'
						);

					}).toThrow(
					
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
						actual[application.aws_settings.dynamodb_table].getClass().getName()
					).toBe(
						'com.amazonaws.services.dynamodbv2.document.Table'
					);

				});


			});

			describe( 'getItem()' , function() {


				it( 'can get a structure using a hash+range lookup' , function() {

					actual = service.getItem(
						table = application.aws_settings.dynamodb_table,
						key = 'key1',
						value = 'hobo',
						key2 = 'key2',
						value2 = 'bot'
					);

					expected = {
						'key1': 'hobo',
						'key2': 'bot',
						'company': 'strayegg',
						'lego': true
					};

					expect ( actual ).toBe( expected );

				});



				it( 'returns an empty structure for a nonexistant record' , function() {

					expect( function() {

						service.getItem(
							table = application.aws_settings.dynamodb_table,
							key = 'company',
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
