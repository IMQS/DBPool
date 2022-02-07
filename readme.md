This is an experimental container that hosts PgBouncer.

### NO SECRETS IN HERE
### THIS IS A PUBLIC REPO

I still haven't figured out how we're going to manage DB authentication.

## TODO
* Figure out how to prevent logs from growing indefinitely - maybe can log to stdout and consume with datadog
* Figure out our DB authentication story

## Tips

To connect to pgbouncer, and get stats:

`PGPASSWORD=bounce psql -h localhost -p 6432 -U bouncer pgbouncer`

and then

`SHOW DATABASES;`

The "pgbouncer.ini" & "users.txt" can be found in the static-conf directory @ https://github.com/IMQS/static-conf
These files need to exist in DBPool when building a new Docker image.
