### UPDATED Product Requirements Document: Laxis

- **Version:** 7.0 (Strategic Pivot: User-Centric Learning Model)

### 1. Vision & Executive Summary (REVISED)

**Vision:** To create the most effective and engaging platform for mastering the structural foundation of any language, empowering users to learn their way.

**Executive Summary:** Laxis is a language learning platform that empowers users by combining curated content with the ability to create and master their own vocabulary. The platform is built on a "Learn > Apply > Master" loop. Users learn vocabulary through Decks—both curated and user-created—using a variety of gamified micro-learning modes. Once proficient, they apply this knowledge in our signature Sentence Builder. All learned content is fed into a global Spaced Repetition System (SRS) to ensure long-term mastery. This user-centric model, starting with the German A1 module, will establish Laxis as the most flexible and effective foundational learning tool on the market.

### Change Log
| Date | Version | Description | Author |
|---|---:|---|---|
| 2025-09-21 | 7.0 | Strategic pivot to user-created decks and Learn hub with micro-games; full PRD overhaul | BMad Master |

### Requirements (REVISED)

#### Functional
1. FR1: The platform shall have functional builds for Web, iOS, and Android.
2. FR2: The Laxis Engine shall include a Quest System, Card System, Sentence-Building Mat, Interactive Conjugation Module, and Instant Feedback System.
3. FR3: The Laxis Engine shall include a Repetition Algorithm (SRS) that integrates learned cards into global review queues.
4. FR4: Deck-based progression replaces rigid level gating; curated A1 content will be provided at launch.
5. FR5: Users shall be able to create, import, edit, and manage their own Decks.
6. FR6: The platform shall support CSV/clipboard import and basic Quizlet-style paste formats for rapid deck creation.
7. FR7: The platform shall include a Learn Hub with multiple micro-games per deck and a global Review Mode (SRS).
8. FR8: The Sentence Builder shall dynamically source vocabulary from a deck once the user attains a proficiency threshold for that deck.

#### Non-Functional Requirements (Core Architectural Mandates)
1. NFR1: True Modularity — The core engine must remain language-agnostic.
2. NFR2: Strict Separation — Language modules (content) and the Laxis Engine (gameplay/UI) must be strictly separated.

#### Non-Functional (Performance, Security, Reliability)
- NFR3: Application should launch in under 3 seconds on a modern smartphone.
- NFR4: Puzzle interactions (card dragging, feedback) should be instant (<100ms).
- NFR5: All user data must be stored securely and support offline-first operation.
- NFR6: The MVP will avoid server-side components to reduce initial attack surface while enabling future sync.
- NFR7: The app should handle unexpected errors gracefully without crashing.

#### Cross-Functional
- CFR1: All user progress stored locally with a migration path for future cloud sync.
- CFR2: No external integrations required for MVP.
- CFR3: Deployment targets: Apple App Store, Google Play Store, Web.

### Out of Scope for MVP (REVISED)
- Rigid A1/A2 level selection as a primary progression mechanism (replaced by Decks).
- Advanced micro-games beyond the core set (post-MVP).
- Full A2 content (post-MVP).
- Social features, monetization, and complex audio features (post-MVP).

### User Interface Design Goals
- UX must feel like an intellectual puzzle game with low cognitive load.
- Primary interaction: drag-and-drop card-based Sentence Builder.
- Accessibility target: WCAG AA.
- Core screens:
  - Library (Curated + User-Created Decks)
  - Deck Learn Hub (micro-games)
  - Sentence Builder (Apply)
  - Global Review / SRS
  - Deck Editor / Importer
- Branding: Modern, engaging, supportive visuals that highlight progress and mastery.

### Proposed Solution (COMPLETELY OVERHAULED)

Laxis guides users through a structured "Learn > Apply > Master" loop.

1. The Deck is Central
   - A Deck is a collection of related vocabulary/grammar cards.
   - Curated Decks: Provided by Laxis (e.g., "A1 German: Food & Dining").
   - User-Created Decks: Users can create decks from scratch, import via CSV/clipboard, or paste content from services like Quizlet. This is a core feature.

