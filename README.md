# 英语学习软件

<description>
一个功能全面的英语学习软件，提供单词学习、音乐播放、签到等功能，帮助用户提高英语水平。
</description>

## 功能特性

1. 根据不同学习阶段获取单词列表 (CET4、CET6、考研、托福、SAT)
2. 获取单词的详细内容 (包括音标、释义、例句等)
3. 获取单词的音频 (包括美音和英音)
4. 音乐播放功能 (搜索并播放全网音乐)
5. 签到功能
6. 设置功能 (可切换词典类型)
7. 学习历史记录 + 单词收藏功能
8. 用户信息设置 (可设置昵称、头像)
9. 背单词功能

## 技术架构

### 项目结构
lib/  
├── apis/ # API接口封装  
├── components/ # 可复用UI组件  
├── models/ # 数据模型  
├── pages/ # 页面组件  
├── services/ # 业务逻辑服务  
└── main.dart # 应用入口文件 


### 核心页面
- HomePage.dart: 主页，单词学习界面
- SearchPage.dart: 单词搜索界面
- MusicPage.dart: 音乐搜索界面
- MusicPlayerPage.dart: 音乐播放界面
- UserPage.dart: 用户信息界面
- CollectionPage.dart: 收藏夹界面
- LearnHistoryPage.dart: 学习历史界面
- SettingPage.dart: 设置界面
- CalenderPage.dart: 签到日历界面
- AboutPage.dart: 关于界面

### 主要依赖
- provider
- http
- just_audio
- shared_preferences
- image_picker
- url_launcher
- flutter_local_notifications
- intl
- timezone

## 使用说明

1. 首次使用时可在设置中选择词典类型
2. 在主页可浏览和学习单词
3. 可通过搜索功能查找特定单词
4. 使用音乐功能可搜索并播放歌曲
5. 收藏功能可保存喜欢的单词
6. 签到功能可记录学习进度

## 免责声明

1. 本项目仅供学习交流使用，不得用于商业用途
2. 项目中使用的词典数据来源于网络，仅用于学习目的
3. 音乐播放功能通过第三方API实现，音频资源版权归其 respective 持有者所有
4. 本项目不提供任何音频存储服务，仅提供搜索和播放功能
5. 使用本项目时请遵守相关法律法规，不要侵犯他人知识产权
6. 开发者不对使用本项目可能造成的任何后果负责
7. 本项目可能存在不完善之处，欢迎提出改进建议

## 许可证

本项目采用MIT许可证，详情请查看LICENSE文件