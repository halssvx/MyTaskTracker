const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const PORT = 3000;

let tasks = [];

app.use(bodyParser.json());
app.use(express.static('public'));

// Get all tasks
app.get('/tasks', (req, res) => {
  res.json(tasks);
});

// Add a task
app.post('/tasks', (req, res) => {
  const task = { id: Date.now(), text: req.body.text };
  tasks.push(task);
  res.status(201).json(task);
});

// Delete a task
app.delete('/tasks/:id', (req, res) => {
  tasks = tasks.filter(task => task.id !== parseInt(req.params.id));
  res.sendStatus(204);
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
