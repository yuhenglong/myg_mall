import { CartGoodsModel, CategoryItem } from "../viewmodels/business";
import { BreakPointEnum } from "./break_point";
import { Type } from "@ohos.arkui.StateManagement";

@ObservedV2
export class AppBreakPoint {
  @Trace
  breakPoint : BreakPointEnum = BreakPointEnum.XS
}

// 封装一个工具 可以帮我们实现适配的更简单一点

interface BreakPointOption<T> {
  xs?: T
  sm?: T
  md?: T
  lg?: T
}

export class BreakPointType<T> {
  options: BreakPointOption<T> = {}

  constructor(opt: BreakPointOption<T>) {
    this.options = opt // 将传入的断点的值赋值给对象
  }

  getValue(breakPoint: BreakPointEnum): T {
    return (this.options as object)[breakPoint]
    // if (breakPoint === BreakPointEnum.XS) {
    //   return this.options.xs!
    // } else if (breakPoint === BreakPointEnum.SM) {
    //   return this.options.sm!
    // } else if (breakPoint === BreakPointEnum.MD) {
    //   return this.options.md!
    // } else {
    //   return this.options.lg!
    // }
  }
}


// 存储当前全局安全区的对象
@ObservedV2
export class AppSafeArea {
  @Trace
  topHeight: number = 0
  @Trace
  bottomHeight: number = 0
}

// 定义统一返回的结构体
export interface ResponseData<T>{
  code: string;
  msg: string;
  result: T
}

@ObservedV2
export class AppCategory {
  @Trace
  category: CategoryItem[] = []
}

// 存储全局用户信息
export interface UserInfo {
  token: string
  avatar: string
  nickname: string
  account: string
}

@ObservedV2
export class HDMUser implements UserInfo {
  @Trace
  token: string = '';
  @Trace
  avatar: string = '';
  @Trace
  nickname: string = '';
  @Trace
  account: string = '';
  //
  // constructor(model:UserInfo) {
  //   this.token = model.token;
  //   this.avatar = model.avatar;
  //   this.nickname = model.nickname;
  //   this.account = model.account
  // }
}

@ObservedV2
export class AppUser {
  // 当储存类型为复杂数据类型时,要用@Type装饰器
  @Type(HDMUser)
  @Trace
  user: UserInfo = new HDMUser()
}

export interface CartCount {
  count: number
}

@ObservedV2
export class AppCart {
  @Trace
  count:number = 0
  @Trace
  cartList: CartGoodsModel[] = [] // 全局购物车
}