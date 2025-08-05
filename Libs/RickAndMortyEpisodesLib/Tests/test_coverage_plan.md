# Test Coverage Improvement Plan

This plan is based on the analysis in `test_coverage_notes.md` and aims to systematically improve test coverage and robustness for the Rick and Morty Episodes library.

## Goals
- Increase coverage for all domain models and service layers
- Add missing tests for error cases, edge cases, and property-based scenarios
- Ensure all Codable, Equatable, and custom logic is robustly tested
- Improve testability and maintainability

---

## Checklist: Files to Update or Add Tests

### 1. Existing Test Files (Enhance Coverage)
- [ ] `Character.tests.swift`
  - Add tests for error cases (e.g., decoding failures, invalid URLs)
  - Add property-based/fuzz tests for edge cases
  - Add direct tests for `CharacterLocation` initializers
  - Add tests for static `dummy` property
- [ ] `CharacterSpecies.tests.swift`
  - Add tests for invalid species strings and decoding failures
  - Add property-based/fuzz tests for edge cases
- [ ] `CharacterStatus.tests.swift`
  - Add tests for invalid status strings and decoding failures
  - Add property-based/fuzz tests for edge cases
- [ ] `Endpoints.tests.swift`
  - Add tests for decoding failures and invalid URLs
  - Add property-based/fuzz tests for edge cases
- [ ] `Episode.tests.swift`
  - Add tests for error cases (e.g., decoding failures, invalid URLs)
  - Add property-based/fuzz tests for edge cases
  - Add direct tests for static `dummy` property
- [ ] `EpisodeList.tests.swift`
  - Add tests for edge cases in air date formatting
  - Add property-based/fuzz tests for date parsing
- [ ] `Location.tests.swift`
  - Add tests for error cases (e.g., decoding failures, invalid URLs)
  - Add property-based/fuzz tests for edge cases

### 2. Production Code Files (Missing or Poor Coverage)
- [ ] `ResponsePage.entity.swift`
  - **Add new test file:** `ResponsePage.tests.swift`
    - Test Codable and Equatable logic for all types
    - Add tests for edge cases (e.g., decoding failures, invalid/missing URLs, empty results)
    - Add tests for cache logic and date handling in `ResponsePageContainer`
    - Add property-based/fuzz tests for pagination scenarios

---

## Action Steps
1. **Review and update all test files listed above.**
2. **Create new tests for `ResponsePage.entity.swift`.**
3. **Add error case and edge case tests for all domain models.**
4. **Implement property-based/fuzz tests where applicable.**
5. **Ensure all static properties and initializers are directly tested.**
6. **Document any remaining risks or untestable code.**

---

## Notes
- Use bundled JSON fixtures for decoding tests where possible.
- Consider using Swift property-based testing libraries for fuzz tests.
- Update documentation to reflect improved coverage.

---

## Progress Tracking
- [ ] All checklist items completed
- [ ] All new tests passing
- [ ] Coverage report updated

### Clarifications and Exclusions

- Static `.dummy` and `.preview` values must be tested to ensure they load without crashing, but only a few fields (e.g., `id`, `name`) should be asserted. Do not deeply test their contents.
- `dummy`/`preview` values used only for debugging or SwiftUI previews are not considered production-relevant and should not receive full test coverage.
- Decoding failure coverage must include a basic "invalid JSON" test for each domain model, but do not exhaustively test missing fields or malformed enums.
- Code coverage percentage is not the goal; focus is on critical logic paths.
- No UI or snapshot tests are in scope.
- All tests must be implemented using `swift-testing` only. No other libraries should be introduced for property-based or unit testing.