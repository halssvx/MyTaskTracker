const express = require('express');
const path = require('path');
const db = require('./db');
const app = express();

const PORT = process.env.PORT || 3000;

app.use(express.json());

// Get all tasks
app.get('/tasks', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM tasks');
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add a task
app.post('/tasks', async (req, res) => {
  const { text } = req.body;
  if (!text) return res.status(400).json({ error: 'Task text is required' });

  try {
    const [result] = await db.query('INSERT INTO tasks (text) VALUES (?)', [text]);
    res.status(201).json({ id: result.insertId, text });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete a task
app.delete('/tasks/:id', async (req, res) => {
  const id = req.params.id;
  try {
    await db.query('DELETE FROM tasks WHERE id = ?', [id]);
    res.sendStatus(204);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Serve frontend
app.use(express.static(path.join(__dirname, '../frontend')));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
