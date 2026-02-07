import { HMRouter, HMRouterMgr } from "@hadss/hmrouter"
import { HDMNavBar, PAGE_PATH, textToVoiceManager } from "basic"

@HMRouter({ pageUrl: PAGE_PATH.PRIVATE_VIEW })
@ComponentV2
export struct PrivateView {
  @Local
  text: string = "【卷一·山水清音】\n" +
    "粼粼秋水裁月色为帛，渔舟枕着星河入眠，松风在崖畔煮一壶云雾，白鹭掠过青峰时抖落几粒蝉鸣。远山以黛色晕染天际线，苔痕攀上石阶，蜿蜒成时光篆刻的秘语。忽有笛声自竹坞飘来，揉碎满涧烟霞，露珠坠入深潭，溅起一斛泠泠旧梦。\n" +
    "\n" +
    "【卷二·夜宴流光】\n" +
    "莲灯浮于荷塘，萤火提笔写就夏夜的长卷，蒲扇摇落流萤，飞入瓷盏化作琥珀色的茶烟。木樨暗香攀上西窗，与半阙残棋对弈，棋子叩响玉枰，惊醒了蜷在砚台边的狸奴。廊下风铃轻晃，恍若故人踏月归来，衣袂携着梅雨时节的潮声，滴答——滴答——洇湿了案头未干的诗笺。\n" +
    "\n" +
    "【卷三·四季行吟】\n" +
    "春雪烹茶，看新绿咬破冻土，桃夭蘸着溪水将云影绣上襦裙；夏蝉织雨，芭蕉叶托住坠落的银河，蒲团静听檐角与雷声论道；秋槭燃火，暮色把雁阵煨成金箔汤，醉卧荻花深处，任白露在鬓边结晶成星；冬炉煨芋，听雪籽轻敲竹瓦，炭火爆出松脂香，拓印出陶罐上褪色的年轮。\n" +
    "\n" +
    "【终章·心镜澄明】\n" +
    "且取半瓢烟波濯足，让浮名沉入沙渚，鸥鸟衔来贝页经，潮汐反复诵读亘古的禅意。当月光浸透茅檐，心舟已卸下所有锚链，随风泊进蒹葭苍苍的彼岸——那里春山不老，流云不系，一川烟草盛开着永恒的清明"

  @Local
  playIng: boolean = false

  aboutToDisappear(): void {
    textToVoiceManager.stop()
    this.playIng = false
  }

  build() {
    Column() {
      HDMNavBar({
        title: '语音播放', onLeftClick: () => {
          HMRouterMgr.pop()
        }
      })
      RelativeContainer() {
        Text(this.text)
          .lineHeight(40)

        Image(this.playIng ? $r("sys.media.ohos_ic_public_pause") : $r("sys.media.ohos_ic_public_play"))
          .width(30)
          .aspectRatio(1)
          .alignRules({
            right: {
              anchor: "__container__",
              align: HorizontalAlign.End
            },
            bottom: {
              anchor: "__container__",
              align: VerticalAlign.Bottom
            }
          })
          .margin({
            bottom: 50,
            right: 20
          })
          .onClick(() => {
            this.playIng = !this.playIng
            if (this.playIng) {
              textToVoiceManager.speech(this.text, () => {
                this.playIng = false
              })
            } else {
              textToVoiceManager.stop()
            }
          })
      }
      .layoutWeight(1)

    }
    .padding({
      left: 30,
      right: 30
    })
  }
}