import { RequestRcp } from "../utils";
import { AddCartParams, CartGoodsModel } from "../viewmodels";


export const addCartAPI = (data: AddCartParams) => RequestRcp.post<null>("/member/cart", data)

// 获取购物车列表
export const getCartListAPI = () => RequestRcp.get<CartGoodsModel[]>("/member/cart")