# Flodo Task Management App

A clean, polished, fully functional Task Management Flutter application built for the **Flodo AI Take-Home Assignment**.

## Track Chosen
**Track B: The Mobile Specialist** (Flutter + Local Database only)

## Stretch Goals Implemented
**All 3 stretch goals** were completed:
1. **Debounced Autocomplete Search** – Instant filtering with 300ms debounce + matching text highlighted in yellow
2. **Recurring Tasks** – Daily/Weekly toggle + automatically creates the next task when marked "Done"
3. **Persistent Drag-and-Drop** – Reorder tasks by dragging; custom order is saved in Hive and persists across restarts

## Core Features Implemented (Exactly as per assignment)
- Task model with Title, Description, Due Date, Status, Blocked By
- Full CRUD operations
- Draft persistence (new task form survives minimize/swipe-back)
- Search by title + Status filter
- Blocked-by rule: Task B is visually greyed out until Task A is marked "Done"
- 2-second simulated delay on Create & Update (with loading spinner + button disabled)
- Beautiful Material 3 UI with smooth animations

## Tech Stack
- Flutter 3.41+
- Riverpod (state management)
- Hive + Hive Flutter (local persistence)
- Intl (date formatting)
- UUID (unique task IDs)

## Screenshots
(You can add 2–3 screenshots here later if you want)

## 🚀 Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR-USERNAME/flodo-task-manager.git
   cd flodo-task-manager
