# Flodo Task Management App

A clean, polished, fully functional Task Management Flutter application.

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

## AI Usage Report

I used **Grok** throughout the project to help me write clean, maintainable code and solve specific technical challenges quickly.

**Prompts I asked during development:**

- “How to properly set up Hive database with Riverpod in Flutter for a task management app, including a Task model with fields like title, description, due date, status, and blocked by ID?”
- “How to implement draft persistence in the task creation screen so that typed data survives when the user navigates back or minimizes the app?”
- “How to add a 2 second simulated delay on task create and update with a clear loading spinner while keeping the UI responsive and preventing double taps?”
- “How to implement debounced search (300ms) in a Flutter list with Riverpod and highlight the matching text in the task title using Rich Text?”
- “How to add recurring tasks logic so that when a daily/weekly recurring task is marked as Done, the app automatically creates the next occurrence with the updated due date?”
- “How to implement persistent drag and drop reordering of tasks using Reorderable List View and save the custom order in Hive so it persists after app restart?”

**One small issue I fixed myself:**  
Grok once suggested using a `Timer` directly inside a stateless widget for debouncing, which caused unexpected behavior. I switched to `ConsumerStatefulWidget` to manage the Timer properly and it worked perfectly.

## Drive Demo Link
https://drive.google.com/file/d/1juelj6QW-aBdnbf2vUqz6CyNvx34t1yN/view?usp=sharing

## Setup Instructions

1. Clone the repository:
   ```bash
   flutter config --enable-windows-desktop
   flutter create --platforms=windows 
   flutter run -d windows
   flutter create 
   flutter clean
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   flutter run -d chrome
