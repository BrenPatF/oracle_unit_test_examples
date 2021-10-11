# Oracle  Unit Test Examples / login_bursts
This subproject belongs to the parent project: Oracle Unit Test Examples, which contains examples of unit testing of Oracle SQL queries and PL/SQL code using the 'Math Function Unit Testing' design pattern. The project introduces a new general method for choosing unit test scenarios, Scenario Category ANalysis (SCAN).

In this design pattern unit testing is data driven from a JSON file containing input data together with expected output data for a set of scenarios. The SCAN method involves creating high level scenarios as combinations of categories within category sets for the specific problem. These high level scenarios are then implemented in the JSON file by creating data to match the categories. Each subproject illusatrates the process of category set analysis and mapping onto scenarios for a specific problem.

I got the idea to include this example after reading this [tweet from Lucas Jellema](https://twitter.com/lucasjellema/status/1367394764371419137) in which he notes that a solution to a SQL puzzle that he had posted on his blog had been shown to be incorrect by a reader. It's one of those cases where a solution may work in some scenarios but not in all, and so I wanted to see how I could unit test solutions using my scenario-based design pattern. I took the three correct solutions posted to the blog, [SQL–Only Counting Records Sufficiently Spaced apart using Analytics with Windowing Clause and Anti Join](https://technology.amis.nl/languages/sql-database/sql-only-counting-records-sufficiently-spaced-apart-using-analytics-with-windowing-clause-and-anti-join/) from the reader, Iudith Mentzel, as well as a version of an incorrect pure analytics solution, and created my own unit test data that tries to cover all distinct scenarios.

You can read a definition of the problem, with a useful diagram, on the blog. However, I think it's worth noting that the problem has been around for a while and I first encountered it on this AskTom thread on 1 June 2011, [group records by interval of 3 seconds](https://asktom.oracle.com/pls/apex/asktom.search?tag=group-records-by-interval-of-3-seconds#3482514200346118756), where it's described thus:

<blockquote>
We need to get the reference date starting from the first row's date value of each group (by ID). Succeeding rows within the 6 hour time will get the same base date. Once a row whose value is on the 6th hour after that base date, the base date is changed and is set to the current row's date value:
</blockquote>

There are Model clause and recursive subquery solutions in the thread similar to the blog, although not Match_Recognize, which was not available at that time.

There are four short recordings on the project (around 2m each), which can also be viewed via a Twitter thread:

|   | Folder                | Recording                     | Tweet                                                                                   |
|:-:|:----------------------|:------------------------------|:----------------------------------------------------------------------------------------|
|   | .                     | oracle_unit_test_examples.mp4 | [1: oracle_unit_test_examples](https://twitter.com/BrenPatF/status/1447145129828098050) |
| * | login_bursts          | login_bursts.mp4              | [2: login_bursts](https://twitter.com/BrenPatF/status/1447441450229194754)              |
|   | sf_epa_investigations | sf_epa_investigations.mp4     |                                                                                         |
|   | sf_sn_log_deathstar   | sf_sn_log_deathstar.mp4       |                                                                                         |

## In this README...
[&darr; Installation](#installation)<br />
[&darr; Unit Testing](#unit-testing)<br />
[&darr; See Also](#see-also)

## Installation
[&uarr; In this README...](#in-this-readme)<br />
[&darr; Prerequisites](#prerequisites)<br />
[&darr; Install login_bursts](#install-login_bursts)<br />
[&darr; Example Data and Solution](#example-data-and-solution)

### Prerequisites
[&uarr; Installation](#installation)

The common project prerequisites must be installed from the project root README, [Oracle Unit Test Examples: Installation](../../../#installation)

### Install login_bursts
[&uarr; Installation](#installation)

#### [Schema: app; Folder: login_bursts/app]

- Run script from slqplus:

```sql
SQL> @install_login_bursts
```

### Example Data and Solution
[&uarr; Installation](#installation)

The installation script includes the setup of an example, with input data and solution shown below.
```
Example data

PERSONID   LOGIN_TIME
---------- --------------
1          01012021 00:00
           01012021 01:00
           01012021 01:59
           01012021 02:00
           01012021 02:39
           01012021 03:00
           01012021 04:59
2          01012021 01:01
           01012021 01:30
           01012021 02:00
           01012021 05:00
           01012021 06:00

12 rows selected.

Solution for example data

PERSONID   BLOCK_ST
---------- --------
1          01 00:00
           01 02:39
           01 04:59
2          01 01:01
           01 05:00
```

## Unit Testing
[&uarr; In this README...](#in-this-readme)<br />
[&darr; Unit Testing Process](#unit-testing-process)<br />
[&darr; Unit Test Wrapper Function](#unit-test-wrapper-function)<br />
[&darr; Unit Test Scenarios](#unit-test-scenarios)

### Unit Testing Process
[&uarr; Unit Testing](#unit-testing)<br />

The package is tested using the Math Function Unit Testing design pattern, described here in its Oracle version: [Trapit - Oracle PL/SQL unit testing module](https://github.com/BrenPatF/trapit_oracle_tester). In this approach, a 'pure' wrapper function is constructed that takes input parameters and returns a value, and is tested within a loop over scenario records read from a JSON file.

Unit testing is data-driven from the input file login_bursts.json and produces an output results file for each program tested, in the Oracle directory `INPUT_DIR`. These contain arrays of expected and actual records by group and scenario, and in this case there are four files corresponding to the four queries tested.

The unit test program may be run from the Oracle app subfolder:

```sql
SQL> @r_tests
```

The output results files are processed by a nodejs program that has to be installed separately, as described in the [Oracle Unit Test Examples: README instructions](https://github.com/BrenPatF/oracle_unit_test_examples/blob/master/README.md#installation). The nodejs program produces listings of the results in HTML and/or text format in a subfolder named from the unit test title, and the four subfolders are included in the folder `testing\output`. 

To run the processor, open a powershell window in the npm trapit package folder after placing the four output JSON files, tt_login_bursts.purely_wrap_view_*_out.json, in a new (or existing) folder, oracle_unit_test_examples, within the subfolder externals and run:

```
$ node externals\format-externals oracle_unit_test_examples
```
This outputs to screen the following summary level report, as well as writing the formatted results files to the subfolders indicated:
```
Unit Test Results Summary for Folder ./externals/oracle_unit_test_examples
==========================================================================
 File                                           Title                           Inp Groups  Out Groups  Tests  Fails  Folder
----------------------------------------------  ------------------------------  ----------  ----------  -----  -----  ------------------------------
*tt_login_bursts.purely_wrap_view_ana_out.json  Login Bursts - Analytics                 1           2      3      2  login-bursts---analytics
 tt_login_bursts.purely_wrap_view_mod_out.json  Login Bursts - Model                     1           2      3      0  login-bursts---model
 tt_login_bursts.purely_wrap_view_mre_out.json  Login Bursts - Match_Recognize           1           2      3      0  login-bursts---match_recognize
 tt_login_bursts.purely_wrap_view_rsf_out.json  Login Bursts - Recursive                 1           2      3      0  login-bursts---recursive

1 externals failed, see ./externals/oracle_unit_test_examples for scenario listings
tt_login_bursts.purely_wrap_view_ana_out.json
```

### Unit Test Wrapper Function
[&uarr; Unit Testing](#unit-testing)<br />
[&darr; Wrapper Function Signature Diagram](#wrapper-function-signature-diagram)<br />
[&darr; Wrapper Function Code](#wrapper-function-code)

#### Wrapper Function Signature Diagram
[&uarr; Unit Test Wrapper Function](#unit-test-wrapper-function)

<img src="testing\oracle_unit_test_examples - logins.png">

An easy way to generate a starting point for the input JSON file is to use a powershell utility [Powershell Utilites module](https://github.com/BrenPatF/powershell_utils) to generate a template file with a single scenario with placeholder records from simple .csv files. See the script login_bursts.ps1 in the `testing` subfolder for an example.

#### Wrapper Function Code
[&uarr; Unit Test Wrapper Function](#unit-test-wrapper-function)

The text box below shows the entire body code for the unit test package containing the four wrapper functions, Purely_Wrap_View_*. Each function calls a core function passing in its own view name, and the core function creates the test data and returns the output from a utility function that gets the output from the view as a list of delimited strings. It's quite short isn't it? 🙂

```sql
CREATE OR REPLACE PACKAGE BODY TT_Login_Bursts AS

PROCEDURE add_Logins(
            p_login_2lis                     L2_chr_arr) IS -- input list of lists for records
BEGIN
  FOR i IN 1..p_login_2lis.COUNT LOOP
    INSERT INTO logins VALUES (p_login_2lis(i)(1), To_Date(p_login_2lis(i)(2), 'DDMMYYYY HH24:MI'));
  END LOOP;
END add_Logins;

FUNCTION purely_Wrap_View(
            p_view_name                    VARCHAR2,     -- view name
            p_inp_3lis                     L3_chr_arr)   -- input list of lists (record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)
  l_act_2lis                     L2_chr_arr := L2_chr_arr();
BEGIN
  DELETE logins;
  add_Logins(p_login_2lis     => p_inp_3lis(1));
  l_act_2lis.EXTEND;
  l_act_2lis(1) := Utils.View_To_List(
                                p_view_name     => p_view_name,
                                p_sel_value_lis => L1_chr_arr('personid', 'block_start_login_time'),
                                p_order_by      => 'personid, block_start_login_time');
  ROLLBACK;
  RETURN l_act_2lis;
END purely_Wrap_View;

FUNCTION Purely_Wrap_View_MRE(
            p_inp_3lis                     L3_chr_arr)   -- input level 3 list (group, record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)
BEGIN
  RETURN purely_Wrap_View(p_view_name => 'Match_Recognize_V', p_inp_3lis  => p_inp_3lis);
END Purely_Wrap_View_MRE;

[...FUNCTION Purely_Wrap_View_MOD, Purely_Wrap_View_RSF, Purely_Wrap_View_ANA - just different views]

END TT_Login_Bursts;
```
### Unit Test Scenarios
[&uarr; Unit Testing](#unit-testing)<br />
[&darr; Scenario Category ANalysis (SCAN)](#scenario-category-analysis-scan)<br />
[&darr; Scenario Results](#scenario-results)

The art of unit testing lies in choosing a set of scenarios that will produce a high degree of confidence in the functioning of the unit under test across the often very large range of possible inputs.

A useful approach to this is to think in terms of categories of inputs, where we reduce large ranges to representative categories. Categories are chosen to explore the full range of potential behaviours of the unit under test.

#### Scenario Category ANalysis (SCAN)
[&uarr; Unit Test Scenarios](#unit-test-scenarios)<br />
[&darr; Simple Category Sets](#simple-category-sets)<br />
[&darr; Composite Category Sets](#composite-category-sets)<br />
[&darr; Scenario Category Mapping](#scenario-category-mapping)<br />

In this section we identify the category sets for the problem, and tabulate the corresponding categories. We need to consider which category sets can be tested independently of each other, and which need to be considered in combination. We can then obtain a set of scenarios to cover all relevant combinations of categories.

##### Simple Category Sets
[&uarr; Scenario Category ANalysis (SCAN)](#scenario-category-analysis-scan)

###### MUL-P - Multiplicity for person

Check works correctly with both 1 and multiple persons.

| Code | Description                                 |
|:----:|:--------------------------------------------|
|   1  | One                                         |
|   2  | Multiple (2 sufficent to repreent multiple) |

###### MUL-L - Multiplicity for login groups per person (or MUL-L1, MUL-L2 for person 1, person 2 etc.)

Check works correctly with both 1 and multiple logins per person.

| Code | Description                       |
|:----:|:----------------------------------|
|   1  | One login group per person        |
|   m  | Multiple login groupss per person |

###### SEP - Group separation

Check works correctly with groups that start shortly after, as well as a long time after, records in a prior group.

| Code | Description                      |
|:----:|:---------------------------------|
|   S  | Small                            |
|   L  | Large                            |
|   B  | Both large and small separations |

###### GAD - Group across days

Check works correctly when group crosses into another day.

| Code | Description         |
|:----:|:--------------------|
|   1  | Group within day    |
|   2  | Group across 2 days |

###### SIM - Simultaneity

Check works correctly with simultaneous group start records.

| Simultaneous | Description             |
|:------------:|:------------------------|
|   Y          | Simultaneous records    |
|   N          | No simultaneous records |

##### Composite Category Sets
[&uarr; Scenario Category ANalysis (SCAN)](#scenario-category-analysis-scan)

The multiplicities of persons and login groups need to be considered in combination.

###### MUL-PL - Multiplicity of persons and logins

Check works correctly with 1 and multiple persons and login groups per person.

| MUL-P | MUL-L1 | MUL-L2 |
|:-----:|:------:|:------:|
|   1   |    1   |    -   |
|   1   |    m   |    -   |
|   2   |    m   |    m   |

##### Scenario Category Mapping
[&uarr; Scenario Category ANalysis (SCAN)](#scenario-category-analysis-scan)

We now want to construct a set of scenarios based on the category sets identified, covering each individual category, and also covering combinations of categories that may interact.

In this case, the first three category sets may be considered as a single composite set with the combinations listed below forming the scenario keys, while the other three categories are covered in parallel.

| # | MUL-P | MUL-L1 | MUL-L2 | SEP | GAD | SIM | Description                                                       |
|:--|:-----:|:------:|:------:|:---:|:---:|:---:|:------------------------------------------------------------------|
| 1 |   1   |    1   |    -   |  S  |  1  |  N  | MUL-P / MUL-L1 / MUL-L2 / SEP / GAD / SIM = 1 / 1 / - / S / 1 / N |
| 2 |   1   |    m   |    -   |  B  |  2  |  N  | MUL-P / MUL-L1 / MUL-L2/  SEP / GAD / SIM = 1 / m / - / B / 2 / N |
| 3 |   2   |    m   |    m   |  B  |  1  |  Y  | MUL-P / MUL-L1 / MUL-L2 / SEP / GAD / SIM = 2 / m / m /B / 1 / Y  |

#### Scenario Results
[&uarr; Unit Test Scenarios](#unit-test-scenarios)<br />
[&darr; Results Summary](#results-summary)<br />
[&darr; Unit Test Report: Login Bursts - Model](#unit-test-report-login-bursts---model)<br />
[&darr; Unit Test Report: Login Bursts - Analytics](#unit-test-report-login-bursts---analytics)<br />

##### Results Summary
[&uarr; Scenario Results](#scenario-results)

The results summary from the JavaScript test formatter for all four queries was:
```
Unit Test Results Summary for Folder ./externals/oracle_unit_test_examples
==========================================================================
 File                                           Title                           Inp Groups  Out Groups  Tests  Fails  Folder                        
----------------------------------------------  ------------------------------  ----------  ----------  -----  -----  ------------------------------
*tt_login_bursts.purely_wrap_view_ana_out.json  Login Bursts - Analytics                 1           2      3      2  login-bursts---analytics      
 tt_login_bursts.purely_wrap_view_mod_out.json  Login Bursts - Model                     1           2      3      0  login-bursts---model          
 tt_login_bursts.purely_wrap_view_mre_out.json  Login Bursts - Match_Recognize           1           2      3      0  login-bursts---match_recognize
 tt_login_bursts.purely_wrap_view_rsf_out.json  Login Bursts - Recursive                 1           2      3      0  login-bursts---recursive      

1 externals failed, see ./externals/oracle_unit_test_examples for scenario listings
tt_login_bursts.purely_wrap_view_ana_out.json
```

You can review the HTML formatted unit test results for the four queries here:

- [Unit Test Report: Login Bursts - Analytics](http://htmlpreview.github.io/?https://github.com/BrenPatF/oracle_unit_test_examples/blob/main/login_bursts/testing/output/login-bursts---analytics/login-bursts---analytics.html)
- [Unit Test Report: Login Bursts - Match_Recognize](http://htmlpreview.github.io/?https://github.com/BrenPatF/oracle_unit_test_examples/blob/main/login_bursts/testing/output/login-bursts---match_recognize/login-bursts---match_recognize.html)
- [Unit Test Report: Login Bursts - Model](http://htmlpreview.github.io/?https://github.com/BrenPatF/oracle_unit_test_examples/blob/main/login_bursts/testing/output/login-bursts---model/login-bursts---model.html)
- [Unit Test Report: Login Bursts - Recursive](http://htmlpreview.github.io/?https://github.com/BrenPatF/oracle_unit_test_examples/blob/main/login_bursts/testing/output/login-bursts---recursive/login-bursts---recursive.html)


The formatted results files, both text and HTML, are available in the `testing/output` subfolders. The summary reports showing scenarios tested, in text format, for two of the queries are copied below:

#### Unit Test Report: Login Bursts - Model
[&uarr; Scenario Results](#scenario-results)
```
Unit Test Report: Login Bursts - Model
======================================

      #    Scenario                                                           Fails (of 2)  Status 
      ---  -----------------------------------------------------------------  ------------  -------
      1    MUL-P / MUL-L1 / MUL-L2 / SEP / GAD / SIM = 1 / 1 / - / S / 1 / N  0             SUCCESS
      2    MUL-P / MUL-L1 / MUL-L2 / SEP / GAD / SIM = 1 / 3 / - / B / 2 / N  0             SUCCESS
      3    MUL-P / MUL-L1 / MUL-L2 / SEP / GAD / SIM = 2 / 3 / 2 / B / 1 / Y  0             SUCCESS

Test scenarios: 0 failed of 3: SUCCESS
======================================
```

#### Unit Test Report: Login Bursts - Analytics
[&uarr; Scenario Results](#scenario-results)
```
Unit Test Report: Login Bursts - Analytics
==========================================

      #    Scenario                                                           Fails (of 2)  Status 
      ---  -----------------------------------------------------------------  ------------  -------
      1    MUL-P / MUL-L1 / MUL-L2 / SEP / GAD / SIM = 1 / 1 / - / S / 1 / N  0             SUCCESS
      2*   MUL-P / MUL-L1 / MUL-L2 / SEP / GAD / SIM = 1 / 3 / - / B / 2 / N  1             FAILURE
      3*   MUL-P / MUL-L1 / MUL-L2 / SEP / GAD / SIM = 2 / 3 / 2 / B / 1 / Y  1             FAILURE

Test scenarios: 2 failed of 3: FAILURE
======================================
```

The detailed report for the second scenario, in text format, is copied below:

<pre>
SCENARIO 2: MUL-P / MUL-L1 / MUL-L2 / SEP / GAD / SIM = 1 / 3 / - / B / 2 / N {
===============================================================================

   INPUTS
   ======

      GROUP 1: Login {
      ================

            #  Person Id  Time          
            -  ---------  --------------
            1  Adam       06032021 10:00
            2  Adam       06032021 12:01
            3  Adam       06032021 14:01
            4  Adam       06032021 23:00
            5  Adam       07032021 00:30

      }
      =

   OUTPUTS
   =======

      GROUP 1: First Login {
      ======================

            #   Person Id    Time    
            --  -----------  --------
            1   Adam         06 10:00
            2   Adam         06 12:01
            3   Adam         06 23:00
            3*  Adam         06 14:01
            4   *NO RECORD*          
            4*  Adam         06 23:00
            5   *NO RECORD*          
            5*  Adam         07 00:30

      } 3 failed of 5: FAILURE
      ========================

      GROUP 2: Unhandled Exception: Empty as expected: SUCCESS
      ========================================================

} 1 failed of 2: FAILURE
========================
</pre>

## See Also
[&uarr; In this README...](#in-this-readme)<br />

- [Oracle Unit Test Examples: See Also](../../../#see-also)
