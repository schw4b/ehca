EHCA - Eye and head coordination analyzer

EHCA is a MATLAB tool to analyze eye and head coordination. Parameters that
are detected are such as eye delay, head offset, eye/head amplitudes and
durations.

![Alt text](/screenshot.png)

The tool and a use case was published in a peer-reviewed scientific journal,
please cite my work if you use my software:

Schwab, S., Würmle, O., & Altorfer, A. (2012). Analysis of eye and head
coordination in a visual peripheral recognition task. Journal of Eye
Movement Research 5(2):3, 1-9.

To access the tool from within MATLAB, you have to add the ehca folder to the
MATLAB path (File... Set Path...). The tool is started by typing 'ehca' in the
MATLAB command window.

    >> ehca

From the GUI, a *.mat file can be loaded, which contains your data. Example
data is contained in ehca_demo.mat. The data file requires the following
specification:

There has to be a struct variable named 'segments', which contains the cells
'time', 'head', 'eye' and 'gaze', which contain the data for each trial. Here,
the data contains 11 trials (data segments).

    time: {1x11 cell}
    head: {1x11 cell}
     eye: {1x11 cell}
    gaze: {1x11 cell}

To see such a data structure, load the ehca_demo.mat from the command window:

    >> load ehca_demo.mat

Parameter detection can be conducted for each of the 11 trials, and the
trials can be visually inspected for proper parameter detection. Therefore,
press 'Parameter Detection' and browse through the trials by pressing the
next button (>).

To access the data, type 

    >> global ehdata

The ehdata is a global variable that contains the parameters detected
(ehdata.param). However, with some of the trials, parameter detection may fail.
Therefore, parameters can be accessed to replace wrong parameters with NaN
values before subject statistics are performed.

It is recommended to save the cleaned up values in a different variable, since
a new parameter detection will just overwrite ehdata.param.

    >> myparam = ehdata.param

At the end, don't forget to save your analyzed data ;)

    >> save subjectA.mat

Project home page: https://github.com/schw4b/ehca

Simon Schwab - May 2012
