import { audio } from "@kit.AudioKit"

export class AudioCapturerManager {
  capturer: audio.AudioCapturer | null = null

  // 创建录音对象
  async initCapturer() {

    let audioStreamInfo: audio.AudioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000, // 采样率 语音识别只能识别16000
      channels: audio.AudioChannel.CHANNEL_1, // 通道1
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
    };

    let audioCapturerInfo: audio.AudioCapturerInfo = {
      source: audio.SourceType.SOURCE_TYPE_MIC,
      capturerFlags: 0
    };

    let audioCapturerOptions: audio.AudioCapturerOptions = {
      streamInfo: audioStreamInfo,
      capturerInfo: audioCapturerInfo
    };
    this.capturer = await audio.createAudioCapturer(audioCapturerOptions);
  }

  async start(callback: (bf: ArrayBuffer) => void) {
    // 1.创建采集器
    if (!this.capturer) {
      await this.initCapturer()
    }
    // 2.监听readData
    this.capturer?.on("readData", (bf) => {
      // bf -> 文字 实时的
      callback(bf)
    })
    // 3.开始录制
    this.capturer?.start() // 开始录音

  }

  async stop() {
    await this.capturer?.stop()
    this.capturer?.release()
    this.capturer = null
  }
}

export const audioCapturerManager = new AudioCapturerManager()