import { AppBreakPoint, AppCategory, AppSafeArea, CategoryItem, CategoryItemChild } from 'basic'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct CategoryView {
  breakPointClass: AppBreakPoint = AppStorageV2.connect(AppBreakPoint, () => new AppBreakPoint())!
  safeArea: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())!
  //  Mock分类数据
  // categories: CategoryItem[] = new Array(10).fill({
  //   id: "1181622001",
  //   name: "气质女装",
  //   picture: "https://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/meikou/c1/qznz.png"
  // })

  // 从AppStorageV2中获取分类数据
  appCategory : AppCategory = AppStorageV2.connect(AppCategory, () => new AppCategory())!

  @Local activeIndex: number = 0

  build() {
    Column() {
      // MkNavbar({
      // })
      //   .border({ width: { bottom: 0.5 }, color: $r('[basic].color.under') })

      Row() {
        Column() {
          Repeat<CategoryItem>(this.appCategory.category).each((obj:  RepeatItem<CategoryItem>) => {
              Text(obj.item.name)// 文本
                .backgroundColor(this.activeIndex === obj.index ? $r('[basic].color.black') : $r('[basic].color.white'))
                .fontSize(14)
                .fontColor(this.activeIndex === obj.index ? $r('[basic].color.white') : $r('[basic].color.black'))
                .textAlign(TextAlign.Center)
                .width('100%')
                .height(56)
                .onClick(() => {
                  this.activeIndex = obj.index
                })
          })
        }
        .width(88)
        .border({ width: { right: 0.5 }, color: $r('[basic].color.under') })

        Scroll() {
          Column() {
            // 顶部图片
            Image(this.appCategory.category[this.activeIndex].picture)
              .width('100%')
              .height(136)
              .objectFit(ImageFit.Contain)
              .backgroundColor('#f6f6f6')
              .borderRadius(8)
              .margin({ bottom: 8 })
            GridRow({ columns: 2, gutter: 8 }) {
              // 子分类
              Repeat<CategoryItemChild>(this.appCategory.category[this.activeIndex]?.children || [])
                .each((obj: RepeatItem<CategoryItemChild>) => {
                    GridCol() {
                      Column() {
                        // 图片
                        Image(obj.item.picture)
                          .width(64)
                          .aspectRatio(1)
                        Text(obj.item.name)// 文本
                          .fontSize(14)
                          .fontColor($r('[basic].color.text'))
                          .margin({ top: 8 })
                      }
                      .height('100%')
                      .justifyContent(FlexAlign.Center)
                    }
                    .aspectRatio(1)
                    .backgroundColor('#f6f6f6')
                    .borderRadius(8)
                })
            }
          }
          .padding(8)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .height('100%')
  }
}