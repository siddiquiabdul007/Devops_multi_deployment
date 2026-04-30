import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '10s', target: 5 }, // Ramp up to 5 users
    { duration: '20s', target: 5 }, // Stay at 5 users
    { duration: '10s', target: 0 }, // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(99)<500'], // 99% of requests must complete below 500ms
    http_req_failed: ['rate<0.01'], // less than 1% failure rate
  },
};

export default function () {
  const url = __ENV.TARGET_URL || 'http://localhost:3001';
  
  const res = http.get(`${url}/health`);
  check(res, {
    'is status 200': (r) => r.status === 200,
  });

  sleep(1);
}
