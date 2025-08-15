const prisma = require('../database/prisma');

/**
 * Centralized status change logging utility
 * This ensures all asset status changes are logged consistently across the application
 */
class StatusChangeLogger {
  /**
   * Log a status change for an asset
   * @param {Object} params - Parameters for logging the status change
   * @param {string} params.assetNo - Asset number
   * @param {string} params.oldStatus - Previous status
   * @param {string} params.newStatus - New status
   * @param {string|null} params.changedBy - User ID who made the change
   * @param {string|null} params.remarks - Optional remarks about the change
   * @param {Object|null} params.tx - Optional Prisma transaction object
   * @returns {Promise<Object>} The created status history record
   */
  static async logStatusChange({ assetNo, oldStatus, newStatus, changedBy, remarks = null, tx = null }) {
    // Skip logging if status didn't actually change
    if (oldStatus === newStatus) {
      return null;
    }

    const prismaClient = tx || prisma;
    
    try {
      const statusHistory = await prismaClient.asset_status_history.create({
        data: {
          asset_no: assetNo,
          old_status: oldStatus,
          new_status: newStatus,
          changed_at: new Date(),
          changed_by: changedBy,
          remarks: remarks || `Status changed from ${oldStatus} to ${newStatus}`
        }
      });

      console.log(`Status change logged for asset ${assetNo}: ${oldStatus} -> ${newStatus} by ${changedBy || 'system'}`);
      return statusHistory;
    } catch (error) {
      console.error('Failed to log status change:', error);
      // Don't throw error to avoid breaking the main operation
      return null;
    }
  }

  /**
   * Enhanced update method that automatically logs status changes
   * @param {Object} params - Parameters for the update
   * @param {string} params.assetNo - Asset number
   * @param {Object} params.updateData - Data to update
   * @param {string|null} params.changedBy - User ID who made the change
   * @param {string|null} params.remarks - Optional remarks
   * @param {Object|null} params.tx - Optional Prisma transaction object
   * @returns {Promise<Object>} The updated asset
   */
  static async updateAssetWithLogging({ assetNo, updateData, changedBy, remarks = null, tx = null }) {
    const prismaClient = tx || prisma;
    
    return await prismaClient.$transaction(async (transaction) => {
      // Get current asset data
      const currentAsset = await transaction.asset_master.findUnique({
        where: { asset_no: assetNo }
      });

      if (!currentAsset) {
        throw new Error(`Asset ${assetNo} not found`);
      }

      // Update the asset
      const updatedAsset = await transaction.asset_master.update({
        where: { asset_no: assetNo },
        data: updateData
      });

      // Log status change if status was updated
      if (updateData.status && updateData.status !== currentAsset.status) {
        await this.logStatusChange({
          assetNo,
          oldStatus: currentAsset.status,
          newStatus: updateData.status,
          changedBy,
          remarks,
          tx: transaction
        });
      }

      return updatedAsset;
    });
  }

  /**
   * Enhanced update by EPC method that automatically logs status changes
   * @param {Object} params - Parameters for the update
   * @param {string} params.epcCode - EPC code
   * @param {Object} params.updateData - Data to update
   * @param {string|null} params.changedBy - User ID who made the change
   * @param {string|null} params.remarks - Optional remarks
   * @param {Object|null} params.tx - Optional Prisma transaction object
   * @returns {Promise<Object>} The updated asset
   */
  static async updateAssetByEpcWithLogging({ epcCode, updateData, changedBy, remarks = null, tx = null }) {
    const prismaClient = tx || prisma;
    
    return await prismaClient.$transaction(async (transaction) => {
      // Get current asset data by EPC
      const currentAsset = await transaction.asset_master.findUnique({
        where: { epc_code: epcCode }
      });

      if (!currentAsset) {
        throw new Error(`Asset with EPC ${epcCode} not found`);
      }

      // Update the asset
      const updatedAsset = await transaction.asset_master.update({
        where: { asset_no: currentAsset.asset_no },
        data: updateData
      });

      // Log status change if status was updated
      if (updateData.status && updateData.status !== currentAsset.status) {
        await this.logStatusChange({
          assetNo: currentAsset.asset_no,
          oldStatus: currentAsset.status,
          newStatus: updateData.status,
          changedBy,
          remarks: remarks || `Status changed via EPC scan`,
          tx: transaction
        });
      }

      return updatedAsset;
    });
  }
}

module.exports = StatusChangeLogger;