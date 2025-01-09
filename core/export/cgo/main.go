package main

import (
	"core/dart_api_dl"
	"core/engine/global"
	"core/engine/model"
	"core/engine/src"
	"fmt"
	"unsafe"
)

// #include <stdlib.h>
import "C"

//export GetTime
func GetTime() *C.char {
	hf := src.HandleFunc{}
	return C.CString(hf.GetTime())
}

//export FreePointer
func FreePointer(pointer *int64) {
	// 专门用来释放内存
	C.free(unsafe.Pointer(pointer))
}

//export InitializeDartApi
func InitializeDartApi(api unsafe.Pointer) bool {
	return dart_api_dl.Init(api)
}

//export InitStart
func InitStart(dbDir *C.char, platform *C.char, token *C.char, port int64) {
	// 程序初始化
	path := C.GoString(dbDir)
	platformGo := C.GoString(platform)
	tokenGo := C.GoString(token)
	fmt.Println("----->")
	hf := src.HandleFunc{}
	go hf.InitStart(path, tokenGo, platformGo, func(evt *model.GoCallbackMessage) {
		dart_api_dl.SendToPort(port, evt)
	})
	global.HF = &hf // 挂全局
}

//export StopWork
func StopWork() {
	// 程序停止
	if global.HF != nil {
		global.HF.StopWork()
	}
}

//export FreeCallbackMessageMemory
func FreeCallbackMessageMemory(pointer *int64) {
	// 释放消息内存
	dart_api_dl.FreeCallbackMessageMemory(pointer)
}

// 这个是ios中进行绑定的关键，详情：https://dev.to/leehack/how-to-use-golang-in-flutter-application-golang-ffi-1950
//
//export enforce_binding
func enforce_binding() {}

func main() {
}
