//
//  TimerViewModel.swift
//  Rhythm
//
//  Created by Omar Alkilani on 2/5/2025.
//

import XCTest
@testable import Rhythm

class TimerViewModelTests: XCTestCase {
    var vm: TimerViewModel!

    override func setUp() {
        super.setUp()
        vm = TimerViewModel()
    }

    func testStartPomodoroSetsRemaining() {
        vm.startPomodoro()
        XCTAssertEqual(vm.remainingTime, AppDurations.pomodoro)
        XCTAssertTrue(vm.isRunning)
    }

    func testPauseStopsTimer() {
        vm.startPomodoro()
        vm.pause()
        XCTAssertFalse(vm.isRunning)
    }

    func testResetClearsTimer() {
        vm.startPomodoro()
        vm.reset()
        XCTAssertEqual(vm.remainingTime, 0)
        XCTAssertFalse(vm.isRunning)
    }
}



