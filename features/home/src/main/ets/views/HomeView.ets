import { AppBreakPoint, AppSafeArea, BreakPointEnum, BreakPointType, CategoryItem, HDMGoodsItem,
  ListDataSource,
  Logger } from 'basic'
import { HDMDiscountGoods, HDMGoods } from '../components'
import { Banner, Params, DiscountType } from '../viewmodels'
import { AppStorageV2, promptAction, PromptAction } from '@kit.ArkUI'
import { getBannerAPI, getCategoryAPI, getHomeNewAPI, getHotResultAPI, getInVogueAPI, getOneStopAPI,
  getRecommendAPI } from '../api'


@ComponentV2
export struct HomeView {
  // 获取断点值
  breakObj: AppBreakPoint = AppStorageV2.connect(AppBreakPoint,() => new AppBreakPoint())!
  //获取安全区域
  safeArea: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())!
  // 轮播图
  @Local
  banners: Banner[] = []
  // 分类
  @Local
  categories: CategoryItem[] = []
  // 特惠推荐
  @Local
  saleGoods: HDMGoodsItem[] = []
  // 爆款推荐
  @Local
  hotGoods: HDMGoodsItem[] = []
  // 一站买全
  @Local
  oneGoods: HDMGoodsItem[] = []
  // 新鲜好物
  @Local
  newGoods: HDMGoodsItem[] = []
  // @Local
  // recommendGoods: HDMGoodsItem[] = []
  @Local
  yOffset: number = 0
  @Local
  searchOpacity: number = 1 // 搜索框透明度
  @Local
  page: number = 1 //页码
  @Local
  isReachLoad: boolean = false // 是否已经请求完成
  @Local
  isFinished :boolean = false // 是否已经没有数据

  // LazyForeach
  // 创建数据源对象
  dataSource: ListDataSource<HDMGoodsItem> = new ListDataSource()

  aboutToAppear(): void {
    this.getHomeData()
  }

  async getHomeData(){
    const result =
      await Promise.allSettled([
        getBannerAPI(),
        getCategoryAPI(),
        getHotResultAPI(),
        getInVogueAPI(),
        getOneStopAPI(),
        getHomeNewAPI(),
        getRecommendAPI({
          limit: this.page * 8
        })
      ])

    if (result[0].status === "fulfilled") {
      this.banners = result[0].value
    }
    if (result[1].status === "fulfilled") {
      this.categories = result[1].value
    }
    if (result[2].status === "fulfilled") {
      this.saleGoods = result[2].value?.subTypes?.[0]?.goodsItems?.items || []
      //this.saleGoods = result[2].value
    }
    if (result[3].status === "fulfilled") {
      this.hotGoods = result[3].value?.subTypes?.[0]?.goodsItems?.items || []
    }
    if (result[4].status === "fulfilled") {
      this.oneGoods = result[4].value?.subTypes?.[0]?.goodsItems?.items || []
    }
    if (result[5].status === "fulfilled") {
      this.newGoods = result[5].value
    }
    if (result[6].status === "fulfilled") {
      this.dataSource.loadData(result[6].value as HDMGoodsItem[])
    }
  }

  // 获取推荐数据
  async getRecommend(){
    const list = await getRecommendAPI({
      limit: this.page * 8
    })
    if (list.length === this.page * 8) {
      this.page ++
    }else{
      this.isFinished = true
      promptAction.showToast({
        message:'没有更多数据了'
      })
    }
    this.dataSource.loadData(list)
  }

  build() {
    RelativeContainer(){
      Scroll() {
        Column() {
          // 轮播图 + 搜索
          Stack({ alignContent: Alignment.Top }) {
            Swiper() {
              ForEach(this.banners, (item: Banner) => {
                Image(item.imgUrl)
              })
            }
            .displayCount(new BreakPointType({
              sm:1,
              md:2,
              lg:3
            }).getValue(this.breakObj.breakPoint))
            .indicator(
              this.breakObj.breakPoint === BreakPointEnum.SM ?
              DotIndicator.dot()
                .itemWidth(8)
                .itemHeight(4)
                .color('#33191919')
                .selectedItemWidth(24)
                .selectedItemHeight(4)
                .selectedColor('#191919') :
                false
            )
            // 设置子组建的间距
            .itemSpace(new BreakPointType({
              sm: 0,
              md: 10,
              lg: 20
            }).getValue(this.breakObj.breakPoint))

            Row() {
              Row({ space: 4 }) {
                Image($r('[basic].media.ic_public_search'))
                  .width(16)
                  .height(16)
                  .fillColor($r('[basic].color.white'))
                Text('搜索...')
                  .fontSize(14)
                  .fontColor($r('[basic].color.white'))
              }
              .backgroundColor('#33191919')
              .width('100%')
              .height(40)
              .borderRadius(20)
              .padding({ left: 12 })
            }
            .padding({ left: 16, right: 16, top: this.safeArea.topHeight })
          }
          .width('100%')


          // 分类
          Column({
            space: new BreakPointType({
              sm: 14,
              md: 36,
              lg: 72
            }).getValue(this.breakObj.breakPoint)
          }) {
            // 分类
            List({ space: new BreakPointType({
                sm: 14,
                md: 36,
                lg: 72
              }).getValue(this.breakObj.breakPoint)
            }) {
              ForEach(this.categories, (item: CategoryItem) => {
                ListItem() {
                  Column() {
                    Image(item.picture)
                      .width(56)
                      .aspectRatio(1)
                    Text(item.name)
                      .fontSize(10)
                      .fontColor('#CC191919')
                  }
                  .width(60)
                  .height(80)
                  .borderRadius(30)

                  .clip(true)
                  .backgroundImage(item.picture)
                  .backgroundImageSize(ImageSize.Contain)
                  .backgroundImagePosition(Alignment.Center)
                  .backgroundBlurStyle(
                    BlurStyle.BACKGROUND_ULTRA_THICK,
                    { scale: 0.25 }
                  )
                }
              })
            }
            .width('100%')
            .height(92)
            .scrollBar(BarState.Off)
            .listDirection(Axis.Horizontal)
            .alignListItem(ListItemAlign.Center)

            // 特惠推荐
            Column({ space: 10 }) {
              Image($r('app.media.home_cmd_title'))
                .width(150)
                .height(20)
              Row() {
                Image($r('app.media.home_cmd_inner'))
                  .width(86)
                  .height(116)
                List({ space: 10 }) {
                  ForEach(this.saleGoods, (item: HDMGoodsItem) => {
                    ListItem() {
                      HDMDiscountGoods({ goods: item })
                    }
                  })
                }
                .layoutWeight(1)
                .width('100%')
                .height(116)
                .backgroundColor($r('[basic].color.white'))
                .borderRadius({
                  topRight: 8,
                  bottomRight: 8
                })
                .padding({ right: 10, left: 10 })
                .scrollBar(BarState.Off)
                .listDirection(Axis.Horizontal)
              }
            }
            .width('100%')
            .height(166)
            .backgroundImage($r('app.media.home_cmd_sm'))
            .backgroundImageSize(ImageSize.Cover)
            .borderRadius(8)
            .padding(10)
            .alignItems(HorizontalAlign.Start)

            // 爆款推荐+一站买全
            Row({ space: 10 }) {
              this.DiscountBuilder({
                title: '爆款推荐',
                subTitle: '最受欢迎',
                bg: '#EDF1FB',
                list: this.hotGoods
              })
              this.DiscountBuilder({
                title: '一站买全',
                subTitle: '精心优选',
                bg: '#FCF6EA',
                list: this.oneGoods
              })
            }

            // 新鲜好物
            Column({ space: 10 }) {
              Image($r('app.media.home_new'))
                .width(146)
                .height(19)
              List({
                space: new BreakPointType({
                  sm: 14,
                  md: 36,
                  lg: 72
                }).getValue(this.breakObj.breakPoint)
              }) {
                ForEach(this.newGoods, (item: HDMGoodsItem) => {
                  ListItem() {
                    HDMDiscountGoods({ type: DiscountType.NEW, goods: item })
                  }
                })
              }
              .width('100%')
              .height(116)
              .scrollBar(BarState.Off)
              .listDirection(Axis.Horizontal)
            }
            .width('100%')
            .height(156)
            .padding(10)
            .backgroundColor('#F7EFF5')
            .borderRadius(8)
            .alignItems(HorizontalAlign.Start)

            // 推荐商品
            WaterFlow() {
              LazyForEach(this.dataSource, (item: HDMGoodsItem) => {
                FlowItem() {
                  HDMGoods({ goods: item })
                }
              })
            }
            .onReachEnd(() => {
              if (!this.isReachLoad && !this.isFinished) {
                this.isReachLoad = true
                this.getRecommend()
                this.isReachLoad = false
              }
            })
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
            .height('100%')
            .columnsTemplate(
              new BreakPointType({
                sm: "1fr 1fr",
                md: "1fr 1fr 1fr",
                lg: "1fr 1fr 1fr 1fr"
              }).getValue(this.breakObj.breakPoint)
            )
            .columnsGap(8)
            .rowsGap(10)

          }
          .padding({
            left: 8,
            right: 8,
            bottom: 10,
            top: 10
          })
        }
      }
      .scrollBar(BarState.Off)
      .onDidScroll((xOffset:number,yOffset:number) => {
        this.yOffset += yOffset
        if (this.yOffset < this.safeArea.topHeight) {
          this.searchOpacity = 0
          // 40搜索框的高度
        } else if (this.yOffset > this.safeArea.topHeight && this.yOffset < (this.safeArea.topHeight + 40)) {
          this.searchOpacity = (this.yOffset - this.safeArea.topHeight) / 40
        } else {
          this.searchOpacity = 1
        }
      })


      // 放置一个搜索元素
      Row() {
        Row({ space: 4 }) {
          Image($r('[basic].media.ic_public_search'))
            .width(16)
            .height(16)
            .fillColor($r('[basic].color.white'))
          Text('搜索...')
            .fontSize(14)
            .fontColor($r('[basic].color.white'))
        }
        .backgroundColor('#33999797')
        .width('100%')
        .height(40)
        .borderRadius(20)
        .padding({ left: 12 })
      }
      .opacity(this.searchOpacity)
      .padding({
        left: 16,
        right: 16,
        top: this.safeArea.topHeight,
        bottom: this.safeArea.topHeight,
      })
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [["#ff949dec", 0], ["#fff", 1]]
      })
    }
  }

  @Builder
  DiscountBuilder(params: Params) {

    Column() {
      Row({ space: 10 }) {
        Text(params.title)
          .fontColor($r('[basic].color.black'))
          .fontSize(14)
        Text(params.subTitle)
          .fontColor($r('[basic].color.text'))
          .fontSize(11)
      }
      .width('100%')
      .margin({ bottom: 10 })

      List({ space: 10 }) {
        ForEach(params.list, (item: HDMGoodsItem) => {
          ListItem() {
            HDMDiscountGoods({ type: DiscountType.DISCOUNT, goods: item })
          }
        })
      }
      .width('100%')
      .height(116)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .height(160)
    .layoutWeight(1)
    .padding(10)
    .backgroundColor(params.bg)
    .borderRadius(8)
  }
}