pipeline {
    agent any
    
    parameters {
        string(name: 'MAJOR_VERSION', defaultValue: '1', description: 'Major version for the Docker image tag (e.g., 1 for v1.x)')
    }
    
    tools {
        jdk 'jdk21'
        nodejs 'node20'
    }
    
    environment {
        SCANNER_HOME = tool 'sonarqube-scanner'
        TRIVY_HOME = '/usr/bin'
        REPO_URL = 'https://github.com/KelvinShan/Jenkins-YouTube-Project.git' 
        REPO_BRANCH = 'main'
        DOCKER_IMAGE_NAME = 'shanlinmaung/youtube-clone'
        SONAR_PROJECT_NAME = 'youtube-cicd-demo'
        SONAR_PROJECT_KEY = 'youtube-cicd-demo'
        DOCKER_CREDENTIALS_ID = 'dockerhub'
        SONAR_CREDENTIALS_ID = 'SonarQube-Token'
        KUBERNETES_CREDENTIALS_ID = 'kubernetes'
        SONAR_SERVER = 'SonarQube-Server'
        DOCKER_TOOL_NAME = 'docker'
        TRIVY_FS_REPORT = 'trivyfs.txt'
        TRIVY_IMAGE_REPORT = 'trivyimage.txt'
        K8S_NAMESPACE = 'default'  
        APP_NAME = 'youtube-clone'
    }
    
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
            post {
                always {
                    echo "Workspace cleaned successfully"
                }
            }
        }
        stage('Checkout from Git') {
            steps {
                git branch: "${REPO_BRANCH}", url: "${REPO_URL}", credentialsId: 'github-credentials'
            }
        }
        stage('Sonarqube Analysis') {
            steps {
                withSonarQubeEnv(credentialsId: "${SONAR_CREDENTIALS_ID}", installationName: "${SONAR_SERVER}") {
                    sh """
                    ${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectName=${SONAR_PROJECT_NAME} \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY}
                    """
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: "${SONAR_CREDENTIALS_ID}"
                }
            }
        }
        
        stage('Install Dependencies') { //Install Dependencies
            steps {
                script {
                    def nodeHome = tool name: 'node20', type: 'nodejs'
                    env.PATH = "${nodeHome}/bin:${env.PATH}"
                    sh "node --version"
                    sh "npm --version"
                    sh "npm install"
                }
            }
            post {
                failure {
                    echo "Failed to install dependencies. Check Node.js setup or package.json."
                }
            }
        }
        stage('OWASP Dependency Check') {
            steps {
                withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_API_KEY')]) {
                    dependencyCheck additionalArguments: "--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey=" + NVD_API_KEY, odcInstallation: 'owasp'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: '**/dependency-check-report.*', allowEmptyArchive: true
                }
            }
        }



        stage('TRIVY FS SCAN') {
            steps {
                script {
                    sh "${TRIVY_HOME}/trivy fs . > ${TRIVY_FS_REPORT}"
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: "${TRIVY_FS_REPORT}", allowEmptyArchive: true
                }
            }
        }
        stage('Set Version') {
            steps {
                script {
                    def buildNumber = env.BUILD_NUMBER ?: '0'
                    env.IMAGE_TAG = "v${params.MAJOR_VERSION}.${buildNumber}"
                    echo "Docker image will be tagged as: ${DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}"
                }
            }
        }
        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker') {
                        // Build the Docker image
                        sh "docker build -t youtube-clone ."
                        // Tag the image with the dynamically fetched version
                        sh "docker tag youtube-clone shanlinmaung/youtube-clone:${env.IMAGE_TAG}"
                        // Push the tagged image
                        sh "docker push shanlinmaung/youtube-clone:${env.IMAGE_TAG}"
                    }
                }
            }
            post {
                always {
                    // Clean up Docker images to save disk space
                    sh "docker rmi youtube-clone shanlinmaung/youtube-clone:${env.IMAGE_TAG} || true"
                }
            }
        }
        
        stage('TRIVY') {
            steps {
                script {
                    sh "${TRIVY_HOME}/trivy image ${DOCKER_IMAGE_NAME}:${env.IMAGE_TAG} > ${TRIVY_IMAGE_REPORT}"
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: "${TRIVY_IMAGE_REPORT}", allowEmptyArchive: true
                }
            }
        }
    }

    //     stage('Deploy to Kubernetes') {
    //             steps {
    //                 withCredentials([[
    //                     $class: 'AmazonWebServicesCredentialsBinding', 
    //                     credentialsId: 'aws-secret' // AWS credentials from Jenkins
    //                 ]]) {
    //                     script {
    //                         dir('Kubernetes') {
    //                             withKubeConfig(
    //                                 credentialsId: "${KUBERNETES_CREDENTIALS_ID}",
    //                                 serverUrl: 'https://99531677060DE78CC1FB5295D7792890.sk1.ap-southeast-1.eks.amazonaws.com', // Optional if kubeconfig is valid
    //                                 namespace: "${K8S_NAMESPACE}"
    //                             ) {
    //                                 // Optional: print version to verify AWS credentials are working
    //                                 sh 'kubectl version'
    //                                 // Update image tag in deployment file (optional)
    //                                 sh "sed -i 's|image: hlaingminpaing/youtube-clone:.*|image: hlaingminpaing/youtube-clone:${env.IMAGE_TAG}|' deployment.yml"
    //                                 // Deploy
    //                                 sh 'kubectl apply -f deployment.yml'
    //                                 sh 'kubectl apply -f service.yml'
    //                             }
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //     }

    // post {
    //     always {
    //         emailext attachLog: true,
    //             subject: "'${currentBuild.result}'",
    //             body: "Project: ${env.JOB_NAME}<br/>" +
    //                 "Build Number: ${env.BUILD_NUMBER}<br/>" +
    //                 "URL: ${env.BUILD_URL}<br/>",
    //             to: 'hlaingminpaing@hotmail.com',
    //             mimeType: 'text/html',
    //             attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
    //     }
    // }
    
}
