import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

struct CharacterLocationTests {
  @Test func testInitializer() {
    let name = "Earth"
    let url = URL(string: "https://rickandmortyapi.com/location/1")!
    let location = CharacterLocation(name: name, url: url)
    #expect(location.name == name)
    #expect(location.url == url)
  }
}
