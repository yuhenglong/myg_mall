import { BreakPointEnum } from "./break_point";

@ObservedV2
export class AppBreakPoint {
  @Trace
  breakPoint : BreakPointEnum = BreakPointEnum.XS
}