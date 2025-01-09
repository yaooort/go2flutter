package dart_api_dl

import (
	"core/engine/model"
	"unsafe"
)

// #include "stdlib.h"
// #include "stdint.h"
// #include "stdio.h"
// #include "include/dart_api_dl.c"
// // Go does not allow calling C function pointers directly. So we are
// // forced to provide a trampoline.
// bool GoDart_PostCObject(Dart_Port_DL port, Dart_CObject* obj) {
//   return Dart_PostCObject_DL(port, obj);
// }
//
//	typedef struct CallbackMessage{
//		char *errMsg;
//    	char *message;
//    	int64_t  code;
//	}CallbackMessage;
//
//	intptr_t GetMsg(void **ppWork, char* errMsg, char*  message, int64_t code) {
//		CallbackMessage *pWork = (CallbackMessage *)malloc(sizeof(CallbackMessage));
//		pWork->errMsg=errMsg;
//		pWork->message=message;
//		pWork->code = code;
//		*ppWork = pWork;
//		intptr_t ptr = (intptr_t)pWork;
//		return ptr;
//	}
//  void deallocateCallbackMessage(CallbackMessage *message) {
//    free(message->errMsg);
//    free(message->message);
//  //  free(message->code);
//    free(message);
//	}
import "C"

func Init(api unsafe.Pointer) bool {
	if C.Dart_InitializeApiDL(api) != 0 {
		//panic("failed to initialize Dart DL C API: version mismatch. " +
		//	"must update include/ to match Dart SDK version")
		return false
	}
	return true
}

func SendToPort(port int64, evt *model.GoCallbackMessage) {
	var obj C.Dart_CObject
	obj._type = C.Dart_CObject_kInt64
	var pwork unsafe.Pointer
	ptrAddr := C.GetMsg(&pwork, C.CString(evt.Error), C.CString(evt.Message), C.int64_t(evt.Type))

	*(*C.intptr_t)(unsafe.Pointer(&obj.value[0])) = ptrAddr

	C.GoDart_PostCObject(C.int64_t(port), &obj)

	//var result = C.GoDart_PostCObject(C.int64_t(port), &obj)
	//fmt.Println(fmt.Sprintf("回调消息:%v", result))
}

func FreeCallbackMessageMemory(pointer *int64) {
	ptr := (*C.struct_CallbackMessage)(unsafe.Pointer(pointer))
	C.deallocateCallbackMessage(ptr)
}
