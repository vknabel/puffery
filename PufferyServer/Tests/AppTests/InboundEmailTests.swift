import APIDefinition
import Foundation
import XCTVapor

@testable import App

let jsonExampleEmail = """
  {
    "headers": "Received: by mx0040p1mdw1.sendgrid.net with SMTP id lIspyF7Ecb Mon, 03 Aug 2020 19:45:18 +0000 (UTC)\nReceived: from MTA-05-4.privateemail.com (mta-05.privateemail.com [198.54.127.60]) by mx0040p1mdw1.sendgrid.net (Postfix) with ESMTPS id 099BDAC056F for <x@notify.puffery.app>; Mon,  3 Aug 2020 19:45:18 +0000 (UTC)\nReceived: from MTA-05.privateemail.com (localhost [127.0.0.1]) by MTA-05.privateemail.com (Postfix) with ESMTP id DAB836004B for <x@notify.puffery.app>; Mon,  3 Aug 2020 15:45:16 -0400 (EDT)\nReceived: from [10.0.0.44] (unknown [10.20.151.231]) by MTA-05.privateemail.com (Postfix) with ESMTPA id 6F1F36004A for <x@notify.puffery.app>; Mon,  3 Aug 2020 19:45:16 +0000 (UTC)\nFrom: Valentin Knabel <dev@vknabel.com>\nContent-Type: text/plain; charset=us-ascii\nContent-Transfer-Encoding: 7bit\nMime-Version: 1.0 (Mac OS X Mail 13.4 \\(3608.120.23.2.1\\))\nSubject: X2\nMessage-Id: <6622F045-EE39-4605-8998-145A8098399E@vknabel.com>\nDate: Mon, 3 Aug 2020 21:45:14 +0200\nTo: x@notify.puffery.app\nX-Mailer: Apple Mail (2.3608.120.23.2.1)\nX-Virus-Scanned: ClamAV using ClamSMTP\n",
    "dkim": "none",
    "to": "x@notify.puffery.app",
    "from": "Valentin Knabel <example@mock.com>",
    "text": "X2\n",
    "sender_ip": "198.54.127.60",
    "envelope": { "to": ["x@notify.puffery.app"], "from": "example@mock.com" },
    "attachments": 0,
    "subject": "X2",
    "charsets": {
      "to": "UTF-8",
      "subject": "UTF-8",
      "from": "UTF-8",
      "text": "us-ascii"
    },
    "SPF": "pass"
  }
  """

final class InboundEmailTests: PufferyTestCase {
  func testInboundEmailChannelNotFound() throws {
    let email = InboundEmail(
      envelope: InboundEmail.Envelope(
        from: "noreply@mock.com", to: ["your-notify-key@notify.puffery.app"]),
      subject: "Mockingmail",
      text: "String"
    )
    try app.testInboundEmail(email) { res in
      XCTAssertEqual(res.status, .notFound)
    }
  }

  func testInboundEmailChannelFoundAndNotified() throws {
    let channel = try app.seedChannel()

    let email = InboundEmail(
      envelope: InboundEmail.Envelope(
        from: "noreply@mock.com", to: ["\(channel.notifyKey)@notify.puffery.app"]),
      subject: "Mockingmail",
      text: "String"
    )
    try app.testInboundEmail(email) { res in
      XCTAssertEqual(res.status, .ok)
      let message = try res.content.decode(NotifyMessageResponse.self)
      XCTAssertEqual(message.title, email.subject)
      XCTAssertEqual(message.body, email.text)

      XCTAssertNotNil(self.sentMessage)
      XCTAssertEqual(self.sentMessage?.id, message.id)
      XCTAssertEqual(self.sentMessage?.title, email.subject)
      XCTAssertEqual(self.sentMessage?.body, email.text)
      XCTAssertEqual(self.sentMessage?.color, message.color)
    }
  }

  func testLowercasedInboundEmailChannelFoundAndNotified() throws {
    let channel = try app.seedChannel()

    let email = InboundEmail(
      envelope: InboundEmail.Envelope(
        from: "noreply@mock.com", to: ["\(channel.notifyKey.lowercased())@notify.puffery.app"]),
      subject: "Mockingmail",
      text: "String"
    )
    try app.testInboundEmail(email) { res in
      XCTAssertEqual(res.status, .ok)
      let message = try res.content.decode(NotifyMessageResponse.self)
      XCTAssertEqual(message.title, email.subject)
      XCTAssertEqual(message.body, email.text)

      XCTAssertNotNil(self.sentMessage)
      XCTAssertEqual(self.sentMessage?.id, message.id)
      XCTAssertEqual(self.sentMessage?.title, email.subject)
      XCTAssertEqual(self.sentMessage?.body, email.text)
      XCTAssertEqual(self.sentMessage?.color, message.color)
    }
  }
}

extension Application {
  @discardableResult
  fileprivate func testInboundEmail(
    _ content: InboundEmail,
    file: StaticString = #file,
    line: UInt = #line,
    afterResponse: @escaping (XCTHTTPResponse) throws -> Void
  ) throws -> XCTApplicationTester {
    try test(
      .POST, "api/v1/notify-inbound-email",
      headers: ["Content-Type": "application/json", "Accept": "application/json"],
      file: file,
      line: line,
      beforeRequest: { req in
        try req.content.encode(content)
      },
      afterResponse: afterResponse
    )
  }
}
