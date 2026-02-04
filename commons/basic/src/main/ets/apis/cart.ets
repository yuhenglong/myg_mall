import { RequestRcp } from "../utils";
import { AddCartParams } from "../viewmodels";


export const addCartAPI = (data: AddCartParams) => RequestRcp.post<null>("/member/cart", data)