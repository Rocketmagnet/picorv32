import sys
import os
import shutil

if len(sys.argv) != 2:
    print("Please specify a name to create a new picosoc")
    print("copy_template.py new_name")
    quit()


print("Creating new picosoc: "+ sys.argv[1])

if os.path.isdir(sys.argv[1] + "/"):
    print(sys.argv[1] + "/ already exists")
else:
    print("creating " + sys.argv[1] + "/")
    os.mkdir(sys.argv[1] + "/")


def CopyWithReplaceString(fileName, oldString, newString):
        srcFileName = "template_icefun/" + fileName
        dstFileName = sys.argv[1]  + "/" + fileName.replace(oldString, newString)

        print("  " + srcFileName)
        print("  " + dstFileName)
	srcFile = open(srcFileName, "r")
	dstFile = open(dstFileName, "w")

	for line in srcFile:
	    newLine = line.replace(oldString, newString)
	    dstFile.write(newLine)

	srcFile.close()
	dstFile.close()


# --------------------
# Copy the other files
# --------------------

filesList = os.listdir('template_icefun/')
filesToReplaceString = ["Makefile", "icefun.v"]

for fileName in filesList:

    if fileName in filesToReplaceString:
        print("copy with string replace: " + fileName)
	CopyWithReplaceString(fileName, "icefun", sys.argv[1])
    else:
        print("copy : " + fileName)
        newName = fileName.replace("icefun", sys.argv[1])
        #print(fileName + " -> " + newName)
        src = 'template_icefun/' + fileName
        dst =  sys.argv[1] + "/" + newName
        print(src + " -> " + dst)
        shutil.copyfile(src, dst)




