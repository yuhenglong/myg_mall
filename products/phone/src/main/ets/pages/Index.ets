import { Logger, TabItem } from 'basic'
import { CartView } from 'cart'
import { CategoryView } from 'category'
import { HomeView } from 'home'
import { MyView } from 'my'


@Entry
@ComponentV2
struct Index {
  @Local
  activeIndex: number = 0
  list: TabItem[] = [
    { text: '首页', normal: $r('app.media.ic_public_home_normal'), active: $r('app.media.ic_public_home_active') },
    { text: '分类', normal: $r('app.media.ic_public_pro_normal'), active: $r('app.media.ic_public_pro_active') },
    { text: '购物袋', normal: $r('app.media.ic_public_cart_normal'), active: $r('app.media.ic_public_cart_active') },
    { text: '我的', normal: $r('app.media.ic_public_my_normal'), active: $r('app.media.ic_public_my_active') },
  ]

  aboutToAppear(): void {
    Logger.info({
      name:'鸿蒙',
      age:9
    })
  }

  @Builder
  getTabItemBuilder(item: TabItem, index: number) {
    Column() {
      Image(this.activeIndex === index ? item.active : item.normal)
        .width(24)
        .aspectRatio(1)
      Text(item.text)// 跨 HSP 访问资源，需要在 oh-package.json5中导入
        .fontColor($r('[basic].color.black'))
        .fontSize(12)
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .height(50)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: $$this.activeIndex }) {
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
  }
}

