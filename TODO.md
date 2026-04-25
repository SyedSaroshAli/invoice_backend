# PDF Table Alignment Fix - AdmitCardScreen

## Plan Status: ✅ Approved

**TODO Checklist:**

### 1. [ ] Create this TODO.md file ✅
### 2. [✅] Edit lib/dashboard/Drawer_Screens/admitcardScreen.dart
   - [ ] Update _buildPdfTable(): 
     - Left table: 3 separate rows with flex 4+8 (Student), 4+8 (Father), 4+3+2+4 (Class+Section)
     - Photo: flex4 with dynamic stretch height (remove fixed 69)
     - Bottom row: flex 3+3+2+2+2+2 exactly
     - Match borders/padding
### 3. [ ] Test PDF generation
   - [ ] Run app, load admitcard, generate PDF
   - [ ] Verify alignment matches UI exactly (flex ratios, photo height, borders)
### 4. [ ] Update TODO.md with completion ✅
### 5. [ ] Attempt completion

**Current Step: 2 - Editing file**

