@..\install_prereq\initspool view_driver
/***************************************************************************************************
Name: view_driver.sql                    Author: Brendan Furey                      Date: 21-Sep-2019

API driver script component in the Oracle PL/SQL API Demos module. 

The module demonstrates instrumentation and logging, code timing, and unit testing of PL/SQL APIs,
using example APIs writtten against Oracle's HR demo schema. 

    GitHub: https://github.com/BrenPatF/https://github.com/BrenPatF/oracle_plsql_api_demos

There are two driver SQL scripts, one for the base packages, with demonstration of instrumentation
and logging, and code timing, and the other for unit testing.

DRIVER SCRIPTS
====================================================================================================
|  SQL Script  |  API/Test Unit                   |  Notes                                         |
|===================================================================================================
| *view_driver* |  Emp_WS.Save_Emps                |  Save a list of new employees                  |
|              |  Emp_WS.Get_Dept_Emps            |  Get department and employee details           |
|              |  Emp_Batch.Load_Emps             |  Load new/updated employees from file          |
|              |  HR_Test_View_V                  |  View for department and employees             |
----------------------------------------------------------------------------------------------------
|  r_tests     |  TT_Emp_WS.Save_Emps             |  Unit test for Emp_WS.Save_Emps                |
|              |  TT_Emp_WS.Get_Dept_Emps         |  Unit test for Emp_WS.Get_Dept_Emps            |
|              |  TT_Emp_Batch.Load_Emps          |  Unit test for Emp_Batch.Load_Emps             |
|              |  TT_View_Drivers.HR_Test_View_V  |  Unit test for HR_Test_View_V                  |
====================================================================================================
This file has the driver script for the example code calling the base APIs, with code timing and
logging via the installed modules Utils, Timer_Set and Log_Set.

***************************************************************************************************/
PROMPT Match_Recognize_V
SELECT personid,
       block_start_login_time
  FROM Match_Recognize_V
 ORDER BY 1, 2
/
PROMPT Model_V
SELECT personid,
       block_start_login_time
  FROM Model_V
 ORDER BY 1, 2
/
PROMPT Recursive_SQF_V
SELECT personid,
       block_start_login_time
  FROM Recursive_SQF_V
 ORDER BY 1, 2
/
PROMPT Analytics_V
SELECT personid,
       block_start_login_time
  FROM Analytics_V
 ORDER BY 1, 2
/
@..\install_prereq\endspool