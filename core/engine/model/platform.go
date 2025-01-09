package model

// Platform 定义 Platform 枚举类型
type Platform int

const (
	E       Platform = iota // 0
	Android                 // 1
	iOS                     // 2
	Web                     // 3
	MacOS                   // 4
	Linux                   // 5
	Windows                 // 6
	Fuchsia                 // 7
	Unknown
)

// String 方法用于输出枚举对应的字符串
func (p Platform) String() string {
	switch p {
	case Android:
		return "Android"
	case iOS:
		return "iOS"
	case Web:
		return "Web"
	case MacOS:
		return "MacOS"
	case Linux:
		return "Linux"
	case Windows:
		return "Windows"
	case Fuchsia:
		return "Fuchsia"
	default:
		return "Unknown"
	}
}

func MapPhoneSystemToPlatform(phoneSystem string) Platform {
	switch phoneSystem {
	case "1":
		return Android
	case "2":
		return iOS
	case "3":
		return Web
	case "4":
		return MacOS
	case "5":
		return Linux
	case "6":
		return Windows
	case "7":
		return Fuchsia
	default:
		return Unknown
	}
}
