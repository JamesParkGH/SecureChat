const express = require('express');
const app = express();
const port = 3000;
const crypto = require('crypto');
const fs = require('fs');


const databaseFile = './data.json';

var db;
try {
  db = JSON.parse(fs.readFileSync(databaseFile, 'utf-8'));
} catch (err) {
  db = {};
}
console.log(db);

/**
 * Stores a key in the database
 * @param {String} user1 
 * @param {String} user2 
 * @param {String} key 
 */
function storeKey(user1, user2, key) {
  index = [user1, user2].sort().toString();
  db[index] = key;
  fs.writeFileSync(databaseFile, JSON.stringify(db, null, 2), 'utf-8');
}

/**
 * Gets a key from the database corresponding to users [user1] and [user2], order does not matter
 * @returns {String} key in hex format
*/
function getKey(user1, user2) {
  index = [user1, user2].sort().toString();
  return db[index];
}

/**
 * Generates a random key
 * @returns {Promise<String>} a Promise that will return the random bits in hex format
 */
function generateKey(user1, user2) {
  return new Promise((resolve, reject) => {

    const iterations = 5000;
    const keylen = 16;
    const digest = 'sha512';

    // resolve(crypto.randomBytes(keylen).toString('hex'));

    // Generate key based on the two users
    crypto.pbkdf2(`${user1} ${user2}`, 'salt', iterations, keylen, digest, (err, key) => {
      if (err) {
        reject(err);
      } else {
        resolve(key.toString('hex'));
      }
    })
  });
}

app.get('/', (req, res) => {
  res.send('Hello World from the root route!');
});

app.get('/key', (req, res) => {
  console.log(`HTTP GET ${req.originalUrl}`)
  if (!req.query.user1 || !req.query.user2) {
    res.send('Please specify two users');
    return;
  }
  dbKey = getKey(req.query.user1, req.query.user2);
  // If the key exists already in database, send it
  if (dbKey) {
    res.send(dbKey);
    return;
  }
  // Otherwise, generate a new one and store it in the database
  generateKey(req.query.user1 + req.query.user2).then((key) => {
    storeKey(req.query.user1, req.query.user2, key);
    res.send(key);
  });
  return;
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});