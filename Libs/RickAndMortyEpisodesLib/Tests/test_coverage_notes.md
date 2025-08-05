# Test Coverage Notes

This is a document for accumulating notes.
It will be used as an input to make a plan test coverage improvements.

## Patterns Notes

## Notes Per `*.tests.swift` File
*Add raw note about each file.**

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
*Add raw note about each file. Make sure you note missing tests or poor testability**

### `tbd.feature.swift`
This is a placeholder

## Improvement Ideas

*Add all raw improvement ideas below. Including known gaps and risks*

- TBD
