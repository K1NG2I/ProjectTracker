# Project Tracker | Personal Project | iOS App SwiftUI SwiftData

Project Tracker is a personal project management app for iPhone that combines calendar scheduling with lightweight bug tracking. Designed for solo developers juggling API work, bug fixes, and meetings, it replaces a generic calendar with type-aware entries (API, Bug, Meeting, Other) that progress through a defined stage lifecycle — Documentation → Development → Testing → Rest → Done. Each entry supports multiple time blocks per day, and concurrent entries are automatically split side-by-side on the timeline.

In this project, I was responsible for building the full application from scratch using SwiftUI and SwiftData. I designed and implemented the month and day calendar views, a custom overlap resolution algorithm for concurrent time blocks, entry management with conditional bug tracking fields (severity, status, steps-to-reproduce), the five-stage lifecycle with color-coded visual feedback, and all CRUD operations with persistent local storage.

## Features

- **Month & Day Views** — Month calendar grid with day indicators, vertical timeline with time blocks
- **Entry Types** — API, Bug, Meeting, Other with color-coded icons
- **Stage Lifecycle** — Documentation → Development → Testing → Rest → Done
- **Bug Tracking** — Severity, status, and steps-to-reproduce for bug entries
- **Multiple Time Blocks** — An entry can have several time segments in a day
- **Overlap Resolution** — Concurrent entries split side-by-side on the timeline
- **Quick Stage Advancement** — Swipe in list, context menu in timeline
- **Stage Colors** — Each stage has a distinct color for visual tracking

## Tech Stack

- SwiftUI + SwiftData (iOS 18+)
- No external dependencies
- Code-generated project via XcodeGen

## Screenshots
<table>
  <tr>
    <td align="center"><img src="Screenshots/screenshot1.png" alt="screenshot1" width="220" /></td>
    <td align="center"><img src="Screenshots/screenshot2.png" alt="screenshot2" width="220" /></td>
    <td align="center"><img src="Screenshots/screenshot3.png" alt="screenshot3" width="220" /></td>
    <td align="center"><img src="Screenshots/screenshot4.png" alt="screenshot4" width="220" /></td>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/screenshot5.png" alt="screenshot5" width="220" /></td>
    <td align="center"><img src="Screenshots/screenshot6.png" alt="screenshot6" width="220" /></td>
    <td align="center"><img src="Screenshots/screenshot7.png" alt="screenshot7" width="220" /></td>
    <td align="center"><img src="Screenshots/screenshot8.png" alt="screenshot8" width="220" /></td>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/screenshot9.png" alt="screenshot9" width="220" /></td>
    <td align="center"><img src="Screenshots/screenshot10.png" alt="screenshot10" width="220" /></td>
    <td align="center"></td>
    <td align="center"></td>
  </tr>
</table>

## Setup

1. Clone the repo
2. Open `Project Tracker.xcodeproj` in Xcode 16+
3. Select your development team in **Signing & Capabilities**
4. Run on iPhone simulator or device

## Project Structure

```
Project Tracker/
├── Models/          # SwiftData models & enums
├── Views/           # SwiftUI views
│   ├── Calendar/    # Month, Day timeline
│   ├── List/        # Filterable entry list
│   ├── EntryForm/   # Create/edit form
│   └── Components/  # Reusable UI components
└── Resources/       # Assets
```
