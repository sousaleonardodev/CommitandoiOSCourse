//

import Foundation
import XCTest
@testable import RestaurantDomain

final class NetworkServiceTests: XCTestCase {
	func testRequestAndCreateDataTaskWithURL() throws {
		let url = try XCTUnwrap(URL(string: "https://comitando.com.br"))
		let session = URLSessionSpy()
		let sut =  NetworkService(session: session)

		sut.request(from: url) { _ in }

		XCTAssertNotNil(session.urlRequest)
	}
}


final class URLSessionSpy: URLSession {
	private(set) var urlRequest: URL?

	override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		urlRequest = url
		return URLSessionDataTask()
	}
}
