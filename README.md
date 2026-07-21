# Offline-First Notes App

A Flutter application demonstrating an **Offline-First Architecture** using **Hive CE**, 
**Riverpod**, **Dio**, and **MockAPI**. The app allows users to create, update, delete, 
and synchronize notes while handling network interruptions and data conflicts gracefully.

---

# Features

* 📱 Offline-first architecture
* 📝 Create, update, and delete notes
* 💾 Local storage using Hive CE
* ☁️ Remote synchronization with MockAPI
* 🔄 Automatic periodic sync
* 🌐 Works offline and syncs when internet is available
* ⚠️ Conflict detection
* ✅ Resolve conflicts using:

    * Keep Local Version
    * Use Server Version
* 🟢 Sync status indicators
* 🗑 Soft delete support

---

# Tech Stack

| Technology | Purpose             |
| ---------- | ------------------- |
| Flutter    | UI Framework        |
| Riverpod   | State Management    |
| Hive CE    | Local Database      |
| Dio        | HTTP Client         |
| MockAPI    | Remote REST API     |
| UUID       | Local ID Generation |

---

# Architecture

```
                User
                  │
                  ▼
          Home Screen (UI)
                  │
                  ▼
         NotesNotifier (Riverpod)
                  │
                  ▼
            SyncService
          ┌────────┴────────┐
          ▼                 ▼
   NoteRepository       NoteApi
      (Hive)          (MockAPI)
```

---

# Data Flow

## Create Note

```
User creates note
        │
        ▼
Save locally (Hive)
        │
pendingOperation = create
        │
        ▼
Automatic Sync
        │
        ▼
POST to Server
        │
        ▼
Mark Synced
```

---

## Update Note

```
User edits note
        │
        ▼
Save locally
        │
pendingOperation = update
        │
        ▼
Sync
        │
        ▼
Fetch latest server copy
        │
        ▼
Conflict?
      /    \
    Yes     No
    │        │
    ▼        ▼
Conflict   Upload
```

---

## Delete Note

```
Delete Note
      │
      ▼
isDeleted = true
pendingOperation = delete
      │
      ▼
Sync
      │
      ▼
DELETE API
      │
      ▼
Remove locally
```

---

# Offline Synchronization

Whenever the internet is available, the application performs:

```
sync()
```

which internally executes

```
Push Local Changes
        │
        ▼
Pull Server Changes
```

Push-first synchronization prevents server updates from accidentally overwriting local unsynced changes.

---

# Sync Workflow

```
sync()
│
├── Push Changes
│      ├── Create
│      ├── Update
│      └── Delete
│
└── Pull Changes
       ├── Download new notes
       └── Merge safe changes
```

---

# Conflict Detection

A conflict occurs when **both** the local copy and the server copy have been modified after the last successful synchronization.

```
Last Sync
     │
 ┌───┴────┐
 │        │
 ▼        ▼
Local    Server
Edited   Edited
     │
     ▼
 Conflict
```

The application compares:

* Local updated timestamp
* Server updated timestamp
* Last synced timestamp

If both local and server versions changed after the previous sync, the note is marked as a conflict.

---

# Conflict Resolution

## Keep Local

```
Local Version
      │
      ▼
Upload Local
      │
      ▼
Replace Server Data
      │
      ▼
Mark Synced
```

---

## Use Server

```
Server Version
      │
      ▼
Replace Local Data
      │
      ▼
Clear Conflict
      │
      ▼
Mark Synced
```

---

# Synchronization Status

| Status   | Description                         |
| -------- | ----------------------------------- |
| Synced   | Local and server data are identical |
| Pending  | Waiting to be synchronized          |
| Conflict | Manual user resolution required     |

---

# Local Database (Hive)

Each note stores:

```dart
localId
remoteId

title
body

updatedAt
lastSyncedAt

syncStatus
pendingOperation

isDeleted

conflictTitle
conflictBody
conflictUpdatedAt
```

---

# Pending Operations

```
none
create
update
delete
```

The pending operation tells the sync engine which API call should be performed.

---

# Remote API

The application communicates with MockAPI using REST APIs.

| Method | Endpoint    | Purpose           |
| ------ | ----------- | ----------------- |
| GET    | /notes      | Fetch all notes   |
| GET    | /notes/{id} | Fetch single note |
| POST   | /notes      | Create note       |
| PUT    | /notes/{id} | Update note       |
| DELETE | /notes/{id} | Delete note       |

---

# State Management

Riverpod manages:

* Note list
* CRUD operations
* Synchronization
* Conflict resolution
* UI refresh

---

# Synchronization Engine

The synchronization engine consists of two main components.

### SyncService

Responsible for:

* Push local changes
* Pull server changes
* Conflict detection
* Merge logic

### SyncManager

Responsible for:

* Periodic synchronization
* Network availability checks
* Triggering sync automatically

---

# Key Design Decisions

### Offline First

The application never depends on the network for CRUD operations. Every operation is saved locally first.

---

### Push Before Pull

Uploading local changes before downloading server updates prevents accidental overwriting of local unsynced data.

---

### Soft Delete

Instead of immediately removing a deleted note, it is marked with:

```dart
isDeleted = true
pendingOperation = delete
```

The note is removed locally only after successful synchronization.

---

### Manual Conflict Resolution

Instead of automatically overwriting data, the application lets the user choose which version to keep.

---

# Future Improvements

* Authentication
* Background synchronization
* Attachments and images
* Pagination
* Search
* Real-time synchronization (WebSockets)
* Server-side versioning
* Encrypted local database
* Unit & integration tests
* Cloud backend (Firebase / Supabase / Node.js)

---

# Getting Started

## Clone the repository

```bash
git clone <repository-url>
```

## Install dependencies

```bash
flutter pub get
```

## Generate Hive adapters

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Run the project

```bash
flutter run
```

---

# Learning Outcomes

This project demonstrates practical implementation of:

* Offline-first mobile architecture
* Local-first data persistence
* Synchronization between local and remote data
* Conflict detection and manual conflict resolution
* Repository pattern
* Riverpod state management
* Hive CE local database
* REST API integration using Dio
* Robust synchronization workflow
