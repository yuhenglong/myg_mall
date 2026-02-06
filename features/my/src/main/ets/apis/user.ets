import { HDMUser, Logger, RequestRcp } from "basic";
import { HuaweiLoginParams, LoginFormModel } from "../viewmodels";

export const loginAPI = (data: LoginFormModel) => {
  Logger.info(data)
  return RequestRcp.post<HDMUser>("/login", data)
}

export const huaweiLoginAPI = (data: HuaweiLoginParams) => RequestRcp.post<HDMUser>("/login/huawei", data)