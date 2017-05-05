// Mohamed Saeed El-Naggar
// Instabug iOS Challenge 
// Date : 5 - 5 - 2017
// NaggarQ@gmail.com

import UIKit
import XCTest

class Bug {
    enum State {
        case open
        case closed
    }
    
    let state: State
    let timestamp: Date
    let comment: String
    
    init(state: State, timestamp: Date, comment: String) {
        // To be implemented
        // used to initialize our local variable
        /* -------- Initialization  -------- */
        self.state = state
        self.timestamp = timestamp
        self.comment = comment
    }
    init(jsonString: String) throws {
        // To be implemented
        
        /* -------- 
         
         Take state , timestamp , comment from jsonString
            and assign it to local Variable
         -> Convert jsonString from String to Dictionary as? [String : Any]
         
         -------- */
        
        // Convert from jsonString to dictonary as [String : AnyObject]
        
        let data = jsonString.data(using: .utf8)
        // Dictonary Contains Date as [String : Any]
        let dict = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        
        /* -------- Initialization  -------- */
        
        // intialize State
        let stateString = (dict?["state"] as? String)!

        switch stateString {
        case "open":
            self.state = .open
        default:
            self.state = .closed
        }
        
        // initialize timestamp
        let timeNumber = (dict?["timestamp"] as? TimeInterval)! // casting it as TimeInterval for Date
        let newDate = Date(timeIntervalSince1970: timeNumber)
        self.timestamp = newDate
        
        // initialize comment
        self.comment = (dict?["comment"] as? String)!
    }
}

enum TimeRange {
    case pastDay
    case pastWeek
    case pastMonth
}

class Application {
    var bugs: [Bug]
    
    init(bugs: [Bug]) {
        self.bugs = bugs
    }

    
    func findBugs(state: Bug.State?, timeRange: TimeRange) -> [Bug] {
        // To be implemented
        /* -------- find all Bugs Array according to parameters(state , timeRange) -------- */
        
        var matchedBugs = [Bug]() // array of Bugs
    
        let estimatedDateBegin: Date // Calculated blew
        let estimatedDateEnd: Date = Date() // now
    
        // no default status because i Covered all cases of timeRange
        switch timeRange {
        case .pastDay : estimatedDateBegin = Date().addingTimeInterval(-1 * (24 * 60 * 60))
        case .pastWeek : estimatedDateBegin = Date().addingTimeInterval(-1 * (7 * 24 * 60 * 60))
        case .pastMonth : estimatedDateBegin = Date().addingTimeInterval(-1 * (30 * 24 * 60 * 60))
        }
        
        
        // iterate over all bugs in Application
        for bug in bugs {
            let bugState = bug.state
            let bugDate = bug.timestamp
            
            if bugState == state && (bugDate >= estimatedDateBegin && bugDate <= estimatedDateEnd) {
                // matched these two conditions
                matchedBugs.append(bug)
            }
        }

        return matchedBugs
    }
}

class UnitTests : XCTestCase {
    lazy var bugs: [Bug] = {
        var date26HoursAgo = Date()
        date26HoursAgo.addTimeInterval(-1 * (26 * 60 * 60))
        
        var date2WeeksAgo = Date()
        date2WeeksAgo.addTimeInterval(-1 * (14 * 24 * 60 * 60))
        
        let bug1 = Bug(state: .open, timestamp: Date(), comment: "Bug 1")
        let bug2 = Bug(state: .open, timestamp: date26HoursAgo, comment: "Bug 2")
        let bug3 = Bug(state: .closed, timestamp: date2WeeksAgo, comment: "Bug 3") // change bug Comment
        
        
        /* -------- Some Bugs Created By ME -------- */
        
        // Bugs in pastDay
        let bug4 = Bug(state: .open , timestamp: Date().addingTimeInterval(-1 * (24 * 60 * 60)), comment: "Bug 4")
    
        // Bugs in pastWeek
        let bug5 = Bug(state: .closed, timestamp: Date().addingTimeInterval(-1 * (7 * 24 * 60 * 60)), comment: "Bug 5")
        
        // Bugs in pastMonth
        let bug6 = Bug(state: .closed , timestamp: Date().addingTimeInterval(-1 * (28 * 24 * 60 * 60)), comment: "Bug 6")
        
        let bug7 = Bug(state: .open , timestamp: Date().addingTimeInterval(-1 * (28 * 24 * 60 * 60)), comment: "Bug 7")
        
        return [bug1, bug2, bug3 , bug4 , bug5 , bug6 , bug7]
    }()
    
    lazy var application: Application = {
        let application = Application(bugs: self.bugs)
        return application
    }()

    func testFindOpenBugsInThePastDay() {
        let bugs = application.findBugs(state: .open, timeRange: .pastDay)
        XCTAssertTrue(bugs.count == 1, "Invalid number of bugs")
        XCTAssertEqual(bugs[0].comment, "Bug 1", "Invalid bug order")
    }
    
    func testFindClosedBugsInThePastMonth() {
        let bugs = application.findBugs(state: .closed, timeRange: .pastMonth)
        
        /* I just added 3 bugs in the PastMonth so change bugs.count to 3 */
        XCTAssertTrue(bugs.count == 3, "Invalid number of bugs")
    }
    
    func testFindClosedBugsInThePastWeek() {
        let bugs = application.findBugs(state: .closed, timeRange: .pastWeek)
 
        XCTAssertTrue(bugs.count == 0, "Invalid number of bugs")
    }
    
    func testInitializeBugWithJSON() {
        do {
            let json = "{\"state\": \"open\",\"timestamp\": 1493393946,\"comment\": \"Bug via JSON\"}"

            let bug = try Bug(jsonString: json)
            
            XCTAssertEqual(bug.comment, "Bug via JSON")
            XCTAssertEqual(bug.state, .open)
            XCTAssertEqual(bug.timestamp, Date(timeIntervalSince1970: 1493393946))
        } catch {
            print(error)
        }
    }
}

class PlaygroundTestObserver : NSObject, XCTestObservation {
    
    @objc func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(String(describing: testCase.name)), \(description)")
    }
    
}

let observer = PlaygroundTestObserver()
let center = XCTestObservationCenter.shared()
center.addTestObserver(observer)

TestRunner().runTests(testClass: UnitTests.self)
