// Mock LDAP Service
// Simulates LDAP authentication without actual LDAP server
class MockLdapService {
   constructor() {
      // Mock LDAP users - in real implementation, this would connect to actual LDAP
      this.mockUsers = [
         { ldap_username: 'user1', password: 'password123', employee_id: '000001' },
         { ldap_username: 'jane.smith', password: 'password123', employee_id: '000002' },
         { ldap_username: 'mike.wilson', password: 'password123', employee_id: '000003' },
         { ldap_username: 'sarah.johnson', password: 'password123', employee_id: '000004' },
         { ldap_username: 'admin', password: 'password123', employee_id: '999999' }
      ];
   }

   /**
    * Mock LDAP authentication
    * @param {string} ldapUsername - LDAP username (not stored in database)
    * @param {string} password - User password
    * @returns {Promise<{success: boolean, employee_id?: string, message?: string}>}
    */
   async authenticate(ldapUsername, password) {
      try {
         // Simulate network delay
         await new Promise(resolve => setTimeout(resolve, 100));

         const user = this.mockUsers.find(u =>
            u.ldap_username === ldapUsername && u.password === password
         );

         if (user) {
            return {
               success: true,
               employee_id: user.employee_id,
               message: 'LDAP authentication successful'
            };
         } else {
            return {
               success: false,
               message: 'Invalid LDAP credentials'
            };
         }
      } catch (error) {
         console.error('Mock LDAP authentication error:', error);
         return {
            success: false,
            message: 'LDAP service unavailable'
         };
      }
   }

   /**
    * Check if LDAP service is available
    * @returns {Promise<boolean>}
    */
   async isAvailable() {
      // Mock service availability check
      return true;
   }

   /**
    * Get mock user list (for testing purposes only)
    * @returns {Array}
    */
   getMockUsers() {
      return this.mockUsers.map(user => ({
         ldap_username: user.ldap_username,
         employee_id: user.employee_id
      }));
   }
}

module.exports = MockLdapService;