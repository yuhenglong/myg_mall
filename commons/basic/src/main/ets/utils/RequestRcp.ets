import { rcp } from '@kit.RemoteCommunicationKit'
import { ResponseData } from '.'
import { GlobalVariable } from '../constants'
import { promptAction } from '@kit.ArkUI'

// 请求拦截器
class RcpRequestInterceptor implements rcp.Interceptor {
  // context上下文 -请求上下文
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    // to from next(必须要执行的函数)
    // next传递到下一个
    // throw new Error("Method not implemented.");
    // axios返回类型无法更改！！！
    // 请求拦截器
    // TODO 注入token
    return next.handle(context) // 将结构返回下一个执行链
  }
}
//响应拦截器
class RcpResponseInterceptor implements rcp.Interceptor {
  // context上下文 -请求上下文
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    // to from next(必须要执行的函数)
    // next传递到下一个
    // throw new Error("Method not implemented.");
    // axios返回类型无法更改！！！
    // 请求拦截器
    const res = await next.handle(context) // 将结构返回下一个执行链
    // if(res.statusCode === 401) {
    //
    // }
    return res
  }
}

//创建一个会话实例
const instance = rcp.createSession({
  baseAddress: GlobalVariable.BASE_URL,
  interceptors: [
      // 配置请求和响应拦截
    new RcpRequestInterceptor(),
    new RcpResponseInterceptor()
  ], //配置多个拦截器,不区分请求和响应
  requestConfiguration:{
    transfer:{
      timeout:  {
        connectMs: GlobalVariable.TIME_OUT, //请求超时
        transferMs: GlobalVariable.TIME_OUT, //传输超时
        inactivityMs: GlobalVariable.TIME_OUT //会话 超时
      }
    }
  }
})

// 3 创建一个给外部调用各类方法的类
export class RequestRcp{
  static get<T>(url: string, params?: object): Promise<T> {
    // url?id=1&name=2 { id: 1, name: 2 }
    return RequestRcp.toRightData<T>(instance.get(url + "?" + RequestRcp.transJSONToParams(params)))
  }

  static post<T>(url: string, data?: object): Promise<T> {
    return RequestRcp.toRightData<T>(instance.post(url, data))
  }

  // delete 支持传body参数 删除购物车需要传递body参数
  static delete<T>(url: string, params?: object, data?: object): Promise<T> {
    const req = new rcp.Request(url + "?" + RequestRcp.transJSONToParams(params), "DELETE", {}, data)
    return RequestRcp.toRightData<T>(instance.fetch(req))
    // return RequestRcp.toRightData<T>(instance.delete(url + "?" + RequestRcp.transJSONToParams(params)))
  }

  static put<T>(url: string, data?: object): Promise<T> {
    return RequestRcp.toRightData<T>(instance.put(url, data))
  }

  static patch<T>(url: string, data?: object): Promise<T> {
    const req = new rcp.Request(url, "PATCH", {}, data)
    return RequestRcp.toRightData<T>(instance.fetch(req))
  }

  static upload<T>() {
  }

  static download<T>() {

  }

  // 将数据转化成正确的数据类型
  static async toRightData<T>(res: Promise<rcp.Response>) {
    const obj = await res
    const result = obj.toJSON() as ResponseData<T>
    if (result.code === GlobalVariable.SUCCESS_CODE) {
      return result.result
    }
    promptAction.showToast({ message: result.msg })
    return Promise.reject(new Error(result.msg))

  }

  // 转化json=> url地址参数的方法 { id: 1, name: 2 } => id=1&name=2
  static transJSONToParams(params?: object) {
    if (params) {
      return Object.keys(params).filter(key => !!params[key]).map(key => `${key}=${params[key]}`).join("&")
    }
    return ""
    // ["id","name"] => ["id=1", "name=2"]

  }
}