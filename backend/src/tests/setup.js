// Global test setup — runs before every test file
process.env.JWT_SECRET = 'test_jwt_secret_for_unit_tests';
process.env.ADMIN_USERNAME = 'admin';

// Pre-compute a bcrypt hash for 'testpass' at cost 4 (fast for tests)
const bcrypt = require('bcryptjs');
process.env.ADMIN_PASSWORD_HASH = bcrypt.hashSync('testpass', 4);
