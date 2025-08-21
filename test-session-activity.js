// Test script to verify session activity extension
const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api/v1';

async function testSessionActivity() {
  console.log('🧪 Starting session activity test...');
  
  try {
    // First, we need to login to get a session
    console.log('📝 Step 1: Attempting login...');
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      ldap_username: 'test_user', // You'll need to use real credentials
      password: 'test_password'
    }, {
      withCredentials: true
    });
    
    console.log('✅ Login successful');
    console.log('Session expires at:', loginResponse.data.data?.expiresAt);
    
    const cookies = loginResponse.headers['set-cookie'];
    const cookieHeader = cookies ? cookies.join('; ') : '';
    
    // Test session extension by calling test endpoint repeatedly
    console.log('🔄 Step 2: Testing session extension...');
    
    for (let i = 0; i < 20; i++) {
      await new Promise(resolve => setTimeout(resolve, 15000)); // Wait 15 seconds
      
      try {
        const testResponse = await axios.get(`${BASE_URL}/auth/test-session`, {
          headers: {
            'Cookie': cookieHeader
          },
          withCredentials: true
        });
        
        console.log(`✅ Test ${i + 1}/20: Session active`);
        console.log(`   User: ${testResponse.data.user}`);
        console.log(`   Expires: ${testResponse.data.sessionExpiry}`);
        console.log(`   Time: ${new Date().toISOString()}`);
        
      } catch (error) {
        console.log(`❌ Test ${i + 1}/20: Session failed`);
        console.log(`   Error: ${error.response?.status} - ${error.response?.data?.message}`);
        break;
      }
    }
    
    console.log('🏁 Test completed');
    
  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

testSessionActivity();