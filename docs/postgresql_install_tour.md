---

# Install postgres & pgadmin

---

# Now the fun part

**Install PostgresQL 16 on Local**

https://www.postgresql.org/download/
https://www.enterprisedb.com/downloads/postgres-postgresql-downloads

**Windows :**
https://www.postgresqltutorial.com/postgresql-getting-started/install-postgresql/

if you run into problems write it down in the doc
https://docs.google.com/document/d/1mX9-5-PeN0QD7OwsRSvTkJ32iwHqoKC7mtHQ8Aw5Cbk/edit?usp=sharing



---

# pgAdmin

---

# Install pgAdmin

- install pgAdmin
- connect to the local server
- psql and query tool
- https://www.pgadmin.org/download/

---

# start, stop, check, connect

make sure you know how to
- start and stop postgres
- check that postgres is running
- connect with psql in the terminal
- list users with \du : you should see 2 users
  - postgres
  - your name

---

# start, stop, check, connect : on mac

- **start**
  - brew services start postgresql@16
- **stop**
  - brew services stop postgresql@16
- **check that postgres is running**
  - launchctl list | grep postgres
- **connection with psql in the terminal**
  - psql -U postgres

---

# start, stop, check, connect : on windows

- **start**
  - …
- **stop**
  - …
- **check that postgres is running**
  - …
- **connection with psql in the terminal**
  - …

---

# psql and command prompts

---

# psql specific prompts

- connect on local as postgres user with psql
- try these prompts
- figure out what they return

```
# \d
# \dt
# \dn
# \df
# \du
# \q
# \d table_name
```

https://commandprompt.com/education/postgresql-basic-psql-commands/
https://tomcam.github.io/postgres/

---

# psql specific prompts

connect with
```
psql -h 35.238.75.182 -U epita -d airdb
```

with password
```
epita_2024
```

Let's go through https://tomcam.github.io/postgres/ on the airdb database

---

# postgres configuration files

There are 2 configuration files for a postgres server
- **postgresql.conf** : manages how the server operates
- **pg_hba.conf** : manages who can connect and how they authenticate

```sql
airdb=# show hba_file;
              hba_file
-----------------------------------
/etc/postgresql/16/main/pg_hba.conf
(1 row)
```

---

# postgres configuration files

**General server configuration**

This file controls most of the global settings for the PostgreSQL server. It includes:

- Resource allocation (memory, CPU)
- Default storage locations
- Replication settings
- Client connection defaults
- Query planner settings
- Logging and statistics
- Autovacuum settings
- Client/server communication parameters
- Locale and formatting
- Error handling

**Key points:**
- Affects the overall behavior and performance of the PostgreSQL server
- Changes typically require a server restart to take effect
- Located in the data directory

**Example settings:**
```
max_connections = 100
shared_buffers = 128MB
log_destination = 'stderr'
```

---

# postgres configuration files

**2. pg_hba.conf**

**Role: Client authentication control**

This file controls how clients are allowed to connect to the server. "HBA" stands for "host-based authentication". It specifies:

- Which hosts can connect
- Which database they can connect to
- Which PostgreSQL user names they can use
- How clients are authenticated (password, ident, trust, etc.)

**Key points:**
- Controls access at a very granular level
- Changes can typically be loaded with a simple reload, not requiring a full restart
- Critical for security management
- Also located in the data directory

**Example entries:**
```
# TYPE DATABASE    USER        ADDRESS        METHOD
local  all         postgres                   peer
host   all         all         127.0.0.1/32   md5
host   production  app_user    192.168.1.0/24 scram-sha-256
```

---

# setup psql with .psqlrc

**.psqlrc** is a configuration file for the psql command-line interface in PostgreSQL. It allows you to **customize your psql environment** and set default behaviors.

- Usually located in your home directory: **~/.psqlrc** on Unix-like systems
- On Windows: **%APPDATA%\postgresql\psqlrc.conf**

- Customizes the psql environment
- Sets default options and behaviors
- Runs commands automatically when psql starts

---

# setup psql with .psqlrc

- always timing the queries
- pager mode
- expanded mode

1. Set default pager: `\pset pager always`
2. Set line style: `\pset linestyle unicode`
3. Set timing on: `\timing`
4. Set expanded auto mode: `\x auto`
5. Custom prompt:
   `\set PROMPT1 '%[%033[1m%]%M %n@%/%R%[%033[0m%]%# '`
6. History settings:
   ```
   \set HISTSIZE 2000
   \set HISTCONTROL ignoredups
   ```
7. Enable verbose error reports: `\set VERBOSITY verbose`


