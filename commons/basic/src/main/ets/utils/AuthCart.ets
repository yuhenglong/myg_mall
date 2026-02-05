import { AppStorageV2 } from "@kit.ArkUI"
import { AppCart, AppUser, auth, getCartCountAPI } from "../../../../Index"

export class AuthCart {
  /**
   * 更新购物车数量
   */
  async updateCartCount(){
    const user = auth.getUser()
    const appCart = AppStorageV2.connect(AppCart,() => new AppCart())!
    if(user.token){
      const res = await getCartCountAPI()
      appCart.count = res.count
    }else{
      appCart.count = 0
    }
  }
}

export const authCart = new AuthCart()