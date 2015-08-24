component accessors=true extends='aws' {

	property name='myClient' type='com.amazonaws.services.dynamodbv2.AmazonDynamoDBClient' getter=false setter=false;	
	property name='dynamodb' type='com.amazonaws.services.dynamodbv2.document.DynamoDB' getter=false setter=false;	

	property name='tables' type='struct' getter=false setter=false;

	public dynamodb function init(
		required string account,
		required string secret,
		string region
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.tables = {};

		variables.myClient = CreateObject(
			'java',
			'com.amazonaws.services.dynamodbv2.AmazonDynamoDBClient'
		).init(
			getCredentials()
		);

		if (
			StructKeyExists( arguments , 'region' ) 
		) {
			setRegion( region = arguments.region );
		}

		variables.dynamodb = CreateObject(
			'java',
			'com.amazonaws.services.dynamodbv2.document.DynamoDB'
		).init(
			getMyClient()
		);

		return this;
	}

	private function getDynamodb() {
		return variables.dynamodb;
	}

	private function getTables() {
		return variables.tables;
	}

	private function getTable(
		required string name
	) {
		if (
			!StructKeyExists( getTables() , arguments.name )
		) {

			var table = getDynamodb().getTable(
				arguments.name
			);

			// Just do a describe to check the table exists
			table.describe();

			variables.tables[ arguments.name ] = table;

		}
		return variables.tables[ arguments.name ];
	}

	public struct function getItem(
		required string table,
		required string key,
		required string value,
		string key2,
		string value2
	) {

		var table = getTable( 
			name = arguments.table
		);

		if (
			StructKeyExists( arguments , 'key2' )
			&&
			StructKeyExists( arguments , 'value2' )
		) {
			var item = table.getItem(
				arguments.key,
				arguments.value,
				arguments.key2,
				arguments.value2
			);
		} else {
			var item = table.getItem(
				arguments.key,
				arguments.value
			);
		}

		return DeserializeJSON(
			item.toJSON()
		);

	}

	public any function newItem() {
		return CreateObject(
			'java',
			'com.amazonaws.services.dynamodbv2.document.Item'
		).init();
	}

	public void function putItem(
		required string table,
		required any item 
	) {
		var table = getTable( 
			name = arguments.table
		);

		table.putItem(
			arguments.item
		);
	}

	public array function scan(
		required string table,
		required string filterExpression,
		required string projectionExpression,
		struct nameMap,
		struct valueMap
	) {

		var table = getTable( 
			name = arguments.table
		);

		var results = table.scan(
			arguments.filterExpression,
			arguments.projectionExpression,
			arguments.nameMap ?: JavaCast( 'null' , 0 ),
			arguments.valueMap ?: JavaCast( 'null' , 0 )
		).iterator();

		var rendered_results = [];

		while ( results.hasNext() ) {
			rendered_results.add(
				DeserializeJSON(
					results.next().toJSON()
				)
			);
		}

		return rendered_results;
	}

}