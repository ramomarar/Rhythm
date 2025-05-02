# Rhythm
Rhythm is a focused task scheduler and Pomodoro timer for iOS, built in SwiftUI. It helps users manage time realistically by estimating task durations and scheduling them into Pomodoro-based work sessions. The interface is kept minimal and intuitive.

---

## 🎯 Target Audience

Rhythm is designed for:
- University students managing deadlines
- Freelancers and creatives juggling flexible work
- Busy professionals aiming to improve focus and task planning

---

## 💡 Problem Solved

Typical to-do list apps don’t help users realistically plan their day or stay focused. Rhythm solves this by:
- Estimating task durations and auto-scheduling
- Using Pomodoro cycles to structure focus time
- Simplifying the UX to avoid overwhelm

---

## 🆚 Compared to Other Apps

| Feature             | Rhythm (iOS)   | Motion (Web)     | Things (iOS)     |
|---------------------|----------------|------------------|------------------|
| Smart Estimation     | ✅ Yes         | ✅ Yes           | ❌ No             |
| Pomodoro Integration | ✅ Built-in    | ❌               | ❌                |
| Native Experience    | ✅ SwiftUI     | ❌ Web-only      | ✅                |
| Task Adaptation      | ✅ Dynamic     | ⚠️ Partial        | ❌ Manual only    |

---

## 📱 How to Use

1. Add a task with a title and optional time estimate
2. Tasks are sorted into Pomodoro sessions automatically
3. Start a session and work through the timer
4. Take built-in breaks to reset focus
5. Track your productivity over time

---

## 🛠️ Tech Stack

- **Language**: Swift 5.9
- **UI Framework**: SwiftUI 3.0
- **Data Layer**: Combine + CoreData (or optional Firebase)
- **Architecture**: MVVM
- **Timer Engine**: Custom Countdown + Background Sync

---

## 💥 Biggest Challenge

**Challenge:** Synchronizing Pomodoro state across app background/foreground and when switching views  
**Solution:** Used `@AppStorage` for persistence + `ScenePhase` monitoring to pause/resume accurately when user exits app.

---

## 🔁 MVP & Iteration Strategy

We followed a 4-step iterative design cycle:

1. **Planning**: Whiteboarding flows + competitor research
2. **Prototype**: Low-fi SwiftUI mockups with hardcoded tasks
3. **MVP Build**: Timer logic, task persistence, UI polish
4. **Testing**: User feedback → added adaptive scheduling

---

## 🤝 GitHub Collaboration

### 📂 Branching Strategy

- `main`: Stable release
- `develop`: Staging / integration branch
- `feature/*`: Individual features
- `bugfix/*`: Targeted fixes

### ✅ Workflow

```bash
# Create and switch to a new branch
git checkout -b feature/task-editor

# Stage changes
git add .

# Commit
git commit -m "Add editable task view"

# Push and create pull request
git push origin feature/task-editor
All code changes must go through a PR, reviewed by at least one team member.

📦 Submission Info
Include this README.md and your GitHub repo URL in your final Canvas submission.

GitHub Repo: [https://github.com/MForemxn/Rhythm](https://github.com/MForemxn/Rhythm)
