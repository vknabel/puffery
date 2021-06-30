# Puffery

An iOS App written in SwiftUI to send push notifications fueled by Siri Shortcuts.

You can follow other's channels and directly receive updates.
There is no algorithm deciding wether you should receive notifications or not.

![](./assets/Sceenshot-iPhoneX.png)

[![Download on the App Store](./assets/Download_on_the_App_Store_Badge.svg)](https://apps.apple.com/de/app/puffery/id1508776889)

[Join the public beta on TestFlight](https://testflight.apple.com/join/066lEjQN).

Do you want to stay up to date with Puffery-dev-builds? [There is a channel for that!](puffery://puffery.app/channels/subscribe/70D2A779-2829-4DD0-93BC-C695E5E1EBE7)

Do you need inspiration or help? Head over to [our GitHub discussions](https://github.com/vknabel/puffery/discussions)!

## Server-Configuration

| env                           | Description                                           | Default                                                                  |
| ----------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------ |
| `DATABASE_URL`                | Connection string for SQL Database.                   | `postgres://vapor_username:vapor_password@localhost:5432/vapor_database` |
| `REDIS_URL`                   | Connection string for Queues.                         | `redis://localhost:6379`                                                 |
| `PUFFERY_IN_PROCESS_JOBS`     | Runs jobs inside the server.                          | `false`                                                                  |
| `APNS_KEY_ID`                 | Key ID for Auth Key.                                  | Only required for push notifications                                     |
| `APNS_TEAM_ID`                | Team ID for Auth Key.                                 | Only required for push notifications                                     |
| `APNS_KEY_PATH`               | Path to private auth key for APNS.                    | `private/AuthKey_$APNS_KEY_ID.p8`                                        |
| `APNS_ENVIRONMENT`            | Path to private auth key for APNS.                    | `production`                                                             |
| `SENDGRID_API_KEY`            | API Key for sending emails.                           | Only required for emails                                                 |
| `PUFFERY_STATISTICS_CHANNELS` | Comma separated list of notify keys to receive stats. | `[]`                                                                     |

## Run Server

```bash
$ cd PufferyServer
$ swift run puffery serve --hostname 0.0.0.0 --auto-migrate
```

To access your server from the mobile app add `127.0.0.1 local.puffery.app` to `/etc/hosts` and select the `Puffery (Local)` scheme.

## API-Routes

```
$ cd PufferyServer && swift run puffery routes
+--------+----------------------------------------------+
| GET    | /                                            |
+--------+----------------------------------------------+
| GET    | /hello                                       |
+--------+----------------------------------------------+
| POST   | /api/v1/register                             |
+--------+----------------------------------------------+
| POST   | /api/v1/login                                |
+--------+----------------------------------------------+
| POST   | /api/v1/confirmations/login/:confirmation_id |
+--------+----------------------------------------------+
| POST   | /api/v1/confirmations/email/:confirmation_id |
+--------+----------------------------------------------+
| GET    | /api/v1/profile                              |
+--------+----------------------------------------------+
| PUT    | /api/v1/profile                              |
+--------+----------------------------------------------+
| POST   | /api/v1/devices                              |
+--------+----------------------------------------------+
| PUT    | /api/v1/devices/:device_token                |
+--------+----------------------------------------------+
| POST   | /api/v1/channels                             |
+--------+----------------------------------------------+
| GET    | /api/v1/channels/:subscription_id            |
+--------+----------------------------------------------+
| POST   | /api/v1/channels/:subscription_id            |
+--------+----------------------------------------------+
| DELETE | /api/v1/channels/:subscription_id            |
+--------+----------------------------------------------+
| GET    | /api/v1/channels                             |
+--------+----------------------------------------------+
| GET    | /api/v1/channels/shared                      |
+--------+----------------------------------------------+
| GET    | /api/v1/channels/own                         |
+--------+----------------------------------------------+
| POST   | /api/v1/notify-inbound-email                 |
+--------+----------------------------------------------+
| POST   | /api/v1/notify/:notify_key                   |
+--------+----------------------------------------------+
| POST   | /notify/:notify_key                          |
+--------+----------------------------------------------+
| GET    | /api/v1/channels/messages                    |
+--------+----------------------------------------------+
| GET    | /api/v1/channels/:subscription_id/messages   |
+--------+----------------------------------------------+
| POST   | /api/v1/channels/:subscription_id/messages   |
+--------+----------------------------------------------+
| POST   | /api/v1/channels/subscribe                   |
+--------+----------------------------------------------+
```

## License

Puffery is available under the [MIT](./LICENSE) license.
