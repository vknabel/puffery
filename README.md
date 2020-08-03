# Puffery Server-side Swift

## Configuration

| env                       | Description                         | Default                                                                  |
| ------------------------- | ----------------------------------- | ------------------------------------------------------------------------ |
| `DATABASE_URL`            | Connection string for SQL Database. | `postgres://vapor_username:vapor_password@localhost:5432/vapor_database` |
| `REDIS_URL`               | Connection string for Queues.       | `redis://localhost:6379`                                                 |
| `PUFFERY_IN_PROCESS_JOBS` | Runs jobs inside the server.        | `false`                                                                  |
| `APNS_KEY_ID`             | Key ID for Auth Key.                | Only required for push notifications                                     |
| `APNS_TEAM_ID`            | Team ID for Auth Key.               | Only required for push notifications                                     |
| `APNS_KEY_PATH`           | Path to private auth key for APNS.  | `private/AuthKey_$APNS_KEY_ID.p8`                                        |
| `APNS_ENVIRONMENT`        | Path to private auth key for APNS.  | `production`                                                             |
| `SENDGRID_API_KEY`        | API Key for sending emails.         | Only required for emails                                                 |

## Run Server

```bash
$ cd PufferyServer
$ swift run puffery serve --hostname 0.0.0.0 --auto-migrate
```

To access your server from the mobile app add `127.0.0.1 local.puffery.app` to `/etc/hosts` and select the `Puffery (Local)` scheme.

## Routes

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
