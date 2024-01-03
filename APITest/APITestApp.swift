//
//  APITestApp.swift
//  APITest
//
//  Created by Juan Olivera on 20/12/23.
//

import SwiftUI

@main
struct APITestApp: App {
    var body: some Scene {
        WindowGroup {
          ContentView(viewModel: SearchViewModel())
        }
    }
}
