// Path: backend/src/features/image/external-storage.service.js
const axios = require('axios');
const FormData = require('form-data');

class ExternalStorageService {
   constructor() {
      this.devServerUrl = 'https://devsever.thaiparker.co.th/tp_service/api/Service_File/Upload';
      this.token = '9f3951f2-597e-49bf-8681-2e4fd2465614';
   }

   async uploadFile(file) {
      try {
         console.log('🔍 DEBUG: Starting dev server upload');
         console.log('🔍 File info:', {
            originalname: file.originalname,
            size: file.size,
            mimetype: file.mimetype
         });

         const form = new FormData();
         form.append('Filename', file.buffer, file.originalname);
         form.append('FolderPath', 'intern_test/IMG');

         console.log('🔍 Request URL:', this.devServerUrl);
         console.log('🔍 Token:', this.token);

         const response = await axios.post(this.devServerUrl, form, {
            headers: {
               'Token': this.token,
               ...form.getHeaders()
            },
            timeout: 30000
         });

         console.log('🔍 Dev server response status:', response.status);
         console.log('🔍 Dev server response data:', response.data);

         if (response.data.IsSuccess) {
            return {
               success: true,
               file_url: response.data.FileUrl,
               file_thumbnail_url: response.data.FileThumbnailUrl,
               external_file_path: response.data.FilePath,
               external_thumbnail_path: response.data.FileThumbnailPath,
               file_type_external: response.data.FileType
            };
         } else {
            throw new Error(response.data.ErrorMessage || 'Upload failed');
         }
      } catch (error) {
         console.error('❌ External storage upload error:', error.message);
         console.error('❌ Error details:', {
            status: error.response?.status,
            statusText: error.response?.statusText,
            data: error.response?.data
         });
         throw new Error(`External upload failed: ${error.message}`);
      }
   }
}

module.exports = ExternalStorageService;