
# 编译ios
# framework 文件导入项目中即可
IOS_OUT=../ios

# 编译android 动态库,生成的H文件可不要
ANDROID_OUT=../android/src/main/jniLibs/
ANDROID_SDK=$(HOME)/Library/Android/sdk
NDK_BIN=$(ANDROIDSDKROOT)/ndk/28.0.13004108/toolchains/llvm/prebuilt/darwin-x86_64/bin


# 编译后名字
BUILD_LIB_NAME=libgocoresdk
BUILD_LIB_NAME_XC=libgocoresdk
# 需要注意的是 -tags=netgo 是为了兼容ios找不到未定义的符号 _res_9_nclose  ,可以在iOS项目添加 libresolv.tbd解决，，也可以使用-tags=netgo，但是使用-tags=netgo iOS17不会让go的网络库进行DNS解析
# 参考https://github.com/golang/go/issues/58416
#ios-framework:
#	go get github.com/sagernet/gomobile/bind
ios-framework:
	CGO_LDFLAGS_ALLOW='-fembed-bitcode' \
    gomobile bind -v -ldflags '-s -w' -trimpath -target=ios -o=$(IOS_OUT)/$(BUILD_LIB_NAME_XC).xcframework ./export/gomobile
#ios: ios-framework  # --------------------->>>>> 直接生成xcframework 推荐这种方式

TEMP_OUT=./build/ios/temp

ios-arm64:
	$(eval GOARCH=arm64)
	$(eval SDK=iphoneos)
	$(eval CARCH=arm64)
	$(eval SDK_PATH=$(shell xcrun --sdk $(SDK) --show-sdk-path))
	$(eval CLANG=$(shell xcrun --sdk $(SDK) --find clang))
	CGO_ENABLED=1 \
	GOOS=ios \
	GOARCH=$(GOARCH) \
	CC="$(CLANG) -target arm64-apple-ios -isysroot $(SDK_PATH) " \
	go build -buildmode=c-archive -tags ios -ldflags '-w' -trimpath -v -o $(TEMP_OUT)/arm64/$(BUILD_LIB_NAME).a ./export/cgo/main.go

ios-amd64-simulator:
	$(eval GOARCH=amd64)
	$(eval SDK=iphonesimulator)
	$(eval CARCH=x86_64)
	$(eval SDK_PATH=$(shell xcrun --sdk $(SDK) --show-sdk-path))
	$(eval CLANG=$(shell xcrun --sdk $(SDK) --find clang))
	CGO_ENABLED=1 \
	GOOS=ios \
    GOARCH=$(GOARCH) \
    CC="$(CLANG) -target x86_64-apple-ios-simulator -isysroot $(SDK_PATH) " \
	go build -buildmode=c-archive -tags ios -ldflags '-w' -trimpath -v -o $(TEMP_OUT)/amd64-simulator/$(BUILD_LIB_NAME).a ./export/cgo/main.go

ios-arm64-simulator:
	$(eval GOARCH=arm64)
	$(eval SDK=iphonesimulator)
	$(eval CARCH=arm64)
	$(eval SDK_PATH=$(shell xcrun --sdk $(SDK) --show-sdk-path))
	$(eval CLANG=$(shell xcrun --sdk $(SDK) --find clang))
	CGO_ENABLED=1 \
	GOOS=ios \
    GOARCH=$(GOARCH) \
    CC="$(CLANG) -target arm64-apple-ios-simulator -isysroot $(SDK_PATH) " \
	go build -buildmode=c-archive -tags ios -ldflags '-w' -trimpath -v -o $(TEMP_OUT)/arm64-simulator/$(BUILD_LIB_NAME).a ./export/cgo/main.go


