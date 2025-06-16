'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('mst_unit', {
      unit_code: {
        type: Sequelize.STRING(10),
        allowNull: false,
        primaryKey: true,
        comment: 'Unit code - unique identifier'
      },
      name: {
        type: Sequelize.STRING(50),
        allowNull: false,
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
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('mst_unit');
  }
};