//
//  AcknowledgementsPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI
import AckeeTracker

struct AcknowledgementsPage: View {
    var assets: [FlaticonAsset]
    var licenses: [License]

    var body: some View {
        List {
            //Asset Section
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

            //Code Section
            Section(header: Text("Acknowledgements.Code.SectionHeader")) {
                ForEach(licenses) { license in
                    NavigationLink(destination: LicensePage(license: license)) {
                        Text(license.name)
                    }
                }
            }.show(when: !licenses.isEmpty)
            
            
            //Source Code Section
            Section {
                Link(destination: URL(string: "https://github.com/vknabel/puffery#readme")!) {
                    HStack{
                        Image(systemName: "link")
                        Text("Git Repository")
                    }
                }
            } header: {
                Text("SOURCE CODE")
            }

        }.roundedListStyle()
            .navigationBarTitle("Acknowledgements.Title", displayMode: .inline)
        .record("acknowledgements")
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
        .record("acknowledgements/license/\(license.name)")
    }

    func openLicense() {
        ackeeTracker.action(.external, key: license.name)
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
        .record("acknowledgements/asset/\(asset.name)")
    }

    func openLicense() {
        ackeeTracker.action(.external, key: asset.name)
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
