pipeline {
    agent any

    environment {
        AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id')  // Updated to lowercase
        AZURE_CLIENT_ID = credentials('azure-client-id')
        AZURE_CLIENT_SECRET = credentials('azure-client-secret')
        AZURE_TENANT_ID = credentials('azure-tenant-id')
        RESOURCE_GROUP = "blue-green-rg"
        APP_NAME = "myapp-bluegreen"
        ACR_NAME = "myacrregistry"
        DOCKER_IMAGE = "myacrregistry.azurecr.io/myapp:latest"
    }

    stages {
        stage('Authenticate to Azure') {
            steps {
                echo "Logging into Azure..."
                sh '''
                az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
                az account set --subscription $AZURE_SUBSCRIPTION_ID
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh "docker build -t $DOCKER_IMAGE ."
            }
        }

        stage('Push Image to ACR') {
            steps {
                echo "Pushing image to Azure Container Registry..."
                sh '''
                az acr login --name $ACR_NAME
                docker push $DOCKER_IMAGE
                '''
            }
        }

        stage('Deploy to Green Slot') {
            steps {
                echo "Deploying to Green slot..."
                sh '''
                az webapp config container set --resource-group $RESOURCE_GROUP --name $APP_NAME --slot green --docker-custom-image-name $DOCKER_IMAGE
                '''
            }
        }

        stage('Swap Green to Blue') {
            steps {
                echo "Swapping Green slot with Blue..."
                sh '''
                az webapp deployment slot swap --resource-group $RESOURCE_GROUP --name $APP_NAME --slot green
                '''
            }
        }
    }
}