ios-xcframework: ios-arm64 ios-amd64-simulator ios-arm64-simulator
	lipo \
    -create \
    $(TEMP_OUT)/amd64-simulator/$(BUILD_LIB_NAME).a \
    $(TEMP_OUT)/arm64-simulator/$(BUILD_LIB_NAME).a \
    -output $(TEMP_OUT)/iphonesimulator.a

	mkdir -p $(TEMP_OUT)/ios-arm64
	mkdir -p $(TEMP_OUT)/ios-simulator
	mv $(TEMP_OUT)/arm64/$(BUILD_LIB_NAME).a $(TEMP_OUT)/ios-arm64/$(BUILD_LIB_NAME).a
	cp $(TEMP_OUT)/arm64/$(BUILD_LIB_NAME).h $(TEMP_OUT)/ios-arm64/$(BUILD_LIB_NAME).h
	mv $(TEMP_OUT)/iphonesimulator.a $(TEMP_OUT)/ios-simulator/$(BUILD_LIB_NAME).a
	mv $(TEMP_OUT)/arm64-simulator/$(BUILD_LIB_NAME).h $(TEMP_OUT)/ios-simulator/$(BUILD_LIB_NAME).h

	lipo -info $(TEMP_OUT)/ios-arm64/$(BUILD_LIB_NAME).a # 检查架构
	lipo -info $(TEMP_OUT)/ios-simulator/$(BUILD_LIB_NAME).a # 检查架构

	xcodebuild -create-xcframework \
			-output $(TEMP_OUT)/$(BUILD_LIB_NAME).xcframework \
			-library $(TEMP_OUT)/ios-arm64/$(BUILD_LIB_NAME).a \
			-headers $(TEMP_OUT)/ios-arm64/$(BUILD_LIB_NAME).h \
			-library $(TEMP_OUT)/ios-simulator/$(BUILD_LIB_NAME).a \
			-headers $(TEMP_OUT)/ios-simulator/$(BUILD_LIB_NAME).h
	rm -rf $(TEMP_OUT)/ios-arm64
	rm -rf $(TEMP_OUT)/ios-simulator
	rm -rf $(TEMP_OUT)/amd64-simulator
	rm -rf $(TEMP_OUT)/arm64-simulator
	rm -rf $(TEMP_OUT)/arm64
	rm -rf $(IOS_OUT)/$(BUILD_LIB_NAME).xcframework
	mv $(TEMP_OUT)/$(BUILD_LIB_NAME).xcframework $(IOS_OUT)
	rm -rf $(TEMP_OUT)


#如果 .xcframework 是静态库
#静态库 .a 文件不支持 DynamicLibrary.open。静态库必须通过链接器在编译时嵌入到 iOS 工程中。用 Objective-C 或 Swift 创建一个桥接层
ios: ios-xcframework   # 实在没办法使用这种方式



android-aar:
	CGO_LDFLAGS_ALLOW='-fembed-bitcode' \
	gomobile bind -v -ldflags '-s -w' -trimpath -target=android -javapkg=com.uoobal -o=$(ANDROID_OUT)$(BUILD_LIB_NAME).aar ./export/gomobile

# android: android-aar # --------------------->>>>> 直接生成aar，推荐这种方式

android-armv7a:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=arm \
	GOARM=7 \
	CC=$(NDK_BIN)/armv7a-linux-androideabi21-clang \
	go build -buildmode=c-shared -ldflags '-w' -trimpath -v -o $(ANDROID_OUT)/armeabi-v7a/$(BUILD_LIB_NAME).so ./export/cgo/main.go
# 如果flutter dart 直接调用需要 CGO_ENABLED打开后 go build -ldflags -buildmode=c-shared '-w' -trimpath -v -o $(ANDROID_OUT)/armeabi-v7a/$(BUILD_LIB_NAME).so ./sdk
android-arm64:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=arm64 \
	CC=$(NDK_BIN)/aarch64-linux-android21-clang \
	go build -buildmode=c-shared -ldflags '-w' -trimpath -v -o $(ANDROID_OUT)/arm64-v8a/$(BUILD_LIB_NAME).so ./export/cgo/main.go

android-x86:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=386 \
	CC=$(NDK_BIN)/i686-linux-android21-clang \
	go build -buildmode=c-shared -ldflags '-w' -trimpath -v -o $(ANDROID_OUT)/x86/$(BUILD_LIB_NAME).so ./export/cgo/main.go

android-x86_64:
	CGO_ENABLED=1 \
	GOOS=android \
	GOARCH=amd64 \
	CC=$(NDK_BIN)/x86_64-linux-android21-clang \
	go build -buildmode=c-shared -ldflags '-w' -trimpath -v -o $(ANDROID_OUT)/x86_64/$(BUILD_LIB_NAME).so ./export/cgo/main.go

android: android-armv7a android-arm64 android-x86 android-x86_64 # 实在没办法使用这种方式


