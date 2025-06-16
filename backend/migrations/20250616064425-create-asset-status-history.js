'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const tableExists = await queryInterface.tableExists('asset_status_history');

    if (!tableExists) {
      await queryInterface.createTable('asset_status_history', {
        history_id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true,
          comment: 'History ID - auto increment'
        },
        asset_no: {
          type: Sequelize.STRING(20),
          allowNull: true,
          defaultValue: null,
          comment: 'Asset number reference'
        },
        old_status: {
          type: Sequelize.STRING(50),
          allowNull: true,
          defaultValue: null,
          comment: 'Previous status'
        },
        new_status: {
          type: Sequelize.STRING(50),
          allowNull: true,
          defaultValue: null,
          comment: 'New status'
        },
        changed_at: {
          type: Sequelize.DATE,
          allowNull: true,
          defaultValue: null,
          comment: 'Status change timestamp'
        },
        changed_by: {
          type: Sequelize.STRING(20),
          allowNull: true,
          defaultValue: null,
          comment: 'User who changed the status'
        },
        remarks: {
          type: Sequelize.TEXT,
          allowNull: true,
          defaultValue: null,
          comment: 'Change remarks'
        }
      }, {
        comment: 'Asset status change history table',
        charset: 'utf8mb4',
        collate: 'utf8mb4_unicode_ci',
        timestamps: false
      });

      // Add foreign key constraints (NO CASCADE)
      await queryInterface.addConstraint('asset_status_history', {
        fields: ['asset_no'],
        type: 'foreign key',
        name: 'fk_asset_status_history_asset_no',
        references: {
          table: 'asset_master',
          field: 'asset_no'
        },
        onDelete: 'NO ACTION',
        onUpdate: 'NO ACTION'
      });

      await queryInterface.addConstraint('asset_status_history', {
        fields: ['changed_by'],
        type: 'foreign key',
        name: 'fk_asset_status_history_changed_by',
        references: {
          table: 'mst_user',
          field: 'user_id'
        },
        onDelete: 'NO ACTION',
        onUpdate: 'NO ACTION'
      });

      // Add indexes
      await queryInterface.addIndex('asset_status_history', ['asset_no'], {
        name: 'idx_asset_status_history_asset_no'
      });

      await queryInterface.addIndex('asset_status_history', ['changed_by'], {
        name: 'idx_asset_status_history_changed_by'
      });
    }
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('asset_status_history');
  }
};