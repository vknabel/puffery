//
//  AcknowledgementsPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct License: Identifiable, Codable {
    var id: String { name }
    
    var name: String
    var source: URL
    var licenseText: String
}

struct FlaticonAsset: Identifiable, Codable {
    var id: String { name }
    
    var name: String
    var author: String
    var source: URL
}

struct AcknowledgementsPage: View {
    var assets: [FlaticonAsset]
    var licenses: [License]
    
    var body: some View {
        List {
            Section(header: Text("Assets")) {
                ForEach(assets) { asset in
                    NavigationLink(destination: FlaticonAssetPage(asset: asset)) {
                        HStack {
                            Image(asset.name)
                            
                            VStack(alignment: .leading) {
                                Text(asset.name)
                                Text("made by \(asset.author) from www.flaticon.com")
                                    .font(.footnote)
                            }
                        }
                    }
                }
            }.show(when: !assets.isEmpty)
            
            Section(header: Text("Code")) {
                ForEach(licenses) { license in
                    NavigationLink(destination: LicensePage(license: license)) {
                        Text(license.name)
                    }
                }
            }.show(when: !licenses.isEmpty)
        }.roundedListStyle()
        .navigationBarTitle("Acknowledgements", displayMode: .inline)
    }
    
    func openAssetDetails(_ asset: FlaticonAsset) {
        UIApplication.shared.open(asset.source)
    }
}

extension AcknowledgementsPage {
    init() {
        assets = [
            FlaticonAsset(name: "Kugelfisch", author: "Freepik", source: URL(string: "https://www.flaticon.com/de/kostenloses-icon/kugelfisch_774951")!),
        ]
        licenses = []
    }
}

struct LicensePage: View {
    var license: License
    
    var body: some View {
        VStack {
            Text(license.licenseText)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            Spacer()
        }
            .navigationBarItems(trailing: Button(action: openLicense) {
                Image(systemName: "safari")
            })
            .navigationBarTitle("\(license.name)", displayMode: .inline)
    }
    
    func openLicense() {
        UIApplication.shared.open(license.source)
    }
}

struct FlaticonAssetPage: View {
    var asset: FlaticonAsset
    
    var body: some View {
        VStack {
            Image(asset.name)
            Text("Icon made by Freepik from www.flaticon.com").navigationBarItems(trailing: Button(action: openLicense) {
                Image(systemName: "safari")
            })
        }
            .navigationBarTitle("\(asset.name)", displayMode: .inline)
    }
    
    func openLicense() {
        UIApplication.shared.open(asset.source)
    }
}

struct AcknowledgementsPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AcknowledgementsPage(
                assets: [
                    FlaticonAsset(name: "Kugelfisch", author: "Freepik", source: URL(string: "https://www.flaticon.com/de/kostenloses-icon/kugelfisch_774951")!),
                ],
                licenses: [
                    License(name: "AckeeTracker-Swift", source: URL(string: "https://github.com/vknabel/AckeeTracker-Swift")!, licenseText: "MIT"),
                ]
            )
        }
    }
}
