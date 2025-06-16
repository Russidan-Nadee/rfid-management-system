'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('mst_user', {
      user_id: {
        type: Sequelize.STRING(20),
        allowNull: false,
        primaryKey: true,
        comment: 'User ID - unique identifier'
      },
      username: {
        type: Sequelize.STRING(100),
        allowNull: false,
        unique: true,
        comment: 'Username for login'
      },
      full_name: {
        type: Sequelize.STRING(255),
        allowNull: false,
        comment: 'Full name of user'
      },
      password: {
        type: Sequelize.STRING(255),
        allowNull: false,
        comment: 'Hashed password'
      },
      role: {
        type: Sequelize.ENUM('admin', 'manager', 'user', 'viewer'),
        allowNull: false,
        defaultValue: 'user',
        comment: 'User role'
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
        comment: 'Record creation timestamp'
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),
        comment: 'Record update timestamp'
      },
      last_login: {
        type: Sequelize.DATE,
        allowNull: true,
        comment: 'Last login timestamp'
      }
    }, {
      comment: 'Master table for user information',
      charset: 'utf8mb4',
      collate: 'utf8mb4_unicode_ci',
      timestamps: false
    });

    // Add indexes
    await queryInterface.addIndex('mst_user', ['username'], {
      name: 'uk_mst_user_username',
      unique: true
    });
    await queryInterface.addIndex('mst_user', ['full_name'], {
      name: 'idx_mst_user_full_name'
    });
    await queryInterface.addIndex('mst_user', ['role'], {
      name: 'idx_mst_user_role'
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('mst_user');
  }
};