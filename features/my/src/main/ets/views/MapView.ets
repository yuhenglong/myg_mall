import { HMRouter } from '@hadss/hmrouter'
import { PAGE_PATH } from 'basic'
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';

@HMRouter({pageUrl:PAGE_PATH.MAP_VIEW})
@ComponentV2
export struct MapView {
  private TAG = "HuaweiMapDemo";
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;

  aboutToAppear(): void {
      // 地图初始化参数，设置地图中心点坐标及层级
      this.mapOptions = {
        position: {
          target: {
            latitude: 39.9,
            longitude: 116.4
          },
          zoom: 10
        }
      };
    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        let callback = () => {
          console.info(this.TAG, `on-mapLoad`);
        }
        this.mapEventManager.on("mapLoad", callback);
      }
    };
  }

  build() {
    Column(){
      // 调用MapComponent组件初始化地图
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback }).width('100%').height('100%')
    }
    .width('100%')
    .height('100%')
  }
}