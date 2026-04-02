const express = require('express');
const app = express();
const port = process.env.PORT || 3001;

app.get('/users', (req, res) => {
  res.json([
    { id: 1, name: 'Alice', role: 'admin' },
    { id: 2, name: 'Bob', role: 'user' },
    { id: 3, name: 'Charlie', role: 'user' }
  ]);
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', service: 'user-service' });
});

app.listen(port, () => {
  console.log(`User service listening at http://localhost:${port}`);
});
