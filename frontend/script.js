const API_URL = '/tasks';

async function fetchTasks() {
  const res = await fetch(API_URL);
  const tasks = await res.json();
  renderTasks(tasks);
}

function renderTasks(tasks) {
  const taskList = document.getElementById('task-list');
  taskList.innerHTML = '';
  tasks.forEach(task => {
    const li = document.createElement('li');
    li.textContent = task.text;
    const delBtn = document.createElement('button');
    delBtn.textContent = 'Delete';
    delBtn.className = 'delete-btn';
    delBtn.onclick = () => deleteTask(task.id);
    li.appendChild(delBtn);
    taskList.appendChild(li);
  });
}

async function addTask() {
  const input = document.getElementById('task-input');
  const text = input.value.trim();
  if (!text) return alert('Please enter a task');
  await fetch(API_URL, {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({ text })
  });
  input.value = '';
  fetchTasks();
}

async function deleteTask(id) {
  await fetch(`${API_URL}/${id}`, { method: 'DELETE' });
  fetchTasks();
}

document.getElementById('add-task').addEventListener('click', addTask);
window.onload = fetchTasks;
