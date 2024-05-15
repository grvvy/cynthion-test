node {
    checkout scm
    def cynTestImage = docker.build 'cynthion-test:latest'


    cynTestImage.inside('''
                --group-add=46 --group-add=20 --device-cgroup-rule="c 189:* rmw"
                --device-cgroup-rule="c 166:* rmw" --net=host
                --volume /run/udev/control:/run/udev/control
                --volume /dev/bus/usb:/dev/bus/usb
                --device /dev/serial/by-id/usb-Black_Magic_Debug_Black_Magic_Probe_v1.9.1_7BB0778C-if00
            ''') {
        sh '''#!/bin/bash
                    git submodule init && git submodule update
                    cp /tmp/calibration.dat calibration.dat
                    python -m venv environment
                    environment/bin/pip install --upgrade pip
                    make
                    make unattended
            '''
    }
}
