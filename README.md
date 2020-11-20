# scrape_linkedin

## Introduction

`scrape_linkedin` is a python package to scrape all details from public LinkedIn
profiles, turning the data into structured json. You can scrape Companies
and user profiles with this package.

**Warning**: LinkedIn has strong anti-scraping policies, they may blacklist ips making
unauthenticated or unusual requests

## Table of Contents

<!--ts-->

- [scrape_linkedin](#scrapelinkedin)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
    - [Install with pip](#install-with-pip)
    - [Install from source](#install-from-source)
    - [Tests](#tests)
  - [Getting & Setting LI_AT](#getting--setting-liat)
    - [Getting LI_AT](#getting-liat)
    - [Setting LI_AT](#setting-liat)
  - [Examples](#examples)
  - [Usage](#usage)
    - [Command Line](#command-line)
    - [Python Package](#python-package)
      - [Profiles](#profiles)
      - [Companies](#companies)
      - [config](#config)
  - [Scraping in Parallel](#scraping-in-parallel)
    - [Example](#example)
    - [Configuration](#configuration)
  - [Issues](#issues)

<!-- Added by: austinoboyle, at: 2018-05-06T20:13-04:00 -->

<!--te-->

## Installation

### Install with pip

Run `pip install git+git://github.com/austinoboyle/scrape-linkedin-selenium.git`

### Install from source

`git clone https://github.com/austinoboyle/scrape-linkedin-selenium.git`

Run `python setup.py install`

### Tests

Tests are (so far) only run on static html files. One of which is a linkedin
profile, the other is just used to test some utility functions.

## Getting & Setting LI_AT

Because of Linkedin's anti-scraping measures, you must make your selenium
browser look like an actual user. To do this, you need to add the li_at cookie
to the selenium session.

### Getting LI_AT

1.  Navigate to www.linkedin.com and log in
2.  Open browser developer tools (Ctrl-Shift-I or right click -> inspect
    element)
3.  Select the appropriate tab for your browser (**Application** on Chrome,
    **Storage** on Firefox)
4.  Click the **Cookies** dropdown on the left-hand menu, and select the
    `www.linkedin.com` option
5.  Find and copy the li_at **value**

### Setting LI_AT

There are two ways to set your li_at cookie:

1.  Set the LI_AT environment variable
    -   `$ export LI_AT=YOUR_LI_AT_VALUE`
    -   **On Windows**: `C:/foo/bar> set LI_AT=YOUR_LI_AT_VALUE`
2.  Pass the cookie as a parameter to the Scraper object.
    > `>>> with ProfileScraper(cookie='YOUR_LI_AT_VALUE') as scraper:`

A cookie value passed directly to the Scraper **will override your
environment variable** if both are set.

## Examples

See [`/examples`](https://github.com/austinoboyle/scrape-linkedin-selenium/tree/master/examples)

## Usage

### Command Line

scrape_linkedin comes with a command line argument module `scrapeli` created
using [click](http://click.pocoo.org/5/).

**Note: CLI only works with Personal Profiles as of now.**

Options:

-   --url : Full Url of the profile you want to scrape
-   --user: www.linkedin.com/in/USER
-   --driver: choose Browser type to use (Chrome/Firefox), **default: Chrome**
-   -a --attribute : return only a specific attribute (default: return all
    attributes)
-   -i --input_file : Raw path to html file of the profile you want to scrape
-   -o --output_file: Raw path to output file for structured json profile (just
    prints results by default)
-   -h --help : Show this screen.

Examples:

-   Get Austin O'Boyle's profile info: `$ scrapeli --user=austinoboyle`
-   Get only the skills of Austin O'Boyle: `$ scrapeli --user=austinoboyle -a skills`
-   Parse stored html profile and save json output: `$ scrapeli -i /path/file.html -o output.json`

### Python Package

#### Profiles

Use `ProfileScraper` component to scrape profiles.

```python
from scrape_linkedin import ProfileScraper

with ProfileScraper() as scraper:
    profile = scraper.scrape(user='austinoboyle')
print(profile.to_dict())
```

`Profile` - the class that has properties to access all information pulled from
a profile. Also has a to_dict() method that returns all of the data as a dict

    with open('profile.html', 'r') as profile_file:
        profile = Profile(profile_file.read())

    print (profile.skills)
    # [{...} ,{...}, ...]
    print (profile.experiences)
    # {jobs: [...], volunteering: [...],...}
    print (profile.to_dict())
    # {personal_info: {...}, experiences: {...}, ...}

**Structure of the fields scraped**

-   personal_info
    -   name
    -   company
    -   school
    -   headline
    -   followers
    -   summary
    -   websites
    -   email
    -   phone
    -   connected
    -   current_company_link
    -   image
-   skills
-   experiences
    -   volunteering
    -   jobs
    -   education
-   interests
-   accomplishments
    -   publications
    -   cerfifications
    -   patents
    -   courses
    -   projects
    -   honors
    -   test scores
    -   languages
    -   organizations

#### Companies

Use `CompanyScraper` component to scrape companies.

```python
from scrape_linkedin import CompanyScraper

with CompanyScraper() as scraper:
    company = scraper.scrape(company='facebook')
print(company.to_dict())
```

`Company` - the class that has properties to access all information pulled from
a company profile. There will be three properties: overview, jobs, and life.
**Overview is the only one currently implemented.**

    with open('overview.html', 'r') as overview,
        open('jobs.html', 'r') as jobs,
        open('life.html', 'r') as life:
            company = Company(overview, jobs, life)

    print (company.overview)
    # {...}

**Structure of the fields scraped**

-   overview
    -   name
    -   company_size
    -   specialties
    -   headquarters
    -   founded
    -   website
    -   description
    -   industry
    -   num_employees
    -   type
    -   image
-   jobs **NOT YET IMPLEMENTED**
-   life **NOT YET IMPLEMENTED**

#### config

Pass these keyword arguments into the constructor of your Scraper to override
default values. You may (for example) want to decrease/increase the timeout if
your internet is very fast/slow.

-   _cookie_ **`{str}`**: li_at cookie value (overrides env variable)
    -   **default: `None`**
-   _driver_ **`{selenium.webdriver}`**: driver type to use
    -   **default: `selenium.webdriver.Chrome`**
-   _driver_options_ **`{dict}`**: kwargs to pass to driver constructor
    -   **default: `{}`**
-   _scroll_pause_ **`{float}`**: time(s) to pause during scroll increments
    -   **default: `0.1`**
-   _scroll_increment_ **`{int}`** num pixels to scroll down each time
    -   **default: `300`**
-   _timeout_ **`{float}`**: default time to wait for async content to load
    -   **default: `10`**

## Scraping in Parallel

New in version 0.2: built in parallel scraping functionality. Note that the
up-front cost of starting a browser session is high, so in order for this to be
beneficial, you will want to be scraping many (> 15) profiles.

### Example

```python
from scrape_linkedin import scrape_in_parallel, CompanyScraper

companies = ['facebook', 'google', 'amazon', 'microsoft', ...]

#Scrape all companies, output to 'companies.json' file, use 4 browser instances
scrape_in_parallel(
    scraper_type=CompanyScraper,
    items=companies,
    output_file="companies.json",
    num_instances=4
)
```

### Configuration

**Parameters:**

-   _scraper_type_ **`{scrape_linkedin.Scraper}`**: Scraper to use
-   _items_ **`{list}`**: List of items to be scraped
-   _output_file_ **`{str}`**: path to output file
-   _num_instances_ **`{int}`**: number of parallel instances of selenium to run
-   _temp_dir_ **`{str}`**: name of temporary directory to use to store data from intermediate steps
    -   **default: 'tmp_data'**
-   _driver_ {selenium.webdriver}: driver to use for scraping
    -   **default: selenium.webdriver.Chrome**
-   _driver_options_ **`{dict}`**: dict of keyword arguments to pass to the driver function.
    -   **default: scrape_linkedin.utils.HEADLESS_OPTIONS**
-   _\*\*kwargs_ **`{any}`**: extra keyword arguments to pass to the `scraper_type` constructor for each job

## Deploy via Docker

This project creates a small dockerized REST API around the scrapeli program.

At the moment, the following functionnalities are exposed via REST :
 * scrap a linkedin profile via username
 * scrap a linkedin profile via url

### How to use this image

This image contains the main binaries for the linkedin scrapper. It requires the LI_AT cookie that can be passed as an environnement variable.

```
docker run --rm -it <NameOfTheImage> \
  --env LI_AT=AQEDAQzZQt0Dm3BeAAABdbbSwNQAAAF2BAsix04AhtA7a6ihL0IcaYSVOOcMSL-teAHhLzGlnzTK4MH1T-nPaxdAcUQDHCK6ENW5s51Sq3OWEmxud6mnldbUEVcBBeBxRa0z_LBF6hA2znjw8K0uHdXe
```

### Examples 

* Request a profile by username

```
curl -v -X POST http://<server>:5057/scrap -d '{"typeoftask": "username", "name": "<user>"}' 
```
e.g.:
```
curl -v -X POST http://127.0.0.1:5057/scrap -d '{"typeoftask": "username", "name": "austinoboyle"}' 
```

* Request a profile by url

```
curl -v -X POST http://<server>:5057/scrap -d '{"typeoftask": "userurl", "name": "<user>"}' 
```
e.g.:
```
curl -v -X POST http://127.0.0.1:5057/scrap -d '{"typeoftask": "userurl", "name": "https://www.linkedin.com/in/austinoboyle/"}' 
```


## Issues

Report bugs and feature requests
[here](https://github.com/austinoboyle/scrape-linkedin-selenium/issues).
