pipeline {
    agent any

    environment {
        azure_subscription_id = credentials('azure-subscription-id')
        azure_client_id = credentials('azure-client-id')
        azure_client_secret = credentials('azure-client-secret')
        azure_tenant_id = credentials('azure-tenant-id')
        resource_group = "blue-green-rg"
        app_name = "myapp-bluegreen"
        acr_name = "myacrregistry"
        docker_image = "myacrregistry.azurecr.io/myapp:latest"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Fetching code from Git repository..."
                git url: 'https://github.com/yourusername/your-repository.git', branch: 'main', credentialsId: 'your-git-credentials-id'
            }
        }

        stage('Authenticate to Azure') {
            steps {
                echo "Logging into Azure..."
                sh '''
                az login --service-principal -u $azure_client_id -p $azure_client_secret --tenant $azure_tenant_id
                az account set --subscription $azure_subscription_id
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh 'docker build -t $docker_image .'
            }
        }

        stage('Push Image to ACR') {
            steps {
                echo "Pushing image to Azure Container Registry..."
                sh '''
                az acr login --name $acr_name
                docker push $docker_image
                '''
            }
        }

        stage('Deploy Using Terraform') {
            steps {
                echo "Deploying using Terraform..."
                sh '''
                terraform init
                terraform apply -auto-approve -var-file=terraform.tfvars
                '''
            }
        }

        stage('Deploy to Green Slot') {
            steps {
                echo "Deploying to Green slot..."
                sh '''
                az webapp config container set --resource-group $resource_group --name $app_name --slot green --docker-custom-image-name $docker_image
                '''
            }
        }

        stage('Swap Green to Blue') {
            steps {
                echo "Swapping Green slot with Blue..."
                sh '''
                az webapp deployment slot swap --resource-group $resource_group --name $app_name --slot green
                '''
            }
        }
    }
}
