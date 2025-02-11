pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS = credentials('azure-service-principal')  // Jenkins credential
        APP_NAME = "myapp-bluegreen"
        RESOURCE_GROUP = "blue-green-rg"
        SLOT_ACTIVE = "blue"
        SLOT_INACTIVE = "green"
    }

    stages {
        stage('Build') {
            steps {
                echo "Building application..."
                sh 'docker build -t myapp:latest .'
            }
        }

        stage('Push to Azure Container Registry') {
            steps {
                echo "Pushing image to Azure..."
                sh 'az acr login --name myacr'
                sh 'docker tag myapp:latest myacr.azurecr.io/myapp:latest'
                sh 'docker push myacr.azurecr.io/myapp:latest'
            }
        }

        stage('Deploy to Inactive Slot') {
            steps {
                script {
                    def activeSlot = sh(script: "az webapp deployment slot list --resource-group ${RESOURCE_GROUP} --name ${APP_NAME} --query \"[?state=='Running'].name\" -o tsv", returnStdout: true).trim()
                    SLOT_INACTIVE = activeSlot == "blue" ? "green" : "blue"
                }

                echo "Deploying to ${SLOT_INACTIVE} slot..."
                sh "az webapp config container set --resource-group ${RESOURCE_GROUP} --name ${APP_NAME} --slot ${SLOT_INACTIVE} --docker-custom-image-name myacr.azurecr.io/myapp:latest"
            }
        }

        stage('Test Deployment') {
            steps {
                echo "Testing ${SLOT_INACTIVE} slot..."
                sh "curl -f http://${APP_NAME}-${SLOT_INACTIVE}.azurewebsites.net || exit 1"
            }
        }

        stage('Swap Slots') {
            steps {
                echo "Swapping slots..."
                sh "az webapp deployment slot swap --resource-group ${RESOURCE_GROUP} --name ${APP_NAME} --slot ${SLOT_INACTIVE}"
            }
        }
    }
}
