import { HDMUser, Logger, RequestRcp } from "basic";
import { LoginFormModel } from "../viewmodels";

export const loginAPI = (data: LoginFormModel) => {
  Logger.info(data)
  return RequestRcp.post<HDMUser>("/login", data)
}