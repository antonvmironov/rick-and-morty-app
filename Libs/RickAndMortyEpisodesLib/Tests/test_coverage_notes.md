# Test Coverage Notes

This is a document for accumulating notes.
It will be used as an input to make a plan for test coverage improvements.

## Patterns Notes

## Notes Per `*.tests.swift` File
*Add raw note about each file.*

### `NetworkGateway.tests.swift`
Contains extension for `MockNetworkGateway` to simplify expectation setup for network requests using local JSON fixtures.
Uses `expect(requestURL:statusCode:jsonFixtureNamed:)` to load test data from bundled fixtures and verify network responses.
Focuses on mocking network layer and verifying correct data loading for endpoints.
Relies on presence of JSON fixtures in test bundle for coverage.

### `Character.tests.swift`
Covers Codable and Equatable conformance for `CharacterDomainModel` and `CharacterLocation`.
Verifies decoding of character fixture JSON and checks all key properties for correctness.
Uses test constants and bundled JSON fixtures for robust coverage of model serialization and equality logic.

### `CharacterSpecies.tests.swift`
Covers ExpressibleByStringLiteral, static values, Codable, and Equatable conformance for `CharacterSpecies`.
Verifies correct rawValue and description for string literals and static cases.
Tests Codable round-trip and equality logic for species values.

### `CharacterStatus.tests.swift`
Covers ExpressibleByStringLiteral, static values, Codable, and Equatable conformance for `CharacterStatus`.
Verifies correct rawValue and description for string literals and static cases.
Tests Codable round-trip and equality logic for status values.

### `Endpoints.tests.swift`
Covers initialization and Codable conformance for `EndpointsDomainModel`.
Verifies correct assignment of endpoint URLs for characters, locations, and episodes.
Tests equality and Codable round-trip for the model.

### `Episode.tests.swift`
Covers Codable and Equatable conformance for `EpisodeDomainModel`.
Verifies decoding of episode fixture JSON and checks all key properties for correctness.
Uses test constants and bundled JSON fixtures for robust coverage of model serialization and equality logic.
Tests include:
- Codable round-trip for model
- Equatable checks for identical and different models
- Decoding from episode_pilot.json fixture and property validation
Relies on presence of JSON fixtures in test bundle for coverage.

### `EpisodeList.tests.swift`
Tests formatting logic for episode air dates via `BaseEpisodeFeature.formatAirDate`.
Verifies that air date strings are correctly transformed to the expected format (e.g., "02/12/2013").
Uses a sample `EpisodeDomainModel` instance to validate formatting output.
Focuses on presentation logic for episode list features.

### `Location.tests.swift`
Covers Codable and Equatable conformance for `LocationDomainModel`.
Verifies decoding of location fixture JSON and checks all key properties for correctness.
Uses test constants and bundled JSON fixtures for robust coverage of model serialization and equality logic.
Tests include:
- Codable round-trip for model
- Equatable checks for identical and different models
- Decoding from location_earth1.json fixture and property validation
Relies on presence of JSON fixtures in test bundle for coverage.

## Notes Per Production Code File
*Add raw note about each file. Make sure you note missing tests or poor testability*

### `Character.entity.swift`
Defines the domain model for Rick and Morty characters (`CharacterDomainModel`) and a helper struct for location (`CharacterLocation`).
Model includes Codable, Equatable, Identifiable, and Sendable conformances. Contains a static dummy instance for testing.

Test coverage:
- Codable and Equatable logic is covered in `Character.tests.swift` (see above)
- Decoding from JSON fixtures and property validation is tested
- Equality and serialization logic is robustly covered

Missing tests / risks:
- No direct tests for the static `dummy` property (relies on asset catalog and Transformers)
- No explicit tests for error cases (e.g., decoding failures, invalid URLs)
- No property-based or fuzz tests for edge cases
- No direct tests for `CharacterLocation` initializers (only Codable logic tested)

