// pages/api/transactions.js   (or app/api/transactions/route.js if using App Router – see note below)
import clientPromise from '../../../lib/mongodb';  // adjust path if needed

export default async function handler(req, res) {
    // Early response for unsupported methods
    if (!['GET', 'POST'].includes(req.method)) {
        res.setHeader('Allow', ['GET', 'POST']);
        return res.status(405).json({ error: `Method ${req.method} Not Allowed` });
    }

    let client;
    try {
        client = await clientPromise;
    } catch (error) {
        console.error('[API] MongoDB connection failed:', error.message);
        return res.status(503).json({ error: 'Database connection unavailable' });
    }

    const db = client.db(process.env.MONGODB_DB || 'finance_tracker');

    // ────────────────────────────────────────────────
    // GET: Fetch all transactions, newest first
    // ────────────────────────────────────────────────
    if (req.method === 'GET') {
        try {
            const transactions = await db
                .collection('transactions')
                .find({})
                .sort({ date: -1 })           // newest first
                .limit(500)                   // safety limit – prevent huge responses
                .toArray();

            return res.status(200).json(transactions);
        } catch (error) {
            console.error('[GET /transactions] Error:', error.message);
            return res.status(500).json({ error: 'Failed to fetch transactions' });
        }
    }

    // ────────────────────────────────────────────────
    // POST: Create a new transaction
    // ────────────────────────────────────────────────
    if (req.method === 'POST') {
        try {
            const { description, amount, category, type } = req.body;

            // Basic input validation
            if (!description || typeof description !== 'string' || description.trim() === '') {
                return res.status(400).json({ error: 'Description is required and must be a non-empty string' });
            }
            if (!amount || isNaN(parseFloat(amount)) || parseFloat(amount) <= 0) {
                return res.status(400).json({ error: 'Amount must be a positive number' });
            }
            if (!category || typeof category !== 'string') {
                return res.status(400).json({ error: 'Category is required' });
            }
            if (!['income', 'expense'].includes(type)) {
                return res.status(400).json({ error: 'Type must be "income" or "expense"' });
            }

            const transaction = {
                description: description.trim(),
                amount: parseFloat(amount),
                category: category.trim(),
                type,
                date: new Date(),
                createdAt: new Date(),          // extra field – useful for auditing
            };

            const result = await db.collection('transactions').insertOne(transaction);

            return res.status(201).json({
                ...transaction,
                _id: result.insertedId.toString(),   // convert ObjectId to string for JSON
            });
        } catch (error) {
            console.error('[POST /transactions] Error:', error.message);
            return res.status(500).json({ error: 'Failed to create transaction' });
        }
    }
}