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
- **SwiftUI State Management:** When a view owns an instance of an `@Observable` class, use the `@State` property wrapper to manage its lifecycle and ensure its persistence (e.g., `@State private var viewModel = MyViewModel()`).
- **Swift API Design Guidelines:** Adhere to the official [Apple Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) for naming and clarity.
- **SwiftLint Integration:** Use `SwiftLint` to enforce a consistent code style and identify potential issues.
- **Immutability:** Prefer `let` over `var` wherever possible to create predictable and safer code.
- **Clear Error Handling:** Utilize Swift's `do-catch` statements and the `Result` type for robust and explicit error handling.

## 5. Development Steps (Roadmap)

### Step 1: Project Setup & Configuration (Completed)
- Add `AudioKit` dependency, configure `Info.plist`, and set up basic project structure.

### Step 2: Audio Input Service Implementation (Completed)
- Implemented `PitchDetectionService` to handle `AudioEngine` setup and provide a real-time stream of `(pitch, amplitude)` data using `PitchTap`.

### Step 3: Melody Data Transformation (Completed)
- Implemented `NoteAggregatorService` to consume the real-time pitch stream and convert it into a clean `[Note]` array, representing the user's melody.

### Step 4: Key & Chord Analysis Service (In Progress)
- **(a) Key Detection (Completed):** Implemented `KeyDetectionService` using the Krumhansl-Schmuckler algorithm to find the most likely key from a `[Note]` array.
- **(b) Chord Generation (Next Step):** Create a `ChordHarmonizationService`. This service will take the detected `Key` and the `[Note]` array as input. It will use the user-provided **BPM and Time Signature** to segment the melody into measures and recommend diatonic chord progressions.

### Step 5: UI & ViewModel Implementation (Partially Completed)
- **ViewModel:** The `ContentViewModel` is implemented to act as a conductor, owning and coordinating all the services (`PitchDetectionService`, `NoteAggregatorService`, `KeyDetectionService`). It processes the audio data flow from start to finish.
- **View:** A basic `ContentView` is implemented with a Record/Stop button and text display. It will be updated to include input fields for **BPM and Time Signature**.

## 6. Tool Usage Conventions

- **API Verification Mandate:** Before writing or suggesting any code that uses an external library's API, Gemini must first use the `context7` toolchain (`resolve_library_id`, `get_library_docs`) to look up and verify the specific APIs being used. Suggestions must be based on this retrieved documentation.
- **Context7 for Documentation:** Whenever code generation, setup, or configuration steps require library/API documentation, automatically use the Context7 MCP tools to resolve library IDs and fetch library documentation without being explicitly asked.
- **Information Retrieval Workflow:** When searching for information, especially for questions about a specific library's API or usage, prioritize the use of `context7`. Only use `GoogleSearch` as a secondary tool if the desired information cannot be found with `context7` or if the search is about a broader topic (architecture, tutorials, etc.).
- **Reference Provisioning Workflow:** When providing a URL as a reference, do not just show the URL text. First, use the `web_fetch` tool to directly fetch and summarize the content of the URL. This verifies the link is active and provides immediate context.
- **Proactive Code Review:** Before suggesting code modifications or new features, always check the latest content of the relevant files to ensure suggestions are based on the current state of the codebase.

## 7. Collaboration Model (TDD Workflow)

We will follow a Test-Driven Development (TDD) workflow with the following roles:

1.  **Goal Proposal:** Gemini proposes the next feature or test target in plain text, including a suggested test function name.
2.  **[RED] - User Action:** The user writes the new failing test code.
3.  **[GREEN] - User Action:** After the test is confirmed to fail, the user writes the production code to make the test pass.
4.  **Review:** Gemini acts as a code reviewer for both the test and production code, providing advice.
5.  **[REFACTOR]:** Together, we refactor the code based on the review.
6.  **Strict TDD Cycle:** All feature additions and modifications, even small logic to support the UI, must go through an independent TDD cycle (Red-Green-Refactor). Gemini will not bundle multiple features or logic changes into a single large step proposal.
7.  **Ground-Truth First Principle:** When a bug related to an external framework occurs, the top priority is to find the source code or documentation for the lowest-level API involved before proposing architectural patterns.
8.  **Hypothesize and Verify:** When forming a hypothesis about a bug's cause, Gemini will state the hypothesis and then explicitly state the process to find evidence to support it.
9.  **User-Observation Priority:** User-provided error messages and intuitive feedback will be treated as the highest-priority clues, and debugging will proceed by verifying these observations first, even if they conflict with Gemini's internal model.
