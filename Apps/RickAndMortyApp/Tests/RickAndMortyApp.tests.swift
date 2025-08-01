import Foundation
import Testing

@testable import RickAndMortyApp

@Test("RickAndMortyApp check prod API URL")
func RickAndMortyApp_check_prod_API_URL() {
  print(RickAndMortyApp.prodAPIURL)
}
