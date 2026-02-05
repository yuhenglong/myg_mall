import {
  addCartAPI,
  AppBreakPoint,
  AppCart,
  AppSafeArea,
  auth,
  authCart,
  HDMGuessGoods,
  HDMNavBar,
  HDMSku,
  HDMSkuType,
  PAGE_PATH
} from 'basic'
import { Goods } from '../viewmodels'
import { AppStorageV2, promptAction } from '@kit.ArkUI'
import { HDMGoodsInfo, HDMGoodsComment, HDMGoodsDetail } from '../components'
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { getGoodsDetailAPI } from '../api'
import { AlertOptions, DialogHelper, SpinType } from '@pura/harmony-dialog'


@HMRouter({ pageUrl: PAGE_PATH.GOODS_PAGE })
@ComponentV2
export struct GoodsView {
  breakPointClass: AppBreakPoint = AppStorageV2.connect(AppBreakPoint, () => new AppBreakPoint())!
  safeArea: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())!
  appCart: AppCart = AppStorageV2.connect(AppCart, () => new AppCart())!
  @Local goods: Goods = {} as Goods
  @Local activeIndex: number = 0
  @Local loading: boolean = false
  @Local
  showSheet: boolean = false
  @Local
  sku: HDMSkuType = {} as HDMSkuType
  scroller = new Scroller()
  tabsList: string[] = ["商品", "评价", "详情", "推荐"]
  @Local count:number = 1;

  async addCart(){
    // 判断是否登录
    const user = auth.getUser()
    if (user.token) {
      // 判断是否有skuId
      if (this.sku.id) {
        const key = DialogHelper.showLoadingDialog({
          loadType: SpinType.spinP,
          loadColor: Color.White,
          loadSize: 50,
          backgroundColor: '#b5000000',
          content: "正在加入…",
          fontSize: 18,
          padding: { top: 30, right: 50, bottom: 30, left: 50 },
          autoCancel: true
        })

        await addCartAPI({
          skuId:this.sku.id,
          count: this.count
        })

        promptAction.showToast({message:'成功加入购物车~' })
        // 更新购物车数量
        await authCart.updateCartCount()
        DialogHelper.closeDialog(key)
        this.showSheet = false
      }else {
        promptAction.showToast({message:'请选择对应规格的商品'})
      }
    }else{
      promptAction.showToast({message:'您还未登录'})
      // 关闭半模态
      this.showSheet = false
      HMRouterMgr.push({
        pageUrl: PAGE_PATH.LOGIN_PAGE
      })
    }
  }

  @Builder
  CustomTitleBuilder() {
    // 楼层切换
    Row() {
      Row({ space: 10 }) {
        Repeat<string>(this.tabsList).each((obj:RepeatItem<string>) => {
          Text(obj.item)
              .fontColor(this.activeIndex === obj.index ? $r("[basic].color.black") : $r("[basic].color.gray"))
              .onClick(() => {
                this.activeIndex = obj.index;
                this.scroller.scrollToIndex(this.activeIndex)
              })
        })
        // ForEach(this.tabsList, (tabName: string, index: number) => {
        //   Text(tabName)
        //     .fontColor(this.activeIndex === index ? $r("[basic].color.black") : $r("[basic].color.gray"))
        //     .onClick(() => {
        //
        //     })
        // })
      }

      Image($r('[basic].media.ic_public_shared'))
        .iconButton()
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width("100%")
    .height("100%")
    .padding({
      left: 50,
      right: 50
    })

  }

  @Builder
  AddCartBuilder() {
    Column() {
      Text(`已选:${this.sku.specsText}`)
        .fontWeight(300)
        .width('100%')
        .fontColor($r('[basic].color.black'))
        .fontSize(14)
        .padding({ bottom: 10, right: 50 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .visibility(this.sku.id ? Visibility.Visible: Visibility.Hidden)
      Row({ space: 10 }) {
        Image(this.sku.picture || this.goods.mainPictures?.[0])
          .alt($r('app.media.ic_sku_img'))
          .width(80)
          .height(80)
          .backgroundColor($r('[basic].color.under'))
          .borderRadius(4)
        Column() {
          Row() {
            Text('现价¥')
              .fontSize(14)
              .fontColor($r('[basic].color.black'))
              .offset({ y: -4 })
            Text(this.sku.price || this.goods.price)
              .fontSize(24)
              .fontColor($r('[basic].color.black'))
              .fontWeight(500)
            Text('原价¥' + (this.sku.oldPrice || this.goods.price))
              .fontSize(12)
              .fontColor($r('[basic].color.gray'))
              .margin({ left: 10 })
              .offset({ y: -4 })
              .decoration({
                type: TextDecorationType.LineThrough,
                color: $r('[basic].color.gray')
              })
          }
          .alignItems(VerticalAlign.Bottom)

          Row({ space: 10 }) {
            // 计数器
            Counter(){
              Text(this.count.toString())
            }
            .onInc(() =>{
              this.count++
            })
            .onDec(() => {
              this.count--
            })
            .enableDec(this.count > 1)

            Text(this.goods.inventory > 10000 ? '库存充足':'库存紧张')
              .fontSize(12)
              .fontColor(this.goods.inventory > 10000 ? $r('[basic].color.gray') : $r('[basic].color.red') )
          }
        }
        .height(80)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Divider()
        .strokeWidth(4)
        .color($r('[basic].color.under'))
        .margin({ left: -8, right: -8, top: 13 })

      List() {
        ListItem() {
          // Sku 组件
          HDMSku({
            skus:this.goods.skus,
            specs:this.goods.specs,
            onSkuChange:(sku) => {
              this.sku = sku
            }
          })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Row() {
        Button(this.loading ? '加入中...' : '加入购物袋')
          .buyButton($r('[basic].color.black'), true)
          .onClick(() => {
            // 实现加入购物车
            this.addCart()
          })
        Button('立即购买')
          .buyButton($r('[basic].color.red'), false)
          .onClick(async () => {

          })
      }
      .width('100%')
    }
    .height(600)
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: this.safeArea.bottomHeight || 16
    })
  }

  aboutToAppear(): void {
    this.goods = HMRouterMgr.getCurrentParam() as Goods
    this.getGoodsDetail()
  }

  async getGoodsDetail() {
    //进度加载类弹出框
    const key = DialogHelper.showLoadingDialog({
      loadType: SpinType.spinP,
      loadColor: Color.White,
      loadSize: 70,
      backgroundColor: '#BB000000',
      content: "加载中…",
      fontSize: 18,
      padding: { top: 30, right: 50, bottom: 30, left: 50 },
      autoCancel: true
    })

    this.goods = await getGoodsDetailAPI({ id: this.goods.id })

    DialogHelper.closeDialog(key)
  }

  build() {
    Column() {
      HDMNavBar({
        title:'',
        showRightIcon: true,
        customTitle: () => {
          this.CustomTitleBuilder()
        },
        onLeftClick: () => {
          HMRouterMgr.pop()
        }
      })
      Column() {
        List({ scroller: this.scroller }) {
          ListItem() {
            // 商品信息
            HDMGoodsInfo({ goods: this.goods })
              .geometryTransition(this.goods.id)
          }

          ListItem() {
            // 评论 目前无评论数据
            HDMGoodsComment({ goods: this.goods })
          }

          ListItem() {
            // 商品详情
            HDMGoodsDetail({ goods: this.goods })
          }

          ListItem() {
            // 猜你喜欢
            HDMGuessGoods()
          }
        }
        .onScrollIndex((index) => {
          this.activeIndex = index
        })
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
      }
      .layoutWeight(1)
      .backgroundColor($r('[basic].color.under'))

      Row() {
        Image($r('[basic].media.ic_public_like'))
          .iconButton()
        Image($r('[basic].media.ic_public_comment'))
          .iconButton()
        Badge({
          count: this.appCart.count,
          style: {},
          position: { x: 30, y: 4 }
        }) {
          Image($r('[basic].media.ic_public_cart'))
            .iconButton()
            .onClick(() => {
              HMRouterMgr.push({
                pageUrl: PAGE_PATH.CART_PAGE,
                param: true
              })
            })
        }

        Row() {
          Button('加入购物袋')
            .buyButton($r('[basic].color.black'), true)
            .onClick(() => {
              this.showSheet = true
            })
          Button('立即购买')
            .buyButton($r('[basic].color.red'), false)
            .onClick(async () => {
              this.showSheet = true
            })
        }
        .layoutWeight(1)
        .padding({ right: 16, left: 6 })
      }
      .height(54)
      .width('100%')
      .margin({ bottom: this.safeArea.topHeight })
    }
    .height('100%')
    .bindSheet($$this.showSheet, this.AddCartBuilder(),
      {
        height: SheetSize.FIT_CONTENT,
        backgroundColor: $r('[basic].color.white'),
        preferType: SheetType.CENTER
      })

  }
}

@Extend(Image)
function iconButton() {
  .width(24)
  .aspectRatio(1)
  .margin(13)
  .fillColor($r('[basic].color.black'))
}

@Extend(Button)
function buyButton(color: ResourceStr, isLeft: boolean) {
  .fontSize(14)
  .height(36)
  .type(ButtonType.Normal)
  .layoutWeight(1)
  .backgroundColor(color)
  .borderRadius({
    topLeft: isLeft ? 18 : 0,
    bottomLeft: isLeft ? 18 : 0,
    topRight: isLeft ? 0 : 18,
    bottomRight: isLeft ? 0 : 18
  })
  .pixelRound({
    end: PixelRoundCalcPolicy.FORCE_CEIL,
    start: PixelRoundCalcPolicy.FORCE_FLOOR
  })
}

