//
//  Log.swift
//  Common
//
//  Created by 马陈爽 on 2022/5/14.
//

import Foundation

import CocoaLumberjack

public class CommonLog {
    
    init() {
        DDLog.add(DDOSLogger.sharedInstance)
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.maximumFileSize = 1024 * 1024 * 2
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
    
    public func info(_ tag: String, _ message: String) {
        DDLogInfo("[Log][Info][\(tag)] \(message)", level: .info)
    }
    
    public func debug(_ tag: String, _ message: String) {
        DDLogDebug("[Log][Debug][\(tag)] \(message)", level: .debug)
    }
    
    public func error(_ tag: String, _ message: String) {
        DDLogError("[Log][Error][\(tag)] \(message)", level: .error)
    }
    
    public func warning(_ tag: String, _ message: String) {
        DDLogWarn("[Log][Warning][\(tag)] \(message)", level: .warning)
    }
}

public let log: CommonLog = CommonLog()

public extension CommonLog {
    var documentsDirectory: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }

    func getLogFilePath() -> String? {
        let fileLogger: DDFileLogger = DDFileLogger()
        let logs = fileLogger.logFileManager.sortedLogFilePaths
        return logs.first
    }

    func getLogFileContent() -> String? {
        let fileLogger: DDFileLogger = DDFileLogger()
        let logs = fileLogger.logFileManager.sortedLogFilePaths
        guard let path = logs.first, let url = URL(string: path) else {
            return nil
        }
        var content: String?
        do {
            let data = try Data(contentsOf: url)
            content = String(data: data, encoding: .utf8)
        } catch  {
            log.error("XCGLogger", "\(error.localizedDescription)")
        }
        return content
    }
}
