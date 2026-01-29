import { RequestRcp } from "basic";
import { SearchParams,SearchResult } from "../viewmodels";

export const getSearchResultApi = (data: SearchParams) => RequestRcp.post<SearchResult>('/search/all',data)