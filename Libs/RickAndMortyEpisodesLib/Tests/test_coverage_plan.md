
# Test Coverage Improvement Plan (Numbered Checklist)

> Use this numbered checklist to prompt GitHub Copilot or any AI assistant step-by-step.
> Mark each item as `[x]` when completed.
> **After performing each step, run the tests and make sure all tests are green before proceeding to the next item.**
> `./test.py RickAndMortyEpisodesLibTests`
> for running "CharacterDomainModel_Codable_conformance" test
> for "RickAndMortyEpisodesLibTests" target


---

## Character.tests.swift
1. [x] Add decoding failure test to `Character`
2. [x] Add test for invalid URL in `Character`
3. [x] Add property-based/fuzz test for `Character`
4. [x] Add test for `CharacterLocation` initializer
5. [x] Add basic test for static `.dummy` property of `Character`

### Refactoring 1: Test Code Conciseness and Maintainability Plan

5.1. [ ] Move all repeating arrays and constants (e.g., validNames, validStatuses, validSpecies, validGenders, validURLs, validImageURLs, validEpisodeURLs, validDates) from test files into `TestUtils.swift` as static properties.
5.2. [ ] Reference these arrays and constants via `TestUtils` in all relevant tests to avoid duplication.
5.3. [ ] Use parameterized tests (supported by swift-testing) for fuzzing and decoding scenarios, leveraging the shared arrays for input data.
5.4. [ ] Keep equality assertions simple and direct (e.g., `#expect(a == b)`), without unnecessary abstraction.
5.5. [ ] Extract any repeated JSON construction or decoding logic into helper methods in `TestUtils.swift` for reuse across tests.
5.6. [ ] After each refactoring step, run all tests to ensure they remain green.

## CharacterSpecies.tests.swift
6. [ ] Add decoding failure test for invalid species string
7. [ ] Add property-based/fuzz test for `CharacterSpecies`

## CharacterStatus.tests.swift
8. [ ] Add decoding failure test for invalid status string
9. [ ] Add property-based/fuzz test for `CharacterStatus`

## Endpoints.tests.swift
10. [ ] Add decoding failure test for `Endpoint`
11. [ ] Add test for invalid URLs in `Endpoint`
12. [ ] Add property-based/fuzz test for `Endpoint`

## Episode.tests.swift
13. [ ] Add decoding failure test for `Episode`
14. [ ] Add test for invalid URL in `Episode`
15. [ ] Add property-based/fuzz test for `Episode`
16. [ ] Add basic test for static `.dummy` property of `Episode`

## EpisodeList.tests.swift
17. [ ] Add edge case tests for air date formatting
18. [ ] Add property-based/fuzz test for date parsing

## Location.tests.swift
19. [ ] Add decoding failure test for `Location`
20. [ ] Add test for invalid URL in `Location`
21. [ ] Add property-based/fuzz test for `Location`

## ResponsePage.entity.swift → ResponsePage.tests.swift (new file)
22. [ ] Add Codable test for `ResponsePage`
23. [ ] Add Equatable test for `ResponsePage`
24. [ ] Add edge case decoding tests (invalid/missing URLs, empty results)
25. [ ] Add tests for cache logic in `ResponsePageContainer`
26. [ ] Add date handling test in `ResponsePageContainer`
27. [ ] Add property-based/fuzz test for pagination scenarios

---

## Constraints & Clarifications

- Use only `swift-testing` (no other test libraries).
- Use bundled JSON fixtures where applicable.
- Do not deeply test `.dummy` or `.preview`; just ensure they load and expose basic fields.
- Only test one decoding failure scenario per model (e.g. completely invalid JSON).
- Focus on critical logic paths over exhaustive coverage.
- UI/snapshot tests are explicitly out of scope.

---

## Tracking

- [ ] All checklist items completed
- [ ] All new tests passing
- [ ] Code coverage report updated
