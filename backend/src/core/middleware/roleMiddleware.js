// backend/src/core/middlewares/roleMiddleware.js

const requireRole = (allowedRoles) => {
   return (req, res, next) => {
      try {
         if (!req.user) {
            return res.status(401).json({
               success: false,
               message: 'Authentication required',
               timestamp: new Date().toISOString()
            });
         }

         const userRole = req.user.role;

         // Convert single role to array
         const roles = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];

         if (!roles.includes(userRole)) {
            return res.status(403).json({
               success: false,
               message: `Access denied. Required role: ${roles.join(' or ')}`,
               timestamp: new Date().toISOString()
            });
         }

         next();
      } catch (error) {
         console.error('Role check error:', error);
         return res.status(500).json({
            success: false,
            message: 'Authorization check failed',
            timestamp: new Date().toISOString()
         });
      }
   };
};

const requireAdmin = requireRole(['admin']);
const requireManagerOrAdmin = requireRole(['admin', 'manager']);
const requireUserOrAbove = requireRole(['admin', 'manager', 'user']);

module.exports = {
   requireRole,
   requireAdmin,
   requireManagerOrAdmin,
   requireUserOrAbove
};
