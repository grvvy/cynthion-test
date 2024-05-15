node {
    checkout scm
    def cynTestImage = docker.build 'cynthion-test:latest'


    cynTestImage.inside('--group-add=46 --group-add=20') {
        sh '''#!/bin/bash
            id
        '''
    }
}
