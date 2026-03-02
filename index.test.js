const request = require('supertest');
const { app, server } = require('./index');

afterAll(() => server.close());

describe('GET /', () => {
  it('returns 200 with deployment message', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body.message).toBe('Deployed via AWS CodePipeline & EKS!');
  });
});

describe('GET /health', () => {
  it('returns healthy status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('healthy');
  });
});
