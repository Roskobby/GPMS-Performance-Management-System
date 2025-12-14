# GPMS Testing Guide

## Complete End-to-End Testing Documentation

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Application**: General Performance Management System (GPMS)

---

## Table of Contents

1. [Testing Overview](#testing-overview)
2. [Test Scenarios](#test-scenarios)
3. [Employee Workflow Tests](#employee-workflow-tests)
4. [Manager Workflow Tests](#manager-workflow-tests)
5. [PDF Export Tests](#pdf-export-tests)
6. [Edge Cases & Error Handling](#edge-cases--error-handling)
7. [Performance Tests](#performance-tests)
8. [Security Tests](#security-tests)
9. [Cross-Browser Compatibility](#cross-browser-compatibility)
10. [Bug Report Template](#bug-report-template)

---

## Testing Overview

### Test Environment
- **Platform**: Web (Flutter Web)
- **URL**: https://5060-i0p82zzuwxxbsdmh089kj-5634da27.sandbox.novita.ai
- **Browsers**: Chrome, Firefox, Safari, Edge
- **Test Data**: Available via Admin Panel

### Testing Principles
1. Test all user journeys end-to-end
2. Verify data persistence across sessions
3. Test error handling and edge cases
4. Validate UI/UX consistency
5. Check performance and responsiveness

---

## Test Scenarios

### Scenario 1: Complete Employee-Manager Workflow ✅

**Objective**: Validate the complete appraisal workflow from creation to HR submission

**Actors**: 
- Employee (Regular staff)
- Manager (M5/M6/M7 or Manager designation)

**Pre-requisites**:
- Both employee and manager accounts exist
- Employee reports to the manager
- Fresh appraisal year

**Steps**:

#### Part A: Employee Creates and Submits Goals

1. **Login as Employee**
   - Navigate to login screen
   - Enter employee credentials
   - Verify successful login
   - Check home screen loads

2. **Navigate to Goal Setting**
   - Click: Home → "Beginning of Year" → "Goal Setting"
   - Expected: Goal Setting screen opens
   - Expected: 🔵 "Draft" badge visible at top

3. **Review Default Goals**
   - Expected: 3 default goals (GOAL 1, 2, 3) present
   - Expected: Each goal has 3 deliverables
   - Expected: All fields are editable
   - Expected: NO "Submit to Manager" button yet

4. **Fill in Goal Information**
   - Goal 1 Description: "Improve operational efficiency by 20%"
   - Deliverable 1: "Implement new workflow system"
   - Priority: 2
   - Weight: Should auto-calculate
   - Threshold: "System operational by Q2"
   - Key Results: "25% reduction in processing time"
   
5. **Save Goals**
   - Click: "Save Goals" button (app bar)
   - Expected: Success message "Goals saved successfully!"
   - Expected: 🔵 "Draft" badge still visible
   - Expected: "Submit to Manager" button NOW appears (blue)
   - Expected: Fields become read-only

6. **Enable Editing Again**
   - Click: "Edit Goals" button (app bar)
   - Expected: Fields become editable
   - Expected: "Submit to Manager" button disappears
   - Modify: Add more details to deliverable
   - Click: "Save Goals" again

7. **Submit to Manager**
   - Verify: All goals have meaningful content
   - Click: "Submit to Manager" button
   - Expected: Confirmation dialog appears
   - Expected: Dialog text: "You won't be able to edit them until..."
   - Click: "Submit" button in dialog
   - Expected: Loading indicator briefly
   - Expected: Success message "Goals submitted to manager successfully!"
   - Expected: Status badge changes to 🟠 "Submitted to Manager"
   - Expected: All fields are read-only
   - Expected: NO "Edit" button in app bar
   - Expected: NO "Save" button
   - Expected: NO "Submit to Manager" button

8. **Verify Read-Only Lock**
   - Try: Click on goal description field
   - Expected: Field is disabled/read-only
   - Try: Click on deliverable description
   - Expected: Field is disabled/read-only
   - Try: Click priority chip
   - Expected: No action (disabled)
   - Expected: Add/Delete buttons hidden

9. **Logout Employee**
   - Navigate: Settings → Logout
   - Expected: Returns to login screen

#### Part B: Manager Reviews and Submits to HR

10. **Login as Manager**
    - Enter manager credentials
    - Verify successful login
    - Expected: Home screen shows purple "Manager Portal" section

11. **Navigate to Team Appraisals**
    - Click: "Manager Portal" → "Team Appraisals"
    - Expected: Team Appraisals screen opens
    - Expected: Search bar visible at top
    - Expected: Filter chips visible (All, Draft, Submitted, etc.)

12. **Find Employee Submission**
    - Scan: List of direct reports
    - Find: Employee from Part A
    - Verify: Employee has 🟠 "Submitted to Manager" badge
    - Verify: "Action Required: Review appraisal" banner shows

13. **Test Search Functionality**
    - Type: Employee name in search bar
    - Expected: List filters to show matching employees
    - Clear: Search bar
    - Expected: Full list returns

14. **Test Filter Functionality**
    - Click: "Submitted to Manager" filter chip
    - Expected: Only submitted appraisals show
    - Click: "All" filter chip
    - Expected: All appraisals return

15. **Open Manager Review Screen**
    - Click: Employee card
    - Expected: Manager Review Screen opens
    - Expected: Title shows "Review: [Employee Name]"
    - Expected: Status badge changes to 🟠 "Manager In Progress"
    - Expected: Auto-transition (no manual action needed)

16. **Review Employee Information**
    - Verify: Employee name is correct
    - Verify: Employee number matches
    - Verify: Year shows (2025)
    - Verify: Submitted date shows (today's date)
    - Expected: All information accurate

17. **Review Goals & KPI Section**
    - Click: "Goals & KPI Review (70%)" to expand
    - Verify: Employee's goals appear
    - Verify: Goal 1 description matches what employee entered
    - Click: GOAL 1 to expand deliverables
    - Verify: Deliverable 1 shows correct description
    - Verify: Priority: 2
    - Verify: Weight: Auto-calculated percentage
    - Verify: Threshold shows
    - Verify: Key Results shows "25% reduction in processing time"
    - Expected: All data is read-only (no edit buttons)

18. **Review Behavioral Assessment**
    - Click: "Behavioral Assessment (30%)" to expand
    - Verify: Count of standards shows
    - Expected: Information displayed correctly

19. **Add Manager Comments**
    - Scroll: To "Manager Comments" section
    - Click: Comments text field
    - Type: "Excellent performance this year. Goals are well-defined, achievable, and aligned with organizational objectives. The 20% efficiency improvement target is ambitious but realistic given the employee's track record."
    - Verify: Text appears in field
    - Expected: No character limit errors

20. **Test PDF Export**
    - Click: PDF icon (📄) in app bar
    - Expected: Loading dialog appears
    - Wait: For PDF generation
    - Expected: PDF downloads automatically
    - Expected: Success message "PDF exported successfully!"
    - Open: Downloaded PDF
    - Verify: All sections present
    - Verify: Employee info correct
    - Verify: Goals display properly
    - Verify: Manager comments included
    - Verify: Signature blocks present

21. **Submit to HR**
    - Scroll: To bottom
    - Verify: Green "Submit to HR" button visible
    - Click: "Submit to HR"
    - Expected: Confirmation dialog appears
    - Expected: Dialog text: "Once submitted, it cannot be edited..."
    - Click: "Submit to HR" in dialog
    - Expected: Loading indicator
    - Expected: Success message "Appraisal submitted to HR successfully!"
    - Expected: Returns to Team Appraisals screen automatically

22. **Verify Status Change in Team List**
    - Check: Employee card in list
    - Expected: Status badge now shows 🟢 "Submitted to HR"
    - Expected: NO "Action Required" banner

23. **Verify Manager Read-Only Lock**
    - Click: Same employee card again
    - Expected: Manager Review Screen opens
    - Expected: Status shows 🟢 "Submitted to HR"
    - Expected: NO "Submit to HR" button at bottom
    - Expected: Comments field is DISABLED (greyed out)
    - Expected: Message: "This appraisal has been submitted to HR and is now read-only"
    - Press: Back button
    - Expected: Returns to Team Appraisals

24. **Logout Manager**
    - Navigate: Settings → Logout

#### Part C: Verify Complete Lock for Employee

25. **Login as Same Employee (from Part A)**
    - Enter employee credentials
    - Verify successful login

26. **Navigate to Goal Setting**
    - Click: Home → "Beginning of Year" → "Goal Setting"
    - Expected: Goal Setting screen opens

27. **Verify Complete Employee Lock**
    - Expected: Status badge shows 🟢 "Submitted to HR"
    - Expected: All goal description fields are read-only
    - Expected: All deliverable fields are read-only
    - Expected: Priority selectors are disabled (no interaction)
    - Expected: NO "Add Deliverable" button visible
    - Expected: NO "Edit Goals" button in app bar
    - Expected: NO "Save Goals" button
    - Expected: NO "Submit to Manager" button
    - Try: Click various fields
    - Expected: No field can be edited

28. **Try Other Screens**
    - Navigate: KPI Review screen
    - Expected: Similar read-only enforcement
    - Navigate: Behavioral Assessment screen
    - Expected: Similar read-only enforcement

29. **Final Verification**
    - Verify: Cannot modify any data
    - Verify: All workflow states respected
    - Verify: Status badge consistent across screens

**Success Criteria**:
- ✅ Employee can create and submit goals
- ✅ Manager receives submission notification
- ✅ Manager can review and add comments
- ✅ PDF export works correctly
- ✅ Manager can submit to HR
- ✅ Complete lock applies after HR submission
- ✅ Both parties cannot edit after final submission

---

### Scenario 2: Multiple Employees Workflow ✅

**Objective**: Test manager handling multiple subordinates

**Steps**:
1. Create 3-5 employees reporting to same manager
2. Have each employee submit goals at different times
3. Manager reviews in different order
4. Verify search and filter work with multiple entries
5. Test bulk workflow operations

**Success Criteria**:
- ✅ All employees show in team list
- ✅ Status badges accurate for each
- ✅ Search finds correct employees
- ✅ Filters work correctly
- ✅ No data mixing between employees

---

### Scenario 3: Edge Cases ⚠️

**Test Case 3.1: Empty Submission**
- Employee tries to submit without filling goals
- Expected: Validation error
- Expected: Cannot submit

**Test Case 3.2: Partial Data**
- Employee fills only 1 of 3 goals
- Can save but validation should check completeness
- Expected: Warning or allow with partial data

**Test Case 3.3: Special Characters**
- Enter special characters in goal descriptions
- Enter emojis in comments
- Expected: System handles gracefully

**Test Case 3.4: Very Long Text**
- Enter 1000+ characters in description
- Expected: Field handles or has character limit

**Test Case 3.5: Network Interruption**
- Submit goals with network disabled
- Expected: Error message
- Expected: Data not lost

**Test Case 3.6: Concurrent Editing**
- Manager opens review while employee still editing
- Expected: Status prevents manager action

---

## Performance Tests

### Load Time Tests
- Home screen load: < 2 seconds
- Goal Setting screen load: < 1 second
- Team Appraisals list load: < 3 seconds
- PDF generation: < 5 seconds

### Data Volume Tests
- 50+ employees in team list
- 10+ goals per employee
- Large comments (1000+ words)

### Browser Performance
- Test on Chrome, Firefox, Safari, Edge
- Verify smooth scrolling
- Check memory usage
- Monitor CPU usage

---

## Security Tests

### Authentication Tests
- Cannot access without login
- Session timeout works
- Password security enforced
- Manager cannot access other manager's team

### Authorization Tests
- Employee cannot access manager features
- Manager can only see direct reports
- HR restrictions enforced

### Data Privacy Tests
- Employee data segregated
- No cross-employee data leaks
- Manager comments private

---

## Cross-Browser Compatibility

### Browsers to Test
- ✅ Chrome (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Edge (latest)

### Features to Verify
- Layout consistency
- Button functionality
- PDF download
- Form submissions
- Modal dialogs

---

## Bug Report Template

```markdown
**Bug Title**: [Short descriptive title]

**Severity**: Critical / High / Medium / Low

**Environment**:
- Browser: Chrome 120
- OS: Windows 11
- URL: https://...

**Steps to Reproduce**:
1. Login as employee
2. Navigate to Goal Setting
3. Click Submit button
4. ...

**Expected Behavior**:
Goals should be submitted and status should change to "Submitted to Manager"

**Actual Behavior**:
Error message appears: "Cannot submit..."

**Screenshots**:
[Attach screenshots if available]

**Additional Notes**:
This happens only when...
```

---

## Test Results Summary

**Scenario 1**: ✅ PASS / ❌ FAIL  
**Scenario 2**: ✅ PASS / ❌ FAIL  
**Scenario 3**: ✅ PASS / ❌ FAIL  

**Overall Status**: PASSED / NEEDS ATTENTION

---

## Known Issues

### Issue #1: [If any found during testing]
**Description**: ...  
**Impact**: Low  
**Workaround**: ...  
**Fix Status**: Pending / In Progress / Fixed

---

## Test Sign-Off

**Tested By**: _______________  
**Date**: _______________  
**Approved By**: _______________  
**Date**: _______________

---

**End of Testing Guide**
