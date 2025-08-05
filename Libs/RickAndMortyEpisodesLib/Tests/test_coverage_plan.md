
# Test Coverage Improvement Plan (Numbered Checklist)

> Use this numbered checklist to prompt GitHub Copilot or any AI assistant step-by-step.
> Mark each item as `[x]` when completed.
> **After performing each step, run the tests and make sure all tests are green before proceeding to the next item.**

---

## Character.tests.swift
1. [ ] Add decoding failure test to `Character`
2. [ ] Add test for invalid URL in `Character`
3. [ ] Add property-based/fuzz test for `Character`
4. [ ] Add test for `CharacterLocation` initializer
5. [ ] Add basic test for static `.dummy` property of `Character`

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
