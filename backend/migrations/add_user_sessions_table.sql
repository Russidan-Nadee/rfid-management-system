-- Add user_sessions table for HTTP-only cookie session management
-- Created: 2025-08-19
-- Description: Secure session storage for authentication using HTTP-only cookies

CREATE TABLE IF NOT EXISTS user_sessions (
    session_id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    device_type VARCHAR(50),
    location_info VARCHAR(255),
    
    -- Foreign key constraint
    CONSTRAINT fk_user_sessions_user_id 
        FOREIGN KEY (user_id) REFERENCES mst_user(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
        
    -- Indexes for performance
    INDEX idx_user_sessions_user_id (user_id),
    INDEX idx_user_sessions_expires_at (expires_at),
    INDEX idx_user_sessions_last_activity (last_activity),
    INDEX idx_user_sessions_active (is_active),
    INDEX idx_user_sessions_cleanup (expires_at, is_active)
);

-- Add cleanup stored procedure for expired sessions
DELIMITER //

CREATE PROCEDURE CleanupExpiredSessions()
BEGIN
    -- Delete expired sessions
    DELETE FROM user_sessions 
    WHERE expires_at < NOW() OR is_active = FALSE;
    
    -- Log cleanup operation
    INSERT INTO user_login_log (
        user_id, 
        username, 
        event_type, 
        timestamp, 
        session_id, 
        success
    ) VALUES (
        'SYSTEM', 
        'session_cleanup', 
        'logout', 
        NOW(), 
        'CLEANUP_JOB', 
        TRUE
    );
END//

DELIMITER ;

-- Add event to run cleanup every hour
-- Note: This requires SUPER privileges, might need to be run separately
-- CREATE EVENT IF NOT EXISTS session_cleanup_event
-- ON SCHEDULE EVERY 1 HOUR
-- DO CALL CleanupExpiredSessions();

-- Add session activity tracking trigger
DELIMITER //

CREATE TRIGGER update_session_activity 
BEFORE UPDATE ON user_sessions
FOR EACH ROW
BEGIN
    IF OLD.last_activity != NEW.last_activity THEN
        SET NEW.last_activity = CURRENT_TIMESTAMP;
    END IF;
END//

DELIMITER ;

-- Sample indexes for analytics (optional)
-- These can help with session analytics and monitoring
CREATE INDEX idx_user_sessions_device_type ON user_sessions(device_type);
CREATE INDEX idx_user_sessions_created_at ON user_sessions(created_at);
CREATE INDEX idx_user_sessions_duration ON user_sessions(created_at, last_activity);