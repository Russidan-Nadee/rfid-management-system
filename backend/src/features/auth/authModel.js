// Path: backend/src/models/authModel.js
const { BaseModel } = require('../scan/scanModel');

class AuthModel extends BaseModel {
   constructor() {
      super('mst_user');
   }

   async findUserByEmployeeId(employeeId) {
      const query = `
            SELECT user_id, full_name, employee_id, department, position, 
                   company_role, email, role, is_active,
                   created_at, updated_at, last_login 
            FROM mst_user 
            WHERE employee_id = ?
        `;
      const results = await this.executeQuery(query, [employeeId]);
      return results[0] || null;
   }

   async findUserById(userId) {
      const query = `
            SELECT user_id, full_name, employee_id, department, position, 
                   company_role, email, role, is_active,
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

   async createOrUpdateUser(employeeData) {
      // Check if user exists by employee_id
      const existingUser = await this.findUserByEmployeeId(employeeData.employee_id);
      
      if (existingUser) {
         // Update existing user with fresh employee data
         const query = `
               UPDATE mst_user 
               SET full_name = ?, department = ?, position = ?, 
                   company_role = ?, email = ?, is_active = ?, updated_at = NOW() 
               WHERE employee_id = ?
         `;
         const params = [
            employeeData.full_name,
            employeeData.department,
            employeeData.position,
            employeeData.company_role,
            employeeData.email,
            employeeData.is_active,
            employeeData.employee_id
         ];
         await this.executeQuery(query, params);
         return this.findUserByEmployeeId(employeeData.employee_id);
      } else {
         // Create new user with employee data
         const userId = `USR_${employeeData.employee_id}`;
         const query = `
               INSERT INTO mst_user (
                  user_id, full_name, employee_id, department, position, 
                  company_role, email, role, is_active, created_at, updated_at
               ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
         `;
         const params = [
            userId,
            employeeData.full_name,
            employeeData.employee_id,
            employeeData.department,
            employeeData.position,
            employeeData.company_role,
            employeeData.email,
            employeeData.role || 'viewer', // Default system role
            employeeData.is_active
         ];
         await this.executeQuery(query, params);
         return this.findUserByEmployeeId(employeeData.employee_id);
      }
   }

   async updateUserRole(userId, role) {
      const query = `
            UPDATE mst_user 
            SET role = ?, updated_at = NOW() 
            WHERE user_id = ?
        `;
      return this.executeQuery(query, [role, userId]);
   }

   async getAllUsers() {
      const query = `
            SELECT user_id, full_name, employee_id, department, position, 
                   company_role, email, role, is_active,
                   created_at, updated_at, last_login 
            FROM mst_user 
            ORDER BY full_name
        `;
      return this.executeQuery(query);
   }

   async getUsersByRole(role) {
      const query = `
            SELECT user_id, full_name, employee_id, department, position, 
                   company_role, email, role, is_active,
                   created_at, updated_at, last_login 
            FROM mst_user 
            WHERE role = ?
            ORDER BY full_name
        `;
      return this.executeQuery(query, [role]);
   }
}

module.exports = AuthModel;