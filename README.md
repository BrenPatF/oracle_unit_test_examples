# Oracle Unit Test Examples

<img src="mountains.png">
> The Math Function Unit Testing design pattern, with Scenario Category ANalysis (SCAN)<br /><br />

:file_cabinet: :question: :outbox_tray:

This project contains examples of unit testing of Oracle SQL queries and PL/SQL code using the 'Math Function Unit Testing' design pattern. The project introduces a new general method for choosing unit test scenarios that I call Scenario Category ANalysis, or SCAN for short.

The base code comes from interesting examples I have come across on the internet, to which I apply my own Oracle unit testing framework. The aim is to demonstrate both the mechanics of implementing the unit tests, and also how to use the new SCAN method in selecting good sets of scenarios for different types of problem, within a data-driven testing framework.

<img src="scanners.jpg">

[Scanners IMDB](https://www.imdb.com/title/tt0081455/)

There are four short recordings on the project (around 2m each), which can also be viewed via a Twitter thread:

|   | Folder                | Recording                     | Tweet                                                                                   |
|:-:|:----------------------|:------------------------------|:----------------------------------------------------------------------------------------|
| * | .                     | oracle_unit_test_examples.mp4 | [1: oracle_unit_test_examples](https://twitter.com/BrenPatF/status/1447145129828098050) |
|   | login_bursts          | login_bursts.mp4              | [2: login_bursts](https://twitter.com/BrenPatF/status/1447441450229194754)              |
|   | sf_epa_investigations | sf_epa_investigations.mp4     | [3: sf_epa_investigations](https://twitter.com/BrenPatF/status/1447805483415445506)     |
|   | sf_sn_log_deathstar   | sf_sn_log_deathstar.mp4       | [4: sf_sn_log_deathstar](https://twitter.com/BrenPatF/status/1448165085831127040)       |

There is also a blog post:

- [Unit Testing, Scenarios and Categories: The SCAN Method](https://brenpatf.github.io/jekyll/update/2021/10/17/unit-testing-scenarios-and-categories-the-scan-method.html)

## In this README...
[&darr; Background](#background)<br />
[&darr; Scenario Category Analysis (SCAN)](#scenario-category-analysis-scan)<br />
[&darr; Subprojects](#Subprojects)<br />
[&darr; Installation](#installation)<br />
[&darr; See Also](#see-also)

## Background
[&uarr; In this README...](#in-this-readme)

I created the [Trapit Oracle PL/SQL unit testing module](https://github.com/BrenPatF/trapit_oracle_tester) on GitHub in 2016, and explained the concepts involved in a presentation at the Oracle User Group Ireland Conference in March 2018:

- [The Database API Viewed As A Mathematical Function: Insights into Testing](https://www.slideshare.net/brendanfurey7/database-api-viewed-as-a-mathematical-function-insights-into-testing)

In 2018 I named the approach 'The Math Function Unit Testing design pattern', and developed a JavaScript module supporting its use in JavaScript unit testing, and formatting unit test results in both text and HTML:
- [The Math Function Unit Testing design pattern, implemented in nodejs](https://github.com/BrenPatF/trapit_nodejs_tester)

The module also formats unit test results produced by programs in any language that follow the pattern and produce JSON results files in the required format. After creating the JavaScript module, I converted the original Oracle Trapit module to use JSON files for both input and output in the required format:

- [Trapit - Oracle PL/SQL unit testing module](https://github.com/BrenPatF/trapit_oracle_tester)


Since then, I have used the Oracle unit testing framework in testing my own Oracle code of various types. These examples are all available on [my GitHub account](https://github.com/BrenPatF), and include utility packages, such as for [code timing](https://github.com/BrenPatF/timer_set_oracle), and a [project](https://github.com/BrenPatF/oracle_plsql_api_demos) intended to demonstrate unit testing (as well as instrumentation) of 'business as usual'-type PL/SQL APIs  using the publicly available Oracle HR demo schema.

The current project demonstrates the unit testing framework on further examples, taken this time from third-party published articles that I have come across on the internet. The project also serves to demonstrate, using these examples, a new, systematic approach to the selection of unit test scenarios - the SCAN method.

Each example has its own subproject, and has a link to the source for the example. The code to create example test data and for the program unit itself comes initially from the source, but may be modified to suit the testing framework, or for other reasons, and its use here is to be understood as purely for unit test demonstration purposes.

## Scenario Category ANalysis (SCAN)
[&uarr; In this README...](#in-this-readme)<br />
[&darr; Input Data Category Sets](#input-data-category-sets)<br />
[&darr; Simple Category Sets](#simple-category-sets)<br />
[&darr; Composite Category Sets](#composite-category-sets)<br />
[&darr; Scenario Category Mapping](#scenario-category-mapping)

### Input Data Category Sets
[&uarr; Scenario Category Analysis (SCAN)](#scenario-category-analysis-scan)

The art of unit testing lies in choosing a set of scenarios that will produce a high degree of confidence in the functioning of the unit under test across the often very large range of possible inputs.

A useful approach to this is to think in terms of categories of inputs, where we reduce large ranges to representative categories. The idea is to choose categories of input data that effectively cover the range of functional behaviour across the entire space. For example, if we have a credit card transaction validation function, we could define valid and invalid categories of credit card numbers, and for valid numbers we could define categories of transaction amount for maximum valid amount, minimum invalid amount, and perhaps some large amount categories to cover possible numeric overflows.

In the proposed approach, we define category sets relevant to the unit under test, each having a finite set of categories. The aim is then to construct high level scenarios consisting of a combination of one category from each category set. The test data for the scenario is then constructed by choosing data points within the chosen categories.

While this approach reduces the size of the input space to be considered, the number of category combinations may still be large. If we write C<sub>i</sub> for the cardinality of the i'th category set then the total number of combinations is the product of the cardinalities:

C_<sub>1</sub>.C<sub>2</sub>...C<sub>N</sub> for N category sets

So, if we had, say, just 3 category sets with 4 categories in each, we would have 4<sup>3</sup> = 64 combinations, and the numbers could be much larger in some cases. Fortunately, in practice we do not need to consider all combinatioons of categories, since many category sets are independent, meaning that we can test their categories in parallel. For example, a common generic category set could be value size for a given field, where we want to verify that both large and small values can be handled without errors. It would usually be reasonable to test small and large categories for all fields in parallel, requiring just two scenarios.


It may be helpful to start by tabulating the relevant simple category sets, before moving on to consider which sets also need to be considered in combination.

### Simple Category Sets
[&uarr; Scenario Category Analysis (SCAN)](#scenario-category-analysis-scan)

This section shows a simple generic way of tabulating a category set. We would create a similar table for each one relevant to the unit under test.

#### CST - Category set description

| Code  | Description               |
|:-----:|:--------------------------|
| Cat-1 | Description of category 1 |
| Cat-2 | Description of category 2 |

### Composite Category Sets
[&uarr; Scenario Category Analysis (SCAN)](#scenario-category-analysis-scan)

While many category sets can be tested independently of others as in the value size example mentioned above, in other cases we may need to consider categories in combination. For example, in the context of sales orders it is common for unit prices to be banded according to quantity ordered, and it is possible (though maybe not so common) for quantities of different items to affect each others' unit prices.

#### CST-1-CST-2 - Category sets CST-1, CST-2 combinations

This section shows a simple generic way of tabulating a combination of category sets, where in this case all 4 combinations of 2 categories within 2 category sets are enumerated.

| CST-1  | CST-2  |
|:------:|:------:|
| Cat-11 | Cat-21 |
| Cat-12 | Cat-21 |
| Cat-11 | Cat-22 |
| Cat-12 | Cat-22 |

There may also be more complex dependencies. For example, we may have a master entity where the category chosen may limit the possible categories available to detail entities. In any case, the aim is to enumerate the possible combinations for the categories considered together; in fact we can consider the combinations to form a single composite category set in itself.

### Scenario Category Mapping
[&uarr; Scenario Category Analysis (SCAN)](#scenario-category-analysis-scan)

Once we have identified the relevant category sets and enumerated the categories within them, we can produce a list of scenarios. If, as noted above, we consider all groups of inter-dependent category sets as category sets in their own right, with their categories being the possible combinations, and by definition independent of each other, we can easily see how to construct a comprehensive list of scenarios: 

- Take the category set of highest cardinality and create a scenario record for each (possibly composite) category
- Use the category description, or combination of sub-category codes, as a unique identifier for the scenario
- Tabulate the list of scenarios with a number, the unique identifier columns and append the other independent category sets as columns
- The secondary category set columns enumerate their categories until exhausted, then repeat categories as necessary to complete the records

Here is a schematic for the kind of table we might construct, representing `category level scenarios`:

| #  | CST-KEY   | Description           | CST-SEC-1 | ETC. |
|:---|:---------:|:----------------------|:---------:|:----:|
| 1  | CAT-KEY-1 | CAT-KEY-1 description | CAT-SEC-1 |  ... |
| 2  | CAT-KEY-2 | CAT-KEY-2 description | CAT-SEC-2 |  ... |
...

Data points can then be constructed within the input JSON file to match the desired categories, to give the `data level scenarios`.

The discussion above is necessarily somewhat abstract, but the examples in the subprojects should make the approach clearer.

## Subprojects
[&uarr; In this README...](#in-this-readme)<br />

### login_bursts
The login_bursts subproject concerns the problem of determining distinct 'bursts of activity', where an initial record defines the start of a burst, which then includes all activities within a fixed time interval of that start, with the first activity outside the burst defining the next burst, and so on.

- [README: login_bursts](login_bursts/README.md)

### sf_epa_investigations
The sf_epa_investigations subproject concerns the efficient allocation of identifiers for spray and pesticide against an investigation identifier, in the context of environmental inspection.

- [README: sf_epa_investigations](sf_epa_investigations/README.md)

### sf_sn_log_deathstar
The sf_sn_log_deathstar subproject concerns the reading of records from a master table and two detail tables each linked by a key_id field, and the writing out of the records from each detail table into two corresponding files without duplication.

- [README: sf_sn_log_deathstar](sf_sn_log_deathstar/README.md)

## Installation
[&uarr; In this README...](#in-this-readme)<br />
[&darr; Install 1: Install prerequisite tools (if necessary)](#install-1-install-prerequisite-tools-if-necessary)<br />
[&darr; Install 2: Clone git repository](#install-2-clone-git-repository)<br />
[&darr; Install 3: Install prerequisite modules](#install-3-install-prerequisite-modules)<br />
[&darr; Install 4: Copy the unit test input JSON files to the database server](#install-4-copy-the-unit-test-input-json-files-to-the-database-server)<br />
[&darr; Install 5: Install the subprojects](#install-5-install-the-subprojects)

### Install 1: Install prerequisite tools (if necessary)
- [&uarr; Installation](#installation)

#### Oracle database
The database installation requires a minimum Oracle version of 12.2 [Oracle Database Software Downloads](https://www.oracle.com/database/technologies/oracle-database-software-downloads.html).

#### Github Desktop
In order to clone the code as a git repository you need to have the git application installed. I recommend [Github Desktop](https://desktop.github.com/) UI for managing repositories on windows. This depends on the git application, available here: [git downloads](https://git-scm.com/downloads), but can also be installed from within Github Desktop, according to these instructions: 
[How to install GitHub Desktop](https://www.techrepublic.com/article/how-to-install-github-desktop/).

#### nodejs (Javascript backend)
nodejs is needed to run a program that turns the unit test output files into formatted HTML pages. It requires no JavaScript knowledge to run the program, and nodejs can be installed [here](https://nodejs.org/en/download/).

### Install 2: Clone git repository
[&uarr; Installation](#installation)

The following steps will download the repository into a folder, oracle_unit_test_examples, within your GitHub root folder:
- Open Github desktop and click [File/Clone repository...]
- Paste into the url field on the URL tab: https://github.com/BrenPatF/oracle_unit_test_examples.git
- Choose local path as folder where you want your GitHub root to be
- Click [Clone]

### Install 3: Install prerequisite modules
[&uarr; Installation](#installation)

The install depends on the prerequisite modules Utils and Trapit and `lib` and `app` schemas refer to the schemas in which the prerequisites and examples are installed, respectively.

The prerequisite modules can be installed by following the instructions for each module at the module root pages listed in the `See Also` section below. This allows inclusion of the examples and unit tests for those modules. Alternatively, the next section shows how to install these modules directly without their examples or unit tests.

#### [Schema: sys; Folder: install_prereq] Create lib and app schemas and Oracle directory
install_sys.sql creates an Oracle directory, `input_dir`, pointing to 'c:\input'. Update this if necessary to a folder on the database server with read/write access for the Oracle OS user
- Run script from slqplus:

```
SQL> @install_sys
```

#### [Schema: lib; Folder: install_prereq\lib] Create lib components
- Run script from slqplus:

```
SQL> @install_lib_all
```

#### [Schema: app; Folder: install_prereq\app] Create app synonyms
- Run script from slqplus:

```
SQL> @c_syns_all
```
#### [Folder: (npm root)] Install npm trapit package
The npm trapit package is a nodejs package used to format unit test results in text and HTML format.

Open a DOS or Powershell window in the folder where you want to install npm packages, and, with [nodejs](https://nodejs.org/en/download/) installed, run
```
$ npm install trapit
```
This should install the trapit nodejs package in a subfolder .\node_modules\trapit

### Install 4: Copy the unit test input JSON files to the database server
[&uarr; Installation](#installation)

- Copy the following files from the `subproject`\testing\input folders to the server folder pointed to by the Oracle directory INPUT_DIR:
    - login_bursts.json
    - sf_epa_investigations.json
    - sf_sn_log_deathstar.json

- There is also a powershell script to do this, assuming C:\input as INPUT_DIR. From a powershell window in the root folder:
```powershell
$ ./Copy-JSONToInput.ps1
```

### Install 5: Install the subprojects
[&uarr; Installation](#installation)

See the subproject READMEs:
- [Install login_bursts](login_bursts/README.md#installation)
- [Install sf_epa_investigations](sf_epa_investigations/README.md#installation)
- [Install sf_sn_log_deathstar](sf_sn_log_deathstar/README.md#installation)

## Operating System/Oracle Versions
### Windows
Windows 10
### Oracle
Oracle Database Version 19.3.0.0.0

## See Also
[&uarr; In this README...](#in-this-readme)<br />
- [Database API Viewed As A Mathematical Function: Insights into Testing](https://www.slideshare.net/brendanfurey7/database-api-viewed-as-a-mathematical-function-insights-into-testing)
- [The Math Function Unit Testing design pattern, implemented in nodejs](https://github.com/BrenPatF/trapit_nodejs_tester)
- [Trapit - Oracle PL/SQL unit testing module](https://github.com/BrenPatF/trapit_oracle_tester)
- [Powershell utilities module](powershell_utils)
- [Utils - Oracle PL/SQL general utilities module](https://github.com/BrenPatF/oracle_plsql_utils)
- [Timer_Set - Oracle PL/SQL code timing module](https://github.com/BrenPatF/timer_set_oracle)
- [Oracle PL/SQL API Demos - demonstrating instrumentation and logging, code timing and unit testing of Oracle PL/SQL APIs](https://github.com/BrenPatF/oracle_plsql_api_demos)

## License
MIT
