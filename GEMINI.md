# Project: Humming-to-Chord App

This document outlines the project plan and coding conventions for the "Humming-to-Chord" iOS application. All development should adhere to the principles and decisions laid out here.

## 1. Core Concept

An iOS app that records a user's humming, analyzes the melody's pitch in real-time, and suggests multiple corresponding chord progressions.

## 2. Feature Breakdown

- **Recording:** Utilizes a Start/Stop button for recording user's humming.
- **Real-time Analysis:** Provides real-time feedback (pitch, amplitude). A visual metronome will be implemented.
- **Key & Chord Analysis:** Analyzes the completed melody to determine the musical key and suggest chord progressions.
- **Interactive Playback:** Allows the user to hear the suggested chords and play them along with their original humming.

## 3. Technical Stack & Key Decisions

- **Platform:** iOS (Swift, SwiftUI)
- **Core Audio Analysis:** `AudioKit` will be the primary framework for audio processing.
- **Architectural Pattern:** The project will adopt the **MVVM (Model-View-ViewModel)** pattern.

## 4. Coding Conventions & Principles

### 4.1. SOLID Principles (Strict Adherence)
1.  **Single Responsibility Principle (SRP)**
2.  **Open/Closed Principle (OCP)**
3.  **Liskov Substitution Principle (LSP)**
4.  **Interface Segregation Principle (ISP)**
5.  **Dependency Inversion Principle (DIP)**

### 4.2. Additional Swift Coding Rules
- **Latest Swift Syntax:** The project's code will always prioritize using the latest Swift syntax.
- **SwiftUI State Management:** When a view owns an instance of an `@Observable` class, use the `@State` property wrapper to manage its lifecycle and ensure its persistence (e.g., `@State private var viewModel = MyViewModel()`).
- **Swift API Design Guidelines:** Adhere to the official [Apple Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) for naming and clarity.
- **SwiftLint Integration:** Use `SwiftLint` to enforce a consistent code style and identify potential issues.
- **Immutability:** Prefer `let` over `var` wherever possible to create predictable and safer code.
- **Clear Error Handling:** Utilize Swift's `do-catch` statements and the `Result` type for robust and explicit error handling.

## 5. Development Steps (Roadmap)

### Step 1-4: Core Logic Implementation (Completed)
- **Audio Service:** Implemented `PitchDetectionService` to provide a real-time stream of pitch and amplitude data.
- **Melody Transformation:** Implemented `NoteAggregatorService` to convert the raw pitch stream into a clean `[Note]` array.
- **Key Analysis:** Implemented `KeyDetectionService` to find the musical key from the `[Note]` array.
- **Chord Generation (Diatonic):** Implemented `ChordHarmonizationService` to generate diatonic chords and candidate chords.
- **ViewModel Integration:** The `ContentViewModel` is set up to own and coordinate these services.

### Step 5: Advanced UI & Chord Harmonization (Current)
- **(a) BPM/Meter Input & Visual Metronome:** Implement UI controls for the user to set BPM and Time Signature. Add a visual element that blinks in time with the set tempo.
- **(b) Chord Progression Algorithm:** Implement the full `harmonize` method using a scoring system to select the best chord for each measure.
- **(c) Chord Progression Display:** Implement a UI to display the final recommended chord progressions in a "block" format.

### Step 6: Audio Playback Features (Next)
- **(a) Interactive Chord Playback:** Make the chord blocks tappable, playing the notes of the chord when pressed. This requires a new `ChordPlaybackService`.
- **(b) Humming Recording & Duet Playback:** Implement a new `AudioRecordingService` to save the user's humming to a file. Implement playback logic that can play the recorded humming in sync with the generated chord progression.

## 6. Tool Usage Conventions

- **API Verification Mandate:** Before writing or suggesting any code that uses an external library's API, Gemini must first use the `context7` toolchain (`resolve_library_id`, `get_library_docs`) to look up and verify the specific APIs being used. Suggestions must be based on this retrieved documentation.
- **Information Retrieval Workflow:** When searching for information, especially for questions about a specific library's API or usage, prioritize the use of `context7`. Only use `GoogleSearch` as a secondary tool if the desired information cannot be found with `context7` or if the search is about a broader topic (architecture, tutorials, etc.).
- **Reference Provisioning Workflow:** When providing a URL as a reference, do not just show the URL text. First, use the `web_fetch` tool to directly fetch and summarize the content of the URL. This verifies the link is active and provides immediate context.
- **Proactive Code Review:** Before suggesting code modifications or new features, always check the latest content of the relevant files to ensure suggestions are based on the current state of the codebase.

## 7. Collaboration Model

Our development process will follow a "Navigator-Driver" model:

1.  **Navigator (User):** Sets the overall direction, proposes features, asks questions, and performs final verification and code review.
2.  **Driver (Gemini):** Implements the features by writing and modifying code, following TDD principles where applicable. Gemini will explain the implementation and then execute it.
