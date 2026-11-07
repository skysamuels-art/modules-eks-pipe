pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
        timeout(time: 45, unit: 'MINUTES')
    }

    parameters {
        string(
            name: 'AWS_ROLE_ARN',
            defaultValue: '',
            description: 'IAM role configured to trust the Jenkins OIDC issuer'
        )
    }

    environment {
        AWS_REGION = 'us-west-1'
        AWS_DEFAULT_REGION = 'us-west-1'
        AWS_EC2_METADATA_DISABLED = 'true'

        ECR_REGISTRY = '060255765406.dkr.ecr.us-west-1.amazonaws.com'
        ECR_REPOSITORY = 'hello-world'
        EKS_CLUSTER = 'tc2-eks'

        APP_DIR = 'app'
        HELM_CHART = 'terraform/environments/dev/helm/k8s'
        HELM_RELEASE = 'hello-world'
        APP_NAMESPACE = 'hello-world'

        SONAR_PROJECT_KEY = 'modules-eks-pipe'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm

                script {
                    if (!params.AWS_ROLE_ARN.trim()) {
                        error('Set AWS_ROLE_ARN before running the pipeline.')
                    }

                    def commit = sh(
                        script: 'git rev-parse --short=12 HEAD',
                        returnStdout: true
                    ).trim()

                    env.IMAGE_TAG = "${commit}-${env.BUILD_NUMBER}"
                    env.IMAGE_URI =
                        "${env.ECR_REGISTRY}/${env.ECR_REPOSITORY}:${env.IMAGE_TAG}"
                }

                sh '''
                    test -f "$APP_DIR/app.py"
                    test -f "$APP_DIR/Dockerfile"
                    test -f "$APP_DIR/requirements.txt"
                    test -f "$HELM_CHART/Chart.yaml"
                '''
            }
        }

        stage('Validate Helm Chart') {
            steps {
                sh 'helm lint "$HELM_CHART"'
            }
        }

        stage('Build Image') {
            steps {
                sh 'docker build -t "$IMAGE_URI" "$APP_DIR"'
            }
        }

        stage('Test Flask Application') {
            steps {
                sh '''
                    docker run --rm "$IMAGE_URI" python -c '
from app import app

response = app.test_client().get("/")
assert response.status_code == 200, response.status_code
assert b"Hello, World!" in response.data, response.data
print("Flask smoke test passed")
'
                '''
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh '''
                        export SONAR_TOKEN="$SONAR_AUTH_TOKEN"

                        sonar-scanner \
                          -Dsonar.projectKey="$SONAR_PROJECT_KEY" \
                          -Dsonar.sources="$APP_DIR" \
                          -Dsonar.exclusions="**/__pycache__/**,**/.venv/**" \
                          -Dsonar.qualitygate.wait=true \
                          -Dsonar.qualitygate.timeout=300
                    '''
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh '''
                    trivy image \
                      --scanners vuln \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      --format table \
                      --output trivy-report.txt \
                      "$IMAGE_URI"
                '''
            }
        }

        stage('AWS OIDC and Push to ECR') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'jenkins-aws-oidc',
                        variable: 'AWS_WEB_IDENTITY_TOKEN_FILE'
                    )
                ]) {
                    withEnv(["AWS_ROLE_ARN=${params.AWS_ROLE_ARN}"]) {
                        sh '''#!/usr/bin/env bash
set -euo pipefail

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE
export AWS_SHARED_CREDENTIALS_FILE=/dev/null
export AWS_CONFIG_FILE=/dev/null

aws sts get-caller-identity

export DOCKER_CONFIG
DOCKER_CONFIG=$(mktemp -d)
trap 'rm -rf "$DOCKER_CONFIG"' EXIT

aws ecr get-login-password --region "$AWS_REGION" |
  docker login \
    --username AWS \
    --password-stdin "$ECR_REGISTRY"

docker push "$IMAGE_URI"
'''
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'jenkins-aws-oidc',
                        variable: 'AWS_WEB_IDENTITY_TOKEN_FILE'
                    )
                ]) {
                    withEnv(["AWS_ROLE_ARN=${params.AWS_ROLE_ARN}"]) {
                        sh '''#!/usr/bin/env bash
set -euo pipefail

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE
export AWS_SHARED_CREDENTIALS_FILE=/dev/null
export AWS_CONFIG_FILE=/dev/null

export KUBECONFIG
KUBECONFIG=$(mktemp)
trap 'rm -f "$KUBECONFIG"' EXIT

aws eks update-kubeconfig \
  --region "$AWS_REGION" \
  --name "$EKS_CLUSTER"

helm upgrade --install "$HELM_RELEASE" "$HELM_CHART" \
  --namespace "$APP_NAMESPACE" \
  --reuse-values \
  --set-string image.repository="$ECR_REGISTRY/$ECR_REPOSITORY" \
  --set-string image.tag="$IMAGE_TAG" \
  --wait \
  --timeout 5m

kubectl rollout status deployment/hello-world \
  --namespace "$APP_NAMESPACE" \
  --timeout=300s

ALB_HOST=$(kubectl get ingress hello-world \
  --namespace "$APP_NAMESPACE" \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

test -n "$ALB_HOST"

curl --fail --silent --show-error \
  --retry 6 \
  --retry-delay 10 \
  --retry-all-errors \
  --connect-timeout 10 \
  --max-time 30 \
  "http://$ALB_HOST/" > application-response.txt

grep -Fq 'Hello, World!' application-response.txt
echo "Application verified at http://$ALB_HOST/"
'''
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts(
                artifacts: 'trivy-report.txt,application-response.txt',
                allowEmptyArchive: true
            )
        }

        success {
            echo 'Tests, security gates, deployment, and verification passed.'
        }

        failure {
            echo 'Pipeline stopped. Check the failed stage and scan report.'
        }
    }
}