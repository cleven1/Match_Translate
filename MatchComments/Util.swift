//
//  MatchChineseComments.swift
//  MatchComments
//
//  Created by zhaoyongqiang on 2024/1/16.
//

import Foundation

struct Util {
    static var task: Process?
    
    /// 执行脚本命令
    ///
    /// - Parameters:
    ///   - command: 命令行内容
    ///   - needAuthorize: 执行脚本时,是否需要 sudo 授权
    /// - Returns: 执行结果
    static func runCommand(_ command: String,
                           filePath: String,
                           filterFile: String,
                           filterText: String,
                           from: String,
                           to: String) async throws -> (isSuccess: Bool, executeResult: String?) {
        stop()
        task?.launchPath = "/usr/bin/python3" // Python解释器的路径
        task?.arguments = [command, filePath, filterFile, filterText, from, to]
        let pipe = Pipe()
        task?.standardOutput = pipe
        task?.launch()
        task?.waitUntilExit()
        
        return try await withUnsafeThrowingContinuation { continuation in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines)
            continuation.resume(returning: (task?.terminationStatus == 0, output ?? ""))
        }
    }
    
    static func stop() {
        if let _ = task?.isRunning {
            task?.terminate()
        }
        task = Process()
    }
}

