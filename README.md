# Puffery Serverside Swift Concept

## Configuration

| env             | Description                    | Default                                                                  |
| --------------- | ------------------------------ | ------------------------------------------------------------------------ |
| `DATABASE_URL`  | Connection string for Database | `postgres://vapor_username:vapor_password@localhost:5432/vapor_database` |
| `APNS_KEY_ID`   | Key ID for Auth Key.           | Required                                                                 |
| `APNS_TEAM_ID`  | Team ID for Auth Key.          | Required                                                                 |
| `APNS_KEY_PATH` | The private auth key for APNS. | `private/AuthKey_$APNS_KEY_ID.p8`                                        |
