# Connecting to TiDB with node-mysql2

[![Language](https://img.shields.io/badge/Language-JavaScript-f1e05a.svg)](https://nodejs.org/en)
[![Driver](https://img.shields.io/badge/Driver-mysql2-blue.svg)](https://github.com/sidorares/node-mysql2)

The following guide will show you how to connect to TiDB with Node.js driver [node-mysql2](https://github.com/sidorares/node-mysql2) and perform basic SQL operations like create, read, update, and delete.

> **Notice:**
>
> TiDB is a MySQL-compatible database, which means you can connect to TiDB in your application using your familiar MySQL driver/ORM framework.
>
> The only difference is that if you connect to a TiDB Serverless cluster with public endpoint, you **MUST** [enable TLS connection on the mysql2 driver](#connect-with-connection-options).

## Prerequisites

To complete this guide, you need:

- [Node.js](https://nodejs.org/en) >= 16.x installed on your machine
- [Git](https://git-scm.com/downloads) installed on your machine
- A TiDB cluster running

**If you don't have a TiDB cluster yet, please create one with one of the following methods:**

1. (**Recommend**) [Start up a TiDB Serverless cluster](https://tidbcloud.com/free-trial?utm_source=github&utm_medium=quickstart) instantly with a few clicks on TiDB Cloud.
2. [Start up a TiDB Playground cluster](https://docs.pingcap.com/tidb/stable/quick-start-with-tidb#deploy-a-local-test-cluster) with TiUP CLI on your local machine.

## Getting started

This section demonstrates how to run the sample application code and connect to TiDB with `mysql2` driver .

### Step 1. Clone the repository

Run the following commands to clone the sample code locally：

```shell
git clone https://github.com/tidb-samples/tidb-nodejs-mysql2-quickstart.git
cd tidb-nodejs-mysql2-quickstart
```

### Step 2. Install dependencies

Run the following command to install the dependencies (including the `mysql2` package) required by the sample code：

```shell
npm install
```

<details>
<summary><b>Install dependencies to existing project</b></summary>

For your existing project, run the following command to install the packages:

- `mysql2`: The Node.js MySQL driver for the database connection and SQL operations.
- `dotenv`: The utils package to loading environment variables from the `.env` file.

```shell
npm install mysql2 dotenv --save
```
</details>

### Step 3. Provide connection parameters

<details open>
<summary><b>(Option 1) TiDB Serverless</b></summary>

1. Navigate to the [Clusters](https://tidbcloud.com/console/clusters) page, and then click the name of your target cluster to go to its overview page.
2. Click **Connect** in the upper-right corner.
3. In the connection dialog, select `General` from the **Connect With** dropdown and keep the default setting of the **Endpoint Type** as `Public`.
4. If you have not set a password yet, click **Create password** to generate a random password.

    <div align="center">
        <picture>
            <source media="(prefers-color-scheme: dark)" srcset="./static/images/tidb-cloud-connect-dialog-dark-theme.png" width="600">
            <img alt="The connection dialog of TiDB Serverless" src="./static/images/tidb-cloud-connect-dialog-light-theme.png" width="600">
        </picture>
        <div><i>The connection dialog of TiDB Serverless</i></div>
    </div>

5. Make a copy of the `.env.example` file to the `.env` file:

   ```shell
   cp .env.example .env
   ```

6. Copy and paste the connection parameters shown on the code block to the corresponding variables in the `.env` file.

    ```dotenv
    DATABASE_HOST=<host>
    DATABASE_PORT=4000
    DATABASE_USER=<user>
    DATABASE_PASSWORD=<password>
    DATABASE_NAME=test
    DATABASE_ENABLE_SSL=true
    ```
   
    > Modify `DATABASE_ENABLE_SSL` to `true` to enable a TLS connection. (Required for public endpoint)

</details>

<details>
<summary><b>(Option 2) TiDB Dedicated</b></summary>

You can obtain the database connection parameters on [TiDB Cloud's Web Console](https://tidbcloud.com/console) through the following steps:

1. Navigate to the [Clusters](https://tidbcloud.com/console/clusters) page, and then click the name of your target cluster to go to its overview page.
2. Click **Connect** in the upper-right corner. A connection dialog is displayed.
3. Click **Allow Access from Anywhere**, and then click **Download TiDB cluster CA** to download the CA certificate.
4. Select `General` from the **Connect With** dropdown and select `Public` from the **Endpoint Type** dropdown.
5. Make a copy of the `.env.example` file to the `.env` file.

    ```shell
    cp .env.example .env
    ```

6. Copy and paste the connection parameters shown on the code block to the corresponding variables in the `.env` file.

    ```dotenv
    DATABASE_HOST=<host>
    DATABASE_PORT=4000
    DATABASE_USER=<user>
    DATABASE_PASSWORD=<password>
    DATABASE_NAME=test
    DATABASE_ENABLE_SSL=true
    DATABASE_SSL_CA=/path/to/ca.pem
    ```
   
    > Modify `DATABASE_ENABLE_SSL` to `true` to enable a TLS connection and using `DATABASE_SSL_CA` to specify the file path of CA certificate downloaded from the connection dialog.

</details>

<details>
<summary><b>(Option 3) TiDB Self-Hosted</b></summary>

1. Make a copy of the `.env.example` file to the `.env` file.

   ```shell
   cp .env.example .env
   ```

2. Replace the placeholders for `<host>`, `<user>`, and `<password>` with the connection parameters of your TiDB cluster.

    ```dotenv
    DATABASE_HOST=<host>
    DATABASE_PORT=4000
    DATABASE_USER=<user>
    DATABASE_PASSWORD=<password>
    DATABASE_NAME=test
    # DATABASE_ENABLE_SSL=true
    # DATABASE_SSL_CA=/path/to/ca.pem
    ```

    The TiDB Self-Hosted cluster using non-encrypted connection between TiDB's server and clients by default.

    If you want to enable TLS connection, please uncomment the `DATABASE_ENABLE_SSL` and `DATABASE_SSL_CA` options and specify the file path of CA certificate defined with [`ssl-ca`](https://docs.pingcap.com/tidb/stable/tidb-configuration-file#ssl-ca) option.

</details>

### Step 4. Run the sample code

Run the following command to execute the sample code:

```shell
npm start
```

If the connection is successful, the console will output the version of the TiDB cluster.

**Expected execution output:**

```
🔌 Connected to TiDB cluster! (TiDB version: 5.7.25-TiDB-v7.1.0)
⏳ Loading sample game data...
✅ Loaded sample game data.

🆕 Created a new player with ID 12.
ℹ️ Got Player 12: Player { id: 12, coins: 100, goods: 100 }
🔢 Added 50 coins and 50 goods to player 12, updated 1 row.
🚮 Deleted 1 player data.
```

## Sample code

### Connect with connection options

The following code establish a connection to TiDB with options defined in environment variables:

```javascript
const options = {
    host: process.env.DATABASE_HOST || '127.0.0.1',
    port: process.env.DATABASE_PORT || 4000,
    user: process.env.DATABASE_USER || 'root',
    password: process.env.DATABASE_PASSWORD || '',
    database: process.env.DATABASE_NAME || 'test',
    ssl: process.env.DATABASE_ENABLE_SSL === 'true' ? {
        minVersion: 'TLSv1.2',
        ca: process.env.DATABASE_SSL_CA ? fs.readFileSync(process.env.DATABASE_SSL_CA) : undefined
    } : null,
}
const conn = await createConnection(options);
```

To enable TLS connection, please set up the environment variable `DATABASE_ENABLE_SSL` to `true`. (Required for TiDB Serverless public endpoint)

> For TiDB Serverless, you **don't** have to specify an SSL CA certificate, because Node.js uses the built-in [Mozilla CA certificate](https://wiki.mozilla.org/CA/Included_Certificates) by default, which is trusted by TiDB Serverless.

### Connect with connection URL

The following code load the `DATABASE_URL` from `.env` file, and establish a connection with the URL:

```javascript
const conn = await createConnection(process.env.DATABASE_URL);
```

The format of the `DATABASE_URL` is as follows, replace the placeholders `{}` with the connection parameters of your TiDB cluster

```dotenv
DATABASE_URL=mysql://{username}:{password}@{host}:{port}/{database_name}
```

> To enable TLS connection, add argument `?ssl={"minVersion":"TLSv1.2"}` to the end of the URL. (Required for TiDB Serverless public endpoint)

### Insert data

The following query creates a single `Player` record and return a `ResultSetHeader` object:

```javascript
const [rsh] = await conn.query('INSERT INTO players (coins, goods) VALUES (?, ?);', [100, 100]);
console.log(rsh.insertId);
```

For more information, refer to [Insert Data](https://docs.pingcap.com/tidbcloud/dev-guide-insert-data).

### Query data

The following query returns a single `Player` record by ID `1`:

```javascript
const [rows] = await conn.query('SELECT id, coins, goods FROM players WHERE id = ?;', [1]);
console.log(rows[0]);
```

For more information, refer to [Query Data](https://docs.pingcap.com/tidbcloud/dev-guide-get-data-from-single-table).

### Update data

The following query adds 50 coins and 50 goods to the `Player` record with ID `1`:

```javascript
const [rsh] = await conn.query(
    'UPDATE players SET coins = coins + ?, goods = goods + ? WHERE id = ?;',
    [50, 50, 1]
);
console.log(rsh.affectedRows);
```

For more information, refer to [Update Data](https://docs.pingcap.com/tidbcloud/dev-guide-update-data).

### Delete data

The following query deletes the `Player` record with ID `1`:

```javascript
const [rsh] = await conn.query('DELETE FROM players WHERE id = ?;', [1]);
console.log(rsh.affectedRows);
```

For more information, refer to [Delete Data](https://docs.pingcap.com/tidbcloud/dev-guide-delete-data).

## Best practices

- Using [Connection Pools](https://github.com/sidorares/node-mysql2#using-connection-pools) to manage database connections, which can reduce the performance overhead caused by frequently establishing/destroying connections.
- Using [Prepared Statements](https://github.com/sidorares/node-mysql2#using-prepared-statements) to avoid SQL injection.
- Using ORM frameworks to improve development efficiency in scenarios without a lot of complex SQL, such as [Sequelize](https://sequelize.org/) and [TypeORM](https://typeorm.io/).
- Enable the `supportBigNumbers: true` option when dealing with big numbers (`BIGINT` and `DECIMAL` columns) in the database.
- Enable the `enableKeepAlive: true` option to avoid socket error `read ECONNRESET` due to network problems. (Related issue: [sidorares/node-mysql2#683](https://github.com/sidorares/node-mysql2/issues/683))

## What's next

- Check out the documentation of [node-mysql2](https://github.com/sidorares/node-mysql2#readme) for more usage about the driver.
- Explore the real-time analytics feature on the [TiDB Cloud Playground](https://play.tidbcloud.com/real-time-analytics).
- Read the [TiDB Developer Guide](https://docs.pingcap.com/tidbcloud/dev-guide-overview) to learn more details about application development with TiDB.
  - [HTAP Queries](https://docs.pingcap.com/tidbcloud/dev-guide-hybrid-oltp-and-olap-queries)
  - [Transaction](https://docs.pingcap.com/tidbcloud/dev-guide-transaction-overview)
  - [Optimizing SQL Performance](https://docs.pingcap.com/tidbcloud/dev-guide-optimize-sql-overview)
