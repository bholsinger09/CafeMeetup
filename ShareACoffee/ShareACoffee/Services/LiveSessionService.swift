import Foundation
import Firebase
import FirebaseDatabase

/// Service for managing real-time collaborative features during live study sessions
class LiveSessionService {
    private let database = Database.database().reference()
    private var listeners: [String: DatabaseHandle] = [:]
    
    // MARK: - Live Session Management
    
    /// Start a live session for a study session
    func startLiveSession(studySessionId: String, userId: String, completion: @escaping (Bool) -> Void) {
        let liveSession = LiveSession(studySessionId: studySessionId)
        let sessionRef = database.child("liveSessions").child(studySessionId)
        
        do {
            let data = try JSONEncoder().encode(liveSession)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            
            sessionRef.setValue(dict) { error, _ in
                if let error = error {
                    print("Error starting live session: \(error.localizedDescription)")
                    completion(false)
                } else {
                    // Add user as active participant
                    self.joinLiveSession(studySessionId: studySessionId, userId: userId, userName: "")
                    completion(true)
                }
            }
        } catch {
            print("Error encoding live session: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    /// Join an active live session
    func joinLiveSession(studySessionId: String, userId: String, userName: String) {
        let participantRef = database.child("liveSessions").child(studySessionId).child("activeParticipants").child(userId)
        
        participantRef.setValue([
            "name": userName,
            "joinedAt": ServerValue.timestamp()
        ])
        
        // Set up presence - auto-remove when disconnected
        participantRef.onDisconnectRemoveValue()
    }
    
    /// Leave a live session
    func leaveLiveSession(studySessionId: String, userId: String) {
        let participantRef = database.child("liveSessions").child(studySessionId).child("activeParticipants").child(userId)
        participantRef.removeValue()
    }
    
    /// Observe active participants
    func observeActiveParticipants(sessionId: String, completion: @escaping ([String]) -> Void) {
        let participantsRef = database.child("liveSessions").child(sessionId).child("activeParticipants")
        
        let handle = participantsRef.observe(.value) { snapshot in
            var participants: [String] = []
            
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let name = dict["name"] as? String {
                    participants.append(name)
                }
            }
            
            completion(participants)
        }
        
        listeners["participants_\(sessionId)"] = handle
    }
    
    // MARK: - Whiteboard Management
    
    /// Add a stroke to the whiteboard
    func addWhiteboardStroke(sessionId: String, stroke: WhiteboardStroke, completion: @escaping (Bool) -> Void) {
        let strokeRef = database.child("liveSessions").child(sessionId).child("whiteboard").child("strokes").childByAutoId()
        
        do {
            let data = try JSONEncoder().encode(stroke)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            
            strokeRef.setValue(dict) { error, _ in
                completion(error == nil)
            }
        } catch {
            print("Error encoding stroke: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    /// Clear the whiteboard
    func clearWhiteboard(sessionId: String, completion: @escaping (Bool) -> Void) {
        let whiteboardRef = database.child("liveSessions").child(sessionId).child("whiteboard").child("strokes")
        
        whiteboardRef.removeValue { error, _ in
            completion(error == nil)
        }
    }
    
    /// Observe whiteboard state
    func observeWhiteboardState(sessionId: String, completion: @escaping (WhiteboardState) -> Void) {
        let whiteboardRef = database.child("liveSessions").child(sessionId).child("whiteboard")
        
        let handle = whiteboardRef.observe(.value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else {
                completion(WhiteboardState())
                return
            }
            
            var strokes: [WhiteboardStroke] = []
            
            if let strokesDict = dict["strokes"] as? [String: [String: Any]] {
                for (_, strokeData) in strokesDict {
                    if let data = try? JSONSerialization.data(withJSONObject: strokeData),
                       let stroke = try? JSONDecoder().decode(WhiteboardStroke.self, from: data) {
                        strokes.append(stroke)
                    }
                }
            }
            
            let state = WhiteboardState(
                strokes: strokes.sorted(by: { $0.createdAt < $1.createdAt }),
                backgroundColor: dict["backgroundColor"] as? String ?? "#FFFFFF",
                lastUpdatedBy: dict["lastUpdatedBy"] as? String,
                lastUpdatedAt: Date()
            )
            
            completion(state)
        }
        
        listeners["whiteboard_\(sessionId)"] = handle
    }
    
    // MARK: - Pomodoro Timer Management
    
    /// Update Pomodoro timer state
    func updatePomodoroState(sessionId: String, state: PomodoroState, completion: @escaping (Bool) -> Void) {
        let pomodoroRef = database.child("liveSessions").child(sessionId).child("pomodoro")
        
        do {
            let data = try JSONEncoder().encode(state)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            
            pomodoroRef.setValue(dict) { error, _ in
                completion(error == nil)
            }
        } catch {
            print("Error encoding pomodoro state: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    /// Observe Pomodoro timer state
    func observePomodoroState(sessionId: String, completion: @escaping (PomodoroState) -> Void) {
        let pomodoroRef = database.child("liveSessions").child(sessionId).child("pomodoro")
        
        let handle = pomodoroRef.observe(.value) { snapshot in
            guard let dict = snapshot.value as? [String: Any],
                  let data = try? JSONSerialization.data(withJSONObject: dict),
                  let state = try? JSONDecoder().decode(PomodoroState.self, from: data) else {
                completion(PomodoroState())
                return
            }
            
            completion(state)
        }
        
        listeners["pomodoro_\(sessionId)"] = handle
    }
    
    // MARK: - Live Poll Management
    
    /// Create a new poll
    func createPoll(sessionId: String, poll: LivePoll, completion: @escaping (Bool) -> Void) {
        let pollRef = database.child("liveSessions").child(sessionId).child("polls").child(poll.id)
        
        do {
            let data = try JSONEncoder().encode(poll)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            
            pollRef.setValue(dict) { error, _ in
                if error == nil {
                    // Set as current poll
                    self.database.child("liveSessions").child(sessionId).child("currentPollId").setValue(poll.id)
                }
                completion(error == nil)
            }
        } catch {
            print("Error encoding poll: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    /// Submit a vote for a poll
    func submitPollVote(sessionId: String, pollId: String, userId: String, optionIndex: Int, completion: @escaping (Bool) -> Void) {
        let voteRef = database.child("liveSessions").child(sessionId).child("polls").child(pollId).child("votes").child(userId)
        
        voteRef.setValue(optionIndex) { error, _ in
            if error == nil {
                // Increment vote count for the option
                let optionRef = self.database.child("liveSessions").child(sessionId).child("polls").child(pollId).child("options").child(String(optionIndex)).child("voteCount")
                optionRef.runTransactionBlock { currentData in
                    let currentCount = (currentData.value as? Int) ?? 0
                    currentData.value = currentCount + 1
                    return TransactionResult.success(withValue: currentData)
                }
            }
            completion(error == nil)
        }
    }
    
    /// Close a poll
    func closePoll(sessionId: String, pollId: String, completion: @escaping (Bool) -> Void) {
        let pollRef = database.child("liveSessions").child(sessionId).child("polls").child(pollId)
        
        pollRef.child("isActive").setValue(false) { error, _ in
            if error == nil {
                pollRef.child("closedAt").setValue(ServerValue.timestamp())
            }
            completion(error == nil)
        }
    }
    
    /// Observe current poll
    func observeCurrentPoll(sessionId: String, completion: @escaping (LivePoll?) -> Void) {
        let pollIdRef = database.child("liveSessions").child(sessionId).child("currentPollId")
        
        let handle = pollIdRef.observe(.value) { snapshot in
            guard let pollId = snapshot.value as? String else {
                completion(nil)
                return
            }
            
            // Now get the actual poll data
            let pollRef = self.database.child("liveSessions").child(sessionId).child("polls").child(pollId)
            
            pollRef.observeSingleEvent(of: .value) { pollSnapshot in
                guard let dict = pollSnapshot.value as? [String: Any],
                      let data = try? JSONSerialization.data(withJSONObject: dict),
                      let poll = try? JSONDecoder().decode(LivePoll.self, from: data) else {
                    completion(nil)
                    return
                }
                
                completion(poll)
            }
        }
        
        listeners["currentPoll_\(sessionId)"] = handle
    }
    
    // MARK: - Live Quiz Management
    
    /// Create a new quiz
    func createQuiz(sessionId: String, quiz: LiveQuiz, completion: @escaping (Bool) -> Void) {
        let quizRef = database.child("liveSessions").child(sessionId).child("quizzes").child(quiz.id)
        
        do {
            let data = try JSONEncoder().encode(quiz)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            
            quizRef.setValue(dict) { error, _ in
                if error == nil {
                    // Set as current quiz
                    self.database.child("liveSessions").child(sessionId).child("currentQuizId").setValue(quiz.id)
                }
                completion(error == nil)
            }
        } catch {
            print("Error encoding quiz: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    /// Submit an answer for a quiz question
    func submitQuizAnswer(sessionId: String, quizId: String, questionIndex: Int, userId: String, answerIndex: Int, completion: @escaping (Bool) -> Void) {
        let answerRef = database.child("liveSessions").child(sessionId).child("quizzes").child(quizId).child("questions").child(String(questionIndex)).child("answers").child(userId)
        
        answerRef.setValue(answerIndex) { error, _ in
            if error == nil {
                // Get the correct answer to see if user got it right
                let questionRef = self.database.child("liveSessions").child(sessionId).child("quizzes").child(quizId).child("questions").child(String(questionIndex))
                
                questionRef.observeSingleEvent(of: .value) { snapshot in
                    if let dict = snapshot.value as? [String: Any],
                       let correctIndex = dict["correctAnswerIndex"] as? Int {
                        
                        // If answer is correct, increment user's score
                        if answerIndex == correctIndex {
                            let scoreRef = self.database.child("liveSessions").child(sessionId).child("quizzes").child(quizId).child("participantScores").child(userId)
                            
                            scoreRef.runTransactionBlock { currentData in
                                let currentScore = (currentData.value as? Int) ?? 0
                                currentData.value = currentScore + 1
                                return TransactionResult.success(withValue: currentData)
                            }
                        }
                    }
                }
            }
            completion(error == nil)
        }
    }
    
    /// Advance to next question
    func nextQuizQuestion(sessionId: String, quizId: String, completion: @escaping (Bool) -> Void) {
        let quizRef = database.child("liveSessions").child(sessionId).child("quizzes").child(quizId)
        
        quizRef.child("currentQuestionIndex").runTransactionBlock { currentData in
            let currentIndex = (currentData.value as? Int) ?? 0
            currentData.value = currentIndex + 1
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, _, _ in
            completion(error == nil)
        }
    }
    
    /// Observe current quiz
    func observeCurrentQuiz(sessionId: String, completion: @escaping (LiveQuiz?) -> Void) {
        let quizIdRef = database.child("liveSessions").child(sessionId).child("currentQuizId")
        
        let handle = quizIdRef.observe(.value) { snapshot in
            guard let quizId = snapshot.value as? String else {
                completion(nil)
                return
            }
            
            // Now get the actual quiz data
            let quizRef = self.database.child("liveSessions").child(sessionId).child("quizzes").child(quizId)
            
            quizRef.observe(.value) { quizSnapshot in
                guard let dict = quizSnapshot.value as? [String: Any],
                      let data = try? JSONSerialization.data(withJSONObject: dict),
                      let quiz = try? JSONDecoder().decode(LiveQuiz.self, from: data) else {
                    completion(nil)
                    return
                }
                
                completion(quiz)
            }
        }
        
        listeners["currentQuiz_\(sessionId)"] = handle
    }
    
    // MARK: - Cleanup
    
    /// Remove all listeners
    func removeAllListeners() {
        for (path, handle) in listeners {
            let components = path.split(separator: "_")
            if components.count == 2 {
                let sessionId = String(components[1])
                let type = String(components[0])
                
                switch type {
                case "participants":
                    database.child("liveSessions").child(sessionId).child("activeParticipants").removeObserver(withHandle: handle)
                case "whiteboard":
                    database.child("liveSessions").child(sessionId).child("whiteboard").removeObserver(withHandle: handle)
                case "pomodoro":
                    database.child("liveSessions").child(sessionId).child("pomodoro").removeObserver(withHandle: handle)
                case "currentPoll":
                    database.child("liveSessions").child(sessionId).child("currentPollId").removeObserver(withHandle: handle)
                case "currentQuiz":
                    database.child("liveSessions").child(sessionId).child("currentQuizId").removeObserver(withHandle: handle)
                default:
                    break
                }
            }
        }
        
        listeners.removeAll()
    }
    
    deinit {
        removeAllListeners()
    }
}
