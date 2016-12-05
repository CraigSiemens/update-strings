PWD=$(shell pwd)
APP_NAME=spool
LIB_PATH=Frameworks
BUILD_PATH=$(PWD)/build
LIB_BUILD_PATH=$(BUILD_PATH)/$(LIB_PATH)
LIBS = Swiftline Commander
SOURCES =$(shell ls spool/*.swift)

build: $(LIBS)
	xcrun -sdk macosx swiftc $(SOURCES) \
		-target x86_64-apple-macosx10.10 \
		-o $(BUILD_PATH)/$(APP_NAME) \
		-I $(LIB_BUILD_PATH) \
		-L $(LIB_BUILD_PATH) \
		-Xlinker -rpath \
		-Xlinker @executable_path/ \
		-v

$(LIBS):
	mkdir -p $(LIB_BUILD_PATH)
	xcrun -sdk macosx swiftc \
		-emit-library \
		-o $(LIB_BUILD_PATH)/lib$@.dylib \
		-Xlinker -install_name \
		-Xlinker @rpath/$(LIB_PATH)/lib$@.dylib \
		-emit-module \
		-emit-module-path $(LIB_BUILD_PATH)/$@.swiftmodule \
		-module-name $@ \
		-module-link-name $@ \
		-v \
		Pods/$@/Source*/*.swift

pod:
	pod update

clean:
	rm -rf build
