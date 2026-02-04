import { HDMGuessGoods, HDMNavBar, HDMUser, CartGoodsModel, AppBreakPoint, AppSafeArea } from 'basic'
import { CartItem } from '../components'
import { HMRouterMgr } from '@hadss/hmrouter'
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'

@ComponentV2
export struct CartView {
  // 用户信息
  user: HDMUser = PersistenceV2.connect(HDMUser, () => new HDMUser())!
  // 商品信息
  breakPointClass: AppBreakPoint = AppStorageV2.connect(AppBreakPoint, () => new AppBreakPoint())!
  safeArea: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())!
  @Local cartList: CartGoodsModel[] = []

  aboutToAppear(): void {

  }

  @Builder
  DeleteBuilder(cart: CartGoodsModel) {
    Text('删除')
      .fontSize(14)
      .width(60)
      .height(100)
      .backgroundColor($r('[basic].color.red'))
      .fontColor($r('[basic].color.white'))
      .textAlign(TextAlign.Center)
      .onClick(() => {

      })
  }

  onCheckOrder() {
    AlertDialog.show({
      message: '去结算'
    })
  }

  build() {
    Column() {
      HDMNavBar({
        onLeftClick: () => {
          // this.stackPath.pop()
          HMRouterMgr.pop()
        },
        title: '购物袋',
        showRightIcon: true,
        showLeftIcon: false
      })
        .border({
          width: { bottom: 0.5 },
          color: '#e4e4e4'
        })

      List() {
        if (this.user.token) {

          if (this.cartList.length) {
            ForEach(this.cartList, (cart: CartGoodsModel) => {
              ListItem() {
                CartItem({
                  cart: cart,
                  onChangeSelected: async selected => {

                  }
                })
              }
              .backgroundColor($r('[basic].color.under'))
              .padding({ left: 8, right: 8 })
              .transition({ type: TransitionType.Delete, opacity: 0 })
              .swipeAction({
                end: this.DeleteBuilder(cart)
              })
            })
          } else {
            ListItem() {

            }
          }
        } else {
          // 未登录
          ListItem() {


          }
        }
        ListItem() {
          HDMGuessGoods()
            .margin({ top: 8, bottom: 8 })
        }

      }
      .contentStartOffset(8)
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      if (this.cartList.length) {
        Row() {
          Checkbox()
            .selectedColor($r('[basic].color.red'))
            .onClick(async () => {

            })
          Text('全选')
            .fontSize(14)
            .fontColor($r('[basic].color.black'))
            .margin({ right: 20 })
          Text('合计:')
            .fontSize(14)
            .fontColor($r('[basic].color.black'))
            .margin({ right: 2 })
          Text("0.00")
            .fontSize(16)
            .fontWeight(500)
            .fontColor($r('[basic].color.red'))
            .layoutWeight(1)
          Button('去结算')
            .enabled(this.cartList.some(item => item.selected))
            .fontSize(14)
            .height(36)
            .backgroundColor($r('[basic].color.red'))
            .onClick(() => {

            })
        }
        .height(50)
        .width('100%')
        .backgroundColor($r('[basic].color.white'))
        .border({
          width: { top: 0.5, bottom: 0.5 },
          color: '#e4e4e4'
        })
        .padding({ left: 16, right: 16 })
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('[basic].color.under'))

  }
}



