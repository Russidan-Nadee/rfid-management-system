// Path: backend/src/scripts/createUser.js
const { PrismaClient } = require('@prisma/client');
const { hashPassword, validatePasswordStrength } = require('../core/auth/passwordUtils');
const readline = require('readline');

const prisma = new PrismaClient();

// Create readline interface
const rl = readline.createInterface({
   input: process.stdin,
   output: process.stdout
});

// Helper function to ask questions
const askQuestion = (question) => {
   return new Promise((resolve) => {
      rl.question(question, (answer) => {
         resolve(answer.trim());
      });
   });
};

// Improved password input function - using readline instead of raw mode
const askPassword = (question) => {
   return new Promise((resolve) => {
      const originalWrite = process.stdout.write;
      let password = '';

      process.stdout.write(question);

      // Override stdout.write to hide password
      process.stdout.write = function (string) {
         if (string === '\n' || string === '\r\n') {
            originalWrite.call(process.stdout, string);
         } else {
            originalWrite.call(process.stdout, '*'.repeat(string.length));
         }
         return true;
      };

      rl.question('', (answer) => {
         // Restore original stdout.write
         process.stdout.write = originalWrite;
         process.stdout.write('\n');
         resolve(answer.trim());
      });
   });
};

// Validate role
const validateRole = (role) => {
   const validRoles = ['admin', 'manager', 'user', 'viewer'];
   return validRoles.includes(role.toLowerCase());
};

// Reset terminal function
const resetTerminal = () => {
   if (process.stdin.isTTY) {
      process.stdin.setRawMode(false);
   }
   process.stdin.pause();
};

// Main function
async function createUser() {
   try {
      console.log('🚀 Interactive User Creation Script');
      console.log('=====================================\n');

      // Check database connection
      await prisma.$connect();
      console.log('✅ Database connected successfully\n');

      let createAnother = true;

      while (createAnother) {
         console.log('📝 Enter user details:\n');

         try {
            // Get user input
            const user_id = await askQuestion('User ID: ');
            if (!user_id) {
               console.log('❌ User ID is required!\n');
               continue;
            }

            // Check if user ID already exists
            const existingUser = await prisma.mst_user.findUnique({
               where: { user_id }
            });

            if (existingUser) {
               console.log(`❌ User ID "${user_id}" already exists!\n`);
               continue;
            }

            const username = await askQuestion('Username: ');
            if (!username) {
               console.log('❌ Username is required!\n');
               continue;
            }

            // Check if username already exists
            const existingUsername = await prisma.mst_user.findUnique({
               where: { username }
            });

            if (existingUsername) {
               console.log(`❌ Username "${username}" already exists!\n`);
               continue;
            }

            const full_name = await askQuestion('Full Name: ');
            if (!full_name) {
               console.log('❌ Full Name is required!\n');
               continue;
            }

            // Simplified password input - using regular readline
            let password1, password2;
            let passwordsMatch = false;

            while (!passwordsMatch) {
               console.log('\n⚠️  Password will be visible. Make sure no one is watching!');
               password1 = await askQuestion('Password: ');

               if (!password1) {
                  console.log('❌ Password is required!\n');
                  continue;
               }

               // Validate password strength
               const passwordValidation = validatePasswordStrength(password1);
               if (!passwordValidation.isValid) {
                  console.log('❌ Password validation failed:');
                  Object.values(passwordValidation.errors).forEach(error => {
                     if (error) console.log(`   - ${error}`);
                  });
                  console.log('');
                  continue;
               }

               password2 = await askQuestion('Confirm Password: ');

               if (password1 === password2) {
                  passwordsMatch = true;
               } else {
                  console.log('❌ Passwords do not match! Please try again.\n');
               }
            }

            // Role input with validation
            let role;
            let validRole = false;

            while (!validRole) {
               console.log('\nAvailable roles: admin, manager, user, viewer');
               role = await askQuestion('Role: ');

               if (validateRole(role)) {
                  role = role.toLowerCase();
                  validRole = true;
               } else {
                  console.log('❌ Invalid role! Please choose from: admin, manager, user, viewer\n');
               }
            }

            // Confirm user creation
            console.log('\n📋 User Summary:');
            console.log(`   User ID: ${user_id}`);
            console.log(`   Username: ${username}`);
            console.log(`   Full Name: ${full_name}`);
            console.log(`   Role: ${role}`);

            const confirm = await askQuestion('\nCreate this user? (y/n): ');

            if (confirm.toLowerCase() === 'y' || confirm.toLowerCase() === 'yes') {
               try {
                  // Hash password
                  console.log('🔐 Encrypting password...');
                  const hashedPassword = await hashPassword(password1);

                  // Create user in database
                  const newUser = await prisma.mst_user.create({
                     data: {
                        user_id,
                        username,
                        full_name,
                        password: hashedPassword,
                        role,
                        created_at: new Date(),
                        updated_at: new Date()
                     }
                  });

                  console.log(`✅ User "${username}" created successfully!`);
                  console.log(`   User ID: ${newUser.user_id}`);
                  console.log(`   Role: ${newUser.role}`);
                  console.log(`   Password encrypted with bcrypt (12 rounds)\n`);

               } catch (error) {
                  console.error('❌ Error creating user:', error.message);
                  if (error.code === 'P2002') {
                     console.log('   This might be due to duplicate username or user_id\n');
                  }
               }
            } else {
               console.log('❌ User creation cancelled\n');
            }

            // Ask if want to create another user
            const another = await askQuestion('Create another user? (y/n): ');
            createAnother = another.toLowerCase() === 'y' || another.toLowerCase() === 'yes';

            if (createAnother) {
               console.log('\n' + '='.repeat(50) + '\n');
            }

         } catch (inputError) {
            console.error('❌ Input error:', inputError.message);
            console.log('Please try again.\n');
            continue;
         }
      }

      console.log('\n🎉 User creation session completed!');

      // Show all users
      const allUsers = await prisma.mst_user.findMany({
         select: {
            user_id: true,
            username: true,
            full_name: true,
            role: true,
            created_at: true
         },
         orderBy: {
            created_at: 'desc'
         }
      });

      console.log('\n👥 Current Users in Database:');
      console.log('================================');
      allUsers.forEach((user, index) => {
         console.log(`${index + 1}. ${user.username} (${user.user_id}) - ${user.role}`);
         console.log(`   Name: ${user.full_name}`);
         console.log(`   Created: ${user.created_at.toISOString().split('T')[0]}\n`);
      });

   } catch (error) {
      console.error('💥 Fatal error:', error.message);
   } finally {
      resetTerminal();
      await prisma.$disconnect();
      rl.close();
      process.exit(0);
   }
}

// Handle process termination
process.on('SIGINT', async () => {
   console.log('\n\n👋 User creation cancelled by user');
   resetTerminal();
   await prisma.$disconnect();
   rl.close();
   process.exit(0);
});

process.on('SIGTERM', async () => {
   console.log('\n\n👋 User creation terminated');
   resetTerminal();
   await prisma.$disconnect();
   rl.close();
   process.exit(0);
});

// Handle uncaught exceptions
process.on('uncaughtException', async (error) => {
   console.error('\n💥 Uncaught Exception:', error.message);
   resetTerminal();
   await prisma.$disconnect();
   rl.close();
   process.exit(1);
});

// Start the script
createUser();