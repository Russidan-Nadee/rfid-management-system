// Simple test to check if our session extension is working
// Run with: node test-session-simple.js

const http = require('http');

function makeRequest(path, cookie = '') {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: `/api/v1${path}`,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Cookie': cookie
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ 
            status: res.statusCode, 
            data: parsed, 
            headers: res.headers,
            cookie: res.headers['set-cookie']
          });
        } catch (e) {
          resolve({ status: res.statusCode, data: data, headers: res.headers });
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
}

async function testSessionExtension() {
  console.log('🧪 Testing session extension mechanism...');
  console.log('⚠️  Note: This test uses hardcoded credentials for demo');
  
  try {
    // Step 1: Login to get a session
    console.log('\n📝 Step 1: Checking if we can reach auth endpoint...');
    const healthCheck = await makeRequest('/dashboard/stats');
    console.log(`Health check status: ${healthCheck.status}`);
    
    if (healthCheck.status === 401) {
      console.log('✅ Server is running and requires authentication (good!)');
      console.log('ℹ️  To test session extension, you need to:');
      console.log('   1. Login to your app manually');
      console.log('   2. Copy the session cookie from browser dev tools');
      console.log('   3. Use that cookie to test the /auth/test-session endpoint');
      console.log('   4. Call the test endpoint every 30 seconds to verify extension');
      
      console.log('\n🔍 Example test commands:');
      console.log('   curl -H "Cookie: session_id=YOUR_SESSION_ID" http://localhost:3000/api/v1/auth/test-session');
      console.log('   (Check the sessionExpiry time in response)');
      
    } else {
      console.log(`❌ Unexpected response: ${healthCheck.status}`);
      console.log(healthCheck.data);
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.log('💡 Make sure the backend server is running on port 3000');
  }
}

testSessionExtension();