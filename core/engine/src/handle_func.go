package src

import (
	"context"
	"core/engine/model"
	"fmt"
	"time"
)

type HandleFunc struct {
	FileDir string         // 存储路径，存放文件或数据库，web没有这个功能
	System  model.Platform // 当前系统
	Token   string         // 当前登录Token
	ctx     context.Context
}

func (hf *HandleFunc) GetTime() string {
	var cstZone = time.FixedZone("CST", 8*3600) // 东八
	timeNow := time.Now().In(cstZone).Format("2006-01-02 15:04:05")
	return timeNow
}

func (hf *HandleFunc) StopWork() {
	hf.ctx.Done()
}

// InitStart 初始化
// fileDir 文件存储路径
// token 当前凭证
// systemPlatform 平台
func (hf *HandleFunc) InitStart(fileDir, token, systemPlatform string, callHandler func(evt *model.GoCallbackMessage)) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	hf.ctx = ctx
	// 这里写初始化代码
	hf.FileDir = fileDir
	hf.Token = token
	hf.System = model.MapPhoneSystemToPlatform(systemPlatform)

	go func() {
		// 创建一个定时器，每秒触发一次
		ticker := time.NewTicker(1 * time.Second)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				fmt.Println("收到退出信号，程序退出")
				return
			case <-ticker.C:
				//这里是每秒执行的任务
				var cstZone = time.FixedZone("CST", 8*3600) // 东八
				timeNow := time.Now().In(cstZone).Format("2006-01-02 15:04:05")
				callHandler(&model.GoCallbackMessage{
					Error:   "",
					Message: "go call time-->" + timeNow,
					Type:    12,
				})
			}
		}
	}()

	for {
		select {
		case <-ctx.Done():
			fmt.Println("收到退出信号，程序退出")
			return
		}
	}
}
