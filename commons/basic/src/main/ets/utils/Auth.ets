import { PersistenceV2 } from "@kit.ArkUI"
import { AppUser, HDMUser } from "."

class Auth {
  /**
   * 存储用户信息
   */
  setUser(user:HDMUser){
    const appUser = PersistenceV2.connect(AppUser,() => new AppUser())!
    appUser.user = user
  }
  /**
   * 获取用户信息
   */
  getUser(){
    const appUser = PersistenceV2.connect(AppUser,() => new AppUser())!
    return appUser.user
  }
}

export const auth = new Auth()