### `CharacterSpecies.swift`
Defines the model for character species in the Rick and Morty domain. Implements `StringRepresentable` and provides static constants for common species.

Test coverage:
- Covered by `CharacterSpecies.tests.swift` (see above)
- Tests include: ExpressibleByStringLiteral, static values, Codable, and Equatable conformance
- Verifies correct `rawValue` and description for string literals and static cases
- Tests Codable round-trip and equality logic for species values

Missing tests / risks:
- No explicit tests for error cases (e.g., invalid species strings, decoding failures)
- No property-based or fuzz tests for edge cases

### `CharacterStatus.swift`
Defines the model for character status in the Rick and Morty domain. Implements `StringRepresentable` and provides static constants for common statuses (`alive`, `dead`, `unknown`).

Test coverage:
- Covered by `CharacterStatus.tests.swift` (see above)
- Tests include: ExpressibleByStringLiteral, static values, Codable, and Equatable conformance
- Verifies correct `rawValue` and description for string literals and static cases
- Tests Codable round-trip and equality logic for status values

Missing tests / risks:
- No explicit tests for error cases (e.g., invalid status strings, decoding failures)
- No property-based or fuzz tests for edge cases

### `Endpoints.entity.swift`
Defines the domain model for API endpoints in the Rick and Morty domain (`EndpointsDomainModel`).
Model includes `Sendable`, `Codable`, and `Equatable` conformances. Contains a static `mock` instance for testing.

Test coverage:
- Covered by `Endpoints.tests.swift` (see above)
- Tests include: initialization, Codable conformance, correct assignment of endpoint URLs, equality, and Codable round-trip for the model

Missing tests / risks:
- No explicit tests for error cases (e.g., decoding failures, invalid URLs)
- No property-based or fuzz tests for edge cases

### `Episode.entity.swift`
Defines the domain model for Rick and Morty episodes (`EpisodeDomainModel`).
Model includes Codable, Equatable, Identifiable, and Sendable conformances. Contains a static dummy instance for testing, loaded via asset catalog and Transformers.

Test coverage:
- Covered by `Episode.tests.swift` (see above)
- Tests include: Codable round-trip for model, Equatable checks for identical and different models, decoding from episode_pilot.json fixture and property validation
- Uses test constants and bundled JSON fixtures for robust coverage of model serialization and equality logic

Missing tests / risks:
- No direct tests for the static `dummy` property (relies on asset catalog and Transformers)
- No explicit tests for error cases (e.g., decoding failures, invalid URLs)
- No property-based or fuzz tests for edge cases

### `Location.entity.swift`
Defines the domain model for Rick and Morty locations (`LocationDomainModel`).
Model includes Codable, Equatable, Identifiable, and Sendable conformances.

Test coverage:
- Covered by `Location.tests.swift` (see above)
- Tests include: Codable round-trip for model, Equatable checks for identical and different models, decoding from location_earth1.json fixture and property validation
- Uses test constants and bundled JSON fixtures for robust coverage of model serialization and equality logic

Missing tests / risks:
- No explicit tests for error cases (e.g., decoding failures, invalid URLs)
- No property-based or fuzz tests for edge cases

### `ResponsePage.entity.swift`
Defines generic models for paginated API responses:
- `ResponsePagePayload<Element>`: Contains page info and an array of results.
- `ResponsePageInfo`: Holds pagination metadata (count, pages, next/prev URLs).
- `ResponsePageContainer<Element>`: Wraps payload, cache timestamp, and page URL.
All types conform to `Sendable`, `Codable`, and `Equatable` for safe concurrency, serialization, and equality checks.

Test coverage:
- No direct unit tests found for these types.
- Codable and Equatable logic is not explicitly tested.
- No coverage for edge cases (e.g., decoding failures, invalid URLs, empty results).

Missing tests / risks:
- No property-based or fuzz tests for edge cases.
- No explicit tests for error cases (e.g., decoding failures, invalid/missing URLs).
- No tests for cache logic or date handling in `ResponsePageContainer`.

---