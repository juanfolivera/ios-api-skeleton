//
//  ContentView.swift
//  APITest
//
//  Created by Juan Olivera on 20/12/23.
//

import SwiftUI

struct ContentView: View {
  @StateObject var viewModel = SearchViewModel()

  var body: some View {
    VStack {
      if viewModel.userResult == nil {
        ProgressView()
      } else {
        Image(systemName: "globe")
            .imageScale(.large)
            .foregroundStyle(.tint)
        Text(viewModel.userResult?.login ?? "Failed")
      }
    }
    .padding()
    .onAppear {
      viewModel.getUser()
    }
    .onDisappear() {
      viewModel.cancelTasks()
    }
  }
}

#Preview {
    ContentView(viewModel: SearchViewModel())
}
