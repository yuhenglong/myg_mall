import { textToSpeech } from '@kit.CoreSpeechKit';

export class TextToVoiceManager {
  engine: textToSpeech.TextToSpeechEngine | null = null
  completeCallBack: () => void = () => {
  }

  async initEngine() {
    try {
      let extraParam: Record<string, Object> =
        { "style": 'interaction-broadcast', "locate": 'CN', "name": 'EngineName' };
      let initParamsInfo: textToSpeech.CreateEngineParams = {
        language: 'zh-CN',
        person: 0,
        online: 1,
        extraParams: extraParam
      };
      // 调用createEngine方法
      this.engine = await textToSpeech.createEngine(initParamsInfo);
    } catch (error) {
      AlertDialog.show({ message: '初始化语音播放引擎失败' })
    }
    this.setListener()

  }

  setListener() {
    // 设置speak的回调信息
    let speakListener: textToSpeech.SpeakListener = {
      // 开始播报回调
      onStart(requestId: string, response: textToSpeech.StartResponse) {
        console.info(`onStart, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 合成完成及播报完成回调
      onComplete: (requestId: string, response: textToSpeech.CompleteResponse) => {
        this.completeCallBack()
        console.info(`onComplete, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 停止播报回调
      onStop(requestId: string, response: textToSpeech.StopResponse) {
        console.info(`onStop, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 返回音频流
      onData(requestId: string, audio: ArrayBuffer, response: textToSpeech.SynthesisResponse) {
        console.info(`onData, requestId: ${requestId} sequence: ${JSON.stringify(response)} audio: ${JSON.stringify(audio)}`);
      },
      // 错误回调
      onError(requestId: string, errorCode: number, errorMessage: string) {
        console.error(`onError, requestId: ${requestId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      }
    };
    // 设置回调
    this.engine?.setListener(speakListener);
  }

  // 播放语音
  async speech(text: string, callBack: () => void) {
    this.completeCallBack = callBack
    if (!this.engine) {
      await this.initEngine()
    }
    let extraParam: Record<string, Object> = {
      "queueMode": 0,
      "speed": 1,
      "volume": 2,
      "pitch": 1,
      "languageContext": 'zh-CN',
      "audioType": "pcm",
      "soundChannel": 3,
      "playType": 1
    };
    let speakParams: textToSpeech.SpeakParams = {
      requestId: Date.now().toString(), // requestId在同一实例内仅能用一次，请勿重复设置
      extraParams: extraParam
    };
    this.engine?.speak(text, speakParams)
  }

  stop() {
    this.engine?.stop()
    this.engine?.shutdown()
    this.engine = null // 释放资源
  }
}

export const textToVoiceManager = new TextToVoiceManager()