# 编译windows 动态库
# 需要在项目目录CMakeLists.txt文件中进行引入,如下
# install(FILES ${PROJECT_SOURCE_DIR}/lib_engine.dll DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
WINDOWS_OUT=../windows

windows-x86:
	CGO_ENABLED=1 \
    GOOS=windows \
    GOARCH=386 \
    CC=i686-w64-mingw32-gcc \
    CXX=i686-w64-mingw32-g++ \
    go build -buildmode=c-shared -ldflags '-w' -trimpath -v -o $(WINDOWS_OUT)/x86/$(BUILD_LIB_NAME).dll ./export/cgo/main.go

windows-x86_64:
	CGO_ENABLED=1 \
    GOOS=windows \
    GOARCH=amd64 \
    CC=x86_64-w64-mingw32-gcc \
    CXX=x86_64-w64-mingw32-g++ \
    go build -buildmode=c-shared -ldflags '-w' -trimpath -v -o $(WINDOWS_OUT)/x86_64/$(BUILD_LIB_NAME).dll ./export/cgo/main.go

windows-arm64:
	CGO_ENABLED=1 \
    GOOS=windows \
    GOARCH=arm64 \
    CC=aarch64-w64-mingw32-gcc \
    CXX=aarch64-w64-mingw32-g++ \
    go build -buildmode=c-shared -ldflags '-w' -trimpath -v -o $(WINDOWS_OUT)/arm64/$(BUILD_LIB_NAME).dll ./export/cgo/main.go

windows: windows-x86 windows-x86_64

# 编译linux
# 需要在项目目录CMakeLists.txt文件中进行引入,如下
# install(FILES ${PROJECT_SOURCE_DIR}/lib_engine.so DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
LINUX_OUT=../linux

linux-amd64:
	CGO_ENABLED=1 \
    GOOS=linux \
    GOARCH=amd64 \
    CC=x86_64-linux-musl-gcc \
    CXX=x86_64-linux-musl-g++ \
    go build -buildmode=c-shared -ldflags '-w' -trimpath -v -o $(LINUX_OUT)/x86_64/$(BUILD_LIB_NAME).so ./export/cgo/main.go

linux: linux-amd64


# 编译macos
MACOS_OUT=../macos
TEMP_OUT_MAC=./build/mac/temp
macos-amd64:
	CGO_ENABLED=1 \
    GOOS=darwin \
    GOARCH=amd64 \
	SDK=macos \
	go build -buildmode=c-shared -ldflags '-w' -trimpath -v -o $(TEMP_OUT_MAC)/amd64/$(BUILD_LIB_NAME).dylib ./export/cgo/main.go

macos-arm64:
	CGO_ENABLED=1 \
    GOOS=darwin \
    GOARCH=arm64 \
	SDK=macos \
	go build -buildmode=c-shared -ldflags '-w' -trimpath -v -o $(TEMP_OUT_MAC)/arm64/$(BUILD_LIB_NAME).dylib ./export/cgo/main.go

# 合并 x86_64 和 arm64 动态库为通用二进制
macos-universal: macos-arm64 macos-amd64
	#mkdir -p $(MACOS_OUT)/universal
	lipo -create -output $(MACOS_OUT)/$(BUILD_LIB_NAME).dylib \
		$(TEMP_OUT_MAC)/amd64/$(BUILD_LIB_NAME).dylib \
		$(TEMP_OUT_MAC)/arm64/$(BUILD_LIB_NAME).dylib
	install_name_tool -id "@rpath/$(BUILD_LIB_NAME).dylib" $(MACOS_OUT)/$(BUILD_LIB_NAME).dylib # 修改动态库自身的 "install name"（安装名称）不然就会报错找不到动态库

macos: macos-universal

# 编译web wasm
WEB_OUT=../web
web-wasm:
	GOOS=js \
	GOARCH=wasm \
	go build -ldflags '-w' -trimpath -v -o $(WEB_OUT)/$(BUILD_LIB_NAME).wasm ./export/web
	cp $(shell go env GOROOT)/misc/wasm/wasm_exec.js $(WEB_OUT)/wasm_exec.js

web: web-wasm

# 复制dart目录代码
cp-dl:
	cp -r $(shell flutter --version --machine | jq -r '.flutterRoot')/bin/cache/dart-sdk/include ./dart_api_dl/

# 编译所有
all: cp-dl ios android windows linux macos web
