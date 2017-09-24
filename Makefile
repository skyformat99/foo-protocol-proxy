include Makefile.conf

# Binary output name.
BINARY=./bin/$(shell basename `pwd`)

.DEFAULT_GOAL: $(BINARY)
.PHONY: clean

help:
	@echo "Please use \`make <target>\`, Available options for <target> are:"
	@echo "  build                   to build the project."
	@echo "  unit                    to run unit tests."
	@echo "  integration             to run integration tests."

${BINARY}:
	@echo "$(OK_COLOR)==> Building$(NO_COLOR)"
	for GOOS in $(OSs); do \
		for GOARCH in $(ARCHS); do \
        	env GOOS=$$GOOS GOARCH=$$GOARCH go build -a -v -o ${BINARY}-$$GOOS-$$GOARCH -installsuffix cgo --tags netgo --ldflags '-extldflags "-lm -lstdc++ -static"' .; \
		done; \
	done

build: clean \
    vet \
    ${BINARY}

# Cleaning the project, by deleting binaries.
clean:
	@echo "$(OK_COLOR)==> Cleaning$(NO_COLOR)"
	for GOOS in $(OSs); do \
        for GOARCH in $(ARCHS); do \
            TARGET_BINARY=${BINARY}-$$GOOS-$$GOARCH; \
            if [ -f $$TARGET_BINARY ] ; then rm -rf $$TARGET_BINARY ; fi \
        done; \
    done
	go clean

# Simplified dead code detector. Used for skipping certain checks on unreachable code
# (for instance, shift checks on arch-specific code).
# https://golang.org/cmd/vet/
vet:
	go vet ./...

# Unit tests
unit:
	go test ./... -v --cover
