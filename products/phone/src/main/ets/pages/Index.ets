import { AppBreakPoint,
  AppCart,
  AppSafeArea,
  authCart,
  AuthCart, BreakPointType, GlobalVariable, Logger, PAGE_PATH, TabItem } from 'basic'
import { CartView } from 'cart'
import { CategoryView } from 'category'
import { HomeView } from 'home'
import { MyView } from 'my'
import { AppStorageV2, AttributeUpdater } from '@kit.ArkUI'
import { HMDefaultGlobalAnimator, HMNavigation } from '@hadss/hmrouter'
import { emitter } from '@kit.BasicServicesKit'

class MyModifier extends AttributeUpdater<NavigationAttribute> {
  // 重写原来的方法
  initializeModifier(instance: NavigationAttribute): void {
    // instance就是Navigation实例对象
    instance.mode(NavigationMode.Stack) // 分栏模式去掉
    instance.titleMode(NavigationTitleMode.Mini) // 标题模式全屏
    instance.hideTitleBar(true) // 隐藏标题栏
  }
}

@Entry
@ComponentV2
struct Index {
  modifier: MyModifier = new MyModifier() // 专门用来修改Navigation特性对象实例
  breakObj: AppBreakPoint = AppStorageV2.connect(AppBreakPoint,() => new AppBreakPoint())!
  // 获取安全区域
  safeArea: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())!

  appCart: AppCart = AppStorageV2.connect(AppCart, () => new AppCart())!

  controller: TabsController = new TabsController()

  @Local
  activeIndex: number = 0
  list: TabItem[] = [
    { text: '首页', normal: $r('app.media.ic_public_home_normal'), active: $r('app.media.ic_public_home_active') },
    { text: '分类', normal: $r('app.media.ic_public_pro_normal'), active: $r('app.media.ic_public_pro_active') },
    { text: '购物袋', normal: $r('app.media.ic_public_cart_normal'), active: $r('app.media.ic_public_cart_active') },
    { text: '我的', normal: $r('app.media.ic_public_my_normal'), active: $r('app.media.ic_public_my_active') },
  ]

  aboutToAppear(): void {
    // 注册监听事件(切换tab)
    this.registerEvent()
    this.getCartCount()
  }

  getCartCount(){
    authCart.updateCartCount()
  }

  registerEvent(){
    emitter.on(GlobalVariable.SWITCH_TAB,(e)=>{
      if (e.data) {
        // 直接切换
        // this.activeIndex = e.data.index as number;
        // 过渡切换
        this.controller.changeIndex(e.data.index as number)
      }
    })
  }

  @Builder
  getTabItemBuilder(item: TabItem, index: number) {
    Column() {
      if (index === 2){
        Badge({ count : this.appCart.count,style :{} }){
          Column(){
            Image(this.activeIndex === index ? item.active : item.normal)
              .width(24)
              .aspectRatio(1)
            Text(item.text)// 跨 HSP 访问资源，需要在 oh-package.json5中导入
              .fontColor($r('[basic].color.black'))
              .fontSize(12)
          }
        }
      }else {
        Image(this.activeIndex === index ? item.active : item.normal)
          .width(24)
          .aspectRatio(1)
        Text(item.text)// 跨 HSP 访问资源，需要在 oh-package.json5中导入
          .fontColor($r('[basic].color.black'))
          .fontSize(12)
      }
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .height(50)
  }

  build() {
    Column(){
      // 使用HMNavigation包裹整个根容器 -坑点-HMNavigation外层必须再包一个容器
      // HMNavigation 是对navigation的封装
      // 坑点 子页面绝不能出现NavDestination
      // homePageUrl 是根页面的地址 想要回来直接写整个地址
      // 想要Navigation的特性
      HMNavigation({
        navigationId: PAGE_PATH.MAIN_PAGE_ID, homePageUrl: PAGE_PATH.MAIN_PAGE,
        options: {
          standardAnimator: HMDefaultGlobalAnimator.STANDARD_ANIMATOR,
          dialogAnimator: HMDefaultGlobalAnimator.DIALOG_ANIMATOR,
          modifier: this.modifier, // 修改Navigation的对象实例
          // 想要改一些Navigation的属性
        }}) {
        Tabs({
          controller:this.controller,
          barPosition: new BreakPointType({
          sm: BarPosition.End,
          md: BarPosition.End,
          lg: BarPosition.Start
        }).getValue(this.breakObj.breakPoint), index: $$this.activeIndex }) {
          ForEach(this.list, (item: TabItem, index: number) => {
            TabContent() {
              if (index == 0) {
                HomeView()
              } else if (index == 1) {
                CategoryView()
              } else if (index == 2) {
                CartView()
              } else {
                MyView()
              }
            }
            .tabBar(this.getTabItemBuilder(item, index))
          })
        }
        .scrollable(false)
        .barHeight(new BreakPointType({
          sm: 60,
          md: 60,
          lg: 220
        }).getValue(this.breakObj.breakPoint))
        .vertical(new BreakPointType({
          sm: false,
          md: false,
          lg: true
        }).getValue(this.breakObj.breakPoint))
        .animationDuration(new BreakPointType({
          sm:300,
          md:300,
          lg:0
        }).getValue(this.breakObj.breakPoint)
        )
        .padding({
          bottom: this.safeArea.bottomHeight
        })
      }
    }



  }
}

