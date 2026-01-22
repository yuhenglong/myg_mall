import { Context } from "@kit.AbilityKit"
import { AppStorageV2, display, window } from "@kit.ArkUI"
import { AppBreakPoint, BreakPointEnum } from "./index"

export class ScreenManager {
  ctx?: Context

  // 注册屏幕宽度变化
  async registerWindowSizeChange() {
    const win = await this.getWin() // 获取window对象
    this.judgeScreen(px2vp(display.getDefaultDisplaySync().width)) // 第一次手动判断一次
    win.on("windowSizeChange", (size) => {
      this.judgeScreen(px2vp(size.width)) // vp区间
    })
  }

  // 判断屏幕
  judgeScreen(width: number) {
    let breakPoint: BreakPointEnum = BreakPointEnum.XS
    if (width > 0 && width < 320) {
      breakPoint = BreakPointEnum.XS
    } else if (width >= 320 && width < 520) {
      breakPoint = BreakPointEnum.SM
    } else if (width >= 520 && width < 840) {
      breakPoint = BreakPointEnum.MD
    } else {
      breakPoint = BreakPointEnum.LG
    }
    //   V1 AppStorage.setOrCreate("key", "value")
    const app = AppStorageV2.connect(AppBreakPoint, () => new AppBreakPoint())!
    app.breakPoint = breakPoint // 将断点值存入到全局状态
  }

  // 取消注册
  async unRegisterWindowSizeChange() {
    const win = await this.getWin() // 获取window对象
    win.off("windowSizeChange") // 卸载监听
  }

  getWin() {
    return window.getLastWindow(this.ctx || getContext())
  }
}

export const screenManager = new ScreenManager()