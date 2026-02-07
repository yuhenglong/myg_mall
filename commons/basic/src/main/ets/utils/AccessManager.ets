import { abilityAccessCtrl, bundleManager, Permissions } from "@kit.AbilityKit";

export class AccessManager {
  async checkPermission(permissions: Permissions[], success: () => void, fail?: () => void) {
    // 1，先看有没有
    const app = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    const manager = abilityAccessCtrl.createAtManager()
    const listResult = permissions.map(p => manager.checkAccessTokenSync(app.appInfo.accessTokenId, p))
    // 检查所有的权限的结果
    const isOK = listResult.every(res => res === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    if (isOK) {
      success()
    } else {
      // 第一次申请权限
      const result = await manager.requestPermissionsFromUser(getContext(), permissions)
      const againCheck = result.authResults.every(res => res === 0)
      if (againCheck) {
        success()
      } else {
        const secondCheck = await manager.requestPermissionOnSetting(getContext(), permissions)
        const checkResult = secondCheck.every(res => res === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
        if (checkResult) {
          success()
        } else {
          fail?.()
          // fail && fail()
          // if (fail) {
          //   fail()
          // }
        }
      }
    }
    //

  }
}

export const accessManager = new AccessManager()