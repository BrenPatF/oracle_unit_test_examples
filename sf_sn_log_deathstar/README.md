# Oracle  Unit Test Examples / sf_sn_log_deathstar
This subproject belongs to the parent project: Oracle Unit Test Examples, which contains examples of unit testing of Oracle SQL queries and PL/SQL code using the 'Math Function Unit Testing' design pattern. The project introduces a new general method for choosing unit test scenarios, Scenario Category ANalysis (SCAN).

In this design pattern unit testing is data driven from a JSON file containing input data together with expected output data for a set of scenarios. The SCAN method involves creating high level scenarios as combinations of categories within category sets for the specific problem. These high level scenarios are then implemented in the JSON file by creating data to match the categories. Each subproject illustrates the process of category set analysis and mapping onto scenarios for a specific problem.

I have taken the base code for this example from a blog post by Samuel Nitsche: [Feuertips #13: My Preconditions for Refactoring](https://developer-sam.de/2021/06/feuertips-13-my-preconditions-for-refactoring/)

Samuel has himself taken his example initially from an article by Steven Feuerstein: [Feuertip #13: Let’s refactor!](https://www.insum.ca/feuertip-13-lets-refactor-2/)

Steven's article is about refactoring and includes some demo code to use as an example. Samuel notes the value of automated unit testing when it comes to refactoring, and has added some table definitions and the base code, which he has made into a procedure, so that he could use it as an example of testing via the utPLSQL framework.

I in turn have taken Samuel's procedure, moved it into a package, reduced its scope by removing all but two of the files it writes, and made some other minor changes such as using my own array types. I then go on to use it to demonstrate my own approach to unit testing via the Math Function Unit Testing design pattern, and to demonstrate the SCAN method for scenario selection.

The procedure, in my version, reads records from a master table and two detail tables each linked by a key_id field, and writes out the records from each detail table into two corresponding files. The master table may have multiple records for a given key_id, but the detail records should only be written once for a given key_id.

There is a short recording on the subproject (2m005s): sf_sn_log_deathstar.mp4

## In this README...
[&darr; Installation](#installation)<br />
[&darr; Unit Testing](#unit-testing)<br />
[&darr; See Also](#see-also)

## Installation
[&uarr; In this README...](#in-this-readme)<br />
[&darr; Prerequisites](#prerequisites)<br />
[&darr; Install sf_sn_log_deathstar](#install-sf_sn_log_deathstar)<br />
[&darr; Example Data and Solution](#example-data-and-solution)

### Prerequisites
[&uarr; Installation](#installation)

The common project prerequisites must be installed from the project root README, [Oracle Unit Test Examples: Installation](../../../#installation)

### Install sf_sn_log_deathstar
[&uarr; Installation](#installation)

#### [Schema: app; Folder: sf_sn_log_deathstar/app]

- Run script from slqplus:

```sql
SQL> @install_sf_sn_log_deathstar
```

### Example Data and Solution
[&uarr; Installation](#installation)

The installation script includes an example (largely taken from Samuel Nitsche's article), that inserts some example data into the tables, as follows:
```
log_deathstar_room_access

KEY_ID ROOM_NAME       CHARACTER_NAME
------ --------------- ---------------
     1 Bridge          Darth Vader
       Bridge          Mace Windu
     2 Engine Room 1   R2D2

log_deathstar_room_actions

KEY_ID ACTION               DONE_BY
------ -------------------- ---------------
     1 Activate Lightsaber  Darth Vader
       Activate Lightsaber  Mace Windu
       Attack               Mace Windu
       Enter                Darth Vader
       Enter                Mace Windu
       Jump up              Darth Vader
       Sit down             Darth Vader
     2 Beep                 R2D2
       Enter                R2D2
       Hack Console         R2D2

10 rows selected.

log_deathstar_room_repairs

KEY_ID ACTION               REPAIR_COMPLETI REPAIRED_BY
------ -------------------- --------------- ---------------
     1 Analyze              53%             The Repairman
       Fix it               95%             Lady Skillful
       Inspect              50%             The Repairman
       Investigate          57%             The Repairman
     2 Analyze              25%             The Repairman
       Fix it               100%            Lady Skillful

6 rows selected.

```
It then calls the packaged procedure to be unit tested later, reports the results, and rolls back the test data. The script reports the results as follows:
```
File room_action.log has lines...
=================================
1|Bridge|Darth Vader|Enter
1|Bridge|Darth Vader|Sit down
1|Bridge|Mace Windu|Enter
1|Bridge|Mace Windu|Activate Lightsaber
1|Bridge|Darth Vader|Jump up
1|Bridge|Darth Vader|Activate Lightsaber
1|Bridge|Mace Windu|Attack
2|Engine Room 1|R2D2|Enter
2|Engine Room 1|R2D2|Hack Console
2|Engine Room 1|R2D2|Beep
.
File room_repair.log has lines...
=================================
1|Bridge|50%|The Repairman|Inspect
1|Bridge|53%|The Repairman|Analyze
1|Bridge|57%|The Repairman|Investigate
1|Bridge|95%|Lady Skillful|Fix it
2|Engine Room 1|25%|The Repairman|Analyze
2|Engine Room 1|100%|Lady Skillful|Fix it
```

## Unit Testing
[&uarr; In this README...](#in-this-readme)<br />
[&darr; Unit Testing Process](#unit-testing-process)<br />
[&darr; Unit Test Wrapper Function](#unit-test-wrapper-function)<br />
[&darr; Unit Test Scenarios](#unit-test-scenarios)

### Unit Testing Process
[&uarr; Unit Testing](#unit-testing)<br />

The package is tested using the Math Function Unit Testing design pattern, described here in its Oracle version: [Trapit - Oracle PL/SQL unit testing module](https://github.com/BrenPatF/trapit_oracle_tester). In this approach, a 'pure' wrapper function is constructed that takes input parameters and returns a value, and is tested within a loop over scenario records read from a JSON file.

Unit testing is data-driven from the input file sf_sn_log_deathstar.json and produces output results files in the Oracle directory `INPUT_DIR`. This contains arrays of expected and actual records by group and scenario. Three versions of the procedure were tested, with bug fixes in the second and third versions, as discussed in the `Unit Test Scenarios` section later.

The unit test programs may be run from the Oracle app subfolder:

```sql
SQL> @r_tests
```

The output results files are processed by a nodejs program that has to be installed separately, as described in the [Oracle Unit Test Examples: README instructions](https://github.com/BrenPatF/oracle_unit_test_examples/blob/master/README.md#installation). The nodejs program produces listings of the results in HTML and/or text format in a subfolder named from the unit test title, and the subfolders (for three versions of the package) are included in the folder `testing\output`. 

To run the processor, open a powershell window in the npm trapit package folder after placing the output JSON files, tt_feuertips_13_*.purely_wrap_feuertips_13_poc_out.json, in a new (or existing) folder, oracle_unit_test_examples, within the subfolder externals and run:

```
$ node externals\format-externals oracle_unit_test_examples
```
This outputs to screen the following summary level report, as well as writing the formatted results files to the subfolders indicated:
```
Unit Test Results Summary for Folder ./externals/oracle_unit_test_examples
==========================================================================
 File                                                    Title                Inp Groups  Out Groups  Tests  Fails  Folder             
-------------------------------------------------------  -------------------  ----------  ----------  -----  -----  -------------------
*tt_feuertips_13.purely_wrap_feuertips_13_poc_out.json   Feuertips 13 - Base           3           3      5      3  feuertips-13---base
*tt_feuertips_13.purely_wrap_feuertips_13_p_v1_out.json  Feuertips 13 - v1             3           3      5      1  feuertips-13---v1  
 tt_feuertips_13.purely_wrap_feuertips_13_p_v2_out.json  Feuertips 13 - v2             3           3      5      0  feuertips-13---v2  

2 externals failed, see ./externals/oracle_unit_test_examples for scenario listings
tt_feuertips_13.purely_wrap_feuertips_13_poc_out.json
tt_feuertips_13.purely_wrap_feuertips_13_p_v1_out.json
```

### Unit Test Wrapper Function
[&uarr; Unit Testing](#unit-testing)<br />
[&darr; Wrapper Function Signature Diagram](#wrapper-function-signature-diagram)<br />
[&darr; Wrapper Function Code](#wrapper-function-code)

#### Wrapper Function Signature Diagram
[&uarr; Unit Test Wrapper Function](#unit-test-wrapper-function)

<img src="testing\oracle_unit_test_examples - sf_sn_log.png">

An easy way to generate a starting point for the input JSON file is to use a powershell utility [Powershell Utilites module](https://github.com/BrenPatF/powershell_utils) to generate a template file with a single scenario with placeholder records from simple .csv files. See the script sf_sn_log_deathstar.ps1 in the `testing` subfolder for an example.

#### Wrapper Function Code
[&uarr; Unit Test Wrapper Function](#unit-test-wrapper-function)

The text box below shows the entire body code for the unit test package containing the wrapper function, Purely_Wrap_Feuertips_13_POC. It's quite short isn't it? 🙂

```sql
CREATE OR REPLACE PACKAGE BODY TT_Feuertips_13 AS

PROCEDURE add_Room_Recs(
            p_room_access_2lis           L2_chr_arr,    -- list of room access triples
            p_room_action_2lis           L2_chr_arr,    -- list of room action triples
            p_room_repair_2lis           L2_chr_arr) IS -- list of room repair quads
BEGIN
  FOR i IN 1..p_room_access_2lis.COUNT LOOP
    INSERT INTO log_deathstar_room_access( key_id, room_name, character_name ) VALUES (
                    p_room_access_2lis(i)(1), 
                    p_room_access_2lis(i)(2), 
                    p_room_access_2lis(i)(3) );
  END LOOP;
  FOR i IN 1..p_room_action_2lis.COUNT LOOP
    INSERT INTO log_deathstar_room_actions( key_id, action, done_by ) VALUES (
                    p_room_action_2lis(i)(1), 
                    p_room_action_2lis(i)(2), 
                    p_room_action_2lis(i)(3) );
  END LOOP;
  FOR i IN 1..p_room_repair_2lis.COUNT LOOP
    INSERT INTO log_deathstar_room_repairs( key_id, action, repair_completion, repaired_by ) VALUES (
                    p_room_repair_2lis(i)(1), 
                    p_room_repair_2lis(i)(2), 
                    p_room_repair_2lis(i)(3),
                    p_room_repair_2lis(i)(4) );
  END LOOP;
END add_Room_Recs;

FUNCTION Purely_Wrap_Feuertips_13_POC(
            p_inp_3lis                     L3_chr_arr)   -- input level 3 list (group, record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)
  l_act_2lis                     L2_chr_arr := L2_chr_arr();
BEGIN
  add_Room_Recs(p_room_access_2lis  => p_inp_3lis(1),
                p_room_action_2lis  => p_inp_3lis(2),
                p_room_repair_2lis  => p_inp_3lis(3));
  Feuertips_13.Feuertips_13_POC;
  l_act_2lis.EXTEND(2);
  l_act_2lis(1) := Utils.Read_File(p_file_name => 'room_action.log');  Utils.Delete_File(p_file_name => 'room_action.log');
  l_act_2lis(2) := Utils.Read_File(p_file_name => 'room_repair.log');  Utils.Delete_File(p_file_name => 'room_repair.log');
  ROLLBACK;
  RETURN l_act_2lis;

EXCEPTION
  WHEN OTHERS THEN UTL_File.FClose_All; RAISE;
END Purely_Wrap_Feuertips_13_POC;

END TT_Feuertips_13;
```
### Unit Test Scenarios
[&uarr; Unit Testing](#unit-testing)<br />
[&darr; Scenario Category Analysis (SCAN)](#scenario-category-analysis-scan)<br />
[&darr; Scenario Results](#scenario-results)

The art of unit testing lies in choosing a set of scenarios that will produce a high degree of confidence in the functioning of the unit under test across the often very large range of possible inputs.

A useful approach to this is to think in terms of categories of inputs, where we reduce large ranges to representative categories. Categories are chosen to explore the full range of potential behaviours of the unit under test.

#### Scenario Category Analysis (SCAN)
[&uarr; Unit Test Scenarios](#unit-test-scenarios)<br />
[&darr; Simple Category Sets](#simple-category-sets)<br />
[&darr; Composite Category Sets](#composite-category-sets)<br />
[&darr; Scenario Category Mapping](#scenario-category-mapping)<br />

In this section we identify the category sets for the problem, and tabulate the corresponding categories. We need to consider which category sets can be tested independently of each other, and which need to be considered in combination. We can then obtain a set of scenarios to cover all relevant combinations of categories.

In this case we have two sets of records each independently linked to sets of master records. This means that categories for the detail entities may depend on those for the master entity.

However, it may be helpful first to consider simpler category sets, where each entity is considered separately, or where the detail entities are considered as a pair. We can then go on to consider master-detail multiplicity category sets.

For convenience, let's use a short code for each entity:

- ACC: Room Access
- ACT: Room Action
- REP: Room Repair

##### Simple Category Sets
[&uarr; Scenario Category Analysis (SCAN)](#scenario-category-analysis-scan)

In this section we identify some simple category sets to apply.

###### SIZ - Size of values

We want to check that large values, as well as small ones, don't cause any problems for each entity such as value errors. We can do these in parallel across the entities, and also across other category sets.

| Code | Description  |
|:----:|:-------------|
| S    | Small values |
| L    | Large values |

###### MBK - Multiplicity By Key (MBK-ACC/ACT/REP)

We want to check behaviour when there are 0, 1, or more than 1 records for each entity by key, with upto 2 keys. 

| Code  | Description                                    |
|:-----:|:-----------------------------------------------|
| 0     |  No records                                    |
| 1     | 1 record for 1 key                             |
| 2     | 2 records for 1 key                            |
| 1-2   | 1 record for 1 key, 2 records for a second key |

###### SHK - Shared Keys

The records for ACT and REP detail entities can reference the same key as referenced by the other, or the key can be unique to one or other. We would like to check the different possibiities.

| Code  | Description                          |
|:-----:|:-------------------------------------|
| Y     | Shared key only                      |
| N     | Unshared keys only                   |
| B-A   | 1 key shared, ACT has 1 unshared key |
| B-R   | 1 key shared, REP has 1 unshared key |

##### Composite Category Sets
[&uarr; Scenario Category Analysis (SCAN)](#scenario-category-analysis-scan)

In this section we consider the multiplicity category sets for the detail entities (ACT, REP) in relation to the multiplicity category for the master entity (ACC).

###### ACC-0 - Empty

Where there is no ACC record there can be no ACT or REP records either.

| MBK-ACT | MBK-REP |
|:-------:|:-------:|
|    0    |     0   |

###### ACC-1 - 1 ACC record

Where there is 1 ACC record there can be 0, 1 or 2 ACT or REP records. We could check the different possibiities in parallel, as we will be looking at combinations later, or we could even just explicitly check the 1-1 pair.

| MBK-ACT | MBK-REP |
|:-------:|:-------:|
|    0    |    0    |
|    1    |    1    |
|    2    |    2    |

###### ACC-2 - 2 ACC record for same key

Where there are 2 ACC record there can be 0, 1 or 2 ACT or REP records. We can check the different combinations of ACT and REP multiplicity here, with 0, 1 and 2 available, while the 2-key category 1-2 is not possible.

| MBK-ACT | MBK-REP |
|:-------:|:-------:|
|    0    |    0    |
|    0    |    1    |
|    0    |    2    |
|    1    |    0    |
|    1    |    1    |
|    1    |    2    |
|    2    |    0    |
|    2    |    1    |
|    2    |    2    |

###### ACC-1-2 - 1 ACC record for 1 key, 2 records for a second key

Where there is 1 master (ACC) record for 1 key, and 2 records for a second, the shared key (SHK) categories for the detail pair (ACT, REP) can be tested, as shown in the table.

| SHK  | MBK-ACT | MBK-REP |
|:----:|:-------:|:-------:|
| Y    |  1-2    | 1-2     |
| N    |  1      | 2       |
| B-A  |  1-2    | 1       |
| B-R  |  1      | 1-2     |

##### Scenario Category Mapping
[&uarr; Scenario Category Analysis (SCAN)](#scenario-category-analysis-scan)

We now want to construct a set of scenarios based on the category sets identified, covering each individual category, and also covering combinations of categories that may interact.

In this case, the first four category sets may be considered as a single composite set with the combinations listed below forming the scenario keys, while the two SIZ categories are covered in the first two scenarios.

| #  | MBK-ACC | MBK-ACT | MBK-REP | SHK | SIZ | Description                                                  |
|:---|:-------:|:-------:|:-------:|:---:|:---:|:-------------------------------------------------------------|
| 1  | 0       |  0      | 0       | Y   | S   |MBK - ACC / ACT / REP = 0   / 0   / 0   ; SHK / SIZ = Y   / S |
| 2  | 1       |  1      | 1       | Y   | L   |MBK - ACC / ACT / REP = 1   / 1   / 1   ; SHK / SIZ = Y   / L |
| 3  | 2       |  0      | 0       | Y   | S   |MBK - ACC / ACT / REP = 2   / 0   / 0   ; SHK / SIZ = Y   / S |
| 4  | 2       |  0      | 1       | Y   | S   |MBK - ACC / ACT / REP = 2   / 0   / 1   ; SHK / SIZ = Y   / S |
| 5  | 2       |  0      | 2       | Y   | S   |MBK - ACC / ACT / REP = 2   / 0   / 2   ; SHK / SIZ = Y   / S |
| 6  | 2       |  1      | 0       | Y   | S   |MBK - ACC / ACT / REP = 2   / 1   / 0   ; SHK / SIZ = Y   / S |
| 7  | 2       |  1      | 1       | Y   | S   |MBK - ACC / ACT / REP = 2   / 1   / 1   ; SHK / SIZ = Y   / S |
| 8  | 2       |  1      | 2       | Y   | S   |MBK - ACC / ACT / REP = 2   / 1   / 2   ; SHK / SIZ = Y   / S |
| 9  | 2       |  2      | 0       | Y   | S   |MBK - ACC / ACT / REP = 2   / 2   / 0   ; SHK / SIZ = Y   / S |
| 10 | 2       |  2      | 1       | Y   | S   |MBK - ACC / ACT / REP = 2   / 2   / 1   ; SHK / SIZ = Y   / S |
| 11 | 2       |  2      | 2       | Y   | S   |MBK - ACC / ACT / REP = 2   / 2   / 2   ; SHK / SIZ = Y   / S |
| 12 | 1-2     |  1-2    | 1-2     | Y   | S   |MBK - ACC / ACT / REP = 1-2 / 1-2 / 1-2 ; SHK / SIZ = Y   / S |
| 13 | 1-2     |  1      | 2       | N   | S   |MBK - ACC / ACT / REP = 1-2 / 1   / 2   ; SHK / SIZ = N   / S |
| 14 | 1-2     |  1-2    | 1       | B-A | S   |MBK - ACC / ACT / REP = 1-2 / 1-2 / 1   ; SHK / SIZ = B-A / S |
| 15 | 1-2     |  1      | 1-2     | B-R | S   |MBK - ACC / ACT / REP = 1-2 / 1   / 1-2 ; SHK / SIZ = B-R / S |



#### Scenario Results
[&uarr; Unit Test Scenarios](#unit-test-scenarios)<br />
[&darr; Results Summary](#results-summary)<br />
[&darr; Unit Test Report: Feuertips 13 - Base](#unit-test-report-feuertips-13---base)<br />
[&darr; Unit Test Report: Feuertips 13 - v1](#unit-test-report-feuertips-13---v1)<br />
[&darr; Unit Test Report: Feuertips 13 - v2](#unit-test-report-feuertips-13---v2)

##### Results Summary
[&uarr; Scenario Results](#scenario-results)

In testing the initial (base) package against the scenarios above, an Oracle exception was raised on the first edge case scenario with no data in the tables:

`ORA-06502: PL/SQL: numeric or value error`

This was traced to a single line of code, and the bug was fixed in a new version of the package (v1). However, a number of the scenarios failed for a different reason, and a third version (v2) of the package was created with a fix for the second bug. This third version passed all scenarios. The results summary from the JavaScript test formatter for all three versions was:

```
Unit Test Results Summary for Folder ./externals/oracle_unit_test_examples
==========================================================================
 File                                                      Title                Inp Groups  Out Groups  Tests  Fails  Folder             
---------------------------------------------------------  -------------------  ----------  ----------  -----  -----  -------------------
*tt_feuertips_13.purely_wrap_feuertips_13_poc_out.json     Feuertips 13 - Base           3           3     15     11  feuertips-13---base
*tt_feuertips_13_v1.purely_wrap_feuertips_13_poc_out.json  Feuertips 13 - v1             3           3     15      7  feuertips-13---v1  
 tt_feuertips_13_v2.purely_wrap_feuertips_13_poc_out.json  Feuertips 13 - v2             3           3     15      0  feuertips-13---v2  

2 externals failed, see ./externals/oracle_unit_test_examples for scenario listings
tt_feuertips_13.purely_wrap_feuertips_13_poc_out.json
tt_feuertips_13_v1.purely_wrap_feuertips_13_poc_out.json
```

You can review the HTML formatted unit test results for the three versions here:

- [Unit Test Report: Feuertips 13 - Base](http://htmlpreview.github.io/?https://github.com/BrenPatF/oracle_unit_test_examples/blob/master/testing/output/feuertips-13---base/feuertips-13---base.html)
- [Unit Test Report: Feuertips 13 - v1](http://htmlpreview.github.io/?https://github.com/BrenPatF/oracle_unit_test_examples/blob/master/testing/output/feuertips-13---v1/feuertips-13---v1.html)
- [Unit Test Report: Feuertips 13 - v2](http://htmlpreview.github.io/?https://github.com/BrenPatF/oracle_unit_test_examples/blob/master/testing/output/feuertips-13---v2/feuertips-13---v2.html)


The formatted results files, both text and HTML, are available in the `testing/output` subfolders. The summary reports showing scenarios tested, in text format, for all three versions are copied below, with explanations for each of the two bugs found:

##### Unit Test Report: Feuertips 13 - Base
[&uarr; Scenario Results](#scenario-results)
```
Unit Test Report: Feuertips 13 - Base
=====================================

      #    Scenario                                                     Fails (of 3)  Status 
      ---  -----------------------------------------------------------  ------------  -------
      1*   MBK - ACC / ACT / REP = 0 / 0 / 0 ; SHK / SIZ = Y / S        1             FAILURE
      2*   MBK - ACC / ACT / REP = 1 / 1 / 1 ; SHK / SIZ = Y / L        3             FAILURE
      3*   MBK - ACC / ACT / REP = 2 / 0 / 0 ; SHK / SIZ = Y / S        1             FAILURE
      4*   MBK - ACC / ACT / REP = 2 / 0 / 1 ; SHK / SIZ = Y / S        2             FAILURE
      5*   MBK - ACC / ACT / REP = 2 / 0 / 2 ; SHK / SIZ = Y / S        2             FAILURE
      6*   MBK - ACC / ACT / REP = 2 / 1 / 0 ; SHK / SIZ = Y / S        2             FAILURE
      7*   MBK - ACC / ACT / REP = 2 / 1 / 1 ; SHK / SIZ = Y / S        3             FAILURE
      8*   MBK - ACC / ACT / REP = 2 / 1 / 2 ; SHK / SIZ = Y / S        3             FAILURE
      9*   MBK - ACC / ACT / REP = 2 / 2 / 0 ; SHK / SIZ = Y / S        2             FAILURE
      10*  MBK - ACC / ACT / REP = 2 / 2 / 1 ; SHK / SIZ = Y / S        3             FAILURE
      11*  MBK - ACC / ACT / REP = 2 / 2 / 2 ; SHK / SIZ = Y / S        3             FAILURE
      12   MBK - ACC / ACT / REP = 1-2 / 1-2 / 1-2 ; SHK / SIZ = Y / S  0             SUCCESS
      13   MBK - ACC / ACT / REP = 1-2 / 1 / 2 ; SHK / SIZ = N / S      0             SUCCESS
      14   MBK - ACC / ACT / REP = 1-2 / 1-2 / 1 ; SHK / SIZ = B-A / S  0             SUCCESS
      15   MBK - ACC / ACT / REP = 1-2 / 1 / 1-2 ; SHK / SIZ = B-R / S  0             SUCCESS

Test scenarios: 11 failed of 15: FAILURE
========================================
```
Here is the output results for the exception raised in scenario 1 (and others):

```
      GROUP 3: Unhandled Exception {
      ==============================

            #   Line                                                                                                                                                                                                                                         
            --  ----------------------------------------------
            1   *NO RECORD*                                                                                                                                                                                                                                  
            1*  ORA-06502: PL/SQL: numeric or value error                                                                                                                                                                                                    
            2   *NO RECORD*                                                                                                                                                                                                                                  
            2*  ORA-06512: at "APP.TT_FEUERTIPS_13", line 116
ORA-06512: at "APP.FEUERTIPS_13", line 33
ORA-06512: at "APP.FEUERTIPS_13", line 94
ORA-06512: at "APP.TT_FEUERTIPS_13", line 106
ORA-06512: at line 1
ORA-06512: at "LIB.TRAPIT_RUN", line 62

      } 2 failed of 2: FAILURE
      ========================
```
The stack trace shows that the error arose at line 33 of the  package, which is:
```
      for i in p_lines.first..p_lines.last loop
```
and we can see immediately what the problem is: In this edge case the p_lines array will be empty, and the methods `first` and `last` are both null for an empty array, which causes the value error in the loop statement. We can fix this by using the `count` method, which has the value zero for an empty array.
```
      for i in 1..p_lines.count loop
```
The loop just performs zero iterations here, so long as the array has been initialized (if not we would get: `ORA-06531: Reference to uninitialized collection`).
##### Unit Test Report: Feuertips 13 - v1
[&uarr; Scenario Results](#scenario-results)
```
Unit Test Report: Feuertips 13 - v1
===================================

      #    Scenario                                                     Fails (of 3)  Status 
      ---  -----------------------------------------------------------  ------------  -------
      1    MBK - ACC / ACT / REP = 0 / 0 / 0 ; SHK / SIZ = Y / S        0             SUCCESS
      2*   MBK - ACC / ACT / REP = 1 / 1 / 1 ; SHK / SIZ = Y / L        1             FAILURE
      3    MBK - ACC / ACT / REP = 2 / 0 / 0 ; SHK / SIZ = Y / S        0             SUCCESS
      4*   MBK - ACC / ACT / REP = 2 / 0 / 1 ; SHK / SIZ = Y / S        1             FAILURE
      5*   MBK - ACC / ACT / REP = 2 / 0 / 2 ; SHK / SIZ = Y / S        1             FAILURE
      6    MBK - ACC / ACT / REP = 2 / 1 / 0 ; SHK / SIZ = Y / S        0             SUCCESS
      7*   MBK - ACC / ACT / REP = 2 / 1 / 1 ; SHK / SIZ = Y / S        1             FAILURE
      8*   MBK - ACC / ACT / REP = 2 / 1 / 2 ; SHK / SIZ = Y / S        1             FAILURE
      9    MBK - ACC / ACT / REP = 2 / 2 / 0 ; SHK / SIZ = Y / S        0             SUCCESS
      10*  MBK - ACC / ACT / REP = 2 / 2 / 1 ; SHK / SIZ = Y / S        1             FAILURE
      11*  MBK - ACC / ACT / REP = 2 / 2 / 2 ; SHK / SIZ = Y / S        1             FAILURE
      12   MBK - ACC / ACT / REP = 1-2 / 1-2 / 1-2 ; SHK / SIZ = Y / S  0             SUCCESS
      13   MBK - ACC / ACT / REP = 1-2 / 1 / 2 ; SHK / SIZ = N / S      0             SUCCESS
      14   MBK - ACC / ACT / REP = 1-2 / 1-2 / 1 ; SHK / SIZ = B-A / S  0             SUCCESS
      15   MBK - ACC / ACT / REP = 1-2 / 1 / 1-2 ; SHK / SIZ = B-R / S  0             SUCCESS

Test scenarios: 7 failed of 15: FAILURE
=======================================
```
Here we see that several of the scenarios that failed now succeed, including the first empty tables scenario, but a number of others are still failing. For example, here are the results  for scenario 4:
```
SCENARIO 4: MBK - ACC / ACT / REP = 2 / 0 / 1 ; SHK / SIZ = Y / S {
===================================================================
   INPUTS
   ======
      GROUP 1: Room Access {
      ======================
            #  Key Id  Room Name  Character Name
            -  ------  ---------  --------------
            1  1       Room 1     Peter         
            2  1       Room 1     Paul          
      }
      =
      GROUP 2: Room Action: Empty
      ===========================
      GROUP 3: Room Repair {
      ======================
            #  Key Id  Action   Completion  Repaired By
            -  ------  -------  ----------  -----------
            1  1       Inspect  10%         Stephanie  
      }
      =
   OUTPUTS
   =======
      GROUP 1: File room_action.log: Empty as expected: SUCCESS
      =========================================================
      GROUP 2: File room_repair.log {
      ===============================
            #   Line                          
            --  ------------------------------
            1   1|Room 1|10%|Stephanie|Inspect
            1*  *NO RECORD*                   

      } 1 failed of 1: FAILURE
      ========================
      GROUP 3: Unhandled Exception: Empty as expected: SUCCESS
      ========================================================
} 1 failed of 3: FAILURE
========================
```
The scenario failed because the expected line in room_repair.log was not present. In fact, all the failed scenarios fail for absence of expected lines in this log. On inspecting the code, we see that there are two loops over the master table, with nested loops over the the room action table in the first, and over the room repair table in the second. To avoid duplicating detail records where multiple records of the same key are present in the master table, a flag variable, l_first_time, is used like this in the master loops:
```
   for crs in (
      select *
        from log_deathstar_room_access
   ) loop
      case
         when l_current_key != crs.key_id then
            l_first_time   := 1;
            l_current_key  := crs.key_id;
         else
            l_first_time := 2;
      end case;

      if l_first_time = 1 then
         for crs2 in (
            select *
              from log_deathstar_room_actions
              where key_id = crs.key_id
         ) loop
...
```
However, the flag is initialized in the package declaration section, but not reset between the two master loops, as it needs to be. One simple solution (without refactoring, as that's not the purpose of this article) is to to add the necessary reset line between the loops:
```
l_current_key := 0;
```
The next section shows that the third version (v2) with this fix has all scenarios succeeding.
##### Unit Test Report: Feuertips 13 - v2
[&uarr; Scenario Results](#scenario-results)
```
Unit Test Report: Feuertips 13 - v2
===================================

      #    Scenario                                                     Fails (of 3)  Status 
      ---  -----------------------------------------------------------  ------------  -------
      1    MBK - ACC / ACT / REP = 0 / 0 / 0 ; SHK / SIZ = Y / S        0             SUCCESS
      2    MBK - ACC / ACT / REP = 1 / 1 / 1 ; SHK / SIZ = Y / L        0             SUCCESS
      3    MBK - ACC / ACT / REP = 2 / 0 / 0 ; SHK / SIZ = Y / S        0             SUCCESS
      4    MBK - ACC / ACT / REP = 2 / 0 / 1 ; SHK / SIZ = Y / S        0             SUCCESS
      5    MBK - ACC / ACT / REP = 2 / 0 / 2 ; SHK / SIZ = Y / S        0             SUCCESS
      6    MBK - ACC / ACT / REP = 2 / 1 / 0 ; SHK / SIZ = Y / S        0             SUCCESS
      7    MBK - ACC / ACT / REP = 2 / 1 / 1 ; SHK / SIZ = Y / S        0             SUCCESS
      8    MBK - ACC / ACT / REP = 2 / 1 / 2 ; SHK / SIZ = Y / S        0             SUCCESS
      9    MBK - ACC / ACT / REP = 2 / 2 / 0 ; SHK / SIZ = Y / S        0             SUCCESS
      10   MBK - ACC / ACT / REP = 2 / 2 / 1 ; SHK / SIZ = Y / S        0             SUCCESS
      11   MBK - ACC / ACT / REP = 2 / 2 / 2 ; SHK / SIZ = Y / S        0             SUCCESS
      12   MBK - ACC / ACT / REP = 1-2 / 1-2 / 1-2 ; SHK / SIZ = Y / S  0             SUCCESS
      13   MBK - ACC / ACT / REP = 1-2 / 1 / 2 ; SHK / SIZ = N / S      0             SUCCESS
      14   MBK - ACC / ACT / REP = 1-2 / 1-2 / 1 ; SHK / SIZ = B-A / S  0             SUCCESS
      15   MBK - ACC / ACT / REP = 1-2 / 1 / 1-2 ; SHK / SIZ = B-R / S  0             SUCCESS

Test scenarios: 0 failed of 15: SUCCESS
=======================================
```

## See Also
[&uarr; In this README...](#in-this-readme)<br />

- [Oracle Unit Test Examples: See Also](../../../#see-also)
