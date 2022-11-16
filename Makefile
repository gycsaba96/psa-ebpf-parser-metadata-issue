

SHELL := /bin/bash
P4C_REPO := /home/p4/p4c

p4c-docker-setup:
	cd p4c-docker && bash build.sh

build:
	rm -f -r p4c-docker/p4c-home/p4src
	mkdir -p p4c-docker/p4c-home
	cp -r p4src p4c-docker/p4c-home/p4src
	docker run -it  -v $(PWD)/p4c-docker/p4c-home:/home mytoolset/p4c-ebpf:latest bash -c "cd /home/p4src; make -f /p4c/backends/ebpf/runtime/kernel.mk P4ARGS='' BPFOBJ=out.o P4FILE=main.p4 P4C=p4c-ebpf psa" 
	rm -f -r out && mkdir out
	cp p4c-docker/p4c-home/p4src/out.c out/out.c
	cp p4c-docker/p4c-home/p4src/out.o out/out.o
	cp p4c-docker/p4c-home/p4src/out.bc out/out.bc

