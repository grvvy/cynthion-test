MAJOR ?= 1
MINOR ?= 4

ENV_PYTHON=environment/bin/python
ENV_INSTALL=environment/bin/pip install --timeout 10000
TIMESTAMP=environment/timestamp
PLATFORM=cynthion.gateware.platform:CynthionPlatformRev$(MAJOR)D$(MINOR)
BOARD_VARS=BOARD_REVISION_MAJOR=$(MAJOR) BOARD_REVISION_MINOR=$(MINOR)
APOLLO_VARS=APOLLO_BOARD=cynthion $(BOARD_VARS)
FIRMWARE=dependencies/apollo/firmware/_build/cynthion_d11/firmware.bin
BOOTLOADER=dependencies/saturn-v/bootloader.elf
GF_FW=dependencies/greatfet/firmware
GF_FW_BIN=$(GF_FW)/build/greatfet_usb/greatfet_usb.bin
ANALYZER=cynthion.gateware.analyzer.top

all: $(TIMESTAMP)

test: $(TIMESTAMP)
	$(ENV_PYTHON) cynthion-test.py

debug: $(TIMESTAMP)
	$(ENV_PYTHON) cynthion-test.py debug

unattended: $(TIMESTAMP)
	$(ENV_PYTHON) cynthion-test.py unattended

calibrate: $(TIMESTAMP)
	$(ENV_PYTHON) calibrate.py

check: $(TIMESTAMP)
	$(ENV_PYTHON) check.py

install-udev: 60-tycho.rules
	sudo cp $< /etc/udev/rules.d/

flash-blackmagic: blackmagic.bin
	dfu-util -d 1d50:6018,:6017 -s 0x08002000:leave -D $<

bootloader: bootloader.elf

bootloader.elf: $(BOOTLOADER)
	cp $< $@

$(BOOTLOADER):
	$(BOARD_VARS) make -C dependencies/saturn-v

firmware: firmware.bin

firmware.bin: $(FIRMWARE)
	cp $< $@

$(FIRMWARE):
	$(APOLLO_VARS) make -C dependencies/apollo/firmware get-deps
	$(APOLLO_VARS) make -C dependencies/apollo/firmware

flash-greatfet: greatfet_usb.bin
	environment/bin/greatfet_firmware -w greatfet_usb.bin -R

greatfet-firmware: $(GF_FW_BIN)
	cp $< greatfet_usb.bin

$(GF_FW_BIN):
	mkdir -p $(GF_FW)/build
	cmake -S $(GF_FW) -B $(GF_FW)/build
	make -C $(GF_FW)/build

bitstreams: analyzer.bit flashbridge.bit selftest.bit speedtest.bit

analyzer.bit: $(TIMESTAMP)
	LUNA_PLATFORM=$(PLATFORM) $(ENV_PYTHON) -m $(ANALYZER) -o $@

%.bit: %.py $(TIMESTAMP)
	LUNA_PLATFORM=$(PLATFORM) $(ENV_PYTHON) $< -o $@

environment:
	python -m venv environment

$(TIMESTAMP): environment submodule-checkout
	environment/bin/python -m pip install --upgrade pip
	$(ENV_INSTALL) -e dependencies/pyfwup
	$(ENV_INSTALL) -e dependencies/libgreat/host
	$(ENV_INSTALL) -e dependencies/greatfet/host
	$(ENV_INSTALL) -e dependencies/amaranth
	$(ENV_INSTALL) -e dependencies/amaranth-boards
	$(ENV_INSTALL) -e dependencies/amaranth-stdio
	$(ENV_INSTALL) -e dependencies/apollo
	$(ENV_INSTALL) -e dependencies/python-usb-protocol
	$(ENV_INSTALL) libusb1==1.9.3 pyserial
	$(ENV_INSTALL) --no-deps -e dependencies/luna
	$(ENV_INSTALL) tomli
	$(ENV_INSTALL) --no-deps -e dependencies/cynthion/cynthion/python
	$(ENV_INSTALL) colorama ipdb
	rm -rf dependencies/amaranth-stdio/build
	touch $(TIMESTAMP)

clean:
	$(APOLLO_VARS) make -C dependencies/apollo/firmware clean
	make -C dependencies/saturn-v clean
	rm -f $(BOOTLOADER)
	rm -rf $(GF_FW)/build
	rm -rf environment

submodule-checkout:
	git submodule init && git submodule update
	cd dependencies/apollo && git submodule init && git submodule update && cd ../..
	cd dependencies/greatfet && git submodule init && git submodule update && cd ../..
