//go:build js && wasm
// +build js,wasm

package main

import (
	"core/engine/global"
	"core/engine/model"
	"core/engine/src"
	"syscall/js"
)

/*
  - *
    *
    web wasm 编译不支持CGO 只支持纯golang
    编译使用 tinygo 出来的体积相对于 直接编译 小很多 但是不好使，还不知道原因
    *

* *
*/
func GetTime(this js.Value, args []js.Value) interface{} {
	hf := src.HandleFunc{}
	return js.ValueOf(hf.GetTime())
}

func InitStart(this js.Value, args []js.Value) interface{} {
	dbDir := args[0].String()
	tokenGo := args[1].String()
	platformGo := args[2].String()
	callback := args[3]
	hf := src.HandleFunc{}
	go hf.InitStart(dbDir, tokenGo, platformGo, func(evt *model.GoCallbackMessage) {
		// 回调给js callback
		callback.Invoke(map[string]interface{}{
			"errMsg":  evt.Error,
			"message": evt.Message,
			"code":    evt.Type,
		})
	})
	global.HF = &hf // 挂全局
	return nil
}

func StopWork(this js.Value, args []js.Value) interface{} {
	// 程序停止
	if global.HF != nil {
		global.HF.StopWork()
	}
	return nil
}

func main() {
	done := make(chan int, 0)
	exportObj := make(map[string]interface{})
	exportObj["GetTime"] = js.FuncOf(GetTime)
	exportObj["InitStart"] = js.FuncOf(InitStart)
	exportObj["StopWork"] = js.FuncOf(StopWork)

	

	js.Global().Set("libgocoresdk", exportObj)
	console := js.Global().Get("console")
	console.Call("log", "导入wasm成功")
	<-done
}
