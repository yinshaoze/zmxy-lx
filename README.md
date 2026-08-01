<h1 align=center>造梦西游3 离线版启动器</h1>

> [!NOTE]
> 本项目仅满足个人学习交流，不保证任何有效性。

## 简介

一个针对《造梦西游3》精简的离线启动器：加载已初始化的游戏文件，并启动本地
Flash Player 进行游玩，无需浏览器、无需登录。

本项目基于 [constfold/Speculum-4399](https://github.com/constfold/Speculum-4399)
开发。原项目为通用 4399 Flash 游戏离线加载器，本项目精简为**仅保留运行功能**，
并适配了《造梦西游3》的存档、点卷/VIP、商店消费、邀请好友（本地存档）。

## 文件结构

```text
zmxylx/
├── run.py                 # 运行入口（打包为 zmhj3.exe）
├── backends/              # 本地代理（缓存 SWF、伪造 4399 平台接口）
├── speculum/swfutil.py    # swfutil 调用封装
├── out/                   # 已初始化的游戏文件
│   ├── cache/             # 游戏资源缓存
│   ├── game.exe           # Flash Player
│   ├── game.json / Game.swf / Main.swf / game_save.json
├── dist/                  # 构建产物与发布包
└── build_run.ps1          # 一键构建单文件 exe
```

## 构建单文件 exe

```powershell
.\build_run.ps1
```

产物：`dist\zmhj3.exe`（单文件，无需安装 Python）。

## 运行

直接双击 `zmhj3.exe`，或 `python run.py`。需要：

- `out\game.exe`：Flash Player（或通过 `.env` 的 `FLASH_PLAYER_PATH` 指定路径）
- `out\` 下完整的游戏文件
- 将当前目录加入 Flash Player 信任列表：

  ```shell
  echo %CD% > %APPDATA%\Macromedia\Flash Player\#Security\FlashPlayerTrust\trust.cfg
  ```

## 配置

参照 `.env.example` 创建 `.env`（端口默认 8888，Flash Player 默认 `out\game.exe`）。

## 协议

基于 [constfold/Speculum-4399](https://github.com/constfold/Speculum-4399)
（AGPL-3.0）开发，本项目同样采用 [AGPL-3.0](LICENSE) 许可。
