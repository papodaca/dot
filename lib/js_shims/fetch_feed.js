const fs = require('fs/promises')
const Parser = require('rss-parser');
const axios = require('axios');

const [cmd, script, url, etag, out] = process.argv;

const headers = {
  "Accept": "en",
  "Pragma": "no-cache",
  "Cache-Control": "no-cache",
  "User-Agent": "Dot/1.0.0 (https://github.com/papodaca/dot)"
}

if(etag != "nil") {
  headers["If-None-Match"] = `"${etag}"`;
}

const parser = new Parser();

async function run() {
  const res = await axios.get({ url, headers });
  if(res.status !== 200) {
    throw "Could not fetch feed";
  }
  const feed = await parser.parseString(res.data);
  if(!feed) {
    throw "Could not fetch feed";
  }
  feed["etag"] = res.headers["etag"].replace('"', "");
  const result = JSON.stringify(feed);
  await fs.writeFile(out, result);
}

run().then(() => {
  process.exit(0);
}, (err) => {
  console.error(err);
  process.exit(1);
});
