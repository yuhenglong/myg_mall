import { CartCount, DeleteCartParams, RequestRcp } from "../utils";
import { AddCartParams, CartGoodsModel, CreateOrderParams,
  CreateOrderResult,
  PreOrder, UpdateCartParams } from "../viewmodels";


export const addCartAPI = (data: AddCartParams) => RequestRcp.post<null>("/member/cart", data)

// 获取购物车列表
export const getCartListAPI = () => RequestRcp.get<CartGoodsModel[]>("/member/cart")
// 获取购物车数量
export const getCartCountAPI = () => RequestRcp.get<CartCount>('/member/cart/count')

export const updateCartAPI = (skuId: string, data: UpdateCartParams) => RequestRcp.put<null>(`/member/cart/${skuId}`, data)
// 全选和取消全选
export const selectOrUnSelectAPI = (data: UpdateCartParams) => RequestRcp.put<null>("/member/cart/selected", data)

export const delCartAPI = (data: DeleteCartParams) => RequestRcp.delete<null>("/member/cart", undefined, data)

// 获取结算信息
export const getPreOrderAPI = () =>  RequestRcp.get<PreOrder>(`/member/order/pre`)

// 下单API
export const createOrderAPI = (data: CreateOrderParams) => {
  return RequestRcp.post<CreateOrderResult>("/member/order", data)
}