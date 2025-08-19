// Path: backend/src/features/session/sessionRoutes.js
const express = require('express');
const sessionController = require('./sessionController');
const SessionMiddleware = require('../../core/middleware/sessionMiddleware');

const router = express.Router();

// Apply session validation to all routes
router.use(SessionMiddleware.validateSession);

// User session management routes
router.get('/my-sessions', sessionController.getUserSessions);
router.delete('/my-sessions/:sessionId', sessionController.terminateSession);
router.delete('/my-sessions', sessionController.terminateOtherSessions);
router.post('/extend', sessionController.extendCurrentSession);
router.get('/current', sessionController.getCurrentSessionInfo);

// Admin-only routes
router.get('/stats', SessionMiddleware.requireAdmin, sessionController.getSessionStats);
router.post('/cleanup', SessionMiddleware.requireAdmin, sessionController.cleanupSessions);

module.exports = router;