# Connecting to TiDB cluster with node-mysql2

[![Language](https://img.shields.io/badge/Language-JavaScript-f1e05a.svg)](https://nodejs.org/en)
[![Driver](https://img.shields.io/badge/Driver-mysql2-blue.svg)](https://github.com/sidorares/node-mysql2)

The following guide will show you how to connect to the TiDB cluster with Node.js driver [node-mysql2](https://github.com/sidorares/node-mysql2) and perform basic SQL operations like create, read, update, and delete.

> **Notice:**
>
> TiDB is a MySQL-compatible database, which means you can connect to a TiDB cluster in your application using the familiar driver/ORM framework from the MySQL ecosystem.
> 
> The only difference is that if you are using the public endpoint to connect to a TiDB Serverless cluster, you **MUST** [enable TLS connection on the mysql2 driver](#connect-to-tidb-cluster).

## Prerequisites

To complete this guide, you need:

- [Node.js](https://nodejs.org/en) >= 16.x installed on your machine
- [Git](https://git-scm.com/downloads) installed on your machine
- A TiDB cluster running

**If you don't have a TiDB cluster yet, please create one with one of the following methods:**

1. (**Recommend**) [Start up a TiDB Serverless cluster](https://tidbcloud.com/free-trial?utm_source=github&utm_medium=quickstart) instantly with a few clicks on TiDB Cloud.
2. [Start up a TiDB Playground cluster](https://docs.pingcap.com/tidb/stable/quick-start-with-tidb#deploy-a-local-test-cluster) with TiUP CLI on your local machine.

## Getting started

Learn how to use the `mysql2` driver to connect to the TiDB cluster through a sample code.

### 1. Clone the repository

Run the following command to clone the sample code locally：

```shell
git clone https://github.com/tidb-samples/tidb-nodejs-mysql2-quickstart.git
cd tidb-nodejs-mysql2-quickstart
```

### 2. Install dependencies

Run the following command to install the dependencies (including the `mysql2` package) required by the sample code：

```shell
npm install
```

<details>
<summary><b>Install dependencies to existing project</b></summary>

For your existing project, run the following command to install the packages:

- `mysql2`: The Node.js MySQL driver for the database connection.
- `dotenv`: The utils package to loading environment variables from the `.env` file.

```shell
npm install mysql2 dotenv --save
```
</details>

### 3. Obtain connection parameters

<details open>
<summary><b>(Option 1) TiDB Serverless</b></summary>

1. Navigate to the [Clusters](https://tidbcloud.com/console/clusters) page, and then click the name of your target cluster to go to its overview page.
2. Click **Connect** in the upper-right corner.
3. In the connection dialog, select `General` from the **Connect With** dropdown and keep the default setting of the **Endpoint Type** as `Public`.
4. If you have not set a password yet, click **Create password** to generate a random password.
5. Copy the connection parameters shown on the code block.

   > **Note:**
   > In Node.js applications, you **don't** have to provide an SSL CA certificate, because Node.js uses the built-in [Mozilla CA certificate](https://wiki.mozilla.org/CA/Included_Certificates) by default when establishing the TLS (SSL) connection.

   <div style="text-align: center;">
      <img width="600" src="./static/images/tidb-cloud-connect-dialog-light-theme.png" alt="The connect dialog in the overview page of TiDB Serverless"/>
      <div><i>The connect dialog in the overview page of TiDB Serverless</i></div>
   </div>

</details>

<details>
<summary><b>(Option 2) TiDB Dedicated</b></summary>

1. Navigate to the [Clusters](https://tidbcloud.com/console/clusters) page, and then click the name of your target cluster to go to its overview page.
2. Click **Connect** in the upper-right corner. A connection dialog is displayed.
3. Create a traffic filter for the cluster.

   1. Click **Allow Access from Anywhere** to add a new CIDR address rule to allow clients from any IP address to access. 
   2. Click **Create Filter** to confirm the changes.

4. Under **Step 2: Download TiDB cluster CA** in the dialog, click **Download TiDB cluster CA** for TLS connection to TiDB clusters.
5. Under **Step 3: Connect with a SQL client** in the dialog, select `General` from the **Connect With** dropdown and select `Public` from the **Endpoint Type** dropdown.
6. Copy the connection parameters shown on the code block.

</details>

<details>
<summary><b>(Option 3) Self-Hosted TiDB</b></summary>

   Prepare the following connection parameters for your cluster:

  - **host**: The IP address or domain name where the TiDB cluster running (For example: `127.0.0.1`).
  - **port**: The port on which your database server is running (Default: `4000`).
  - **user**: The name of your database user (Default: `root`).
  - **password**: The password of your database user (No password for TiDB Playground by default).

</details>

### 4. Set up the environment variables

<details open>
   <summary><b>(Option 1) TiDB Serverless</b></summary>

   1. Make a copy of the `.env.example` file to the `.env` file.
   2. Edit the `.env` file, and replace the placeholders for `<host>`, `<user>`, and `<password>` with the copied connection parameters.
   3. Modify `DATABASE_ENABLE_SSL` to `true` to enable a TLS connection. (Required for public endpoint)

   ```dotenv
   DATABASE_HOST=<host>
   DATABASE_PORT=4000
   DATABASE_USER=<user>
   DATABASE_PASSWORD=<password>
   DATABASE_NAME=test
   DATABASE_ENABLE_SSL=true
   ```

</details>

<details>
   <summary><b>(Option 2) TiDB Dedicated</b></summary>

   1. Make a copy of the `.env.example` file to the `.env` file.
   2. Edit the `.env` file, and replace the placeholders for `<host>`, `<user>`, and `<password>` with the copied connection parameters.
   3. Modify `DATABASE_ENABLE_SSL` to `true` to enable a TLS connection. (Required for public endpoint)
   4. Modify `DATABASE_SSL_CA` to the file path of the CA certificate provided by TiDB Cloud. (Required for public endpoint)

   ```dotenv
   DATABASE_HOST=<host>
   DATABASE_PORT=4000
   DATABASE_USER=<user>
   DATABASE_PASSWORD=<password>
   DATABASE_NAME=test
   DATABASE_ENABLE_SSL=true
   DATABASE_SSL_CA=/path/to/ca.pem
   ```

</details>

<details>
   <summary><b>(Option 3) Self-Hosted TiDB</b></summary>

   1. Make a copy of the `.env.example` file to the `.env` file.
   2. Edit the `.env` file, and replace the placeholders for `<host>`, `<user>`, and `<password>` with the copied connection parameters.

   > The Self-Hosted TiDB using non-encrypted connection between TiDB's server and clients by default, SKIP the below steps if your cluster doesn't [enable TLS connections](https://docs.pingcap.com/tidb/stable/enable-tls-between-clients-and-servers#configure-tidb-server-to-use-secure-connections).
   
   3. (Optional) Modify `DATABASE_ENABLE_SSL` to `true` to enable a TLS connection.
   4. (Optional) Modify `DATABASE_SSL_CA` to the file path of the trusted CA certificate defined with [`ssl-ca`](https://docs.pingcap.com/tidb/stable/tidb-configuration-file#ssl-ca) option.

   ```dotenv
   DATABASE_HOST=<host>
   DATABASE_PORT=4000
   DATABASE_USER=<user>
   DATABASE_PASSWORD=<password>
   DATABASE_NAME=test
   # DATABASE_ENABLE_SSL=true
   # DATABASE_SSL_CA=/path/to/ca.pem
   ```

</details>

### 5. Run the sample code

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

## Example codes

### Connect to TiDB cluster

The following code use the environment variables (stored in the `.env` file) as the connection options to establish a database connection with the TiDB cluster:

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

> **Notice**:
> To connect TiDB Serverless cluster with the public endpoint, please set up the environment variable `DATABASE_ENABLE_SSL` to `true` to enable TLS connection.

### Connect with connection URL

The following code read the connection URL from the environment variable `DATABASE_URL`, and establish a connection with the TiDB cluster:

```javascript
const conn = await createConnection(process.env.DATABASE_URL);
```

#### Connection URL

The connection URL configures the [parameters for connecting to the database](#3-obtain-connection-parameters) in the following URL format:

```dotenv
DATABASE_URL=mysql://<user>:<password>@<host>:<port>/<database>?<key1>=<value1>
```

**Example 1: Connect to TiDB Serverless with public endpoint:**

**MUST** enable SSL (TLS) connection via adding the argument `?ssl={"minVersion":"TLSv1.2"}` to the connection URL.

```dotenv
DATABASE_URL=mysql://87pMDHi7EVaPxAR.root:password@gateway01.us-west-2.prod.aws.tidbcloud.com:4000/test?ssl={"minVersion":"TLSv1.2"}
```

**Example 2: Connect to local TiDB playground cluster**

```dotenv
DATABASE_URL=mysql://root@localhost:4000/test
```

### Insert data

The following query creates a single `Player` with two fields and return a `ResultSetHeader` object (`rsh`):

```javascript
async function createPlayer(conn, coins, goods) {
   const [rsh] = await conn.query('INSERT INTO players (coins, goods) VALUES (?, ?);', [coins, goods]);
   return rsh.insertId;
}
```

Check out the [Insert Data](https://docs.pingcap.com/tidbcloud/dev-guide-insert-data) chapter for more information.

### Query data

The following query returns a single `Player` record by ID:

```javascript
async function getPlayerByID(conn, id) {
   const [rows] = await conn.query('SELECT id, coins, goods FROM players WHERE id = ?;', [id]);
   return rows[0];
}
```

Check out the [Query Data](https://docs.pingcap.com/tidbcloud/dev-guide-get-data-from-single-table) chapter for more information.

### Update data

The following query updated a single `Player` record by ID:

```javascript
async function updatePlayer(conn, playerID, incCoins, incGoods) {
    const [rsh] = await conn.query(
        'UPDATE players SET coins = coins + ?, goods = goods + ? WHERE id = ?;',
        [incCoins, incGoods, playerID]
    );
    return rsh.affectedRows;
}
```

Check out the [Update Data](https://docs.pingcap.com/tidbcloud/dev-guide-update-data) chapter for more information.

### Delete data

The following query deletes a single `Player` record:

```javascript
async function deletePlayerByID(conn, id) {
    const [rsh] = await conn.query('DELETE FROM players WHERE id = ?;', [id]);
    return rsh.affectedRows;
}
```

Check out the [Delete Data](https://docs.pingcap.com/tidbcloud/dev-guide-delete-data) chapter for more information.

## Best practices

- Using [Connection Pools](https://github.com/sidorares/node-mysql2#using-connection-pools) to manage database connections, which can reduce the performance overhead caused by frequently establishing/destroying connections.
- Using [Prepared Statements](https://github.com/sidorares/node-mysql2#using-prepared-statements) to avoid SQL injection.
- Using ORM frameworks to improve development efficiency in scenarios without a lot of complex SQL, such as [Sequelize](https://sequelize.org/) and [TypeORM](https://typeorm.io/).
- Enable the `supportBigNumbers: true` option when dealing with big numbers (`BIGINT` and `DECIMAL` columns) in the database.
- Enable the `enableKeepAlive: true` option to avoid socket error `read ECONNRESET` due to network problems. (Related issue: [sidorares/node-mysql2#683](https://github.com/sidorares/node-mysql2/issues/683))

## What's next

- Check out the documentation of [node-mysql2](https://github.com/sidorares/node-mysql2#readme) for more usage about the driver.
- Explore the real-time analytics feature on the [TiDB Cloud Playground](https://play.tidbcloud.com/real-time-analytics).
- Read the development guide to learn more application development details about TiDB.
  - [HTAP Queries](https://docs.pingcap.com/tidbcloud/dev-guide-hybrid-oltp-and-olap-queries)
  - [Transaction](https://docs.pingcap.com/tidbcloud/dev-guide-transaction-overview)
  - [Optimizing SQL Performance](https://docs.pingcap.com/tidbcloud/dev-guide-optimize-sql-overview)
