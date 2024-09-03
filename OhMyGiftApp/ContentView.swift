//
//  ContentView.swift
//  OhMyGiftApp
//
//  Created by 吴金泳 on 18/07/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
       // AppMainView()
        LogInView(didCompleteLoginProcess: {})
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
