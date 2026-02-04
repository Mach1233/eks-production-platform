import { useState, useEffect } from 'react';
import Head from 'next/head';

export default function Home() {
    const [transactions, setTransactions] = useState([]);
    const [form, setForm] = useState({ description: '', amount: '', category: 'General', type: 'expense' });
    const [loading, setLoading] = useState(false);

    // Fetch transactions
    const fetchTransactions = async () => {
        const res = await fetch('/api/transactions');
        const data = await res.json();
        setTransactions(data);
    };

    useEffect(() => {
        fetchTransactions();
    }, []);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        await fetch('/api/transactions', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(form),
        });
        setForm({ description: '', amount: '', category: 'General', type: 'expense' });
        fetchTransactions();
        setLoading(false);
    };

    const income = transactions
        .filter(t => t.type === 'income')
        .reduce((acc, t) => acc + t.amount, 0);

    const expense = transactions
        .filter(t => t.type === 'expense')
        .reduce((acc, t) => acc + t.amount, 0);

    const balance = income - expense;

    return (
        <div className="min-h-screen p-8 max-w-6xl mx-auto">
            <Head>
                <title>Finance Tracker</title>
            </Head>

            <header className="mb-8 flex justify-between items-center bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                <h1 className="text-3xl font-bold text-gray-800">Finance Tracker</h1>
                <div className="text-right">
                    <p className="text-sm text-gray-500 uppercase">Total Balance</p>
                    <span className={`text-3xl font-bold ${balance >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                        ${balance.toFixed(2)}
                    </span>
                </div>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <h3 className="text-gray-500 font-medium">Income</h3>
                    <p className="text-2xl font-bold text-green-600">+${income.toFixed(2)}</p>
                </div>
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <h3 className="text-gray-500 font-medium">Expenses</h3>
                    <p className="text-2xl font-bold text-red-600">-${expense.toFixed(2)}</p>
                </div>
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <h3 className="text-gray-500 font-medium">Transactions</h3>
                    <p className="text-2xl font-bold text-blue-600">{transactions.length}</p>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Form */}
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 h-fit sticky top-6">
                    <h2 className="text-xl font-bold mb-4">Add Transaction</h2>
                    <form onSubmit={handleSubmit} className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700">Type</label>
                            <div className="mt-1 flex gap-2">
                                <button
                                    type="button"
                                    onClick={() => setForm({ ...form, type: 'income' })}
                                    className={`flex-1 py-2 px-4 rounded-lg border ${form.type === 'income' ? 'bg-green-50 border-green-500 text-green-700 font-bold' : 'border-gray-300 text-gray-600'
                                        }`}
                                >
                                    Income
                                </button>
                                <button
                                    type="button"
                                    onClick={() => setForm({ ...form, type: 'expense' })}
                                    className={`flex-1 py-2 px-4 rounded-lg border ${form.type === 'expense' ? 'bg-red-50 border-red-500 text-red-700 font-bold' : 'border-gray-300 text-gray-600'
                                        }`}
                                >
                                    Expense
                                </button>
                            </div>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700">Amount</label>
                            <input
                                required
                                type="number"
                                step="0.01"
                                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 p-2 border"
                                value={form.amount}
                                onChange={(e) => setForm({ ...form, amount: e.target.value })}
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700">Description</label>
                            <input
                                required
                                type="text"
                                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 p-2 border"
                                value={form.description}
                                onChange={(e) => setForm({ ...form, description: e.target.value })}
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700">Category</label>
                            <select
                                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 p-2 border"
                                value={form.category}
                                onChange={(e) => setForm({ ...form, category: e.target.value })}
                            >
                                <option>General</option>
                                <option>Food</option>
                                <option>Rent</option>
                                <option>Salary</option>
                                <option>Utilities</option>
                                <option>Entertainment</option>
                            </select>
                        </div>

                        <button
                            type="submit"
                            disabled={loading}
                            className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
                        >
                            {loading ? 'Adding...' : 'Add Transaction'}
                        </button>
                    </form>
                </div>

                {/* List */}
                <div className="lg:col-span-2 bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <h2 className="text-xl font-bold mb-4">Recent Transactions</h2>
                    <div className="overflow-hidden">
                        <table className="min-w-full divide-y divide-gray-200">
                            <thead className="bg-gray-50">
                                <tr>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Category</th>
                                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
                                </tr>
                            </thead>
                            <tbody className="bg-white divide-y divide-gray-200">
                                {transactions.map((t) => (
                                    <tr key={t._id}>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                            {new Date(t.date).toLocaleDateString()}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                                            {t.description}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                            <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">
                                                {t.category}
                                            </span>
                                        </td>
                                        <td className={`px-6 py-4 whitespace-nowrap text-sm text-right font-bold ${t.type === 'income' ? 'text-green-600' : 'text-red-600'
                                            }`}>
                                            {t.type === 'income' ? '+' : '-'}${t.amount.toFixed(2)}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                        {transactions.length === 0 && (
                            <p className="text-center py-8 text-gray-500">No transactions recorded.</p>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
