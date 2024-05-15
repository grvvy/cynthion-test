pipeline {
    agent {
        dockerfile {
            args '''
                --tag greatscottgadgets/cynthion-test:latest
                --group-add=46 --group-add=20 --device-cgroup-rule="c 189:* rmw"
                --device-cgroup-rule="c 166:* rmw" --net=host
                --volume /run/udev/control:/run/udev/control
                --volume /dev/bus/usb:/dev/bus/usb
                --device /dev/serial/by-id/usb-Black_Magic_Debug_Black_Magic_Probe_v1.9.1_7BB0778C-if00
            '''
        }
    }
    stages {
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
    post {
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true)
        }
    }
}
