'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const tableExists = await queryInterface.tableExists('mst_plant');

    if (!tableExists) {
      await queryInterface.createTable('mst_plant', {
        plant_code: {
          type: Sequelize.STRING(10),
          allowNull: false,
          primaryKey: true,
          comment: 'Plant code - unique identifier'
        },
        description: {
          type: Sequelize.STRING(255),
          allowNull: true,
          defaultValue: null,
          comment: 'Plant description'
        }
      }, {
        comment: 'Master table for plant information',
        charset: 'utf8mb4',
        collate: 'utf8mb4_unicode_ci',
        timestamps: false
      });

      // Add index for description
      await queryInterface.addIndex('mst_plant', ['description'], {
        name: 'idx_mst_plant_description'
      });
    }
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('mst_plant');
  }
};