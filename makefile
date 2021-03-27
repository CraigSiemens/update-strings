NAME=update-strings
SWIFT_BUILD_FLAGS=--configuration release
UPDATE_STRINGS_EXECUTABLE=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/$(NAME)
MAIN_BRANCH=main

BINARIES_FOLDER=/usr/local/bin

.PHONY: all clean build install uninstall new-version

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

push-version:
ifneq ($(strip $(shell git status --untracked-files=no --porcelain 2>/dev/null)),)
	$(error git state is not clean)
endif
ifneq ($(strip $(shell git branch --show-current)),$(MAIN_BRANCH))
	$(error not on branch $(MAIN_BRANCH))
endif
	$(eval NEW_VERSION := $(filter-out $@,$(MAKECMDGOALS)))
	echo "let version = \"$(NEW_VERSION)\"" > Sources/update-strings/Utilities/Version.swift
	git commit -a -m "Release $(NEW_VERSION)"
	git tag -a $(NEW_VERSION) -m "Release $(NEW_VERSION)"
	git push origin $(MAIN_BRANCH)
	git push origin $(NEW_VERSION)

%:
	@:
