# Rhythm

Rhythm is a minimalist, intelligent task scheduler and Pomodoro timer designed for focused, time-efficient work. It helps users manage their time realistically by estimating task durations and integrating them into a smooth workflow using Pomodoro-based sessions.

---

## 🌟 Target Audience

Rhythm is built for busy students, freelancers, and professionals who struggle with time estimation and task planning. These users value simplicity, intelligent scheduling, and frictionless time management.

---

## 💡 Problem Being Solved

Traditional to-do lists and calendars often lack realistic time estimation and require manual planning. Rhythm solves this by:
- Automatically estimating task durations
- Scheduling tasks into focused work blocks (Pomodoro sessions)
- Keeping the interface clean and non-overwhelming

---

## 🔍 Comparison to Existing Solutions

| Feature             | Rhythm         | Motion          | Todoist        |
|---------------------|----------------|------------------|----------------|
| Time estimation     | ✅ Smart Estimation | ✅ (via AI)      | ❌             |
| Pomodoro integration| ✅ Built-in     | ❌               | ⚠️ (via plugin) |
| Simplicity          | ✅ Minimal UI   | ❌ Over-featured | ✅              |
| Real-time planning  | ✅ Seamless     | ✅               | ❌              |

Rhythm finds a balance between automation and usability, integrating planning and time tracking more fluidly than its competitors.

---

## 🎮 How to Use Rhythm

1. **Create a Task**  
   Add a task with a title and optional estimate.

2. **Auto-Schedule**  
   Tasks are auto-sorted into Pomodoro sessions based on priority and time blocks.

3. **Start a Session**  
   Use the Pomodoro timer to begin focused work. Short and long breaks are built-in.

4. **Track & Adjust**  
   Adjust task estimates over time; the app adapts future sessions based on your actual performance.

---

## 🛠️ Frameworks & Services

- **Frontend**: React with Vite
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **Backend**: Firebase (Auth, Firestore, Hosting)
- **Timer Engine**: Custom-built hook-based Pomodoro system

---

## ⚔️ Biggest Challenge

### Challenge: Seamless Integration of Timer + Task Scheduler

Building a responsive system that updates the timer state while also rescheduling tasks in real-time was non-trivial. This required designing a shared context with an event-driven architecture in React. We solved it using:
- `useReducer` for state consistency
- Debounced task rescheduling logic
- State snapshots for rollback if interrupted

---

## 🔁 MVP & Iteration Strategy

We followed an iterative product design cycle:
1. **Research**: Analyzed competitor apps and interviewed target users.
2. **Prototype**: Low-fidelity Figma mockups, then high-fidelity clickable designs.
3. **Build**: Implemented core features — task entry, scheduling, and timer.
4. **Test & Improve**: Weekly user testing and adjustments.
5. **Polish**: Final week used for animation, responsiveness, and bug fixes.

---

## 👩‍💻 Github Collaboration Guide

### 🧾 Repository Setup

Clone the project:

```bash
git clone https://github.com/your-org/rhythm.git
cd rhythm
npm install
````

### 🌿 Branching Strategy

* **main**: Stable production-ready code
* **dev**: Staging branch for new features
* **feature/**\*: New features (`feature/timer`, `feature/task-form`)
* **bugfix/**\*: Fixes (`bugfix/sync-error`)
* **hotfix/**\*: Urgent production patches

```bash
git checkout -b feature/your-feature-name
```

### ✅ Making a Pull Request

1. Push your branch:

   ```bash
   git push origin feature/your-feature-name
   ```

2. Go to GitHub → Open a Pull Request to `dev` branch

3. Add reviewers from your team

4. Include:

   * What the feature does
   * Screenshots if needed
   * Any known bugs or limitations

5. Only merge after approval and successful CI tests

---

## 🧠 Code Structure

```
/src
  /components       → Reusable UI components
  /hooks            → Custom React hooks (e.g. usePomodoro)
  /pages            → Main views (Dashboard, TaskList)
  /store            → Zustand global store
  /utils            → Helpers, formatters
```

---

## ✅ Assessment Criteria: Code

* **✅ Data Modeling**
  Task objects are structured with `id`, `title`, `estimatedTime`, `status`, and `actualTime`. Firestore handles persistence.

* **✅ Immutability & Type Safety**
  All state updates use immutability principles. TypeScript enforces structure and prevents invalid state.

* **✅ Functional Separation**
  UI, logic, and state are modular and separated. Pomodoro logic is isolated in a custom hook.

* **✅ Loose Coupling**
  Pages and components interact via props or global store — easy to swap or reuse modules.

* **✅ Extensibility**
  Adding new features (e.g. tags, dark mode) requires minimal structural changes thanks to modularity.

* **✅ Error Handling**
  User input is validated (no empty tasks, invalid time). Timer handles edge cases (paused sessions, task deletions during focus).

* **✅ Github Collaboration**
  Each team member contributes via separate branches and PRs. All code is peer-reviewed.

---

## 📦 Submission

This README and the GitHub repository URL must be included in the final zip submission on Canvas.

GitHub URL: [https://github.com/your-org/rhythm](https://github.com/your-org/rhythm)

---

## 📽️ Final Presentation

Your team will present Rhythm during Week 12 lab session:

* Describe the app and user problem
* Compare with competitors
* Walk through key features and tech choices
* Reflect on biggest challenges
* Show how the MVP evolved

