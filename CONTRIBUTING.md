# Contributing

First of all: thank you for your interest in contributing to this project and open source in general.

There are many ways you could contribute to this project:

- Opening issues: most contributions start with an issue. Bug reports and feature requests are always welcome.
- Do you have troubles using the app? Let’s improve the documentation together!
- Already using Puffery? You can share your use case and eventually even some scripts!
- If you want to get your hands dirty, you could try finding a starter issue.

## Technical Overview

Puffery consists of multiple parts working together to bring you your push notifications:

- The server which actually sends out push notifications to subscribed and registered user devices. Sending and receiving emails is also part of the server.
- Next up, there obviously is the mobile app. It communicates with the server and integrates Apple‘s SDKs. There are multiple additional bundles like intents or widgets involved.
- Both, client and server share the same models within the `APIDefintion`. The goal is to force compatibility between clients, server and to detect possible breaking API changes.

Also note: this project currently is Swift Package Manager only.
You can simply open the `Puffery.xcworkspace` in Xcode or the repository folder in VS Code to get started.

## Server

The server is written in Vapor 4, the sources are located at [PufferyServer](./PufferyServer) and loosely conform to most applicable parts of the [Vapor Style Guide](https://docs.vapor.codes/3.0/extras/style-guide/) (written for Vapor 3). Also the [Vapor 4 docs](https://docs.vapor.codes/4.0/) make some recommendations which should be considered.

But after all: it is a small project, created in my free time. The code should be testable, but isn’t required to be perfect. Some shortcuts (pun not intended) are acceptable.

## Puffery App

The app itself consists of multiple modules and targets:

- [`Puffery`](./Puffery) which is the iOS app itself containing assets and the app delegate. The stuff in here is specific to `UIKit`. For new targets like macOS or watchOS, a new target is required.
- With the [`PufferyKit`](./PufferyKit) SwiftPM project things get more interesting. It contains most relevant modules regarding data model and UI. As of now it contains `UIKit`-specific code, which will be replaced or shimmed in the future (hello macOS and watchOS).
- Another interesting target is `Puffery Intents` which powers Siri Shortcuts and Widget configuration.
- Last but not least `PufferyWidget` which, you nailed it, implements iOS 14‘s new SwiftUI widgets.

## Testing

The code coverage isn’t at the level it should be, but most roadblocks have been solved.

To run tests, the server requires working postgres and redis databases. If you have [Docker](https://www.docker.com/) and [Archery](https://github.com/vknabel/Archery) installed, running `archery test-server` will set up the databases, run the actual tests and will then tear them down again.

If you wish to run the tests in Xcode, run `archery test-setup` to start the database and redis in docker containers and select the `AppTests` target. In case your database credentials or urls differ, set `DATABASE_URL` accordingly `REDIS_URL`.
