'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const tableExists = await queryInterface.tableExists('asset_scan_log');

    if (!tableExists) {
      await queryInterface.createTable('asset_scan_log', {
        scan_id: {
          type: Sequelize.INTEGER,
          allowNull: false,
          primaryKey: true,
          autoIncrement: true,
          comment: 'Scan ID - auto increment'
        },
        asset_no: {
          type: Sequelize.STRING(20),
          allowNull: true,
          defaultValue: null,
          comment: 'Asset number reference'
        },
        scanned_by: {
          type: Sequelize.STRING(20),
          allowNull: true,
          defaultValue: null,
          comment: 'User who scanned the asset'
        },
        location_code: {
          type: Sequelize.STRING(10),
          allowNull: true,
          defaultValue: null,
          comment: 'Location where asset was scanned'
        },
        ip_address: {
          type: Sequelize.STRING(45),
          allowNull: true,
          defaultValue: null,
          comment: 'IP address of scanning device'
        },
        user_agent: {
          type: Sequelize.TEXT,
          allowNull: true,
          defaultValue: null,
          comment: 'User agent of scanning device'
        },
        scanned_at: {
          type: Sequelize.DATE,
          allowNull: true,
          defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
          comment: 'Scan timestamp'
        }
      }, {
        comment: 'Asset scan log table',
        charset: 'utf8mb4',
        collate: 'utf8mb4_unicode_ci',
        timestamps: false
      });

      // Add foreign key constraints (NO CASCADE)
      await queryInterface.addConstraint('asset_scan_log', {
        fields: ['asset_no'],
        type: 'foreign key',
        name: 'fk_asset_scan_log_asset_no',
        references: {
          table: 'asset_master',
          field: 'asset_no'
        },
        onDelete: 'NO ACTION',
        onUpdate: 'NO ACTION'
      });

      await queryInterface.addConstraint('asset_scan_log', {
        fields: ['scanned_by'],
        type: 'foreign key',
        name: 'fk_asset_scan_log_scanned_by',
        references: {
          table: 'mst_user',
          field: 'user_id'
        },
        onDelete: 'NO ACTION',
        onUpdate: 'NO ACTION'
      });

      await queryInterface.addConstraint('asset_scan_log', {
        fields: ['location_code'],
        type: 'foreign key',
        name: 'fk_asset_scan_log_location_code',
        references: {
          table: 'mst_location',
          field: 'location_code'
        },
        onDelete: 'NO ACTION',
        onUpdate: 'NO ACTION'
      });

      // Add indexes
      await queryInterface.addIndex('asset_scan_log', ['asset_no'], {
        name: 'idx_asset_scan_log_asset_no'
      });

      await queryInterface.addIndex('asset_scan_log', ['scanned_by'], {
        name: 'idx_asset_scan_log_scanned_by'
      });

      await queryInterface.addIndex('asset_scan_log', ['location_code'], {
        name: 'idx_asset_scan_log_location_code'
      });
    }
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('asset_scan_log');
  }
};