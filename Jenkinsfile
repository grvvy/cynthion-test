node {
    checkout scm
    def cynTestImage = docker.build 'cynthion-test:latest'

    cynTestImage.inside {
        sh '''#!/bin/bash
            git submodule init && git submodule update
            cp /tmp/calibration.dat calibration.dat
            python -m venv environment
            environment/bin/pip install --upgrade pip
            make
        '''
    }
}
