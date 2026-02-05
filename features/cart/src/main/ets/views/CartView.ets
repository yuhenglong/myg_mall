import { HDMGuessGoods, HDMNavBar, HDMUser, CartGoodsModel, AppBreakPoint, AppSafeArea, AppUser, HDMEmpty,
  PAGE_PATH,
  GlobalVariable,
  getCartListAPI,
  AppCart,
  updateCartAPI,
  authCart,
  selectOrUnSelectAPI,
  delCartAPI} from 'basic'
import { CartItem } from '../components'
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { emitter } from '@kit.BasicServicesKit'
import { DialogAction, DialogHelper } from '@pura/harmony-dialog'

@HMRouter({pageUrl: PAGE_PATH.CART_PAGE})

@ComponentV2
export struct CartView {
  // 用户信息
  appUser: AppUser = PersistenceV2.connect(AppUser, () => new AppUser())!
  // 商品信息
  breakPointClass: AppBreakPoint = AppStorageV2.connect(AppBreakPoint, () => new AppBreakPoint())!
  safeArea: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())!
  appCart: AppCart = AppStorageV2.connect(AppCart, () => new AppCart())!
  // @Local cartList: CartGoodsModel[] = []
  @Local
  showLeftIcon : boolean = false

  aboutToAppear(): void {
    this.showLeftIcon = HMRouterMgr.getCurrentParam() as boolean;
  }
// 全选按钮是否勾选
  @Computed
  get isCheckAll(){
    return this.appCart.cartList.every(item => item.selected)
  }
// 计算总价格
  @Computed
  get totalPrice(){
    return (this.appCart.cartList.filter(item => item.selected)).reduce((count : number , item : CartGoodsModel) => {
      return count + item.count * item.price;
    }, 0 )
  }

  //去结算是否可点击
  @Computed
  get isClick(){
    return this.appCart.cartList.some(item => item.selected)
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
        DialogHelper.showAlertDialog({
          content:'确定删除该商品吗?',
          onAction: async (action) => {
            if (action == DialogAction.CANCEL) {

            } else if (action == DialogAction.SURE) {
              await delCartAPI({ ids: [cart.skuId] })
              await authCart.updateCartCount()
            }
          }
        })
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
        showLeftIcon: this.showLeftIcon
      })
        .border({
          width: { bottom: 0.5 },
          color: '#e4e4e4'
        })

      List() {
        if (this.appUser.user.token) {

          if (this.appCart.cartList.length) {
            Repeat<CartGoodsModel>(this.appCart.cartList).each((obj:RepeatItem<CartGoodsModel>) => {
              ListItem() {
                CartItem({
                  cart: obj.item,
                  onChangeCount: async (count: number) => {
                    const key = DialogHelper.showLoadingDialog({
                      loadColor:$r('[basic].color.white'),
                      loadSize:40,
                      backgroundColor:'#BB000000',
                      content:'更新中...'
                    })
                    await updateCartAPI(obj.item.skuId, { count ,selected:obj.item.selected })
                    await authCart.updateCartCount() //   更新整体购物车
                    DialogHelper.closeDialog(key)
                  },
                  onChangeSelected: async selected => {
                    const key = DialogHelper.showLoadingDialog({
                      loadColor:$r('[basic].color.white'),
                      loadSize:40,
                      backgroundColor:'#BB000000',
                      content:'更新中...'
                    })
                    await updateCartAPI(obj.item.skuId, { count : obj.item.count ,selected })
                    await authCart.updateCartCount() //   更新整体购物车
                    DialogHelper.closeDialog(key)
                  }
                })
              }
              .backgroundColor($r('[basic].color.under'))
              .padding({ left: 8, right: 8 })
              .transition({ type: TransitionType.Delete, opacity: 0 })
              .swipeAction({
                end: this.DeleteBuilder(obj.item)
              })
            })
              .virtualScroll()
              .key((item: CartGoodsModel, index: number) => `${index}_${item}`)
          } else {
            // 购物车是空的
            ListItem() {
              HDMEmpty({
                onBtnClick:() =>{
                  emitter.emit(GlobalVariable.SWITCH_TAB,{data:{index: 0}})
                }
              })
            }
          }
        } else {
          // 未登录
          ListItem() {
            HDMEmpty({
              tip:'您还未登录',
              buttonText:'去登录',
              onBtnClick: () => {
                HMRouterMgr.push({
                  pageUrl: PAGE_PATH.LOGIN_PAGE
                })
              }
            })

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

      if (this.appCart.cartList.length) {
        Row() {
          Checkbox()
            .select(this.isCheckAll)
            .selectedColor($r('[basic].color.red'))
            .onClick(async () => {
              const key = DialogHelper.showLoadingDialog({
                loadColor:$r('[basic].color.white'),
                loadSize:40,
                backgroundColor:'#BB000000',
                content:'更新中...'
              })
              await selectOrUnSelectAPI({selected: !this.isCheckAll})
              await authCart.updateCartCount()
              DialogHelper.closeDialog(key)
            })
          Text('全选')
            .fontSize(14)
            .fontColor($r('[basic].color.black'))
            .margin({ right: 20 })
          Text('合计:')
            .fontSize(14)
            .fontColor($r('[basic].color.black'))
            .margin({ right: 2 })
          Text(this.totalPrice.toFixed(2))
            .fontSize(16)
            .fontWeight(500)
            .fontColor($r('[basic].color.red'))
            .layoutWeight(1)
          Button('去结算')
            .enabled(this.isClick)
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



