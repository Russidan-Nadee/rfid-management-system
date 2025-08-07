// Mock Employee Information System Service
// Simulates fetching employee data from company's Employee Information System
class MockEmployeeInfoService {
   constructor() {
      // Mock employee database - in real implementation, this would call actual Employee Information System API
      this.mockEmployees = [
         {
            employee_id: '000001',
            full_name: 'John Doe',
            department: 'Information Technology',
            position: 'Senior Developer',
            company_role: 'Senior Staff',
            email: 'john.doe@company.com',
            is_active: true
         },
         {
            employee_id: '000002',
            full_name: 'Jane Smith',
            department: 'Human Resources',
            position: 'HR Manager',
            company_role: 'Manager',
            email: 'jane.smith@company.com',
            is_active: true
         },
         {
            employee_id: '000003',
            full_name: 'Mike Wilson',
            department: 'Operations',
            position: 'Operations Coordinator',
            company_role: 'Staff',
            email: 'mike.wilson@company.com',
            is_active: true
         },
         {
            employee_id: '000004',
            full_name: 'Sarah Johnson',
            department: 'Finance',
            position: 'Financial Analyst',
            company_role: 'Staff',
            email: 'sarah.johnson@company.com',
            is_active: true
         },
         {
            employee_id: '999999',
            full_name: 'System Administrator',
            department: 'Information Technology',
            position: 'IT Administrator',
            company_role: 'Administrator',
            email: 'admin@company.com',
            is_active: true
         }
      ];
   }

   /**
    * Get employee information by employee ID
    * @param {string} employeeId - Employee ID from LDAP
    * @returns {Promise<{success: boolean, employee?: Object, message?: string}>}
    */
   async getEmployeeById(employeeId) {
      try {
         // Simulate API call delay
         await new Promise(resolve => setTimeout(resolve, 150));

         const employee = this.mockEmployees.find(emp => emp.employee_id === employeeId);

         if (employee) {
            return {
               success: true,
               employee: { ...employee },
               message: 'Employee information retrieved successfully'
            };
         } else {
            return {
               success: false,
               message: `Employee with ID ${employeeId} not found in Employee Information System`
            };
         }
      } catch (error) {
         console.error('Mock Employee Information System error:', error);
         return {
            success: false,
            message: 'Employee Information System service unavailable'
         };
      }
   }

   /**
    * Get multiple employees by IDs
    * @param {Array<string>} employeeIds - Array of employee IDs
    * @returns {Promise<{success: boolean, employees?: Array, message?: string}>}
    */
   async getEmployeesByIds(employeeIds) {
      try {
         await new Promise(resolve => setTimeout(resolve, 200));

         const employees = this.mockEmployees.filter(emp =>
            employeeIds.includes(emp.employee_id)
         );

         return {
            success: true,
            employees: employees.map(emp => ({ ...emp })),
            message: `Retrieved ${employees.length} employees`
         };
      } catch (error) {
         console.error('Mock Employee Information System error:', error);
         return {
            success: false,
            message: 'Employee Information System service unavailable'
         };
      }
   }

   /**
    * Check if Employee Information System is available
    * @returns {Promise<boolean>}
    */
   async isAvailable() {
      // Mock service availability check
      return true;
   }

   /**
    * Get all mock employees (for testing purposes only)
    * @returns {Array}
    */
   getMockEmployees() {
      return this.mockEmployees.map(emp => ({ ...emp }));
   }

   /**
    * Search employees by department
    * @param {string} department - Department name
    * @returns {Promise<{success: boolean, employees?: Array, message?: string}>}
    */
   async getEmployeesByDepartment(department) {
      try {
         await new Promise(resolve => setTimeout(resolve, 100));

         const employees = this.mockEmployees.filter(emp =>
            emp.department.toLowerCase().includes(department.toLowerCase())
         );

         return {
            success: true,
            employees: employees.map(emp => ({ ...emp })),
            message: `Found ${employees.length} employees in ${department}`
         };
      } catch (error) {
         console.error('Mock Employee Information System error:', error);
         return {
            success: false,
            message: 'Employee Information System service unavailable'
         };
      }
   }
}

module.exports = MockEmployeeInfoService;