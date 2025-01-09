package model

type GoCallbackMessage struct {
	Error   string
	Message string
	Type    int
	Data    []byte
}
