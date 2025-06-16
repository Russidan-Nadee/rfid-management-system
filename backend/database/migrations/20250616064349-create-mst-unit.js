'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const tableExists = await queryInterface.tableExists('mst_unit');

    if (!tableExists) {
      await queryInterface.createTable('mst_unit', {
        unit_code: {
          type: Sequelize.STRING(10),
          allowNull: false,
          primaryKey: true,
          comment: 'Unit code - unique identifier'
        },
        name: {
          type: Sequelize.STRING(50),
          allowNull: true,
          defaultValue: null,
          comment: 'Unit name'
        }
      }, {
        comment: 'Master table for unit of measurement',
        charset: 'utf8mb4',
        collate: 'utf8mb4_unicode_ci',
        timestamps: false
      });

      // Add index for name
      await queryInterface.addIndex('mst_unit', ['name'], {
        name: 'idx_mst_unit_name'
      });
    }
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('mst_unit');
  }
};