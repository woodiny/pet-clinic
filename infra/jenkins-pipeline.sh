pipeline {
    agent any 
    
    tools{
        jdk 'jdk17'
        maven 'maven3'
    }
    
     environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }

    stages{
        stage("Git Checkout"){
            steps{
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/writetoritika/Petclinic.git'
            }
        }
        
        stage("Compile"){
            steps{
                sh "mvn clean compile"
            }
        }
        
        stage("Test Cases"){
            steps{
                sh "mvn test"
            }
        }
        
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Petclinic \
                    -Dsonar.java.binaries=. \
                    -Dsonar.projectKey=Petclinic '''
    
                }
            }
        }
        
        stage("Build"){
            steps{
                sh " mvn clean install"
            }
        }
        
        stage("OWASP Dependency Check"){
            steps{
                dependencyCheck additionalArguments: '--scan ./ ' , odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage("Docker Build & Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: '727f00aa-6ffd-455e-85d7-56b3e290983d', toolName: 'docker') {
                        sh "docker build -t petclinic1 ."
                        sh "docker tag petclinic1 woodiny/pet-clinic123:latest"
                        sh "docker push woodiny/pet-clinic123:latest"
                    }
                }
            }
        }

        stage("Deploy Using Docker"){
            steps{
                sh " docker run -d --name pet1 -p 8082:8082 woodiny/pet-clinic123:latest "
            }
        }
        
    }
}