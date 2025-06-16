'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const tableExists = await queryInterface.tableExists('user_login_log');

    if (!tableExists) {
      await queryInterface.createTable('user_login_log', {
        log_id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true,
          comment: 'Log ID - auto increment'
        },
        user_id: {
          type: Sequelize.STRING(20),
          allowNull: true,
          defaultValue: null,
          comment: 'User ID reference'
        },
        username: {
          type: Sequelize.STRING(100),
          allowNull: true,
          defaultValue: null,
          comment: 'Username used for login attempt'
        },
        event_type: {
          type: Sequelize.ENUM('login', 'logout', 'failed_login', 'password_change'),
          allowNull: true,
          defaultValue: null,
          comment: 'Type of login event'
        },
        timestamp: {
          type: Sequelize.DATE,
          allowNull: true,
          defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
          comment: 'Event timestamp'
        },
        ip_address: {
          type: Sequelize.STRING(50),
          allowNull: true,
          defaultValue: null,
          comment: 'IP address of the client'
        },
        user_agent: {
          type: Sequelize.TEXT,
          allowNull: true,
          defaultValue: null,
          comment: 'User agent string'
        },
        session_id: {
          type: Sequelize.STRING(255),
          allowNull: true,
          defaultValue: null,
          comment: 'Session identifier'
        },
        success: {
          type: Sequelize.TINYINT(1),
          allowNull: true,
          defaultValue: 1,
          comment: 'Success flag (1=success, 0=failure)'
        }
      }, {
        comment: 'User login activity log table',
        charset: 'utf8mb4',
        collate: 'utf8mb4_unicode_ci',
        timestamps: false
      });

      // Add foreign key constraint (NO CASCADE)
      await queryInterface.addConstraint('user_login_log', {
        fields: ['user_id'],
        type: 'foreign key',
        name: 'fk_user_login_log_user_id',
        references: {
          table: 'mst_user',
          field: 'user_id'
        },
        onDelete: 'NO ACTION',
        onUpdate: 'NO ACTION'
      });

      // Add index for user_id
      await queryInterface.addIndex('user_login_log', ['user_id'], {
        name: 'idx_user_login_log_user_id'
      });
    }
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('user_login_log');
  }
};