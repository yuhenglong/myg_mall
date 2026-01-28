import { AppBreakPoint, AppSafeArea, BreakPointType, HDMGoodsItem, ListDataSource, PAGE_PATH } from 'basic'
import { SearchParams, SearchRouterParam, SortCompAttr, SortField, SortMethod } from '../viewmodels'
import { SearchSortItem } from '../components'
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { AppStorageV2 } from '@kit.ArkUI'
import { HDMGoods } from '../components'


@HMRouter({ pageUrl: PAGE_PATH.SEARCH_RESULT_PAGE })
@ComponentV2
export struct SearchResultView {
  breakPointClass: AppBreakPoint = AppStorageV2.connect(AppBreakPoint, () => new AppBreakPoint())!
  safeArea: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())!
  // 查询数据源
  lazyDataSource: ListDataSource<HDMGoodsItem> = new ListDataSource()
  // 查询参数
  params: SearchParams = new SearchParams()
  // 筛选条件
  sortList: SortCompAttr[] = [
    { label: '时间', field: 'publishTime' },
    { label: '销量', field: 'orderNum' },
    { label: '价格', field: 'price' }
  ]
  // 控制器
  scroller = new Scroller()

  aboutToAppear(): void {
    // 接收上一个页面传过来的参数
    const params = HMRouterMgr.getCurrentParam() as SearchRouterParam
    AlertDialog.show({message:JSON.stringify(params)})
  }

  build() {
    Column() {
      // 搜索区域
      Row() {
        Image($r('[basic].media.ic_public_left'))
          .width(24)
          .aspectRatio(1)
          .fillColor($r('[basic].color.white'))
          .margin(13)
          .onClick(() => {
            HMRouterMgr.pop()
          })
        Search({ placeholder: '商品关键字...', value: $$this.params.keyword })
          .searchIcon({ src: $r('[basic].media.ic_public_search'), color: $r('[basic].color.gray') })
          .placeholderColor($r('[basic].color.gray'))
          .placeholderFont({ size: 14 })
          .backgroundColor($r('[basic].color.white'))
          .textFont({ size: 14 })
          .layoutWeight(1)
          .padding(0)
          .margin(0)
          .height(36)
          .caretStyle({ color: $r('[basic].color.red') })
          .onSubmit(() => {

          })
      }
      .padding({ top: this.safeArea.topHeight, right: 16 })
      .linearGradient({
        angle: 135,
        colors: [[$r('[basic].color.linear_begin'), 0], [$r('[basic].color.linear_end'), 1]]
      })

      // list
      Row() {
        ForEach(this.sortList, (item: SortCompAttr) => {
          // 筛选组件
          SearchSortItem({
            label: item.label,
            field: item.field,
            sortField: this.params.sortField,
            sortMethod: this.params.sortMethod,
            // onSortChange: (field: SortField, method: SortMethod) => {
            // }
          })
        })
        Text('筛选')
          .fontSize(14)
          .fontColor($r('[basic].color.gray'))
      }
      .padding({ left: 16, right: 16 })
      .height(50)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .border({ width: { bottom: 0.5 }, color: $r('[basic].color.border') })

      WaterFlow({ scroller: this.scroller }) {
        LazyForEach(this.lazyDataSource, (item: HDMGoodsItem) => {
          FlowItem() {
            HDMGoods({ goods: item, smallImage: true })
          }
        })
      }
      .columnsTemplate(
        new BreakPointType({
          sm: '1fr 1fr',
          md: '1fr 1fr 1fr',
          lg: '1fr 1fr 1fr 1fr'
        })
          .getValue(this.breakPointClass.breakPoint)

      )
      .columnsGap(0.5)
      .rowsGap(0.5)
      .layoutWeight(1)
      .onReachEnd(async () => {

      })
    }
  }
}
