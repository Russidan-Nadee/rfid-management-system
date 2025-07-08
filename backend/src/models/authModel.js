// Path: backend/src/models/authModel.js
const { BaseModel } = require('../features/scan/scanModel');

class AuthModel extends BaseModel {
   constructor() {
      super('mst_user');
   }

   async findUserByUsername(username) {
      const query = `
            SELECT user_id, username, full_name, password, role, 
                   created_at, updated_at, last_login 
            FROM mst_user 
            WHERE username = ?
        `;
      const results = await this.executeQuery(query, [username]);
      return results[0] || null;
   }

   async findUserById(userId) {
      const query = `
            SELECT user_id, username, full_name, role, 
                   created_at, updated_at, last_login 
            FROM mst_user 
            WHERE user_id = ?
        `;
      const results = await this.executeQuery(query, [userId]);
      return results[0] || null;
   }

   async updateLastLogin(userId) {
      const query = `
            UPDATE mst_user 
            SET last_login = NOW(), updated_at = NOW() 
            WHERE user_id = ?
        `;
      return this.executeQuery(query, [userId]);
   }

   async updatePassword(userId, hashedPassword) {
      const query = `
            UPDATE mst_user 
            SET password = ?, updated_at = NOW() 
            WHERE user_id = ?
        `;
      return this.executeQuery(query, [hashedPassword, userId]);
   }

   async createUser(userData) {
      const query = `
            INSERT INTO mst_user (user_id, username, full_name, password, role, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, NOW(), NOW())
        `;
      const params = [
         userData.user_id,
         userData.username,
         userData.full_name,
         userData.password,
         userData.role || 'user'
      ];
      return this.executeQuery(query, params);
   }

   async updateUserRole(userId, role) {
      const query = `
            UPDATE mst_user 
            SET role = ?, updated_at = NOW() 
            WHERE user_id = ?
        `;
      return this.executeQuery(query, [role, userId]);
   }
}

module.exports = AuthModel;