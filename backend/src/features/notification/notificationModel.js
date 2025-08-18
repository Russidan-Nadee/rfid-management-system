const prisma = require('../../core/database/prisma');

const NotificationModel = {
  // Create a new problem notification
  async createNotification(data) {
    return await prisma.problem_notification.create({
      data: {
        asset_no: data.asset_no,
        reported_by: data.reported_by,
        problem_type: data.problem_type,
        priority: data.priority || 'normal',
        subject: data.subject,
        description: data.description,
        status: 'pending'
      },
      include: {
        asset_master: {
          select: {
            asset_no: true,
            description: true,
            location_code: true,
            plant_code: true
          }
        },
        reporter: {
          select: {
            user_id: true,
            full_name: true,
            email: true
          }
        }
      }
    });
  },

  // Get all notifications (for admin)
  async getAllNotifications(filters = {}) {
    const {
      status,
      priority,
      problem_type,
      asset_no,
      plant_code,
      location_code,
      page = 1,
      limit = 20,
      sortBy = 'created_at',
      sortOrder = 'desc'
    } = filters;

    try {
      // Build base where clause for direct problem_notification fields
      const where = {};
      
      if (status) where.status = status;
      if (priority) where.priority = priority;
      if (problem_type) where.problem_type = problem_type;
      if (asset_no) where.asset_no = { contains: asset_no };
      
      // If we need to filter by plant_code or location_code, use a different approach
      if (plant_code || location_code) {
        // First get asset numbers that match the plant/location criteria
        const assetFilter = {};
        if (plant_code) assetFilter.plant_code = plant_code;
        if (location_code) assetFilter.location_code = location_code;
        
        const matchingAssets = await prisma.asset_master.findMany({
          where: assetFilter,
          select: { asset_no: true }
        });
        
        const assetNumbers = matchingAssets.map(asset => asset.asset_no);
        
        if (assetNumbers.length > 0) {
          where.asset_no = { in: assetNumbers };
        } else {
          // No matching assets found, return empty result
          return {
            notifications: [],
            pagination: {
              total: 0,
              pages: 0,
              current_page: page,
              per_page: limit
            }
          };
        }
      }

      const skip = (page - 1) * limit;

      const [notifications, total] = await Promise.all([
        prisma.problem_notification.findMany({
          where,
          skip,
          take: parseInt(limit),
          orderBy: { [sortBy]: sortOrder },
          include: {
            asset_master: {
              select: {
                asset_no: true,
                description: true,
                location_code: true,
                plant_code: true
              }
            },
            reporter: {
              select: {
                user_id: true,
                full_name: true,
                email: true
              }
            },
            acknowledger: {
              select: {
                user_id: true,
                full_name: true
              }
            },
            resolver: {
              select: {
                user_id: true,
                full_name: true
              }
            }
          }
        }),
        prisma.problem_notification.count({ where })
      ]);

      return {
        notifications,
        pagination: {
          total,
          pages: Math.ceil(total / limit),
          current_page: page,
          per_page: limit
        }
      };
    } catch (error) {
      console.error('Error in getAllNotifications:', error);
      throw error;
    }
  },

  // Get notification by ID
  async getNotificationById(id) {
    return await prisma.problem_notification.findUnique({
      where: { notification_id: parseInt(id) },
      include: {
        asset_master: {
          select: {
            asset_no: true,
            description: true,
            location_code: true,
            plant_code: true
          }
        },
        reporter: {
          select: {
            user_id: true,
            full_name: true,
            email: true
          }
        },
        acknowledger: {
          select: {
            user_id: true,
            full_name: true
          }
        },
        resolver: {
          select: {
            user_id: true,
            full_name: true
          }
        }
      }
    });
  },

  // Update notification status
  async updateNotificationStatus(id, updates, userId) {
    const updateData = {
      ...updates,
      updated_at: new Date()
    };

    // Handle status-specific updates
    if (updates.status === 'acknowledged' && !updates.acknowledged_by) {
      updateData.acknowledged_by = userId;
      updateData.acknowledged_at = new Date();
    }

    // When status changes to in_progress, it means the report was acknowledged
    if (updates.status === 'in_progress' && !updates.acknowledged_by) {
      updateData.acknowledged_by = userId;
      updateData.acknowledged_at = new Date();
    }

    if (updates.status === 'resolved' && !updates.resolved_by) {
      updateData.resolved_by = userId;
      updateData.resolved_at = new Date();
    }

    // When status changes to cancelled, it means the report was rejected
    if (updates.status === 'cancelled' && !updates.resolved_by) {
      updateData.resolved_by = userId;
      updateData.resolved_at = new Date();
      // Handle rejection note
      if (updates.rejection_note) {
        updateData.rejection_note = updates.rejection_note;
      }
    }

    return await prisma.problem_notification.update({
      where: { notification_id: parseInt(id) },
      data: updateData,
      include: {
        asset_master: {
          select: {
            asset_no: true,
            description: true,
            location_code: true,
            plant_code: true
          }
        },
        reporter: {
          select: {
            user_id: true,
            full_name: true,
            email: true
          }
        },
        acknowledger: {
          select: {
            user_id: true,
            full_name: true
          }
        },
        resolver: {
          select: {
            user_id: true,
            full_name: true
          }
        }
      }
    });
  },

  // Get notifications count by status (for admin dashboard)
  async getNotificationsCounts() {
    const [
      pending,
      acknowledged,
      in_progress,
      resolved,
      cancelled
    ] = await Promise.all([
      prisma.problem_notification.count({ where: { status: 'pending' } }),
      prisma.problem_notification.count({ where: { status: 'acknowledged' } }),
      prisma.problem_notification.count({ where: { status: 'in_progress' } }),
      prisma.problem_notification.count({ where: { status: 'resolved' } }),
      prisma.problem_notification.count({ where: { status: 'cancelled' } })
    ]);

    return {
      pending,
      acknowledged,
      in_progress,
      resolved,
      cancelled,
      total: pending + acknowledged + in_progress + resolved + cancelled
    };
  },

  // Get notifications by asset
  async getNotificationsByAsset(assetNo) {
    return await prisma.problem_notification.findMany({
      where: { asset_no: assetNo },
      orderBy: { created_at: 'desc' },
      include: {
        reporter: {
          select: {
            user_id: true,
            full_name: true
          }
        },
        acknowledger: {
          select: {
            user_id: true,
            full_name: true
          }
        },
        resolver: {
          select: {
            user_id: true,
            full_name: true
          }
        }
      }
    });
  },

  // Get notifications by user (for user's own reports)
  async getNotificationsByUser(userId) {
    return await prisma.problem_notification.findMany({
      where: { reported_by: userId },
      orderBy: { created_at: 'desc' },
      include: {
        asset_master: {
          select: {
            asset_no: true,
            description: true,
            location_code: true,
            plant_code: true
          }
        },
        reporter: {
          select: {
            user_id: true,
            full_name: true
          }
        },
        acknowledger: {
          select: {
            user_id: true,
            full_name: true
          }
        },
        resolver: {
          select: {
            user_id: true,
            full_name: true
          }
        }
      }
    });
  }
};

module.exports = NotificationModel;