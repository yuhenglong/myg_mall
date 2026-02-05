import { AppStorageV2 } from "@kit.ArkUI"
import { AppCart, AppUser, auth, CartGoodsModel, getCartCountAPI, getCartListAPI } from "../../../../Index"

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
      // Observed(class) ObjectLink ObservedV2 必须通过new才具备响应式
      appCart.cartList = (await getCartListAPI()).map(item => new CartGoodsModel(item))
    }else{
      appCart.count = 0
      appCart.cartList = []
    }
  }
}

export const authCart = new AuthCart()