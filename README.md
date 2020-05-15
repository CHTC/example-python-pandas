Python Pandas Case Study Example
======================

In this case study, we are going to use [Pandas](https://pandas.pydata.org/) package to read two dataset from CSV and merge them togother. For general example about how to use HTCondor and our submit server, plase visit: [http://chtc.cs.wisc.edu/helloworld.shtml](http://chtc.cs.wisc.edu/helloworld.shtml)

**_Note: You must be logged into an HTCondor submit machine for the following example to work_**

A. Submit an Interactive Job
----------------------------

Create a folder and download the python code and dataset from our server
```
[alice@submit]$ mkdir python_example
[alice@submit]$ cd  python_example
[alice@submit]$ wget 
[alice@submit]$ wget 
[alice@submit]$ wget 
[alice@build]$ ls -lh
-rw-rw-r-- 1 alice alice   59 Nov 27 12:59 fruit.csv
-rw-rw-r-- 1 alice alice  293 Nov 27 12:59 python_example.py
-rw-rw-r-- 1 alice alice   59 Nov 27 12:59 vege.csv
```

The following is the code for the _python\_example.py_, which will read two arguments and combine the dataset together

```python
import pandas as pd
import sys

# Read the first argument 
fruit = pd.read_csv(sys.argv[1])
# Read the second argument
vege = pd.read_csv(sys.argv[2])

# Merge to a new dataset
total = pd.merge(fruit, vege, on='name')

# Save to the csv file
total.to_csv('result.csv', index = None)
```

The following is the dataset for _fruit.csv_

| Name | Apple | Orange |
|:---:|:---:|:---:|
| June  | 3 | 0 |
| Robert| 2 | 3 | 
| Lily  | 0 | 7 | 
| David | 1 | 2 |




The following is the dataset for _vege.csv_


| Name | Tomato | Onion |
|:---:|:---:|:---:|
| June  | 4 | 2 |
| Robert| 7 | 6 | 
| Lily  | 9 | 3 | 
| David | 10 | 18 |


Create a bulld.sub by using any text editor that you lile. We use [_vim_](https://www.vim.org/) in the following example.

```
[alice@submit]$ vim build.sub
```

Create the following special submit file on the submit server, we use python _3.8_ for the case study

```
# Python build file

universe = vanilla
log = interactive.log

# Choose a version of Python from the table above
transfer_input_files = http://proxy.chtc.wisc.edu/SQUID/chtc/python38.tar.gz

+IsBuildJob = true
requirements = (OpSysMajorVer =?= 7) && ( IsBuildSlot == true )
request_cpus = 1
request_memory = 2GB
request_disk = 2GB

queue
```
Once this submit file is created, you will start the interactive job by running the following command:

```
[alice@submit]$ condor_submit -i build.sub
```
B. Install the Packages
-----------------------

Once the interactive build job starts, you should see the Python that you specified inside the working directory:

```
[alice@build]$ ls -lh
-rw-r--r-- 1 alice alice  78M Mar 26 12:24 python38.tar.gz
drwx------ 2 alice alice 4.0K Mar 26 12:24 tmp
drwx------ 3 alice alice 4.0K Mar 26 12:24 var
```

We'll now unzip the copy of Python and set the `PATH` variable to reference that version of Python:

```
[alice@build]$ tar -xzf python38.tar.gz
[alice@build]$ export PATH=$PWD/python/bin:$PATH
```

To make sure that your setup worked, try running:

```
[alice@build]$ python3 --version
Python 3.8
```

First, create, a directory to put your packages into:

```
[alice@build]$ mkdir packages
```

Run the following command to install _Pandas_ package

```
[alice@build]$ python3 -m pip install --target=$PWD/packages pandas
```

C. Finish Up the Interactive Job
--------------------------------

Compress the package into a tarball file

Run the following command to compress the package into a tarball file:

```
[alice@build]$ tar -czf packages.tar.gz packages/
```

We now have our packages bundled and ready for CHTC! You can now exit the interactive job and the tar.gz file with your Python packages will return to the submit server with you (this sometimes takes a few extra seconds after exiting).

```
[alice@build]$ exit 
```

D. Creating a Shell Script for HTCondor submit
----------------------------------------------

Open your text editor again to create a shell script for your job named _run\_python.sh_

```
[alice@build]$ vim run_python.sh
```

```shell
#!/bin/bash

# untar your Python installation. Make sure you are using the right version!
tar -xzf python38.tar.gz
# (optional) if you have a set of packages (created in Part 1), untar them also
tar -xzf packages.tar.gz

# make sure the script will use your Python installation, 
# and the working directory as its home location
export PATH=$PWD/python/bin:$PATH
export PYTHONPATH=$PWD/packages

# run your script, since we will use fruit.csv and vege.csv as input file,
# we put them into the argument
python3 python_example.py fruit.csv vege.csv
```

Once your script does what you would like, give it executable permissions by running:

```
[alice@submit] chmod +x run_python.sh
```

E. Creating a Submit Script for HTCondor submit
-----------------------------------------------

**1.** Open your text editor to create a submit script for your job named _run\_python.sub_

```
[alice@build]$ vim run_python.sub
```

**2.** Put the following code into the _run\_python.sub_

```
# run_python.sub
# Python demo example
#
# Specify the HTCondor Universe (vanilla is the default and is used
#  for almost all jobs), the desired name of the HTCondor log file,
#  and the desired name of the standard error file.  
#  Wherever you see $(Cluster), HTCondor will insert the queue number
#  assigned to this set of jobs at the time of submission.
universe = vanilla
log = python_example_$(Cluster).log
error = python_example_$(Cluster)_$(Process).err
#
# Specify your executable (single binary or a script that runs several
#  commands), arguments, and a files for HTCondor to store standard
#  output (or "screen output").
#  $(Process) will be a integer number for each job, starting with "0"
#  and increasing for the relevant number of jobs.
executable = run_python.sh
output = python_example_$(Cluster)_$(Process).out
#
# Specify that HTCondor should transfer files to and from the
#  computer where each job runs. The last of these lines *would* be
#  used if there were any other files needed for the executable to run.
should_transfer_files = YES
when_to_transfer_output = ON_EXIT
transfer_input_files = http://proxy.chtc.wisc.edu/SQUID/chtc/python38.tar.gz, packages.tar.gz, python_example.py, fruit.csv, vege.csv
#
# Tell HTCondor what amount of compute resources
#  each job will need on the computer where it runs.
request_cpus = 1
request_memory = 1GB
request_disk = 1MB
#
# Tell HTCondor to run 1 instances of our job:
queue 1
```

**3.** Now, submit your job to the queue using condor\_submit:

```
[alice@submit]$ condor_submit run_python.sub
```

**4.** After running the job, you should get the ouput as the following

```
[alice@submit]$ ls -lh
-rw-rw-r-- 1 alice alice  356 Nov 27 12:28 build.sub
-rw-rw-r-- 1 alice alice   59 Nov 27 12:59 fruit.csv
-rw-r--r-- 1 alice alice 3.8K Nov 27 12:47 interactive.log
-rw-rw-r-- 1 alice alice  36M Nov 27 12:38 packages.tar.gz
-rw-r--r-- 1 alice alice    0 Nov 27 13:10 python_2551450_0.err
-rw-r--r-- 1 alice alice 2.0K Nov 27 13:10 python_2551450.log
-rw-rw-r-- 1 alice alice  293 Nov 27 12:59 python_example.py
-rw-r--r-- 1 alice alice    0 Nov 27 13:10 python_output_2551450_0.out
-rw-r--r-- 1 alice alice   90 Nov 27 13:10 result.csv
-rwxrwxr-x 1 alice alice  458 Nov 27 13:02 run_python.sh
-rw-rw-r-- 1 alice alice 1.5K Nov 27 13:03 run_python.sub
-rw-rw-r-- 1 alice alice   59 Nov 27 12:59 vege.csv
```

Open the _result.csv_ and you can find the following table

| Name | Apple | Orange | Tomato | Onion |
|:---:|:---:|:---:| :---:|:---:|
| June  | 3 | 0 | 4 | 2 |
| Robert| 2 | 3 | 7 | 6 | 
| Lily  | 0 | 7 | 9 | 3 | 
| David | 1 | 2 | 10 | 18 |



