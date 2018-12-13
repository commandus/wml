SET DP=c:\D7\bin\
%DP%brcc32 resource.rc
%DP%dcc32.exe apooedr.dpr
copy apooedr.dll ..
copy apooedr.dll ..\setup\data\
copy apooedr.dll "C:\Program Files\apoo editor\"
pause
