import UIKit
import Flutter
import AVFoundation
import MetalPetal
import MetalKit

/// 视频剪辑导航处理器 - 处理Flutter到原生页面的跳转逻辑
public class VideoClipNavigationHandler {
    
    /// 处理导航到视频剪辑页面的请求
    /// - Parameters:
    ///   - call: Flutter方法调用对象
    ///   - result: 回调结果
    public static func handleNavigateToVideoClip(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // 获取传递的参数
        guard let args = call.arguments as? [String: Any],
              let arrPath = args["arrPath"] as? [String] else {
            result(FlutterError(code: "BAD_ARGS", message: "参数错误", details: nil))
            return
        }

        print("arrPath: \(arrPath)")
        print("navigateToVideoClip called with paths: \(arrPath)")

        // 调用拼接视频方法，传递回调
        self.splicingVideos(arrPath: arrPath, completion: { outputPath, error in
            if let error = error {
                result(FlutterError(code: "VIDEO_SPLICE_ERROR", message: error.localizedDescription, details: nil))
            } else if let outputPath = outputPath {
                result(["success": true, "outputPath": outputPath])
            } else {
                result(FlutterError(code: "UNKNOWN_ERROR", message: "未知错误", details: nil))
            }
        })
    }

    /// 使用分批处理实现视频拼接的方法
    /// - Parameters:
    ///   - arrPath: 视频文件路径数组
    ///   - completion: 完成回调，返回输出路径或错误
    static func splicingVideos(arrPath: [String], completion: @escaping (String?, Error?) -> Void) {
        guard !arrPath.isEmpty else {
            completion(nil, NSError(domain: "VideoSplicingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "视频路径数组为空"]))
            return
        }
        
        // 分批处理，每批最多5个视频
        let batchSize = 5
        let batches = stride(from: 0, to: arrPath.count, by: batchSize).map {
            Array(arrPath[$0..<min($0 + batchSize, arrPath.count)])
        }
        
        print("总共 \(arrPath.count) 个视频，分为 \(batches.count) 批处理")
        
        // 在后台线程执行分批拼接
        DispatchQueue.global(qos: .userInitiated).async {
            self.processBatches(batches: batches, completion: completion)
        }
    }
    
    /// 分批处理视频
    private static func processBatches(batches: [[String]], completion: @escaping (String?, Error?) -> Void) {
        var batchResults: [String] = []
        let dispatchGroup = DispatchGroup()
        var hasError: Error?
        
        // 创建临时目录
        let tempDir = NSTemporaryDirectory() + "video_batches/"
        if !FileManager.default.fileExists(atPath: tempDir) {
            try? FileManager.default.createDirectory(atPath: tempDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        // 处理每一批
        for (batchIndex, batch) in batches.enumerated() {
            if hasError != nil { break }
            
            dispatchGroup.enter()
            
            autoreleasepool {
                self.spliceBatch(batch: batch, batchIndex: batchIndex, tempDir: tempDir) { result, error in
                    if let error = error {
                        hasError = error
                    } else if let result = result {
                        batchResults.append(result)
                    }
                    dispatchGroup.leave()
                }
            }
            
            // 添加延迟避免系统过载
            Thread.sleep(forTimeInterval: 0.5)
        }
        
        dispatchGroup.wait()
        
        if let error = hasError {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        // 合并所有批次结果
        self.mergeBatchResults(batchResults: batchResults, tempDir: tempDir, completion: completion)
    }
    
    /// 拼接单个批次的视频
    private static func spliceBatch(batch: [String], batchIndex: Int, tempDir: String, completion: @escaping (String?, Error?) -> Void) {
        autoreleasepool {
            do {
                let composition = AVMutableComposition()
                
                guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                      let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                    completion(nil, NSError(domain: "VideoSplicingError", code: -2, userInfo: [NSLocalizedDescriptionKey: "批次 \(batchIndex) 无法创建轨道"]))
                    return
                }
                
                var currentTime = CMTime.zero
                
                for (index, path) in batch.enumerated() {
                    autoreleasepool {
                        let url = URL(fileURLWithPath: path)
                        let asset = AVAsset(url: url)
                        
                        guard let assetVideoTrack = asset.tracks(withMediaType: .video).first else {
                            print("警告：批次 \(batchIndex) 视频 \(index) 没有视频轨道，跳过")
                            return
                        }
                        
                        let assetAudioTrack = asset.tracks(withMediaType: .audio).first
                        let duration = asset.duration
                        let timeRange = CMTimeRange(start: CMTime.zero, duration: duration)
                        
                        do {
                            try videoTrack.insertTimeRange(timeRange, of: assetVideoTrack, at: currentTime)
                            if let assetAudioTrack = assetAudioTrack {
                                try audioTrack.insertTimeRange(timeRange, of: assetAudioTrack, at: currentTime)
                            }
                            currentTime = CMTimeAdd(currentTime, duration)
                            print("批次 \(batchIndex) 成功添加视频片段 \(index + 1)")
                        } catch {
                            completion(nil, error)
                            return
                        }
                    }
                }
                
                // 导出批次结果
                let outputPath = "\(tempDir)batch_\(batchIndex).mp4"
                let outputURL = URL(fileURLWithPath: outputPath)
                
                if FileManager.default.fileExists(atPath: outputPath) {
                    try? FileManager.default.removeItem(at: outputURL)
                }
                
                guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetLowQuality) else {
                    completion(nil, NSError(domain: "VideoSplicingError", code: -3, userInfo: [NSLocalizedDescriptionKey: "批次 \(batchIndex) 无法创建导出会话"]))
                    return
                }
                
                exportSession.outputURL = outputURL
                exportSession.outputFileType = .mp4
                exportSession.shouldOptimizeForNetworkUse = true
                
                exportSession.exportAsynchronously {
                    switch exportSession.status {
                    case .completed:
                        print("批次 \(batchIndex) 导出成功: \(outputPath)")
                        completion(outputPath, nil)
                    case .failed:
                        let errorMessage = exportSession.error?.localizedDescription ?? "批次 \(batchIndex) 导出失败"
                        print("批次 \(batchIndex) 导出失败: \(errorMessage)")
                        completion(nil, NSError(domain: "VideoSplicingError", code: -4, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                    default:
                        completion(nil, NSError(domain: "VideoSplicingError", code: -5, userInfo: [NSLocalizedDescriptionKey: "批次 \(batchIndex) 未知状态"]))
                    }
                }
                
            } catch {
                completion(nil, error)
            }
        }
    }
    
    /// 合并所有批次的结果
    private static func mergeBatchResults(batchResults: [String], tempDir: String, completion: @escaping (String?, Error?) -> Void) {
        guard !batchResults.isEmpty else {
            DispatchQueue.main.async {
                completion(nil, NSError(domain: "VideoSplicingError", code: -6, userInfo: [NSLocalizedDescriptionKey: "没有可合并的批次结果"]))
            }
            return
        }
        
        if batchResults.count == 1 {
            // 只有一个批次，直接移动到最终位置
            let finalOutputPath = self.getFinalOutputPath()
            do {
                try FileManager.default.moveItem(atPath: batchResults[0], toPath: finalOutputPath)
                self.cleanupTempDir(tempDir: tempDir)
                DispatchQueue.main.async {
                    completion(finalOutputPath, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            return
        }
        
        // 合并多个批次
        autoreleasepool {
            do {
                let composition = AVMutableComposition()
                
                guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                      let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                    DispatchQueue.main.async {
                        completion(nil, NSError(domain: "VideoSplicingError", code: -7, userInfo: [NSLocalizedDescriptionKey: "合并阶段无法创建轨道"]))
                    }
                    return
                }
                
                var currentTime = CMTime.zero
                
                for (index, batchPath) in batchResults.enumerated() {
                    autoreleasepool {
                        let url = URL(fileURLWithPath: batchPath)
                        let asset = AVAsset(url: url)
                        
                        guard let assetVideoTrack = asset.tracks(withMediaType: .video).first else {
                            print("警告：批次结果 \(index) 没有视频轨道")
                            return
                        }
                        
                        let assetAudioTrack = asset.tracks(withMediaType: .audio).first
                        let duration = asset.duration
                        let timeRange = CMTimeRange(start: CMTime.zero, duration: duration)
                        
                        do {
                            try videoTrack.insertTimeRange(timeRange, of: assetVideoTrack, at: currentTime)
                            if let assetAudioTrack = assetAudioTrack {
                                try audioTrack.insertTimeRange(timeRange, of: assetAudioTrack, at: currentTime)
                            }
                            currentTime = CMTimeAdd(currentTime, duration)
                            print("合并批次结果 \(index + 1)")
                        } catch {
                            DispatchQueue.main.async {
                                completion(nil, error)
                            }
                            return
                        }
                    }
                }
                
                // 导出最终结果
                let finalOutputPath = self.getFinalOutputPath()
                let outputURL = URL(fileURLWithPath: finalOutputPath)
                
                if FileManager.default.fileExists(atPath: finalOutputPath) {
                    try? FileManager.default.removeItem(at: outputURL)
                }
                
                guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality) else {
                    DispatchQueue.main.async {
                        completion(nil, NSError(domain: "VideoSplicingError", code: -8, userInfo: [NSLocalizedDescriptionKey: "最终合并无法创建导出会话"]))
                    }
                    return
                }
                
                exportSession.outputURL = outputURL
                exportSession.outputFileType = .mp4
                exportSession.shouldOptimizeForNetworkUse = true
                
                exportSession.exportAsynchronously {
                    switch exportSession.status {
                    case .completed:
                        print("最终视频拼接成功: \(finalOutputPath)")
                        self.cleanupTempDir(tempDir: tempDir)
                        DispatchQueue.main.async {
                            completion(finalOutputPath, nil)
                        }
                    case .failed:
                        let errorMessage = exportSession.error?.localizedDescription ?? "最终合并导出失败"
                        print("最终合并失败: \(errorMessage)")
                        self.cleanupTempDir(tempDir: tempDir)
                        DispatchQueue.main.async {
                            completion(nil, NSError(domain: "VideoSplicingError", code: -9, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                        }
                    default:
                        self.cleanupTempDir(tempDir: tempDir)
                        DispatchQueue.main.async {
                            completion(nil, NSError(domain: "VideoSplicingError", code: -10, userInfo: [NSLocalizedDescriptionKey: "最终合并未知状态"]))
                        }
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    /// 获取最终输出路径
    private static func getFinalOutputPath() -> String {
        let outputFileName = "spliced_video_\(Int(Date().timeIntervalSince1970)).mp4"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return "\(documentsPath)/\(outputFileName)"
    }
    
    /// 清理临时目录
    private static func cleanupTempDir(tempDir: String) {
        try? FileManager.default.removeItem(atPath: tempDir)
    }
} 