//
//  AcknowledgementsPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct AcknowledgementsPage: View {
    var assets: [FlaticonAsset]
    var licenses: [License]

    var body: some View {
        List {
            Section(header: Text("Acknowledgements.Assets.SectionHeader")) {
                ForEach(assets) { asset in
                    NavigationLink(destination: FlaticonAssetPage(asset: asset)) {
                        HStack {
                            Image(asset.assetName)

                            VStack(alignment: .leading) {
                                Text(asset.name)
                                Text("Acknowledgements.Assets.InlineByAuthor \(asset.author)")
                                    .font(.footnote)
                            }
                        }
                    }
                }
            }.show(when: !assets.isEmpty)

            Section(header: Text("Acknowledgements.Code.SectionHeader")) {
                ForEach(licenses) { license in
                    NavigationLink(destination: LicensePage(license: license)) {
                        Text(license.name)
                    }
                }
            }.show(when: !licenses.isEmpty)
        }.roundedListStyle()
            .navigationBarTitle("Acknowledgements.Title", displayMode: .inline)
            .onAppear { Current.tracker.record("acknowledgements") }
    }

    func openAssetDetails(_ asset: FlaticonAsset) {
        UIApplication.shared.open(asset.source)
    }
}

extension AcknowledgementsPage {
    init() {
        assets = FlaticonAsset.assets
        licenses = License.licenses
    }
}

struct LicensePage: View {
    var license: License

    var body: some View {
        VStack {
            ScrollView {
                Text(license.licenseText)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                    .padding()
                Spacer()
            }
        }
        .navigationBarItems(trailing: Button(action: openLicense) {
            Image(systemName: "safari").padding()
            })
        .navigationBarTitle("\(license.name)", displayMode: .inline)
        .onAppear { Current.tracker.record("acknowledgements/licenses/\(self.license.id)") }
    }

    func openLicense() {
        UIApplication.shared.open(license.source)
    }
}

struct FlaticonAssetPage: View {
    var asset: FlaticonAsset

    var body: some View {
        VStack {
            Image(asset.assetName)
            Text("Acknowledgements.Assets.ByAuthor \(asset.author)").navigationBarItems(trailing: Button(action: openLicense) {
                Image(systemName: "safari").padding()
            })
        }
        .navigationBarTitle("\(asset.name)", displayMode: .inline)
        .onAppear { Current.tracker.record("acknowledgements/assets/\(self.asset.id)") }
    }

    func openLicense() {
        UIApplication.shared.open(asset.source)
    }
}

#if DEBUG
    struct AcknowledgementsPage_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                AcknowledgementsPage()
            }
        }
    }
#endif
