supertab
==========

**supertab** aims to provide tab completion to satisfy all your insert completion 
needs (:help ins-completion). 

This version is a continuation of vimscript #182 by Gergely Kontra, who has 
asked me to take over support and maintenance.  This version contains many 
enhancements. 

**supertab** provides several features to enhance your insert completion 
experience: 

* You can set your favorite insert completion type (keyword, omni, etc.) as 
  supertab's default. 

* When using another completion type (ctrl-x ctrl-f), supertab will 
  temporarily make that the default allowing you to continue to use tab for 
  that completion. The duration is configurable to one of 'completion' 
  (retained until you exit the current completion mode), 'insert' (retained 
  until you leave insert mode), or 'session' (retained for the remainder of 
  your vim session). 

* **supertab** provides a 'context' completion type which examines the text 
  preceding the cursor to decide which type of completion should be used 
  (omni, user, file, or keyword).  You can also plug in your own functions 
  which will be used to determine which completion type to use according to 
  your new functionality. 

* The 'context' completion can also be used to set the default completion type 
  according to what the file supports, based on a discovery mechanism which 
  you specify. 

* For users not yet familiar with all the various insert completion types that 
  vim supports, supertab also provides a :SuperTabHelp command which opens a 
  temporary buffer listing all the available types and the ability to easily 
  switch to that type. 

After installing, see the supertab help for more information (:h supertab). 
 
install details
------------------

1. Download supertab.vba to any directory. 

2. Open the file in vim ($ vim supertab.vba). 

3. Source the file (:so %).

