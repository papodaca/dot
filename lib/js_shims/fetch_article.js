const fs = require('fs/promises')
const { extract, setNodeFetchOptions } = require('article-parser');

const [cmd, script, url, etag, out] = process.argv;

setNodeFetchOptions({
  headers: {
    "Accept": "en",
    "Pragma": "no-cache",
    "Cache-Control": "no-cache",
    "User-Agent": "Dot/1.0.0 (https://github.com/papodaca/dot)"
  }
});

async function run() {
  let result = await extract(url);
  if(!result) {
    throw "Could not fetch article"
  }
  const data = JSON.stringify(result);
  await fs.writeFile(out, data);
}

run().then(() => {
  process.exit(0);
}, (err) => {
  console.error(err);
  process.exit(1);
});
