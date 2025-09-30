// Path: backend/src/features/cost-center/costCenter.controller.js
const CostCenterService = require('./costCenter.service');

class CostCenterController {
  constructor() {
    this.costCenterService = new CostCenterService();
  }

  // GET /api/cost-centers
  async getAllCostCenters(req, res) {
    try {
      const filters = {
        division_code: req.query.division_code,
        plant_code: req.query.plant_code,
        function_type: req.query.function_type,
        is_active: req.query.is_active !== undefined ? req.query.is_active === 'true' : true
      };

      // Remove undefined filters
      Object.keys(filters).forEach(key => {
        if (filters[key] === undefined) {
          delete filters[key];
        }
      });

      const costCenters = await this.costCenterService.getAllCostCenters(filters);

      res.json({
        success: true,
        message: 'Cost centers retrieved successfully',
        data: costCenters,
        total: costCenters.length
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  // GET /api/cost-centers/:code
  async getCostCenterByCode(req, res) {
    try {
      const { code } = req.params;
      const costCenter = await this.costCenterService.getCostCenterByCode(code);

      res.json({
        success: true,
        message: 'Cost center retrieved successfully',
        data: costCenter
      });
    } catch (error) {
      const statusCode = error.message.includes('not found') ? 404 : 500;
      res.status(statusCode).json({
        success: false,
        message: error.message
      });
    }
  }

  // GET /api/divisions
  async getAllDivisions(req, res) {
    try {
      const divisions = await this.costCenterService.getAllDivisions();

      res.json({
        success: true,
        message: 'Divisions retrieved successfully',
        data: divisions,
        total: divisions.length
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  // GET /api/divisions/:divisionCode/cost-centers
  async getCostCentersByDivision(req, res) {
    try {
      const { divisionCode } = req.params;
      const costCenters = await this.costCenterService.getCostCentersByDivision(divisionCode);

      res.json({
        success: true,
        message: 'Cost centers retrieved successfully',
        data: costCenters,
        total: costCenters.length
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  // GET /api/plants/:plantCode/cost-centers
  async getCostCentersByPlant(req, res) {
    try {
      const { plantCode } = req.params;
      const costCenters = await this.costCenterService.getCostCentersByPlant(plantCode);

      res.json({
        success: true,
        message: 'Cost centers retrieved successfully',
        data: costCenters,
        total: costCenters.length
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  // GET /api/cost-centers/stats
  async getCostCenterStats(req, res) {
    try {
      const stats = await this.costCenterService.getCostCenterStats();

      res.json({
        success: true,
        message: 'Cost center statistics retrieved successfully',
        data: stats
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }
}

module.exports = CostCenterController;