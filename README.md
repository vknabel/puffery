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
+------+---------------------------------------+
| GET  | /                                     |
+------+---------------------------------------+
| GET  | /hello                                |
+------+---------------------------------------+
| POST | /register                             |
+------+---------------------------------------+
| POST | /login                                |
+------+---------------------------------------+
| POST | /confirmations/login/:confirmation_id |
+------+---------------------------------------+
| POST | /confirmations/email/:confirmation_id |
+------+---------------------------------------+
| GET  | /profile                              |
+------+---------------------------------------+
| PUT  | /profile                              |
+------+---------------------------------------+
| POST | /devices                              |
+------+---------------------------------------+
| PUT  | /devices/:device_token                |
+------+---------------------------------------+
| POST | /channels                             |
+------+---------------------------------------+
| GET  | /channels                             |
+------+---------------------------------------+
| GET  | /channels/shared                      |
+------+---------------------------------------+
| GET  | /channels/own                         |
+------+---------------------------------------+
| POST | /notify/inbound-email                 |
+------+---------------------------------------+
| POST | /notify/:notify_key                   |
+------+---------------------------------------+
| GET  | /channels/messages                    |
+------+---------------------------------------+
| GET  | /channels/:subscription_id/messages   |
+------+---------------------------------------+
| POST | /channels/:subscription_id/messages   |
+------+---------------------------------------+
| POST | /channels/subscribe                   |
+------+---------------------------------------+
```
