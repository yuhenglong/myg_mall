import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { HDMUser, HDMNavBar, HDMCellGroup, HDMCell, PAGE_PATH, AppSafeArea, AppUser, auth, authCart } from 'basic'
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { DialogAction, DialogHelper } from '@pura/harmony-dialog'
import common from '@ohos.app.ability.common'
import { Want } from '@kit.AbilityKit'


@HMRouter({ pageUrl: PAGE_PATH.SETTING_PAGE })
@ComponentV2
export struct SettingView {
  appUser: AppUser = PersistenceV2.connect(AppUser, () => new AppUser())!
  safeArea: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())!

  @Builder
  getProfileBuilder() {
    RelativeContainer() {
      Image($r("[basic].media.ic_public_right"))
        .fillColor($r("[basic].color.gray"))
        .width(30)
        .aspectRatio(1)
        .alignRules({
          center: {
            anchor: '__container__',
            align: VerticalAlign.Center
          },
          right: {
            anchor: '__container__',
            align: HorizontalAlign.End
          }
        })
        .onClick(() => {

        })

      Image(this.appUser.user.avatar)
        .alt($r("app.media.ic_user_avatar"))
        .width(50)
        .aspectRatio(1)
        .borderRadius(25)
        .alignRules({
          center: {
            anchor: '__container__',
            align: VerticalAlign.Center
          }
        })
        .id("avatar")
      Column({ space: 4 }) {
        Text(this.appUser.user.nickname || this.appUser.user.account)
          .fontColor($r('[basic].color.black'))
          .fontWeight(500)
        Text('账号名：' + this.appUser.user.account)
          .fontColor($r('[basic].color.gray'))
          .fontSize(12)
      }

      .alignRules({
        center: {
          anchor: '__container__',
          align: VerticalAlign.Center
        },
        left: {
          anchor: 'avatar',
          align: HorizontalAlign.End
        }
      })
      .alignItems(HorizontalAlign.Start)
      .margin({
        left: 10
      })
    }
    .constraintSize({
      maxHeight: 100
    })
    .padding({ top: 16, bottom: 16 })
  }

  aboutToAppear(): void {
    // 下载混合开发压缩包的工具

  }

  build() {
    Column() {
      HDMNavBar({
        title: '设置',
        onLeftClick: () => {
          // 点击返回

        }
      })
      Column({ space: 8 }) {
        // 头像昵称 还有账号
        HDMCellGroup() {
          this.getProfileBuilder()
        }

        Blank() // 空格
        HDMCellGroup() {
          HDMCell({
            title: '收货地址管理', onRightClick: () => {

            }
          })

          HDMCell({ title: '语音播报' })
            .onClick(() => {
              HMRouterMgr.push({
                pageUrl: PAGE_PATH.PRIVATE_VIEW
              })
            })
          HDMCell({ title: '跳转到设置app' })
            .onClick(() => {
              const want: Want = {
                bundleName: 'com.huawei.hmos.settings',
                abilityName: 'com.huawei.hmos.settings.MainAbility',
                uri: 'application_info_entry',
                parameters: {
                  // 修改成你的应用包名
                  pushParams: 'com.itcast.mg_mall'
                }
              }
              const ctx = getContext(this) as common.UIAbilityContext
              ctx.startAbility(want)
            })
          HDMCell({ title: '去地图' })
            .onClick(() => {
              HMRouterMgr.push({
                pageUrl: PAGE_PATH.MAP_VIEW
              })
            })
          HDMCell({ title: '通用设置' })
        }

        Blank() // 空格

        HDMCellGroup() {
          HDMCell({ title: '退出登录' })
            .onClick(() => {
              // 弹出层
              // AlertDialog.show({
              //   message:'你确定退出吗?',
              //   primaryButton:{
              //     value:'取消',
              //     fontColor: $r('[basic].color.red'),
              //     action: () => {}
              //   },
              //   secondaryButton:{
              //     value:'确定',
              //     fontColor: $r('[basic].color.gray'),
              //     action: () => {
              //       auth.setUser({} as HDMUser)
              //       HMRouterMgr.pop()
              //     }
              //   }
              // })

              DialogHelper.showAlertDialog({
                content: "确认退出登录吗？",
                onAction: async (action) => {
                  if (action == DialogAction.CANCEL) {

                  } else if (action == DialogAction.SURE) {
                    auth.setUser({} as HDMUser)
                    // 退出登陆后,更新购物车数量
                    await authCart.updateCartCount()
                    HMRouterMgr.pop()
                  }
                }
              })
            })

        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('[basic].color.under'))
  }
}