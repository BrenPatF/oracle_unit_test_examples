# Oracle  Unit Test Examples / sf_epa_investigations
This subproject belongs to the parent project: Oracle Unit Test Examples, which contains examples of unit testing of Oracle SQL queries and PL/SQL code using the 'Math Function Unit Testing' design pattern. The project introduces a new general method for choosing unit test scenarios, Scenario Category ANalysis (SCAN).


This example comes from [Feuertip #8: “On the cheap” testing](https://www.insum.ca/feuertip-8-on-the-cheap-testing/), where Steven Feuerstein creates a table and PL/SQL package to demonstrate a possible approach to unit testing: 

<blockquote>
Here’s my “on the cheap” suggestion for testing: build yourself a simple test harness.
</blockquote>

The table, investigation_details, holds identifiers for spray and pesticide against an investigation identifier, in the context of environmental inspection. Either of the spray and pesticide identifiers may be null, and the unit under test is a procedure, investigation_mgr.pack_details, to add one or both of the optional fields against an investigation in the table. The procedure has the requirement that it must fill in any blank spray or pesticide identifier already in the table for the given investigation before adding any new record.

I borrow Steven's example here to demonstrate my own approach to unit testing via the Math Function Unit Testing design pattern, copying his base code, but using my own framework to test it, and to demonstrate the SCAN method for scenario selection.

There are four short recordings on the project (around 2m each), which can also be viewed via a Twitter thread:

|   | Folder                | Recording                     | Tweet                                                                                   |
|:-:|:----------------------|:------------------------------|:----------------------------------------------------------------------------------------|
|   | .                     | oracle_unit_test_examples.mp4 | [1: oracle_unit_test_examples](https://twitter.com/BrenPatF/status/1447145129828098050) |
|   | login_bursts          | login_bursts.mp4              |                                                                                         |
| * | sf_epa_investigations | sf_epa_investigations.mp4     |                                                                                         |
|   | sf_sn_log_deathstar   | sf_sn_log_deathstar.mp4       |                                                                                         |

## In this README...
[&darr; Installation](#installation)<br />
[&darr; Unit Testing](#unit-testing)<br />
[&darr; See Also](#see-also)

## Installation
[&uarr; In this README...](#in-this-readme)<br />
[&darr; Prerequisites](#prerequisites)<br />
[&darr; Install sf_epa_investigations](#install-sf_epa_investigations)<br />
[&darr; Example Data and Solution](#example-data-and-solution)

### Prerequisites
[&uarr; Installation](#installation)

The common project prerequisites must be installed from the project root README, [Oracle Unit Test Examples: Installation](../../../#installation)

### Install sf_epa_investigations
[&uarr; Installation](#installation)

#### [Schema: app; Folder: sf_epa_investigations/app]

- Run script from slqplus:

```sql
SQL> @install_sf_epa_investigations
```
### Example Data and Solution
[&uarr; Installation](#installation)

The installation script includes an example (taken from Steven Feuerstein's article), with three calls to the procedure and the resulting single record created in the table shown below.
```
Call procedure as example three times...

PL/SQL procedure successfully completed.

  1  BEGIN
  2     investigation_mgr.pack_details(
  3        p_investigation_id  => 100,
  4        p_pesticide_id      => 123,
  5        p_spray_id          => 789
  6     );
  7
  8     investigation_mgr.pack_details(
  9        p_investigation_id  => 100,
 10        p_pesticide_id      => 123,
 11        p_spray_id          => 789
 12     );
 13
 14     investigation_mgr.pack_details(
 15        p_investigation_id  => 100,
 16        p_pesticide_id      => null,
 17        p_spray_id          => 789
 18     );
 19* END;

Example data created by calls...

        ID INVESTIGATION_ID   SPRAY_ID PESTICIDE_ID
---------- ---------------- ---------- ------------
         1              100        789          123
```

## Unit Testing
[&uarr; In this README...](#in-this-readme)<br />
[&darr; Unit Testing Process](#unit-testing-process)<br />
[&darr; Unit Test Wrapper Function](#unit-test-wrapper-function)<br />
[&darr; Unit Test Scenarios](#unit-test-scenarios)

### Unit Testing Process
[&uarr; Unit Testing](#unit-testing)<br />

The package is tested using the Math Function Unit Testing design pattern, described here in its Oracle version: [Trapit - Oracle PL/SQL unit testing module](https://github.com/BrenPatF/trapit_oracle_tester). In this approach, a 'pure' wrapper function is constructed that takes input parameters and returns a value, and is tested within a loop over scenario records read from a JSON file.

Unit testing is data-driven from the input file sf_epa_investigations.json and produces an output results file, in the Oracle directory `INPUT_DIR`. This contains arrays of expected and actual records by group and scenario.

The unit test program may be run from the Oracle app subfolder:

```sql
SQL> @r_tests
```

The output results files are processed by a nodejs program that has to be installed separately, as described in the [Oracle Unit Test Examples: README instructions](https://github.com/BrenPatF/oracle_unit_test_examples/blob/master/README.md#installation). The nodejs program produces listings of the results in HTML and/or text format in a subfolder named from the unit test title, and the subfolder is included in the folder `testing\output`.

To run the processor, open a powershell window in the npm trapit package folder after placing the output JSON file, tt_investigation_mgr.purely_wrap_investigation_mgr_out.json, in a new (or existing) folder, oracle_unit_test_examples, within the subfolder externals and run:

```
$ node externals\format-externals oracle_unit_test_examples
```
This outputs to screen the following summary level report, as well as writing the formatted results files to the subfolder indicated:
```
Unit Test Results Summary for Folder ./externals/oracle_unit_test_examples
==========================================================================
 File                                                         Title               Inp Groups  Out Groups  Tests  Fails  Folder            
------------------------------------------------------------  ------------------  ----------  ----------  -----  -----  ------------------
 tt_investigation_mgr.purely_wrap_investigation_mgr_out.json  EPA Investigations           2           2      9      0  epa-investigations

0 externals failed, see ./externals/oracle_unit_test_examples for scenario listings
```

### Unit Test Wrapper Function
[&uarr; Unit Testing](#unit-testing)<br />
[&darr; Wrapper Function Signature Diagram](#wrapper-function-signature-diagram)<br />
[&darr; Wrapper Function Code](#wrapper-function-code)

#### Wrapper Function Signature Diagram
[&uarr; Unit Test Wrapper Function](#unit-test-wrapper-function)

<img src="testing\oracle_unit_test_examples - sf_epa.png">

An easy way to generate a starting point for the input JSON file is to use a powershell utility [Powershell Utilites module](https://github.com/BrenPatF/powershell_utils) to generate a template file with a single scenario with placeholder records from simple .csv files. See the script sf_epa_investigations.ps1 in the `testing` subfolder for an example.

#### Wrapper Function Code
[&uarr; Unit Test Wrapper Function](#unit-test-wrapper-function)

The text box below shows the entire body code for the unit test package containing the wrapper function, Purely_Wrap_Investigation_Mgr. It's quite short isn't it? 🙂

```sql
CREATE OR REPLACE PACKAGE BODY TT_Investigation_Mgr AS

PROCEDURE add_Investigations(
            p_investigation_2lis           L2_chr_arr) IS -- list of investigation triples
BEGIN
  FOR i IN 1..p_investigation_2lis.COUNT LOOP
    INSERT INTO investigation_details(
                    investigation_id,
                    spray_id,
                    pesticide_id
    ) VALUES (
                    p_investigation_2lis(i)(1), 
                    p_investigation_2lis(i)(2), 
                    p_investigation_2lis(i)(3));
  END LOOP;
END add_Investigations;

FUNCTION do_Call(
            p_investigation_lis            L1_chr_arr)   -- list of investigation triples
            RETURN                         L1_chr_arr IS -- list of delimited records
  l_ret_lis             L1_chr_arr;
BEGIN
  Investigation_Mgr.Pack_Details(
      p_investigation_id  => p_investigation_lis(1),
      p_spray_id          => p_investigation_lis(2),
      p_pesticide_id      => p_investigation_lis(3)
  );
  SELECT Utils.Join_Values(
                  investigation_id,
                  spray_id,
                  pesticide_id)
    BULK COLLECT
    INTO l_ret_lis
    FROM investigation_details
   ORDER BY id;
  RETURN l_ret_lis;
END do_Call;

FUNCTION Purely_Wrap_Investigation_Mgr(
            p_inp_3lis                     L3_chr_arr)   -- input level 3 list (group, record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)

  l_act_2lis                     L2_chr_arr := L2_chr_arr();
BEGIN
  add_Investigations(p_investigation_2lis => p_inp_3lis(1));
  l_act_2lis.EXTEND;
  l_act_2lis(1) := do_Call(p_investigation_lis => p_inp_3lis(2)(1));
  ROLLBACK;
  RETURN l_act_2lis;
END Purely_Wrap_Investigation_Mgr;

END TT_Investigation_Mgr;
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
[&darr; Scenario Category Mapping]()<br />

In this section we identify the category sets for the problem, and tabulate the corresponding categories. We need to consider which category sets can be tested independently of each other, and which need to be considered in combination. We can then obtain a set of scenarios to cover all relevant combinations of categories.

In this case, we have as inputs a pair of identifiers, spray id and pesticide id, linked to an investigation id, in the form of existing records in a table, and also as a single parameter triple.

It may be helpful first to consider each of the two identifiers separately, and obtain single identifier category sets with associated categories. However, we also need to consider the identifiers as pairs, as they may interact; for example, if neither parameter has a slot available we need to insert a new record, but only one.

##### Simple Category Sets
[&uarr; Scenario Category Analysis (SCAN)](#scenario-category-analysis-scan)

First we consider simple, single identifier category sets.

- Parameter null?
    - Yes
    - No

- Parameter value in table for investigation?
    - Yes
    - No

- Slot availabile for investigation?<br />
    - Yes
    - No

The categories result in actions for the parameter value in relation to the table:

- Actions
    - Do nothing
    - Update
    - Insert

We can represent the categories with associated actions in a dependency tree:

<img src="oracle_unit_test_examples - tree.png">

We will clearly want to ensure that each leaf node for each parameter is represented in a test scenario. However, while the action tree fully represents the required actions for the categories shown, there remain categories of input data that we would like to test are handled correctly. For example, the node corresponding to the Insert action could arise because there are no records in the table for the investigation, or it could arise because there are records but all have values for the parameter. It's possible that the program could behave correctly for one but not for the other. 

- Slot unavailable cases<br />
    - No records in table
    - Only records for another investigation, with slot available
    - Records for another investigation, with slot available, and for current investigation with no slots

Now, let's write out a consolidated list of categories by set with short codes for ease of reference:

###### PNL - Parameter null (for S and P: PNL-S, PNL-P)

| Parameter Null? | Null/Not null |
|:---------------:|:--------------|
|         Y       | Null          |
|         N       | Not null      |

######  ACT - Action with subdivisions (for S and P: ACT-S, ACT-P)

| Code | Action  | Reason                                                                                              |
|:----:|:--------|:----------------------------------------------------------------------------------------------------|
| NPN  | Nothing | Parameter null                                                                                      |
| NVT  | Nothing | Value in table                                                                                      |
| UPD  | Update  | Slot available                                                                                      |
| INR  | Insert  | No records in table                                                                                 |
| IOR  | Insert  | Only records for another investigation, with slot available                                         |
| INS  | Insert  | Records for another investigation, with slot available, and for current investigation with no slots |

###### NUI - Simple action (for S and P: NUI-S, NUI-P)

This simpler actions category set may be useful for considering action combinations in the next section.

| Code | Action  |
|:----:|:--------|
|   N  | Nothing |
|   U  | Update  |
|   I  | Insert  |

##### Composite Category Sets
[&uarr; Scenario Category Analysis (SCAN)](#scenario-category-analysis-scan)

As noted above, we need to account for possible parameter interactions, by considering category sets for the identifier pairs.

###### PPN - Parameter Pair Nullity Category Set
This category set contains all combinations of null and not null for the pair of parameters.

| Code | Spray | Pesticide | S-Null?  | P-Null? |
|:----:|:-----:|:---------:|:---------|:--------|
|  YY  |   Y   |      Y    | Null     |Null     |
|  NY  |   N   |      Y    | Not null |Null     |
|  YN  |   Y   |      N    | Null     |Not null |
|  NN  |   N   |      N    | Not null |Not null |
 
###### PPA - Parameter Pair Actions Category Set
This category set contains all combinations of the simple action category set (NUI) for the pair of parameters.

| Code | Spray | Pesticide | S-Action | P-Action |
|:----:|:-----:|:---------:|:---------|:---------|
|  NN  |    N  |      N    | Nothing  | Nothing  |
|  NU  |    N  |      U    | Nothing  | Update   |
|  NI  |    N  |      I    | Nothing  | Insert   |
|  UN  |    U  |      N    | Update   | Nothing  |
|  UU  |    U  |      U    | Update   | Update   |
|  UI  |    U  |      I    | Update   | Insert   |
|  IN  |    I  |      N    | Insert   | Nothing  |
|  IU  |    I  |      U    | Insert   | Update   |
|  II  |    I  |      I    | Insert   | Insert   |
 
##### Scenario Category Mapping
[&uarr; Scenario Category Analysis (SCAN)](#scenario-category-analysis-scan)

We now want to construct a set of scenarios based on the category sets identified, covering each individual category, and also covering combinations of categories that may interact.

In this case we want to ensure each identifier has all single-identifier categories covered, and also that both of the identifier pair category sets are fully covered. We can achieve this by creating a scenario for each PPA composite category, and choosing the other categories appropriately, as in the following table:

| # | PPA | PPN | ACT-S | ACT-P | Description                                                                  |
|:--|:---:|:---:|:-----:|:-----:|:-----------------------------------------------------------------------------|
| 1 |  NN | YY  |  NPN  |  NPN  | NPN-NPN: S, P - parameter null                                               |
| 2 |  NU | NN  |  NVT  |  UPD  | NVT-UPD: S - value in table, P - update slot                                 |
| 3 |  NI | YN  |  NPN  |  IOR  | NPN-IOR: S - parameter null, P - records for other investigation, with slots |
| 4 |  UN | NY  |  UPD  |  NPN  | UPD-NPN: S - update slot, P - parameter null                                 |
| 5 |  UU | NN  |  UPD  |  UPD  | UPD-UPD: S, P - update slot                                                  |
| 6 |  UI | NN  |  UPD  |  INS  | UPD-INS: S - update slot, P - records but no slots                           |
| 7 |  IN | NN  |  INS  |  NVT  | INS-NVT: S - records but no slots, P - value in table                        |
| 8 |  IU | NN  |  IOR  |  UPD  | IOR-UPD: S - records for other investigation, with slots, P - update  slot   |
| 9 |  II | NN  |  INR  |  INR  | INR-INR: S, P - no records                                                   |

#### Scenario Results
[&uarr; Unit Test Scenarios](#unit-test-scenarios)<br />
[&darr; Results Summary](#results-summary)<br />
[&darr; Unit Test Report: EPA Investigations](#unit-test-report-epa-investigations)

##### Results Summary
[&uarr; Scenario Results](#scenario-results)

The results summary from the JavaScript test formatter for the unit test was:

```
Unit Test Results Summary for Folder ./externals/oracle_unit_test_examples
==========================================================================
 File                                                         Title               Inp Groups  Out Groups  Tests  Fails  Folder            
------------------------------------------------------------  ------------------  ----------  ----------  -----  -----  ------------------
 tt_investigation_mgr.purely_wrap_investigation_mgr_out.json  EPA Investigations           2           2     12      0  epa-investigations

0 externals failed, see ./externals/oracle_unit_test_examples for scenario listings
```

You can review the HTML formatted unit test results for the program here: 

- [Unit Test Report: EPA Investigations](http://htmlpreview.github.io/?https://github.com/BrenPatF/oracle_unit_test_examples/blob/main/sf_epa_investigations/testing/output/epa-investigations/epa-investigations.html)

The formatted results files, both text and HTML, are available in the `testing/output/epa-investigations` subfolder. The summary report showing scenarios tested, in text format, is copied below:

##### Unit Test Report: EPA Investigations
[&uarr; Scenario Results](#scenario-results)
```
Unit Test Report: EPA Investigations
====================================

      #    Scenario                                                                      Fails (of 2)  Status 
      ---  ----------------------------------------------------------------------------  ------------  -------
      1    NPN-NPN: S, P - parameter null                                                0             SUCCESS
      2    NVT-UPD: S - value in table, P - update slot                                  0             SUCCESS
      3    NPN-IOR: S - parameter null, P - records for other investigation, with slots  0             SUCCESS
      4    UPD-NPN: S - update slot, P - parameter null                                  0             SUCCESS
      5    UPD-UPD: S, P - update slot                                                   0             SUCCESS
      6    UPD-INS: S - update slot, P - records but no slots                            0             SUCCESS
      7    INS-NVT: S - records but no slots, P - value in table                         0             SUCCESS
      8    IOR-UPD: S, P - records for other investigation, with slots                   0             SUCCESS
      9    INR-INR: S, P - no records                                                    0             SUCCESS

Test scenarios: 0 failed of 9: SUCCESS
======================================
```

The detailed report for a single scenario, in text format, is copied below:

```
SCENARIO 6: UPD-INS: S - update slot, P - records but no slots {
================================================================

   INPUTS
   ======

      GROUP 1: Table {
      ================

            #  Investigation Id  Spray Id  Pesticide Id
            -  ----------------  --------  ------------
            1  100                         2001        

      }
      =

      GROUP 2: Parameters {
      =====================

            #  Investigation Id  Spray Id  Pesticide Id
            -  ----------------  --------  ------------
            1  100               1001      2002        

      }
      =

   OUTPUTS
   =======

      GROUP 1: Table {
      ================

            #  Investigation Id  Spray Id  Pesticide Id
            -  ----------------  --------  ------------
            1  100               1001      2001        
            2  100                         2002        

      } 0 failed of 2: SUCCESS
      ========================

      GROUP 2: Unhandled Exception: Empty as expected: SUCCESS
      ========================================================

} 0 failed of 2: SUCCESS
========================
```

## See Also
[&uarr; In this README...](#in-this-readme)<br />

- [Oracle Unit Test Examples: See Also](../../../#see-also)
