require('./tracing');
const express = require('express');
const pino = require('pino');
const logger = pino();

const app = express();
const port = process.env.PORT || 3001;

// core logic in one place
const getUsers = () => ({
  version: "stable-v1",
  users: [
    { id: 1, name: 'Alice', role: 'admin' },
    { id: 2, name: 'Bob', role: 'user' },
    { id: 3, name: 'Charlie', role: 'user' }
  ]
});

// root route (internal usage)
app.get('/', (req, res) => {
  logger.info('GET / requested');
  res.json(getUsers());
});

// external API route (ingress)
app.get('/users', (req, res) => {
  logger.info('GET /users requested');
  res.json(getUsers());
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', service: 'user-service' });
});

app.listen(port, () => {
  logger.info(`User service running on port ${port}`);
});