import { rcp } from '@kit.RemoteCommunicationKit'
import { GlobalVariable } from '../constants'

//创建一个会话实例
const instance = rcp.createSession({
  baseAddress: GlobalVariable.BASE_URL,
  interceptors: [
      // 配置请求和响应拦截
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
  static get<T>(url: string, params?: object) {
  }

  static post<T>(url: string, data?: object) {
  }

  static delete<T>(url: string, params?: object, data?: object) {
  }

  static put<T>(url: string, data?: object) {
  }

  static patch<T>(url: string, data?: object) {
  }

  static upload<T>() {
  }

  static download<T>() {

  }
}