## **Introduction**

This ReadMe file explains the two components of the project submission: the "run_analysis.R"
script file and the "CodeBook.md" file.

## **R Script file**

The "run_analysis.R" file contains the code for all portions of this project. It is made
up of five sections, each of which are explained in detail below but also extensively
commented in the script.

The packages "dplyr" and "tidyr" are used in this code, and loaded at the beginning of the
script.

#### **1. Merge the training and the test sets to create one data set**

This sections start with defining the various directories where the data exist. The code
assumes that no modification is made to the folder structure when the original zip file is
unzipped--meaning that there is a main folder "UCI HAR Dataset" which contain some of the
data files, and then there are two subfolders--"test" and "train", which contain the rest
of the data.

Next, it loads all the relevant files into variables for use in R. Important to note here
that the subfolders within the "test" and "train" subfolders, each of which bear the name
"Inertial Signals", are NOT used in this project, per David Hood's "David Project FAQ" post
(https://class.coursera.org/getdata-010/forum/thread?thread_id=49).

It then:
* attaches the variable names from "features.txt" to the "x.train" and "x.test" data
* attaches the numerical activity data (as opposed to the activity names) from the "y.train"
and "y.test" files
* renames that column as "activity"
* attaches the subject data and renames that column as "subject"
* and finally, combines the test and train data using the rbind() function into a new
dataframe named "complete"

I also took the opportunity here to remove all the original variables used above from memory
now that they were all combined and fitted together to make the one "complete" dataframe.
This was not a necessary step, but aside from freeing up some memory, I found it easier to
have a cleaner, more concise list of variables from which to proceed into the next steps.

#### **2. Extract only the measurements on the mean and standard deviation for each measurement**

This would have been an easy enough step to accomplish, but the presence of duplicate
column names necessitated some data cleaning before filtering the data set down to just
the measurements on the mean and standard deviation. Using the duplicated() function, I
identified the duplicate column names and examined them to ensure none of them were part of
my target filtered data set. If they had been (i.e., if there were duplicate column names
for columns related to the mean and standard deviation), I would have had a larger task of
determining which columns were the relevant ones or perhaps renaming some columns to include
them all in the analysis. But none of the duplicate column names were relevant to my final
analysis, so I filtered all of them out.

With this cleaner data set, I used the select() command from "dplyr" to choose only the
columns that contained "mean()" and "std()" (along with the subject and activity columns).
I read lots of posts in the discussion forums about whether to also include the meanFreq()
columns and/or the "angle...mean" columns (555:561), but without any other information, I
decided that those represented a different type of measurement than what I was looking for
and left them out. It is worth it to point out here that in a real world situation, if
it was determined that those columns should be left in, it would be a simple addition to
this one line of code to include those columns in the analysis.

#### **3. Use descriptive activity names to name the activities in the data set**

I took this to mean very simply to use the activity names provided in the "activity_labels.txt"
file instead of the numerical activity data used in the "y.train" and "y.test" files. Since
every row had an activity number associated with it, and each of those numbers corresponded
to one of the number/name mappings in the "activity_labels.txt", I didn't have to worry about
the various types of joins (e.g., inner, outer, left, right) and instead just used the
standard merge() function to map the names to the numbers.

I then removed the original numerical activity column (no reason to have that data represented
twice), renamed the name data as "activity", and then sorted the entire data set by subject
and activity. This last step was not required but I found it easier to get a feel for the
data when they were sorted in a logical way, instead of the arbitrary ordering that the
data were in due to the random split of the test vs train data.

#### **4. Appropriately label the data set with descriptive variable names**

This was the most subjective step of the project for me. I made a choice not to fundamentally
reword the column titles as I have no subject expertise and the naming conventions seemed
descriptive enough (i.e., t vs f, Acc vs Gyro). Even for column names that seemed erroneous
(e.g., BodyBody...), in a real world setting, I would rely on the subject matter experts to
guide the renaming of the columns. My goal here was simply to standardize the naming conventions
and modify the symbols so that the full set of analytical tools could be applied to the data
set (i.e., there are some R functions that do not work with hyphens).

Specifically, I performed the following modifications:
* replaced hyphens "-" with periods "."
* added ".mean" or ".std" to the end of the variable names
  - I preferred to keep the XYZ variable immediately following the variable name rather 
    than have it split up with the 'mean' or 'std' term
  - Identifying those columns later on is easier if they all end in 'mean' or 'std'
* removed original "mean()" or "std()" from variable names

To finish off this step, I moved the activity column from last to second, so that it would
be easier to see the subject/activity combinations as I finished the analysis

#### **5. From the data set in step 4, creates a second, independent tidy data set with**
#### **the average of each variable for each activity and each subject**

This was another subjective step, as mentioned in the "David Project FAQ" post above, as
"tidy data" can mean different things, especially from a wide vs long persepctive. Before
reading Hadley Wickham's "tidy data" treatise, I was always a "wide format" person, mostly
because that is how Excel prefers data for graphing. But since reading Wickham's perspective,
I've completely converted to the "long format", and chose to tidy this data set in as pure
a long form as possible, so I opted to create a new dataframe with just four columns--subject,
activity, variable, and value (which was the average of each variable for each activity and
subject). This results in a dataframe with dimensions of 11880 x 4, which I find much more 
manageable than the 180 x 68 dataframe that many people seemed to target, per the discussion
forums. The difference between 180 and 11880 rows is trivial, in my opinion, as the approach
to analysis doesn't change regardless of the number of rows. But having any more than 7-10
columns always seems to make grappling with the data a bit more challenging. There are
obviously times when it's unavoidable, but in this case, I like the simplicity that
converting all the measurement column names into one variable column provided.

To calculate the value column, I grouped the data by subject, activity, and variable, and
then used the summarize() function to get the mean.

To finish, I included the code to write the output of this tidy data set to a text file.

## **Codebook**

The "CodeBook.md" file provides information on the source of the data and its description.
In full transparency, the description of the data comes directly for the study website and
its related files. I did not feel that I had anything of value to add in the description of
the data.

At the end of the Codebook file, I summarized the five steps that I've detailed in this
ReadMe file.