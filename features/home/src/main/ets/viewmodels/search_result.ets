import { GoodsItems } from "."

// 联合类型
export type SortField = 'publishTime' | 'orderNum' | 'price'

export type SortMethod = 'desc' | 'asc'

// 提交给服务器的参数
// 提交给服务器的参数
@ObservedV2
export class SearchParams {
  @Trace
  keyword: string = ""
  @Trace
  sortField: SortField = "publishTime"
  @Trace
  sortMethod: SortMethod = "desc"
  page: number = 1
  pageSize: number = 10
}
// 筛选条件
export interface SortCompAttr {
  field: SortField
  label: string
}

// 路由参数
export interface SearchRouterParam {
  keyword: string
}

// 搜索结果类型
export interface SearchResult {
  pageData : GoodsItems
}
