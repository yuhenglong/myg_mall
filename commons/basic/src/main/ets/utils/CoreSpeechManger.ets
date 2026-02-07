import { speechRecognizer } from '@kit.CoreSpeechKit';
import { Logger } from '.';

export class CoreSpeechManager {
  asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null // 语音识别引擎
  // 引擎得提前初始化 -录音已经有buffer 你说了一句你好 需要保证此时语音识别引擎已经准备好了
  sessionId: string = Date.now().toString() // 必须是数字字符串
  // 把转换出的文字传递给调用处
  resultCallBack?: (content: string) => void

  async initEngine(callBack: (content: string) => void) {
    this.resultCallBack = callBack // 将外界传入的函数赋值给本身的一个函数

    // 创建引擎，通过callback形式返回
    // 设置创建引擎参数
    let extraParam: Record<string, Object> = { "locate": "CN", "recognizerMode": "short" };
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN', // 支持中文
      online: 1, // 离线模式 比较弱 没那么大的准确性
      extraParams: extraParam
    };
    // 调用createEngine方法
    this.asrEngine = await speechRecognizer.createEngine(initParamsInfo);
    this.setListener() // 设置监听
    this.startListening() // 开始监听
  }

  // 设置监听回调
  private setListener() {
    // 创建回调对象
    let setListener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart(sessionId: string, eventMessage: string) {
        console.info(`onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 事件回调
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        console.info(`onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
      },
      // 识别结果回调，包括中间结果和最终结果
      onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
        Logger.info(result.result)
        // 回传文本
        this.self.resultCallBack?.(result.result)
        // console.info(`onResult, sessionId: ${sessionId} sessionId: ${JSON.stringify(result)}`);
      },
      // 识别完成回调
      onComplete(sessionId: string, eventMessage: string) {
        console.info(`onComplete, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 错误回调，错误码通过本方法返回
      // 如：返回错误码1002200006，识别引擎正忙，引擎正在识别中
      // 更多错误码请参考错误码参考
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        console.error(`onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      }
    }
    // 设置回调
    this.asrEngine?.setListener(setListener);
  }

  // 开启监听
  private startListening() {
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      audioInfo: {
        audioType: 'pcm',
        sampleRate: 16000,
        soundChannel: 1,
        sampleBit: 16
      } //audioInfo参数配置请参考AudioInfo
    }
    // 调用开始识别方法
    this.asrEngine?.startListening(recognizerParams);
  }

  // 开始分析
  startTransVoice(bf: ArrayBuffer) {
    this.asrEngine?.writeAudio(this.sessionId, new Uint8Array(bf)) // 写入音频流
  }

  // 停止分析
  stopTransVoice() {
    this.asrEngine?.finish(this.sessionId) // 结束识别
    this.asrEngine?.shutdown() // 释放资源
    this.asrEngine = null // 内存清空
    this.sessionId = Date.now().toString() // 重新初始化sessionId
  }
}

export const coreSpeechManager = new CoreSpeechManager()