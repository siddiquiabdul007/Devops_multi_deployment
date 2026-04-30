require('./tracing');
const express = require('express');
const pino = require('pino');
const logger = pino();

const app = express();
const port = process.env.PORT || 3002;
// In Kubernetes, this should point to the user-service ClusterIP address or DNS name
const userServiceUrl = process.env.USER_SERVICE_URL || 'http://localhost:3001';

app.get('/orders', async (req, res) => {
  logger.info('GET /orders requested');
  try {
    const response = await fetch(`${userServiceUrl}/users`);
    if (!response.ok) {
      throw new Error(`Failed to fetch users, status: ${response.status}`);
    }
    const data = await response.json();
    const usersList = data.users || [];

    // Create some dummy orders for users
    const orders = usersList.map((user, index) => ({
      orderId: `ORD-${1000 + index}`,
      userId: user.id,
      userName: user.name,
      item: `Product ${index + 1}`,
      amount: Math.floor(Math.random() * 100) + 10
    }));

    res.json(orders);
  } catch (error) {
    logger.error({ err: error }, 'Error fetching users');
    res.status(500).json({ error: 'Failed to fetch users from user-service', details: error.message });
  }
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', service: 'order-service' });
});

app.listen(port, () => {
  logger.info(`Order service running on port ${port}`);
});
