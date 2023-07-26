//

import XCTest
@testable import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {

	func testInitializerRestaurantLoaderAndValidateURLRequest() {
		let requestURL = URL(string: "https://comintando.com.br")!
		let client = NetworkClientSpy()

		let sut = RemoteRestaurantLoader(url: requestURL, networkClient: client)
		
		sut.load()

		XCTAssertNotNil(client.urlRequest)
	}
}

final class NetworkClientSpy: NetworkClient {
	private(set) var urlRequest: URL?

	func request(from url: URL) {
		urlRequest = url
	}
}
