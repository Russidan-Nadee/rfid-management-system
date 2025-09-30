// Path: backend/src/features/cost-center/costCenter.service.js
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class CostCenterService {
  // Get all cost centers with division info
  async getAllCostCenters(filters = {}) {
    try {
      const where = {};

      // Apply filters
      if (filters.division_code) {
        where.division_code = filters.division_code;
      }

      if (filters.plant_code) {
        where.plant_code = filters.plant_code;
      }

      if (filters.function_type) {
        where.function_type = filters.function_type;
      }

      if (filters.is_active !== undefined) {
        where.is_active = filters.is_active;
      }

      const costCenters = await prisma.mst_cost_center.findMany({
        where,
        include: {
          mst_division: {
            select: {
              division_code: true,
              division_name: true
            }
          },
          mst_plant: {
            select: {
              plant_code: true,
              description: true
            }
          }
        },
        orderBy: [
          { division_code: 'asc' },
          { cost_center_code: 'asc' }
        ]
      });

      return costCenters;
    } catch (error) {
      throw new Error(`Failed to get cost centers: ${error.message}`);
    }
  }

  // Get cost center by code
  async getCostCenterByCode(costCenterCode) {
    try {
      const costCenter = await prisma.mst_cost_center.findUnique({
        where: { cost_center_code: costCenterCode },
        include: {
          mst_division: {
            select: {
              division_code: true,
              division_name: true,
              description: true
            }
          },
          mst_plant: {
            select: {
              plant_code: true,
              description: true
            }
          }
        }
      });

      if (!costCenter) {
        throw new Error('Cost center not found');
      }

      return costCenter;
    } catch (error) {
      throw new Error(`Failed to get cost center: ${error.message}`);
    }
  }

  // Get all divisions
  async getAllDivisions() {
    try {
      const divisions = await prisma.mst_division.findMany({
        where: { is_active: true },
        include: {
          mst_cost_center: {
            select: {
              cost_center_code: true,
              cost_center_name: true,
              plant_code: true,
              function_type: true,
              is_active: true
            },
            where: { is_active: true }
          }
        },
        orderBy: { division_code: 'asc' }
      });

      return divisions;
    } catch (error) {
      throw new Error(`Failed to get divisions: ${error.message}`);
    }
  }

  // Get cost centers by division
  async getCostCentersByDivision(divisionCode) {
    try {
      const costCenters = await prisma.mst_cost_center.findMany({
        where: {
          division_code: divisionCode,
          is_active: true
        },
        include: {
          mst_plant: {
            select: {
              plant_code: true,
              description: true
            }
          }
        },
        orderBy: { cost_center_code: 'asc' }
      });

      return costCenters;
    } catch (error) {
      throw new Error(`Failed to get cost centers by division: ${error.message}`);
    }
  }

  // Get cost centers by plant
  async getCostCentersByPlant(plantCode) {
    try {
      const costCenters = await prisma.mst_cost_center.findMany({
        where: {
          plant_code: plantCode,
          is_active: true
        },
        include: {
          mst_division: {
            select: {
              division_code: true,
              division_name: true
            }
          }
        },
        orderBy: { cost_center_code: 'asc' }
      });

      return costCenters;
    } catch (error) {
      throw new Error(`Failed to get cost centers by plant: ${error.message}`);
    }
  }

  // Get cost center statistics
  async getCostCenterStats() {
    try {
      const stats = await prisma.mst_cost_center.groupBy({
        by: ['division_code'],
        where: { is_active: true },
        _count: {
          cost_center_code: true
        }
      });

      const totalCostCenters = await prisma.mst_cost_center.count({
        where: { is_active: true }
      });

      const divisionStats = await Promise.all(
        stats.map(async (stat) => {
          const division = await prisma.mst_division.findUnique({
            where: { division_code: stat.division_code },
            select: { division_name: true }
          });

          return {
            division_code: stat.division_code,
            division_name: division?.division_name || 'Unknown',
            cost_center_count: stat._count.cost_center_code
          };
        })
      );

      return {
        total_cost_centers: totalCostCenters,
        by_division: divisionStats
      };
    } catch (error) {
      throw new Error(`Failed to get cost center statistics: ${error.message}`);
    }
  }
}

module.exports = CostCenterService;