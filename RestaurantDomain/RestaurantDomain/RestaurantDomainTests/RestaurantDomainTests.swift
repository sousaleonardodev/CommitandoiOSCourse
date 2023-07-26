//

import XCTest
@testable import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {

	func testInitializerRestaurantLoaderAndValidateURLRequest() {
		let requestURL = URL(string: "https://comintando.com.br")!
		let sut = RemoteRestaurantLoader(url: requestURL)

		let client = NetworkClientSpy()
		NetworkClient.shared = client
		
		sut.load()

		XCTAssertNotNil(client.urlRequest)
	}
}

final class NetworkClientSpy: NetworkClient {
	private(set) var urlRequest: URL?

	override func request(from url: URL) {
		urlRequest = url
	}
}
