# Project Tracker

A calendar-style project tracker I built for managing my personal workflow, handling API development, bug fixes, meetings, and general tasks. Entries move through a Documentation → Development → Testing → Rest → Done pipeline with each stage color-coded for quick visual tracking across month and day views. Supports multiple time blocks per entry and automatically splits overlapping entries side-by-side on the timeline. Includes bug tracking fields with severity, status, and steps to reproduce. Stage can be advanced via swipe gestures in the list view or context menus on the timeline. Built for personal use with SwiftUI and SwiftData.

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
