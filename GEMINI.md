# Project: Humming-to-Chord App

This document outlines the project plan and coding conventions for the "Humming-to-Chord" iOS application. All development should adhere to the principles and decisions laid out here.

## 1. Core Concept

An iOS app that records a user's humming, analyzes the melody's pitch in real-time, and suggests multiple corresponding chord progressions.

## 2. Feature Breakdown (MVP)

- **Recording:**
    - Utilizes a Start/Stop button for recording user's humming.
- **Pitch Analysis:**
    - Performs real-time pitch detection on the incoming audio signal.
    - Implements automatic pitch correction for minor inaccuracies in humming.
- **Chord Suggestion:**
    - Generates and displays multiple possible chord progressions that fit the analyzed melody.
    - The chord vocabulary includes basic triads as well as more complex chords (e.g., 7ths).
- **Display:**
    - Presents the suggested chord progressions in a simple, clear text format.

## 3. Technical Stack & Key Decisions

- **Platform:** iOS (Swift, SwiftUI)
- **Core Audio Analysis:** `AudioKit` will be the primary framework for handling audio input and real-time pitch detection via `PitchTap`.
- **Architectural Pattern:** The project will adopt the **MVVM (Model-View-ViewModel)** pattern to ensure a clean separation of concerns.

## 4. Coding Conventions & Principles

### 4.1. SOLID Principles (Strict Adherence)

The five SOLID principles of object-oriented design will be strictly followed:
1.  **Single Responsibility Principle (SRP):** Each class or struct will have only one reason to change.
2.  **Open/Closed Principle (OCP):** Software entities should be open for extension, but closed for modification.
3.  **Liskov Substitution Principle (LSP):** Subtypes must be substitutable for their base types.
4.  **Interface Segregation Principle (ISP):** Clients should not be forced to depend on interfaces they do not use.
5.  **Dependency Inversion Principle (DIP):** High-level modules should not depend on low-level modules. Both should depend on abstractions.

### 4.2. Additional Swift Coding Rules

- **Latest Swift Syntax:** The project's code will always prioritize using the latest Swift syntax.
- **Swift API Design Guidelines:** Adhere to the official [Apple Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) for naming and clarity.
- **SwiftLint Integration:** Use `SwiftLint` to enforce a consistent code style and identify potential issues.
- **Immutability:** Prefer `let` over `var` wherever possible to create predictable and safer code.
- **Clear Error Handling:** Utilize Swift's `do-catch` statements and the `Result` type for robust and explicit error handling.

## 5. Development Steps (Roadmap)

### Step 1: Project Setup & Configuration
- Add `AudioKit` dependency to the project using Swift Package Manager (SPM).
- Configure the project's `Info.plist` to request microphone usage permission (`Privacy - Microphone Usage Description`).
- Set up basic project structure with folders for `View`, `ViewModel`, `Model`, and `Service`.

### Step 2: Pitch Analysis Service Implementation
- Create a `PitchDetectionService` class in accordance with SRP.
- Inside this service, set up the `AudioEngine`, microphone input, and `PitchTap`.
- Implement `start()` and `stop()` methods to control the audio analysis.
- The `PitchTap` handler will process incoming `pitch` and `amp` values.
- Implement noise filtering by ignoring events where `amp` is below a certain threshold (e.g., 0.01).

### Step 3: Melody Data Transformation
- Define a `Note` struct to represent a musical note (e.g., containing pitch name like "C#4" and duration).
- Create a utility or service to convert raw frequency (Hz) from `PitchTap` into `Note` objects.
- Implement logic to capture a sequence of these `Note` objects during a recording session.

### Step 4: Chord Harmonization Service Implementation
- Create a `ChordHarmonizationService` class.
- This service will accept a sequence of `Note` objects as input.
- **(a) Key Detection:** Implement an algorithm to determine the most likely musical key from the note sequence.
- **(b) Chord Generation:** Based on the detected key and the notes, generate a list of suitable chord progression suggestions. Start with common diatonic chord patterns (e.g., I-IV-V, ii-V-I).

### Step 5: UI & ViewModel Implementation (MVVM)
- **View:** Create a `ContentView` in SwiftUI with a "Record" button and a text area to display results.
- **ViewModel:** Create a `ContentViewModel` to act as a bridge.
    - The ViewModel will hold the state (e.g., `isRecording`, `resultText`).
    - The "Record" button action in the View will call methods on the ViewModel (e.g., `toggleRecording()`).
    - The ViewModel will use `PitchDetectionService` to manage recording.
    - Upon completion, the ViewModel will pass the note sequence to `ChordHarmonizationService` and receive chord suggestions.
    - The ViewModel will format the suggestions and update the `resultText`, which the View will automatically display.

## 6. Tool Usage Conventions

- **Context7 for Documentation:** Whenever code generation, setup, or configuration steps require library/API documentation, automatically use the Context7 MCP tools to resolve library IDs and fetch library documentation without being explicitly asked.
- **Documentation Lookup Workflow:** Use GoogleSearch to discover what official documentation exists. Use Context7 to understand the content of that official documentation.
- **Reference Provisioning Workflow:** When providing a URL as a reference, do not just show the URL text. First, use the `web_fetch` tool to directly fetch and summarize the content of the URL. This verifies the link is active and provides immediate context.
- **Proactive Code Review:** Before suggesting code modifications or new features, always check the latest content of the relevant files to ensure suggestions are based on the current state of the codebase.

## 7. Collaboration Model (TDD Workflow)

We will follow a Test-Driven Development (TDD) workflow with the following roles:

1.  **Goal Proposal:** Gemini proposes the next feature or test target in plain text, including a suggested test function name.
2.  **[RED] - User Action:** The user writes the new failing test code.
3.  **[GREEN] - User Action:** After the test is confirmed to fail, the user writes the production code to make the test pass.
4.  **Review:** Gemini acts as a code reviewer for both the test and production code, providing advice.
5.  **[REFACTOR]:** Together, we refactor the code based on the review.