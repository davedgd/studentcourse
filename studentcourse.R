# ------------
# Instructions
# ------------

# Make sure to install any missing package libraries before trying to run this script. Note that you may need to change the server settings based on your configuration (see dbConnect below).

# -------------
# Load Packages
# -------------

library(dplyr)
library(ggplot2)
library(DBI)
library(RMySQL)

# install.packages(c("dplyr", "ggplot2", "DBI", "RMySQL"))

# -------------
# Connect to DB
# -------------

# Load the database driver:

driver <- dbDriver("MySQL")

# Connect to the database:

studentcourse <- dbConnect(driver, 
                           dbname = "studentcourse",
                           host = "localhost", 
                           port = 3306,
                           user = "root", 
                           password = "root")

# --------------------
# DBI Command Examples
# --------------------

# List all tables:

dbListTables(studentcourse)

# List columns of a particular table (e.g., student):

dbListFields(studentcourse, "student")

# Store a particular table as an R object:

student <- dbReadTable(studentcourse, "student")

student

# ---------------
# Running Queries
# ---------------

# SQL queries can be executed using dbGetQuery. Let's run a few examples from the SQL unit:

# Return an Entire Table:

dbGetQuery(studentcourse, 
           "SELECT * FROM student;")

# Return Rows Matching Conditions:

dbGetQuery(studentcourse, 
           "SELECT studentid, name, year FROM student 
           WHERE major = 'COMM' AND year > 2;")

# Using IN:

dbGetQuery(studentcourse, 
           "SELECT courseid, topic FROM course 
            WHERE topic IN ('Global', 'RDBMS');")

# Group By and Having:

dbGetQuery(studentcourse, 
           "SELECT studentid, COUNT(courseid) FROM takes 
            WHERE courseid != 3100 
            GROUP BY studentid HAVING COUNT(courseid) > 2;")

# Left Outer Join Example:

dbGetQuery(studentcourse, 
           "SELECT * FROM students LEFT JOIN studentemp ON studentid = studentident;")

# Joining Multiple Tables at Once:

dbGetQuery(studentcourse, 
           "SELECT * FROM student NATURAL JOIN major NATURAL JOIN takes NATURAL JOIN course;")

# ------------------------
# Using Query Results in R
# ------------------------

# The commands above simply run the queries and print the results to the R console. We could also store the results as R objects and then work with them directly in R via assignment. For example, consider the NATURAL JOIN example involving four tables:

takes <- dbGetQuery(studentcourse, 
           "SELECT * FROM takes;")

# We can now work with student within R; for example, using piping and dplyr:

takes %>% 
  filter(courseid != 3100) %>% 
  group_by(studentid) %>% 
  summarise(countCourseID = length(courseid)) %>% # see also ?n
  filter(countCourseID > 2)

# This series of operations using dplyr is identical to the SQL query shown earlier (i.e., Group By and Having):

dbGetQuery(studentcourse, 
           "SELECT studentid, COUNT(courseid) FROM takes 
           WHERE courseid != 3100 
           GROUP BY studentid HAVING COUNT(courseid) > 2;")

# Similarly, let's recreate an example involving the SQL keyword IN using R (using R's %in% operator):

course <- dbGetQuery(studentcourse, 
                    "SELECT * FROM course;")

course %>% 
  filter(topic %in% c("Global", "RDBMS")) %>% 
  select(courseid, topic)

# Again, the result is identical to the SQL query (i.e., Using IN):

dbGetQuery(studentcourse, 
           "SELECT courseid, topic FROM course 
           WHERE topic IN ('Global', 'RDBMS');")

# Now let's consider another example involving joining tables. First let's do it in R by fetching each table first and then using dplyr:

students <- dbGetQuery(studentcourse, 
           "SELECT * FROM students;")

studentemp <- dbGetQuery(studentcourse, 
           "SELECT * FROM studentemp;")

students %>% 
  left_join(studentemp, by = c("studentid" = "studentident"))

# Note this is essentially the same result as doing it directly with SQL (except SQL returns both the studentid and studentident columns in the result):

dbGetQuery(studentcourse, 
           "SELECT * FROM students LEFT JOIN studentemp ON studentid = studentident;")

# It's ultimately up to you to decide if operations should be run in SQL or in R. Regardless of how you do it however, you can use the results within R to extend the possibilities:

fourTableJoin <- dbGetQuery(studentcourse, 
           "SELECT * FROM student NATURAL JOIN major NATURAL JOIN takes NATURAL JOIN course;")

fourTableJoin$studentid <- factor(fourTableJoin$studentid)
unique(fourTableJoin$topic)

ggplot(filter(fourTableJoin, !( topic %in% c("RDBMS", "Stats") )), 
       aes(x = studentid, fill = studentid)) + 
  geom_bar() + 
  theme_bw(base_size = 18) + 
  theme(legend.position = "none")

# ------------------
# Disconnect from DB
# ------------------

dbDisconnect(studentcourse)
