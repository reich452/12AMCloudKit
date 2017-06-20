//
//  TimerExtension.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation

// https://github.com/radex/SwiftyTimer/blob/master/Sources/SwiftyTimer.swift
extension Timer {
    
    // MARK: Schedule timers
    
    /// Create and schedule a timer that will call `block` once after the specified time.
    
    @discardableResult
    class func after(_ interval: TimeInterval, _ block: @escaping () -> Void) -> Timer {
        let timer = Timer.new(after: interval, block)
        timer.start()
        return timer
    }
    
    /// Create and schedule a timer that will call `block` repeatedly in specified time intervals.
    
    @discardableResult
    class func every(_ interval: TimeInterval, _ block: @escaping () -> Void) -> Timer {
        let timer = Timer.new(every: interval, block)
        timer.start()
        return timer
    }
    
    // MARK: Create timers without scheduling
    
    /// Create a timer that will call `block` once after the specified time.
    ///
    /// - Note: The timer won't fire until it's scheduled on the run loop.
    ///         Use `NSTimer.after` to create and schedule a timer in one step.
    /// - Note: The `new` class function is a workaround for a crashing bug when using convenience initializers (rdar://18720947)
    class func new(after interval: TimeInterval, _ block: @escaping () -> Void) -> Timer {
        return CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + interval, 0, 0, 0) { _ in
            block()
        }
    }
    
    /// Create a timer that will call `block` repeatedly in specified time intervals.
    ///
    /// - Note: The timer won't fire until it's scheduled on the run loop.
    ///         Use `NSTimer.every` to create and schedule a timer in one step.
    /// - Note: The `new` class function is a workaround for a crashing bug when using convenience initializers (rdar://18720947)
    class func new(every interval: TimeInterval, _ block: @escaping () -> Void) -> Timer {
        return CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + interval, interval, 0, 0) { _ in
            block()
        }
    }
    
    // MARK: Manual scheduling
    
    /// Schedule this timer on the run loop
    ///
    /// By default, the timer is scheduled on the current run loop for the default mode.
    /// Specify `runLoop` or `modes` to override these defaults.
    
    func start(runLoop: RunLoop = .current, modes: RunLoopMode...) {
        let modes = modes.isEmpty ? [.defaultRunLoopMode] : modes
        
        for mode in modes {
            runLoop.add(self, forMode: mode)
        }
    }
    
}

// MARK: - Time extensions
extension Double {
    var millisecond: TimeInterval  {
        return self / 1000
    }
    var milliseconds: TimeInterval {
        return self / 1000
    }
    var ms: TimeInterval           {
        return self / 1000
    }
    
    var second: TimeInterval       {
        return self
    }
    var seconds: TimeInterval      {
        return self
    }
    
    var minute: TimeInterval       {
        return self * 60
    }
    var minutes: TimeInterval      {
        return self * 60
    }
    
    var hour: TimeInterval         {
        return self * 3600
    }
    var hours: TimeInterval        {
        return self * 3600
    }
    
    var day: TimeInterval          {
        return self * 3600 * 24
    }
    var days: TimeInterval         {
        return self * 3600 * 24
    }
}
