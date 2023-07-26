//

import Foundation

final class NetworkClient {
	static let shared: NetworkClient = NetworkClient()
	
	private init() {}
	private(set) var urlRequest: URL?
	
	func request(from url: URL) {
		urlRequest = url
	}
}

final class RemoteRestaurantLoader {
	let url: URL
	
	init(url: URL) {
		self.url = url
	}
	
	func load() {
		NetworkClient.shared.request(from: url)
	}
}
