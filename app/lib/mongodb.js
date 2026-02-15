// lib/mongodb.js
const { MongoClient } = require('mongodb');

const uri = process.env.MONGODB_URI;

if (!uri) {
    throw new Error(
        'Please define the MONGODB_URI environment variable inside .env.local (or .env) – required for MongoDB Atlas'
    );
}

// Recommended options especially for Atlas M0 free tier + dev reliability
const options = {
    connectTimeoutMS: 10000,          // Fail faster if Atlas is slow/unreachable
    socketTimeoutMS: 20000,           // Prevent hanging on inactive sockets
    serverSelectionTimeoutMS: 15000,  // Faster failure during replica set elections
    maxPoolSize: 10,                  // Small pool – prevents overwhelming free tier (~500 conn limit)
    minPoolSize: 2,                   // Keep a couple warm (reduces cold-start latency)
    // loggerLevel: 'debug',          // ← Uncomment only when debugging connection issues
};

let client;
let clientPromise;

if (process.env.NODE_ENV === 'development') {
    // In development: cache via global to survive HMR reloads
    // (This is the official Next.js / Vercel recommended pattern)
    if (!global._mongoClientPromise) {
        client = new MongoClient(uri, options);

        global._mongoClientPromise = client
            .connect()
            .then((connectedClient) => {
                console.log('[MongoDB] Atlas connected successfully (dev mode – cached)');
                return connectedClient;
            })
            .catch((err) => {
                console.error('[MongoDB] Atlas connection failed in dev mode:', err.message);
                // Optional: reset so next import can retry
                global._mongoClientPromise = undefined;
                throw err;
            });
    }

    clientPromise = global._mongoClientPromise;
} else {
    // Production / serverless: fresh client per module load (safe for Vercel/Edge/EKS)
    client = new MongoClient(uri, options);
    clientPromise = client.connect();
}

module.exports = clientPromise;