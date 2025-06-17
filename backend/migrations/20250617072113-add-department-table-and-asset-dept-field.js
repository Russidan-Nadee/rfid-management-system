'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // 1. Create mst_department table
    const deptTableExists = await queryInterface.tableExists('mst_department');
    if (!deptTableExists) {
      await queryInterface.createTable('mst_department', {
        dept_code: {
          type: Sequelize.STRING(10),
          allowNull: false,
          primaryKey: true,
          comment: 'Department code - unique identifier'
        },
        description: {
          type: Sequelize.STRING(255),
          allowNull: true,
          defaultValue: null,
          comment: 'Department description'
        },
        plant_code: {
          type: Sequelize.STRING(10),
          allowNull: true,
          defaultValue: null,
          comment: 'Plant code reference'
        }
      }, {
        comment: 'Master table for department information',
        charset: 'utf8mb4',
        collate: 'utf8mb4_unicode_ci',
        timestamps: false
      });

      // Add foreign key constraint to plant
      await queryInterface.addConstraint('mst_department', {
        fields: ['plant_code'],
        type: 'foreign key',
        name: 'fk_mst_department_plant_code',
        references: {
          table: 'mst_plant',
          field: 'plant_code'
        },
        onDelete: 'RESTRICT',
        onUpdate: 'CASCADE'
      });

      // Add index for plant_code
      await queryInterface.addIndex('mst_department', ['plant_code'], {
        name: 'idx_mst_department_plant_code'
      });
    }

    // 2. Add dept_code column to asset_master
    const assetTable = await queryInterface.describeTable('asset_master');
    if (!assetTable.dept_code) {
      // Add column using raw SQL to ensure exact type match
      await queryInterface.sequelize.query(`
        ALTER TABLE asset_master 
        ADD COLUMN dept_code VARCHAR(10) DEFAULT NULL COMMENT 'Department code reference' 
        AFTER location_code
      `);

      // Add foreign key constraint
      await queryInterface.sequelize.query(`
        ALTER TABLE asset_master 
        ADD CONSTRAINT fk_asset_master_dept_code 
        FOREIGN KEY (dept_code) REFERENCES mst_department(dept_code) 
        ON DELETE SET NULL ON UPDATE CASCADE
      `);

      // Add index
      await queryInterface.sequelize.query(`
        ALTER TABLE asset_master 
        ADD INDEX idx_asset_master_dept_code (dept_code)
      `);
    }
  },

  async down(queryInterface, Sequelize) {
    // Remove dept_code from asset_master
    const assetTable = await queryInterface.describeTable('asset_master');
    if (assetTable.dept_code) {
      await queryInterface.removeConstraint('asset_master', 'fk_asset_master_dept_code');
      await queryInterface.removeIndex('asset_master', 'idx_asset_master_dept_code');
      await queryInterface.removeColumn('asset_master', 'dept_code');
    }

    // Drop mst_department table
    await queryInterface.dropTable('mst_department');
  }
};