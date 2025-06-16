'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const tableExists = await queryInterface.tableExists('mst_location');

    if (!tableExists) {
      await queryInterface.createTable('mst_location', {
        location_code: {
          type: Sequelize.STRING(10),
          allowNull: false,
          primaryKey: true,
          comment: 'Location code - unique identifier'
        },
        description: {
          type: Sequelize.STRING(255),
          allowNull: true,
          defaultValue: null,
          comment: 'Location description'
        },
        plant_code: {
          type: Sequelize.STRING(10),
          allowNull: true,
          defaultValue: null,
          comment: 'Plant code reference'
        }
      }, {
        comment: 'Master table for location information',
        charset: 'utf8mb4',
        collate: 'utf8mb4_unicode_ci',
        timestamps: false
      });

      // Add foreign key constraint (NO CASCADE)
      await queryInterface.addConstraint('mst_location', {
        fields: ['plant_code'],
        type: 'foreign key',
        name: 'fk_mst_location_plant_code',
        references: {
          table: 'mst_plant',
          field: 'plant_code'
        },
        onDelete: 'NO ACTION',
        onUpdate: 'NO ACTION'
      });

      // Add index for plant_code
      await queryInterface.addIndex('mst_location', ['plant_code'], {
        name: 'idx_mst_location_plant_code'
      });
    }
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('mst_location');
  }
};