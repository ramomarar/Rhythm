## 👥 Group Member Task Assignments

---

### 🟢 Mason — Firebase & Data Integration Lead  
**Responsibility:** Backend services, user authentication, data persistence

**Tasks:**
- [X] Set up Firebase project and add iOS app
- [X] Install Firebase SDKs via Swift Package Manager
- [X] Configure `GoogleService-Info.plist` in Xcode
- [X] Create and Implement User Signup and Login Page
- [X] Implement Firebase **Email/Password Auth**
- [X] Create `UserSession` model & bind to SwiftUI state
- [X] Build `TaskDataService.swift` to read/write tasks (Firestore)
- [X] Sync task data to `TaskViewModel`
- [X] Handle loading states and error messages
- [X] Secure user-scoped data (per UID)

---

### 🔵 Chris — UI & SwiftUI Views Lead  
**Responsibility:** Core screens and user interface

**Tasks:**
- [ ] Build `HomeView` with quick overview of tasks and timer
- [ ] Create `TaskListView` with list of tasks from `TaskViewModel`
- [ ] Implement `TaskDetailView` (add/edit tasks)
- [ ] Build `PomodoroView` to show active timer with controls
- [ ] Add `SettingsView` with options for notifications, theme
- [ ] Use `@State`, `@ObservedObject`, and `@Binding` properly
- [ ] Make views responsive to session state and Firebase user

---

### 🟠 Chloe — Timer Logic & Productivity Features  
**Responsibility:** Pomodoro system, timers, and session handling

**Tasks:**
- [ ] Implement countdown timer engine in `TimerHelper.swift`
- [ ] Build `TimerViewModel.swift` with timer logic (start, pause, reset)
- [ ] Integrate long/short breaks and session state
- [ ] Add optional streaks or session counter
- [ ] Work with Chris to bind `PomodoroView` to timer engine
- [ ] Handle timer persistence when app backgrounded (`ScenePhase`)

---

### 🟣 Omar — Architecture, Testing & UI Polish  
**Responsibility:** File structure, constants, theme, and testing

**Tasks:**
- [X] Create reusable `Constants.swift` (colors, durations)
- [X] Add `Date+Extensions.swift` for date formatting
- [X] Add `NotificationService.swift` for session alerts
- [ ] Build app-wide navigation flow (tabs or navigation stack)
- [X] Support light/dark mode via themes
- [X] Write unit tests for `TaskViewModel` and `TimerViewModel`
- [ ] Polish layout and accessibility (font size, spacing)
