'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const tableExists = await queryInterface.tableExists('export_history');

    if (!tableExists) {
      await queryInterface.createTable('export_history', {
        export_id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true,
          comment: 'Export ID - auto increment'
        },
        user_id: {
          type: Sequelize.STRING(20),
          allowNull: false,
          comment: 'User who requested the export'
        },
        export_type: {
          type: Sequelize.ENUM('assets', 'scan_logs', 'status_history'),
          allowNull: false,
          comment: 'Type of export'
        },
        status: {
          type: Sequelize.CHAR(1),
          allowNull: false,
          defaultValue: 'P',
          comment: 'Export status: P=Pending, C=Completed, F=Failed'
        },
        export_config: {
          type: Sequelize.JSON,
          allowNull: false,
          comment: 'Export configuration in JSON format'
        },
        file_path: {
          type: Sequelize.STRING(500),
          allowNull: true,
          defaultValue: null,
          comment: 'Path to exported file'
        },
        file_size: {
          type: Sequelize.BIGINT,
          allowNull: true,
          defaultValue: null,
          comment: 'Size of exported file in bytes'
        },
        total_records: {
          type: Sequelize.INTEGER,
          allowNull: true,
          defaultValue: null,
          comment: 'Total number of records exported'
        },
        created_at: {
          type: Sequelize.DATE,
          allowNull: false,
          defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
          comment: 'Export request timestamp'
        },
        expires_at: {
          type: Sequelize.DATE,
          allowNull: true,
          defaultValue: null,
          comment: 'Export file expiration timestamp'
        },
        error_message: {
          type: Sequelize.TEXT,
          allowNull: true,
          defaultValue: null,
          comment: 'Error message if export failed'
        }
      }, {
        comment: 'Export history and status tracking table',
        charset: 'utf8mb4',
        collate: 'utf8mb4_unicode_ci',
        timestamps: false
      });

      // Add foreign key constraint (NO CASCADE)
      await queryInterface.addConstraint('export_history', {
        fields: ['user_id'],
        type: 'foreign key',
        name: 'fk_export_history_user_id',
        references: {
          table: 'mst_user',
          field: 'user_id'
        },
        onDelete: 'NO ACTION',
        onUpdate: 'NO ACTION'
      });

      // Add indexes
      await queryInterface.addIndex('export_history', ['user_id'], {
        name: 'idx_export_history_user_id'
      });

      await queryInterface.addIndex('export_history', ['created_at'], {
        name: 'idx_export_history_created_at'
      });

      await queryInterface.addIndex('export_history', ['expires_at'], {
        name: 'idx_export_history_expires_at'
      });
    }
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('export_history');
  }
};