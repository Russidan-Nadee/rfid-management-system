const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const app = require('./app');

const PORT = process.env.PORT || 3000;

// Start server
app.listen(PORT, '0.0.0.0', () => {
   console.log(`Server is running on port ${PORT}`);
   console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});