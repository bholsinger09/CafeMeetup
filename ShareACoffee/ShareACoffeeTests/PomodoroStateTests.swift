import XCTest
@testable import ShareACoffee

/// Tests for Pomodoro timer state management
@MainActor
final class PomodoroStateTests: XCTestCase {
    
    // MARK: - PomodoroPhase Tests
    
    func testPomodoroPhaseRawValues() {
        // Test that all phases have correct raw values
        let phases: [(PomodoroPhase, String)] = [
            (.work, "Work"),
            (.shortBreak, "Short Break"),
            (.longBreak, "Long Break")
        ]
        
        for (phase, expected) in phases {
            XCTAssertEqual(phase.rawValue, expected)
        }
    }
    
    func testPomodoroPhaseColors() {
        // Each phase should have a distinct color
        XCTAssertNotEqual(PomodoroPhase.work.color, PomodoroPhase.shortBreak.color)
        XCTAssertNotEqual(PomodoroPhase.shortBreak.color, PomodoroPhase.longBreak.color)
    }
    
    func testPomodoroPhase Durations() {
        // Durations should be in seconds and properly ordered
        XCTAssertGreaterThan(PomodoroPhase.work.duration, 0)
        XCTAssertGreaterThan(PomodoroPhase.shortBreak.duration, 0)
        XCTAssertGreaterThan(PomodoroPhase.longBreak.duration, PomodoroPhase.shortBreak.duration)
    }
    
    // MARK: - PomodoroState Initialization Tests
    
    func testPomodoroStateDefaultInitialization() {
        // Given: A new PomodoroState
        let state = PomodoroState()
        
        // Then: Should have default values
        XCTAssertEqual(state.currentPhase, .work)
        XCTAssertEqual(state.completedPomodoros, 0)
        XCTAssertFalse(state.isRunning)
        XCTAssertNil(state.startedAt)
        XCTAssertNil(state.pausedAt)
        XCTAssertGreaterThan(state.secondsRemaining, 0)
    }
    
    func testPomodoroStateFromDecoderInitialization() {
        // Given: A JSON representation of PomodoroState
        let json = """
        {
            "currentPhase": "Work",
            "completedPomodoros": 2,
            "isRunning": true,
            "secondsRemaining": 1200,
            "startedAt": 729652800.0,
            "pausedAt": null
        }
        """
        
        guard let data = json.data(using: .utf8) else {
            XCTFail("Failed to encode JSON")
            return
        }
        
        // When: Decoding from JSON
        let decoder = JSONDecoder()
        do {
            let state = try decoder.decode(PomodoroState.self, from: data)
            
            // Then: Should correctly decode
            XCTAssertEqual(state.completedPomodoros, 2)
            XCTAssertTrue(state.isRunning)
            XCTAssertEqual(state.secondsRemaining, 1200)
        } catch {
            XCTFail("Failed to decode: \(error)")
        }
    }
    
    // MARK: - PomodoroState State Transition Tests
    
    func testPomodoroStateStartsAtWorkPhase() {
        // Given: A new state
        let state = PomodoroState()
        
        // Then: Should start at work phase
        XCTAssertEqual(state.currentPhase, .work)
    }
    
    func testPomodoroStateCodable() {
        // Given: An initial state
        let initial = PomodoroState()
        
        // When: Encoding and decoding
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(initial) else {
            XCTFail("Failed to encode")
            return
        }
        
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(PomodoroState.self, from: data) else {
            XCTFail("Failed to decode")
            return
        }
        
        // Then: Should match
        XCTAssertEqual(initial.currentPhase, decoded.currentPhase)
        XCTAssertEqual(initial.completedPomodoros, decoded.completedPomodoros)
        XCTAssertEqual(initial.isRunning, decoded.isRunning)
    }
}