2. The "Learn" Phase: Multi-Mode Mastery
   - For any Deck, the user enters the Learn Hub which contains micro-games:
     - Flashcards: Primary exposure and SRS-driven learning.
     - Quiz/Match: Quick recall (word↔image, word↔translation).
     - Connections (post-MVP): Sorting words into categories (post-MVP).
   - The Learn Hub records per-card proficiency and feeds results to the global SRS.

3. The "Apply" Phase: Contextual Sentence Builder
   - After achieving a proficiency threshold on a Deck, the Sentence Builder unlocks for that Deck.
   - Quests and puzzles will dynamically use words from the studied Deck to create contextual sentence-building challenges.

4. The "Master" Phase: Global Review Engine (SRS)
   - Every card is integrated into a global Review Mode powered by SRS to ensure long-term retention.

### MVP Scope (COMPLETELY OVERHAULED)

Goal: Deliver a complete "Learn > Apply > Master" loop validating curated content and user-created deck features.

In Scope (Must-Haves):
- Core Feature: Deck Management
  - Library screen showing Curated and User-Created Decks.
  - Create new empty deck.
  - Add/Edit Card UI (fields: Word, Translation, Notes, optional Image/Audio).
  - CSV/Quizlet Paste Import: parse tab/comma-separated text into cards.

- The Learn Hub
  - Must include Flashcards (SRS).
  - Must include one additional micro-game: Quick Match (Quiz).

- The Sentence Builder
  - Core puzzle mechanic dynamically populated from learned Deck vocabulary.

- Global Review Mode (SRS)
  - Unified review queue for all cards from all decks.

- Launch Content
  - At least 3–4 curated German A1 starter decks.

Out of Scope (MVP):
- Re-introducing rigid A1/A2 track gating.
- Additional micro-games like Connections (post-MVP).
- Full A2 content.

### Epics & Stories (COMPLETELY RESTRUCTURED)

Epic 1: The Laxis Core & Deck Management
- User Value: I can organize my learning by creating and managing my own Decks.
- Stories:
  - Setup project foundation.
  - Build the Library screen UI.
  - Implement "Create New Deck".
  - Implement "Add/Edit Card" UI.
  - Implement CSV/Quizlet Paste-to-Import feature.

Epic 2: The "Learn" & "Master" Loop (SRS)
- User Value: I can effectively memorize words using smart flashcards and quizzes.
- Stories:
  - Build the Learn Hub UI for a selected Deck.
  - Implement the Flashcard Micro-Game with SRS logic.
  - Implement the Quick Match Micro-Game.
  - Implement the global Review Mode screen.
  - Integrate all learned cards into the global SRS queue.

Epic 3: The "Apply" Loop & Curated Content
- User Value: I can practice words in real sentences immediately after learning them.
- Stories:
  - Build the Sentence Builder UI (mat, cards).
  - Implement logic to dynamically generate Sentence Builder puzzles from a specific Deck.
  - Create and load initial 3–4 curated German A1 Decks.
  - Implement the locking/unlocking mechanism: proficiency in Learn mode unlocks Apply for that Deck.

### Technical Assumptions (RECONFIRMED)
- Monorepo structure with Flutter/Dart codebase.
- Modular engine with strict separation from language content modules.
- Unit and integration tests required.
- Offline-first local storage with future sync capability.

### Checklist Results Summary (UPDATED)
- PRD completeness: High (reflects strategic pivot).
- MVP scope: Focused on Deck-based loop and user-created content.
- Readiness for architecture phase: Ready — recommend immediate work on data models for Decks, SRS integration, and the import parser.

### Next Steps
- UX: Design the Learn Hub flows and micro-game wireframes.
- Architecture: Define Deck data model, SRS schema, and import parser spec.
- Implementation: Begin Epic 1 with Library and Deck Editor, followed by Flashcards (SRS).

This document replaces the previous PRD and centers Laxis on user-created Decks and a dedicated Learn hub to create a cohesive, user-centric "Learn > Apply > Master" product.