import UIKit
import Flutter
import AVFoundation
import MetalPetal
import MetalKit

/// 视频剪辑导航处理器 - 处理Flutter到原生页面的跳转逻辑
public class navigateDuplicateRemovalpHandler {

    public static func Removalp(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: String],
              let bgPath = args["bgPath"],
              let fgPath = args["fgPath"],
              let outputPath = args["outputPath"] else {
                  result(FlutterError(code: "BAD_ARGS", message: "参数错误", details: nil))
          return
        }
        self.pipVideoMetalPetal(bgPath: bgPath, fgPath: fgPath, outputPath: outputPath) { success, finalPath in
          if success, let finalPath = finalPath {
            result(finalPath)
          } else {
            result(FlutterError(code: "PIP_FAILED", message: "合成失败", details: nil))
          }
        }
    }
    
    // 创建进度条图像的方法 - 高效CPU绘制版本
    static func createProgressBarImage(progress: Float, size: CGSize) -> MTIImage? {
        // 验证输入尺寸
        guard size.width > 0 && size.height > 0 else {
            print("❌ 无效的画布尺寸: \(size)")
            return nil
        }
        
        // 进度条配置
        let progressBarHeight: CGFloat = 8.0
        let progressBarMargin: CGFloat = 40.0
        let progressBarY: CGFloat = 30.0  // 尝试使用小值让进度条在底部
        let backgroundWidth = size.width - 2 * progressBarMargin
        
        print("📏 进度条配置: Y位置=\(progressBarY), 视频高度=\(size.height), 进度条高度=\(progressBarHeight)")
        
        // 使用最高效的CPU绘制
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: Int(size.width) * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            print("❌ 无法创建绘制上下文")
            return nil
        }
        
        // 清除背景为透明
        context.clear(CGRect(origin: .zero, size: size))
        
        // 绘制进度条背景
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        let backgroundRect = CGRect(
            x: progressBarMargin,
            y: progressBarY,
            width: backgroundWidth,
            height: progressBarHeight
        )
        context.fill(backgroundRect)
        
        // 绘制进度条前景
        if progress > 0 {
            let progressWidth = max(2.0, backgroundWidth * CGFloat(progress))
            context.setFillColor(red: 1, green: 1, blue: 1, alpha: 0.9)
            let progressRect = CGRect(
                x: progressBarMargin,
                y: progressBarY,
                width: progressWidth,
                height: progressBarHeight
            )
            context.fill(progressRect)
        }
        
        // 创建CGImage
        guard let cgImage = context.makeImage() else {
            print("❌ 无法创建CGImage")
            return nil
        }
        
        // 转换为MTIImage
        let mtiImage = MTIImage(__cgImage: cgImage, options: [.SRGB: false], isOpaque: false)
        return mtiImage
    }
    
    static func pipVideoMetalPetal(bgPath: String, fgPath: String, outputPath: String, completion: @escaping (Bool, String?) -> Void) {
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

        // 计算总帧数用于进度条
        let videoDuration = min(foregroundAsset.duration.seconds, backgroundAsset.duration.seconds)
        let frameRate: Double = 30.0
        let totalFrames = Int(videoDuration * frameRate)
        print("预计总帧数: \(totalFrames)")

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

                let cropFilter = MTICropFilter()
                cropFilter.inputImage = blendFilter.outputImage
                // 计算10%边缘的像素值
                let margin = 0.1
                let cropX = outputSize.width * margin
                let cropY = outputSize.height * margin
                let cropWidth = outputSize.width * (1.0 - 2 * margin)
                let cropHeight = outputSize.height * (1.0 - 2 * margin)
                cropFilter.cropRegion = MTICropRegion(bounds: CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight), unit: .pixel) // 裁剪掉10%的边缘

                guard let croppedImage = cropFilter.outputImage else {
                  print("❌ 图像裁剪失败")
                  return
                }

                // 添加进度条
                let currentProgress = totalFrames > 0 ? Float(frameCount) / Float(totalFrames) : 0.0
                guard let progressBarImage = createProgressBarImage(progress: currentProgress, size: croppedImage.size) else {
                  print("❌ 创建进度条失败")
                  return
                }

                // 将进度条合成到图像上
                let progressBlendFilter = MTIBlendFilter(blendMode: .normal)
                progressBlendFilter.inputBackgroundImage = croppedImage
                progressBlendFilter.inputImage = progressBarImage
                progressBlendFilter.intensity = 1.0

                guard let outputImage = progressBlendFilter.outputImage else {
                  print("❌ 进度条合成失败")
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