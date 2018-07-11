component accessors=true extends='aws' {

	property name='opsworksClient' type='com.amazonaws.services.opsworks.AWSOpsWorksClient' getter=false setter=false;	

	property name='tables' type='struct' getter=false setter=false;

	public opsworks function init(
		string account,
		string secret
	) {

		super.init(
			argumentCollection = arguments
		);

		variables.opsworksClient = CreateAWSObject( 'services.opsworks.AWSOpsWorksClient' ).init(
			getCredentials()
		);

		return this;
	}

	public function getOpsworksClient() {
		return variables.opsworksClient;
	}

	private function getStackOntoDeploymentRequest(
		required string stack,
		required opsworksClient,
		required deploymentRequest
	) {

		for ( var r in arguments.opsworksClient.describeStacks(
			CreateAWSObject( 'services.opsworks.model.DescribeStacksRequest' ).init()
		).getStacks() ) {
			if (
				r.getName() == arguments.stack
			) {
				arguments.deploymentRequest.setStackId(
					r.getStackId()
				);
				return arguments.deploymentRequest;
				break;
			}
		}
		return deploymentRequest;
	}

	public function runRecipe(
		required string stack,
		required string recipe
	) {

		var deploymentRequest = CreateAWSObject( 'services.opsworks.model.CreateDeploymentRequest' ).init();

		var deploymentCommand = CreateAWSObject( 'services.opsworks.model.DeploymentCommand' )
			.withName(
				'execute_recipes'
			);

		deploymentCommand.setArgs( 
			{
				'recipes': [
					arguments.recipe 
				]
			}
		);

		deploymentRequest.setCommand(
			deploymentCommand
		);

		var opsworksClient = getOpsworksClient();

		deploymentRequest = getStackOntoDeploymentRequest(
			stack = arguments.stack,
			opsworksClient = opsworksClient,
			deploymentRequest = deploymentRequest
		);
		
		opsworksClient.createDeployment(
			deploymentRequest
		);

	}


	public function deploy(
		required string stack,
		required string app
	) {
		writedump( arguments );

		var deploymentRequest = CreateAWSObject( 'services.opsworks.model.CreateDeploymentRequest' ).init();

		var deploymentCommand = CreateAWSObject( 'services.opsworks.model.DeploymentCommand' )
			.withName(
				'deploy'
			);

		deploymentRequest.setCommand(
			deploymentCommand
		);

		var opsworksClient = getOpsworksClient();

		deploymentRequest = getStackOntoDeploymentRequest(
			stack = arguments.stack,
			opsworksClient = opsworksClient,
			deploymentRequest = deploymentRequest
		);
		
		var describeAppsRequest = CreateAWSObject( 'services.opsworks.model.DescribeAppsRequest' ).init();

		describeAppsRequest.setStackId(
			deploymentRequest.getStackId()
		);

		for ( var r in opsworksClient.describeApps(
			describeAppsRequest
		).getApps() ) {
			if (
				r.getName() == arguments.app
			) {
				deploymentRequest.setAppId(
					r.getAppId()
				);
				break;
			}
		}

		opsworksClient.createDeployment(
			deploymentRequest
		);

	}

}