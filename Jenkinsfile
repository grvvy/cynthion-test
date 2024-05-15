node {
    checkout scm
    def cynTestImage = docker.build("cynthion-test:latest")

    cynTestImage.inside[('--group-add=46')] {
        stage('Build') {
            steps {
                sh '''#!/bin/bash
                    git submodule init && git submodule update
                    cp /tmp/calibration.dat calibration.dat
                    python -m venv environment
                    environment/bin/pip install --upgrade pip
                    make
                '''
            }
        }
        stage('Test') {
            steps {
                retry(3) {
                    sh 'make unattended'
                    sh 'echo Test complete'
                    sh 'echo now on local_development'
                    sh 'echo another dummy commit'
                    sh 'echo another dummy commit'
                }
            }
        }
    }
}
