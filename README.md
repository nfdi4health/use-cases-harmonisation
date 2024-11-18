# use-cases-harmonisation

A repository for generating and storing essential documents to support data harmonization in use case studies.
test

## Folder Structure

### rmonize
This folder consists of 3 sub-folders (data_dictionary, data_proc_elem and data_schema) which are essential for the
correct harmonisation of the local data to a common structure. In the sub-folders, the actual Excel-Files are located
separately for each study and pilot project. You can open, change them if necessary and save them. You need to be
consistent with the structure of the file name using the prefixes (DD, DPE) in combination with study specific
names (_STUDY_PX / _STUDY_XX_PX; e.g. DD_EPICP_P1, DPE_KORA_S3_P2). There should only be one DataSchema for each pilot
project (Dataschema_P1 and Dataschema_P2). Currently, there is an additional, preliminary P2 version because of open
questions, duplicates etc. Note, that once you change the Dataschema for your projects (e.g. different name of a 
variable), you also need to change the respective DPE's in ALL studies. 

### create_mock_data 
This folder includes two R Scripts called mock_data_function.R and mock_data_initiation.R. The first Script contains
the function to create artificial data of a study based on the respective DataDictionary File. It is not necessary to
change anything in that file.
The second script contains two lines of code that are important to run the function. The first call (source) is only
sourcing the mock_data_function.R Script and doesn't need changing. The second codeline specifies for which study
mock data should be produced (e.g. studyname = "KORA_S1_P1"). Note that this will overwrite previously existing files.
Should an error occur while running this command, it can be due to different reasons (e.g. not existing DataDictionaries
that match the study name structure, duplicate variable names in the DataDictionary). Contact Sofia or Florian if
you need help with this.For some studies, more than one data file is necessary to imitate the local setting. We will think
of a solution for that.

### data
This folder contains the mock data created by the mock_data_initiation.R Script for the different studies. When deploying
the R Project folder to the studies, this is where they should copy their data files into with the specific names.

### scripts
This folder contains all the R Scripts to run Rmonize. The scripts should be study- and pilot-project specific ones. Only
very minor things need to changed. This includes data import file names from the rmonize and data objects as well as the
study name under "Step 2", "Step 5" & "Step 8". Potentially, there will be more Scripts that address the challenge in some studies
where multiple datasets are present. Sofia and Florian will address those challenges in R.

### output
This folder has two sub-folders: harmonised_dataset and rmonize_report. In the first of those sub-folders, the harmonised
dataset will be stored for further use in data analysis projects, i.e. DataSHIELD. The second folder contains the report
on how the harmonised variables were derived, including the transformation function call and some summary statistics. 
