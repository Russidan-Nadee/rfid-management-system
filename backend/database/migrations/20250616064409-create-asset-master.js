'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const tableExists = await queryInterface.tableExists('asset_master');

    if (!tableExists) {
      await queryInterface.createTable('asset_master', {
        asset_no: {
          type: Sequelize.STRING(20),
          allowNull: false,
          primaryKey: true,
          comment: 'Asset number - unique identifier'
        },
        description: {
          type: Sequelize.STRING(255),
          allowNull: true,
          defaultValue: null,
          comment: 'Asset description'
        },
        plant_code: {
          type: Sequelize.STRING(10),
          allowNull: true,
          defaultValue: null,
          comment: 'Plant code reference'
        },
        location_code: {
          type: Sequelize.STRING(10),
          allowNull: true,
          defaultValue: null,
          comment: 'Location code reference'
        },
        serial_no: {
          type: Sequelize.STRING(50),
          allowNull: true,
          defaultValue: null,
          unique: true,
          comment: 'Serial number - unique'
        },
        inventory_no: {
          type: Sequelize.STRING(50),
          allowNull: true,
          defaultValue: null,
          unique: true,
          comment: 'Inventory number - unique'
        },
        quantity: {
          type: Sequelize.DECIMAL(10, 2),
          allowNull: true,
          defaultValue: null,
          comment: 'Asset quantity'
        },
        unit_code: {
          type: Sequelize.STRING(10),
          allowNull: true,
          defaultValue: null,
          comment: 'Unit of measurement'
        },
        status: {
          type: Sequelize.CHAR(1),
          allowNull: true,
          defaultValue: null,
          comment: 'Asset status'
        },
        created_by: {
          type: Sequelize.STRING(20),
          allowNull: true,
          defaultValue: null,
          comment: 'User who created this asset'
        },
        created_at: {
          type: Sequelize.DATE,
          allowNull: true,
          defaultValue: null,
          comment: 'Creation timestamp'
        },
        deactivated_at: {
          type: Sequelize.DATE,
          allowNull: true,
          defaultValue: null,
          comment: 'Deactivation timestamp'
        }
      }, {
        comment: 'Asset master table',
        charset: 'utf8mb4',
        collate: 'utf8mb4_unicode_ci',
        timestamps: false
      });

      // Add foreign key constraints
      await queryInterface.addConstraint('asset_master', {
        fields: ['plant_code'],
        type: 'foreign key',
        name: 'fk_asset_master_plant_code',
        references: {
          table: 'mst_plant',
          field: 'plant_code'
        },
        onDelete: 'SET NULL',
        onUpdate: 'CASCADE'
      });

      await queryInterface.addConstraint('asset_master', {
        fields: ['location_code'],
        type: 'foreign key',
        name: 'fk_asset_master_location_code',
        references: {
          table: 'mst_location',
          field: 'location_code'
        },
        onDelete: 'SET NULL',
        onUpdate: 'CASCADE'
      });

      await queryInterface.addConstraint('asset_master', {
        fields: ['unit_code'],
        type: 'foreign key',
        name: 'fk_asset_master_unit_code',
        references: {
          table: 'mst_unit',
          field: 'unit_code'
        },
        onDelete: 'RESTRICT',
        onUpdate: 'CASCADE'
      });

      await queryInterface.addConstraint('asset_master', {
        fields: ['created_by'],
        type: 'foreign key',
        name: 'fk_asset_master_created_by',
        references: {
          table: 'mst_user',
          field: 'user_id'
        },
        onDelete: 'RESTRICT',
        onUpdate: 'CASCADE'
      });

      // Add indexes
      await queryInterface.addIndex('asset_master', ['plant_code'], {
        name: 'idx_asset_master_plant_code'
      });

      await queryInterface.addIndex('asset_master', ['location_code'], {
        name: 'idx_asset_master_location_code'
      });

      await queryInterface.addIndex('asset_master', ['unit_code'], {
        name: 'idx_asset_master_unit_code'
      });

      await queryInterface.addIndex('asset_master', ['status'], {
        name: 'idx_asset_master_status'
      });

      await queryInterface.addIndex('asset_master', ['created_by'], {
        name: 'idx_asset_master_created_by'
      });

      await queryInterface.addIndex('asset_master', ['created_at'], {
        name: 'idx_asset_master_created_at'
      });

      // Add unique constraints
      await queryInterface.addIndex('asset_master', ['serial_no'], {
        name: 'uk_asset_master_serial_no',
        unique: true
      });

      await queryInterface.addIndex('asset_master', ['inventory_no'], {
        name: 'uk_asset_master_inventory_no',
        unique: true
      });
    }
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('asset_master');
  }
};