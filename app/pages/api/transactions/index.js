import clientPromise from '../../../lib/mongodb';

export default async function handler(req, res) {
    const client = await clientPromise;
    const db = client.db(process.env.MONGODB_DB);

    if (req.method === 'GET') {
        try {
            const transactions = await db
                .collection('transactions')
                .find({})
                .sort({ date: -1 })
                .toArray();
            res.status(200).json(transactions);
        } catch (e) {
            console.error(e);
            res.status(500).json({ error: 'Unable to fetch transactions' });
        }
    } else if (req.method === 'POST') {
        try {
            const { description, amount, category, type } = req.body;
            const transaction = {
                description,
                amount: parseFloat(amount),
                category,
                type, // 'income' or 'expense'
                date: new Date(),
            };

            const result = await db.collection('transactions').insertOne(transaction);
            res.status(201).json({ ...transaction, _id: result.insertedId });
        } catch (e) {
            console.error(e);
            res.status(500).json({ error: 'Unable to create transaction' });
        }
    } else {
        res.setHeader('Allow', ['GET', 'POST']);
        res.status(405).end(`Method ${req.method} Not Allowed`);
    }
}
