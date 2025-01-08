# 🏦 **QB Advanced Banking System Installation Guide**  

## 📋 **Requirements**  
- **QBCore Framework**  
- **oxmysql**  
- **qb-target** (or **ox_target/qtarget**)  

---

## ⚙️ **Installation Steps**  

1. 📝 **Download** the latest release from the repository.  
2. 🔐 **Extract** the files to your `resources` folder.  
3. 🖋️ Add `ensure dankiebankingv2` to your `server.cfg`.  
4. 🔄 **Restart** your server.  

---

## 🔧 **Configuration**  

### **Core Settings**  
- `Config.Core`: Select framework (supports **QBCore** only).  
- `Config.BankLabel`: UI display name (e.g., `'QB BANKING'`).  
- `Config.Target`: Choose target system (**qb-target**, **ox_target**, or **qtarget**).  
- `Config.TextUI`: Enable/disable text prompts.  
- `Config.SteamName`: Use Steam or character name for transactions.  

### **Banking Settings**  
- **IBAN Setup**: Prefix and number length customization.  
- **PIN & IBAN Costs**: Change fees for IBAN/PIN.  
- **Transaction Limits**: Daily transaction cap.  
- **Date Format**: Customize displayed format.  
- **Menu Key**: Default key to open the banking menu (**E**).  

### **Distance Settings**  
- Marker visibility and interaction distance adjustments.  

### **ATM & Bank Blips**  
- **ATM Models**: Define interactable ATM props.  
- **Blips**: Customize bank minimap icons (color, size, sprite).  

### **Locations**  
Customize bank locations, assistants, and markers in the `Config.Banks` table.  

---

## 💡 **Features Overview**  
- **Multi-Character Support**  
- **Interest Rate System**  
- **Loan Management**  
- **Sub-Accounts**  
- **Transaction History**  
- **Custom Notifications**  
- **Bank Assistant NPCs**  
- **ATM Functionality**  

---

## 🔄 **Manual Installation (If Automatic Fails)**  

### 1⃣ **Database Setup**  
1. **Install MariaDB** (preferred for better performance):  
   👉 [Download MariaDB](https://mariadb.org/download/)  

2. **Backup Database**:  
   To ensure the safety of your data, create a backup using one of the following methods:  
   
   #### **Using HeidiSQL**  
   1. Open HeidiSQL and connect to your database.  
   2. Right-click on your database and select **Export database as SQL**.  
   3. Choose the following options:  
      - ✓ Include **CREATE DATABASE**.  
      - ✓ Include **DROP TABLE IF EXISTS**.  
      - ✓ Include **AUTO_INCREMENT**.  
   4. Save the exported file to a secure location.  
   
   #### **Using phpMyAdmin**  
   1. Log in to phpMyAdmin and select your database.  
   2. Click on **Export** at the top menu.  
   3. Choose **Custom** export method and select:  
      - Format: SQL.  
      - ✓ Add **CREATE DATABASE**.  
      - ✓ Add **DROP TABLE**.  
   4. Download and save the backup file.  
   
   #### **Using Command Line**  
   ```bash  
   mysqldump -u [username] -p [database_name] > backup.sql  
   ```  
   Replace `[username]` and `[database_name]` with your database credentials and name. The `backup.sql` file will be created in the current directory.  
   
   #### **Using MySQL Workbench**  
   1. Connect to your database in MySQL Workbench.  
   2. Go to **Server** > **Data Export**.  
   3. Select the database and tables you want to back up.  
   4. Choose a location to save the export file and start the export process.  

3. **Manual SQL Execution**:  
   - Run installation queries from `installation/install.lua`. To locate the file, navigate to the `installation` folder within the extracted `dankiebankingv2` resource folder. Open the file in a text editor (e.g., Notepad++, VS Code) or your preferred SQL tool. Copy the queries and execute them in your database management tool.  
   - Verify table structure:  
     ```sql  
     DESCRIBE bank_accounts;  
     DESCRIBE bank_account_members;  
     DESCRIBE bank_loans;  
     ```  

---

## 🔧 **Troubleshooting**  

### **Common Issues & Fixes**  
1. **Tables not created**:  
   - Check MySQL connection.  
   - Enable debug mode.  
   - Run `InstallBankSystem` export.  

2. **Target System Issues**:  
   - Ensure correct target resource in config.  
   - Start target system before banking resource.  

3. **NPC Problems**:  
   - Validate ped models and coordinates.  
   - Ensure `pedEnabled` is set to `true`.  

4. **Database Errors**:  
   - Verify oxmysql setup and credentials. Ensure `oxmysql` is running and the database credentials are correctly configured in your `server.cfg`. For detailed assistance, refer to the [oxmysql documentation](https://github.com/overextended/oxmysql) or check for common issues like incorrect database name or user permissions.  
   - Restart oxmysql and banking resources.  

---

### **Maintenance Commands**  
- Optimize tables:  
  ```sql  
  OPTIMIZE TABLE bank_accounts, bank_account_members, bank_loans;  
  ```  
  Optimizing tables is important for maintaining database performance by reorganizing data and reclaiming unused space. Run this command periodically, such as weekly or after significant database changes, to keep your database efficient and responsive.  
- Archive old transaction data for performance.  

---

### 🚀 **You're Ready!**  
Follow these steps to set up and maintain the **QB Advanced Banking System** seamlessly. Happy banking! 😊
