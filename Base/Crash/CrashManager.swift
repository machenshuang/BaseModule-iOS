//
//  CrashManager.swift
//  Common
//
//  Created by 马陈爽 on 2022/7/29.
//

import Foundation
import Bugly

class CrashManager: NSObject {
    static let shared = CrashManager()
    
    override init() {
        super.init()
        commonInit()
    }
    
    private func commonInit() {
        let config = BuglyConfig()
        config.reportLogLevel = .warn
        config.blockMonitorEnable = false
        config.debugMode = false
        config.unexpectedTerminatingDetectionEnable = true
        config.delegate = self
        if let versionStr = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
            #if DISTRIBUTE
            config.version = versionStr
            config.channel = "POOK"
            #else
            config.version = versionStr.appending("_dev")
            config.channel = "POOK_DEV"
            #endif
        }
        Bugly.start(withAppId: "730bbf3017", config: config)
        Bugly.setTag(200)
        let identify = String(format: "用户:%@", UIDevice.current.name)
        Bugly.setUserIdentifier(identify)
    }
    
    func upload(exception: NSException) {
        Bugly.report(exception)
    }
}

extension CrashManager: BuglyDelegate {
    func attachment(for exception: NSException?) -> String? {
        guard let content = log.getLogFileContent() else {
            return nil
        }
        return String(format: "LogInfo: %@", content)
    }
}
