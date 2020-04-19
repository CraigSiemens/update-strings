NAME=update-strings
SWIFT_BUILD_FLAGS=--configuration release
UPDATE_STRINGS_EXECUTABLE=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/$(NAME)

BINARIES_FOLDER=/usr/local/bin

.PHONY: all clean build install uninstall

all: build

clean:
	swift package clean

build:
	swift build $(SWIFT_BUILD_FLAGS)

install: build
	install -d "$(BINARIES_FOLDER)"
	install "$(UPDATE_STRINGS_EXECUTABLE)" "$(BINARIES_FOLDER)"

uninstall:
	rm -f "$(BINARIES_FOLDER)/$(NAME)"

