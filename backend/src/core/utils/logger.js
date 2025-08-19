// Path: backend/src/core/utils/logger.js
const fs = require('fs');
const path = require('path');

class Logger {
  constructor(component = 'APP') {
    this.component = component;
    this.logDir = path.join(__dirname, '../../../logs');
    
    // Ensure logs directory exists
    if (!fs.existsSync(this.logDir)) {
      fs.mkdirSync(this.logDir, { recursive: true });
    }
  }

  formatMessage(level, message, data = null) {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] [${level}] [${this.component}] ${message}`;
    
    if (data) {
      return `${logMessage} ${JSON.stringify(data)}`;
    }
    
    return logMessage;
  }

  writeToFile(level, message) {
    const logFile = path.join(this.logDir, `${level}.log`);
    fs.appendFileSync(logFile, message + '\n');
  }

  info(message, data = null) {
    const formattedMessage = this.formatMessage('INFO', message, data);
    console.log(formattedMessage);
    this.writeToFile('info', formattedMessage);
  }

  error(message, data = null) {
    const formattedMessage = this.formatMessage('ERROR', message, data);
    console.error(formattedMessage);
    this.writeToFile('error', formattedMessage);
  }

  warn(message, data = null) {
    const formattedMessage = this.formatMessage('WARN', message, data);
    console.warn(formattedMessage);
    this.writeToFile('warn', formattedMessage);
  }

  debug(message, data = null) {
    if (process.env.NODE_ENV === 'development') {
      const formattedMessage = this.formatMessage('DEBUG', message, data);
      console.log(formattedMessage);
      this.writeToFile('debug', formattedMessage);
    }
  }
}

function createLogger(component) {
  return new Logger(component);
}

module.exports = { Logger, createLogger };