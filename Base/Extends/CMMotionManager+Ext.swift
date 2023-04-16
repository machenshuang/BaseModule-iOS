//
//  CMMotionManager+Ext.swift
//  Common
//
//  Created by 马陈爽 on 2021/11/21.
//

import Foundation
import CoreMotion

public enum DeviceOrientation {
    case portrait
    case left
    case right
    case down
}

public extension CMMotionManager {
    func motionStart(update:((_ orientation: DeviceOrientation) -> Void)?) {
        if !self.isAccelerometerAvailable {
            return
        }
        self.accelerometerUpdateInterval = 0.3
        self.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) in
            if let error = error {
                log.error("CMMotionManager", error.localizedDescription)
                return
            }
            guard let acceleration = accelerometerData?.acceleration else { return }
            guard let completion = update else { return }
            var orientation: DeviceOrientation = .portrait
            if acceleration.y <= -0.75 {
                orientation = .portrait
            } else if acceleration.y >= 0.75 {
                orientation = .down
            } else if acceleration.x <= -0.75 {
                orientation = .left
            } else if acceleration.x >= 0.75 {
                orientation = .right
            } else {
                orientation = .portrait
            }
            completion(orientation)
        }
    }
    
    func motionStop() {
        if self.isAccelerometerAvailable && self.isAccelerometerActive {
            self.stopAccelerometerUpdates()
        }
    }
}
