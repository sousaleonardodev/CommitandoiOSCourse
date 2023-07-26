//

import Foundation

class NetworkClient {
	static var shared: NetworkClient = NetworkClient()

	func request(from url: URL) {}
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
