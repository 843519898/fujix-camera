import UIKit
import Flutter
import GPUImage
import AVFoundation
import MetalPetal
import MetalKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController

    let channel1 = FlutterMethodChannel(name: "com.cx.flutter.native/channel", binaryMessenger: controller.binaryMessenger)
    channel1.setMethodCallHandler { (call, result) in
          if call.method == "navigateToVideoClip" {
            VideoClipNavigationHandler.handleNavigateToVideoClip(call: call, result: result)
          } else if call.method == "navigateDuplicateRemovalp" {
            navigateDuplicateRemovalpHandler.Removalp(call: call, result: result)
          } else {
            result(FlutterMethodNotImplemented)
          }
        }


    let channel = FlutterMethodChannel(name: "gpuimage_pip", binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler { (call, result) in
      if call.method == "pip" {
        guard let args = call.arguments as? [String: String],
              let bgPath = args["bgPath"],
              let fgPath = args["fgPath"],
              let outputPath = args["outputPath"] else {
          result(FlutterError(code: "BAD_ARGS", message: "参数错误", details: nil))
          return
        }
        self.pipVideoWithMetalPetal(bgPath: bgPath, fgPath: fgPath, outputPath: outputPath) { success, finalPath in
          if success, let finalPath = finalPath {
            result(finalPath)
          } else {
            result(FlutterError(code: "PIP_FAILED", message: "合成失败", details: nil))
          }
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 画中画合成
  func pipVideo(bgPath: String, fgPath: String, outputPath: String, completion: @escaping (Bool, String?) -> Void) {
    let bgURL = URL(fileURLWithPath: bgPath)
    let fgURL = URL(fileURLWithPath: fgPath)
    let outputURL = URL(fileURLWithPath: outputPath)
    let backgroundMovie = GPUImageMovie(url: bgURL)
    let frontMovie = GPUImageMovie(url: fgURL)
    backgroundMovie?.playAtActualSpeed = false
    frontMovie?.playAtActualSpeed = false

    // 获取视频尺寸
    let bgAsset = AVAsset(url: bgURL)
    let fgAsset = AVAsset(url: fgURL)
    guard let bgTrack = bgAsset.tracks(withMediaType: .video).first,
          let fgTrack = fgAsset.tracks(withMediaType: .video).first else {
      completion(false, nil)
      return
    }
    let bgSize = bgTrack.naturalSize
    let fgSize = fgTrack.naturalSize
    let scale = bgSize.width / fgSize.width
    let scaledFgHeight = fgSize.height * scale
    let yOffset = (bgSize.height - scaledFgHeight) / 2
    var transform = CGAffineTransform.identity
    transform = transform.scaledBy(x: scale, y: scale)
    transform = transform.translatedBy(x: 0, y: yOffset / scale)
    let transformFilter = GPUImageTransformFilter()
    transformFilter.affineTransform = transform

    let blendFilter = GPUImageAlphaBlendFilter()
    blendFilter.mix = 0.2 // 只需改这里

    frontMovie?.addTarget(transformFilter)
    transformFilter.addTarget(blendFilter)
    backgroundMovie?.addTarget(blendFilter)

    // 输出为mov
    let tempMovURL = outputURL.deletingPathExtension().appendingPathExtension("mov")
    let movieWriter = GPUImageMovieWriter(movieURL: tempMovURL, size: bgSize)
    blendFilter.addTarget(movieWriter)

    var hasFinished = false

    movieWriter?.completionBlock = {
      if hasFinished { return }
      hasFinished = true
      movieWriter?.finishRecording()
      // 合成后转码为mp4
      self.convertMovToMp4(movUrl: tempMovURL, mp4Url: outputURL) { success in
        completion(success, success ? outputURL.path : nil)
      }
    }
    movieWriter?.failureBlock = { error in
      if hasFinished { return }
      hasFinished = true
      completion(false, nil)
    }

    movieWriter?.startRecording()
    backgroundMovie?.startProcessing()
    frontMovie?.startProcessing()
  }

  // mov转mp4，保证video_player兼容
  func convertMovToMp4(movUrl: URL, mp4Url: URL, completion: @escaping (Bool) -> Void) {
    let asset = AVAsset(url: movUrl)
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
      completion(false)
      return
    }
    exportSession.outputURL = mp4Url
    exportSession.outputFileType = .mp4
    exportSession.exportAsynchronously {
      completion(exportSession.status == .completed)
    }
  }

  func pipVideoWithMetalPetal(bgPath: String, fgPath: String, outputPath: String, completion: @escaping (Bool, String?) -> Void) {
    print("开始MetalPetal视频合成")
    print("背景视频路径: \(bgPath)")
    print("前景视频路径: \(fgPath)")
    print("输出路径: \(outputPath)")
    
    // 1. 初始化 MetalPetal 上下文
    guard let device = MTLCreateSystemDefaultDevice() else {
      print("❌ 无法创建Metal设备")
      completion(false, nil)
      return
    }
    
    let context: MTIContext
    do {
      context = try MTIContext(device: device)
      print("✅ MetalPetal上下文创建成功")
    } catch {
      print("❌ MetalPetal上下文创建失败: \(error)")
      completion(false, nil)
      return
    }
    
    // 2. 加载前景和背景视频
    let foregroundURL = URL(fileURLWithPath: fgPath)
    let backgroundURL = URL(fileURLWithPath: bgPath)
    let foregroundAsset = AVAsset(url: foregroundURL)
    let backgroundAsset = AVAsset(url: backgroundURL)
    
    print("前景视频时长: \(foregroundAsset.duration.seconds)秒")
    print("背景视频时长: \(backgroundAsset.duration.seconds)秒")
    
    // 获取视频轨道信息
    guard let fgTrack = foregroundAsset.tracks(withMediaType: .video).first,
          let bgTrack = backgroundAsset.tracks(withMediaType: .video).first else {
      print("❌ 无法获取视频轨道")
      completion(false, nil)
      return
    }
    
    let fgSize = fgTrack.naturalSize.applying(fgTrack.preferredTransform)
    let bgSize = bgTrack.naturalSize.applying(bgTrack.preferredTransform)
    print("前景视频尺寸: \(abs(fgSize.width)) x \(abs(fgSize.height))")
    print("背景视频尺寸: \(abs(bgSize.width)) x \(abs(bgSize.height))")
    
    // 3. 创建输出配置
    let outputSize = CGSize(width: abs(bgSize.width), height: abs(bgSize.height))
    let videoSettings: [String: Any] = [
      AVVideoCodecKey: AVVideoCodecType.h264,
      AVVideoWidthKey: Int(outputSize.width),
      AVVideoHeightKey: Int(outputSize.height),
      AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: 5000000
      ]
    ]
    
    let outputURL = URL(fileURLWithPath: outputPath)
    
    // 删除已存在的文件
    if FileManager.default.fileExists(atPath: outputPath) {
      try? FileManager.default.removeItem(at: outputURL)
      print("删除已存在的输出文件")
    }
    
    let writer: AVAssetWriter
    do {
      writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
      print("✅ AVAssetWriter创建成功")
    } catch {
      print("❌ AVAssetWriter创建失败: \(error)")
      completion(false, nil)
      return
    }
    
    let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
    writerInput.expectsMediaDataInRealTime = false
    
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
      assetWriterInput: writerInput,
      sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
        kCVPixelBufferWidthKey as String: Int(outputSize.width),
        kCVPixelBufferHeightKey as String: Int(outputSize.height),
        kCVPixelBufferMetalCompatibilityKey as String: true
      ]
    )
    
    writer.add(writerInput)
    
    // 4. 创建AVAssetReader
    let foregroundReader: AVAssetReader
    let backgroundReader: AVAssetReader
    
    do {
      foregroundReader = try AVAssetReader(asset: foregroundAsset)
      backgroundReader = try AVAssetReader(asset: backgroundAsset)
      print("✅ AVAssetReader创建成功")
    } catch {
      print("❌ AVAssetReader创建失败: \(error)")
      completion(false, nil)
      return
    }
    
    let pixelFormatSettings = [
      kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
    ]
    
    let fgOutput = AVAssetReaderTrackOutput(track: fgTrack, outputSettings: pixelFormatSettings)
    let bgOutput = AVAssetReaderTrackOutput(track: bgTrack, outputSettings: pixelFormatSettings)
    
    fgOutput.alwaysCopiesSampleData = false
    bgOutput.alwaysCopiesSampleData = false
    
    foregroundReader.add(fgOutput)
    backgroundReader.add(bgOutput)
    
    // 5. 开始读取和写入
    guard writer.startWriting() else {
      print("❌ 无法开始写入: \(writer.error?.localizedDescription ?? "未知错误")")
      completion(false, nil)
      return
    }
    
    writer.startSession(atSourceTime: .zero)
    print("✅ 开始写入会话")
    
    // 启动读取器
    guard foregroundReader.startReading() && backgroundReader.startReading() else {
      print("❌ 无法开始读取视频")
      completion(false, nil)
      return
    }
    print("✅ 开始读取视频")
    
    var frameCount = 0
    let frameDuration = CMTime(value: 1, timescale: 30) // 30fps
    
    // 创建串行队列用于视频处理
    let videoProcessingQueue = DispatchQueue(label: "video.processing", qos: .userInitiated)
    
    // 6. 处理帧的函数
    func processNextFrame() {
      videoProcessingQueue.async {
        guard writerInput.isReadyForMoreMediaData else {
          // 如果writer还没准备好，等待一段时间后重试
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            processNextFrame()
          }
          return
        }
        
        // 检查reader状态
        guard foregroundReader.status == .reading && backgroundReader.status == .reading else {
          print("❌ Reader状态异常 - 前景: \(foregroundReader.status.rawValue), 背景: \(backgroundReader.status.rawValue)")
          if foregroundReader.status == .failed {
            print("❌ 前景reader错误: \(foregroundReader.error?.localizedDescription ?? "未知错误")")
          }
          if backgroundReader.status == .failed {
            print("❌ 背景reader错误: \(backgroundReader.error?.localizedDescription ?? "未知错误")")
          }
          DispatchQueue.main.async {
            completion(false, nil)
          }
          return
        }
        
        autoreleasepool {
          // 读取下一帧
          guard let foregroundSample = fgOutput.copyNextSampleBuffer(),
                let backgroundSample = bgOutput.copyNextSampleBuffer(),
                let foregroundPixelBuffer = CMSampleBufferGetImageBuffer(foregroundSample),
                let backgroundPixelBuffer = CMSampleBufferGetImageBuffer(backgroundSample) else {
            print("📱 完成读取所有帧，总计: \(frameCount)帧")
            writerInput.markAsFinished()
            
            writer.finishWriting {
              DispatchQueue.main.async {
                let success = writer.status == .completed
                if success {
                  print("✅ 视频合成完成！输出路径: \(outputURL.path)")
                } else {
                  print("❌ 视频合成失败: \(writer.error?.localizedDescription ?? "未知错误")")
                }
                completion(success, success ? outputURL.path : nil)
              }
            }
            return
          }
          
          if frameCount % 30 == 0 {
            print("处理第 \(frameCount) 帧")
          }
          
          do {
            // 创建MTIImage
            let foregroundImage = MTIImage(cvPixelBuffer: foregroundPixelBuffer, alphaType: .alphaIsOne)
            let backgroundImage = MTIImage(cvPixelBuffer: backgroundPixelBuffer, alphaType: .alphaIsOne)
            
            // 调整前景图像尺寸以匹配背景
            let resizedForeground: MTIImage
            if foregroundImage.size != backgroundImage.size {
              let scaleX = backgroundImage.size.width / foregroundImage.size.width
              let scaleY = backgroundImage.size.height / foregroundImage.size.height
              let scale = min(scaleX, scaleY)
              
              // 使用MTITransformFilter进行缩放
              let transformFilter = MTITransformFilter()
              transformFilter.transform = CATransform3DMakeScale(scale, scale, 1.0)
              transformFilter.inputImage = foregroundImage
              
              guard let scaledImage = transformFilter.outputImage else {
                print("❌ 图像缩放失败")
                return
              }
              resizedForeground = scaledImage
            } else {
              resizedForeground = foregroundImage
            }
            
            // 混合图像（直接设置前景透明度为0.2）
            let blendFilter = MTIBlendFilter(blendMode: .normal)
            blendFilter.inputBackgroundImage = backgroundImage
            blendFilter.inputImage = resizedForeground
            blendFilter.intensity = 0.2  // 设置前景透明度为0.2
            
            guard let outputImage = blendFilter.outputImage else {
              print("❌ 图像混合失败")
              return
            }
            
            // 创建输出PixelBuffer
            var outputPixelBuffer: CVPixelBuffer?
            let attrs = [
              kCVPixelBufferCGImageCompatibilityKey: true,
              kCVPixelBufferCGBitmapContextCompatibilityKey: true,
              kCVPixelBufferMetalCompatibilityKey: true,
              kCVPixelBufferWidthKey: Int(outputSize.width),
              kCVPixelBufferHeightKey: Int(outputSize.height),
              kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA
            ] as CFDictionary
            
            let status = CVPixelBufferCreate(
              kCFAllocatorDefault,
              Int(outputSize.width),
              Int(outputSize.height),
              kCVPixelFormatType_32BGRA,
              attrs,
              &outputPixelBuffer
            )
            
            guard status == kCVReturnSuccess, let pixelBuffer = outputPixelBuffer else {
              print("❌ PixelBuffer创建失败: \(status)")
              return
            }
            
            // 渲染到PixelBuffer
            try context.render(outputImage, to: pixelBuffer)
            
            // 写入视频
            let presentationTime = CMTime(value: Int64(frameCount), timescale: 30)
            let success = adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
            
            if !success {
              print("❌ 写入第 \(frameCount) 帧失败")
            }
            
            frameCount += 1
            
          } catch {
            print("❌ 处理第 \(frameCount) 帧时出错: \(error)")
          }
          
          // 处理下一帧
          DispatchQueue.main.async {
            processNextFrame()
          }
        }
      }
    }
    
    // 开始处理第一帧
    DispatchQueue.main.async {
      processNextFrame()
    }
  }
}