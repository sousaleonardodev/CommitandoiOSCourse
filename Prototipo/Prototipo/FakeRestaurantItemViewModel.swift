//

import Foundation

struct RestaurantItemViewModel {
	let title: String
	let location: String
	let distance: String
	let parasols: String
	let rating: Int
}

extension RestaurantItemViewModel {
	static var dataModel: [RestaurantItemViewModel] {
		[
			.init(title: "Barraquinha do seu Zé", location: "Canto do Forte - Praia Grande", distance: "Distancia: 60m", parasols: "Guarda sol(#2)", rating: 4),
			.init(title: "Barraquinha do coronel", location: "Canto do Forte - Praia Grande", distance: "Distancia: 150m", parasols: "Guarda sol(#3)", rating: 3),
			.init(title: "Tenda dos soldados", location: "Canto do Forte - Praia Grande", distance: "Distância: 200m", parasols: "Guarda sol(#4)", rating: 4)
		]
	}
}
