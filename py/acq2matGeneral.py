# -*- coding: utf-8 -*-
"""
Created on Tue Aug  7 15:17:29 2018

@author: matan
"""

#   Part 0:
#   After installing python, follow instructions in the following
#   Amazing bioread package: https://github.com/njvack/bioread
#   So, what this code really does is just to take the brilliant
#   command line prompt solution for single file that the bioread
#   package gives, and to generalize it to many files in one folder
#   This code recieves as inputs:
#   - Input folder Location 1 where the anaconda prompt lies
#   - Input folder location 2 (where all the .acq files are saved)
#   - Name suffix (what suffix is added to the new .dat files)
#   - Output folder location (where do you want the .dat files
#   at the end of the process)


#   Part 1: The function
def acq2matGeneral(inputLocation1,inputLocation2,outputLocation,suffix):
    #   Part 1.1: Importing packages
    import os
    import shutil

    #   Part 1.2: Going into working directories
    os.chdir(inputLocation2)
    fileList = (os.listdir())
    
    #   Part 1.3: The loop
    for file in fileList:
        newName = file +" "+ file[:-4]+suffix
        os.system("acq2mat " + newName)
        shutil.move(inputLocation2 + file[:-4]+suffix+'.mat', outputLocation + '/' + newName+'.mat')
    return


iLocation1 = 'D:/Anaconda/Scripts/activate.bat'
iLocation2 = 'C:/Users/matan/Python/Mara/physio/'
oLocation = 'C:/Users/matan/Python/Mara/'
s = '_matlabVersion'

acq2matGeneral(iLocation1,iLocation2,oLocation,s)