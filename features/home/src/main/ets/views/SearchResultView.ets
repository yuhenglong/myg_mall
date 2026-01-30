import { AppBreakPoint, AppSafeArea, BreakPointType, HDMGoodsItem, ListDataSource, Logger, PAGE_PATH } from 'basic'
import { GoodsItems, SearchParams, SearchRouterParam, SortCompAttr, SortField, SortMethod } from '../viewmodels'
import { SearchSortItem } from '../components'
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { AppStorageV2 } from '@kit.ArkUI'
import { HDMGoods } from '../components'
import { getSearchResultApi } from '../api/search'


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

  @Local
  list: HDMGoodsItem[] = []
  @Local
  loading: boolean = false // 正在加载
  @Local
  finished: boolean = false // 是否完成

  aboutToAppear(): void {
    // 接收上一个页面传过来的参数
    const params = HMRouterMgr.getCurrentParam() as SearchRouterParam
    this.params.keyword = params.keyword;
    this.getSearchResult()
  }

  onRefresh() {
    this.params.page = 1
    this.list = [] // 重新赋值为空
    this.finished = false
    this.getSearchResult()
  }

  // 获取搜索数据的方法
  async getSearchResult(){
    // const res = await getSearchResultApi({
    //   keyword: this.params.keyword,
    //   sortField: this.params.sortField,
    //   sortMethod: this.params.sortMethod,
    //   page: this.params.page,
    //   pageSize:this.params.pageSize
    // })
    // const res = await getSearchResultApi(JSON.parse(JSON.stringify(this.params).replace(/__ob_/,'')) as SearchParams)
    const res = await getSearchResultApi(this.params)
    this.list.push(...res.pageData.items);
    if (this.params.page >= res.pageData.pages) {
      this.finished = true
    }else {
      this.params.page ++;
    }
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
            this.params.page = 1;
            this.list = [];
            this.finished = false;
            this.getSearchResult();
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
            onSortChange: (field: SortField, method: SortMethod) => {
              this.params.sortField = field // 相当于重新加载数据 排序字段
              this.params.sortMethod = method // 排序方式
              this.onRefresh()
            }
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

      WaterFlow({ scroller: this.scroller, footer: this.getFootBuilder() }) {
        // LazyForEach(this.lazyDataSource, (item: HDMGoodsItem) => {
        //   FlowItem() {
        //     HDMGoods({ goods: item, smallImage: true })
        //   }
        // })
        Repeat<HDMGoodsItem>(this.list).each((obj) => {
          HDMGoods({ goods: obj.item, smallImage: true })
        })
          .virtualScroll()
          .key( (item: HDMGoodsItem, index: number) => `${index}_${JSON.stringify(item)}`)
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
        if (!this.loading && !this.finished) {
          this.loading = true
          await this.getSearchResult()
        }
      })
    }
  }

  @Builder
  getFootBuilder() {
    Row({ space: 10 }) {
      if (this.loading) {
        Text("加载中...")
          .fontSize(12)
          .fontColor($r("[basic].color.gray"))
        LoadingProgress()
          .width(20)
          .aspectRatio(1)
      } else {
        if (this.finished) {
          Text("没有更多啦")
            .fontSize(12)
            .fontColor($r("[basic].color.gray"))
        }
      }
    }
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .height(50)
  }
}
