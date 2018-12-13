rem
rem Java wap gateway
rem
setlocal
set lib=C:\Program Files\Nokia\WAP_Toolkit\ServerSimulator\lib\
set path=%lib%\i386;%PATH%
set cp=.;.\wmlc;%lib%\wapsrv.jar;%lib%\activation.jar;%lib%\jsdk.jar;%lib%\mail.jar;%lib%\ssl0.jar%classpath%
java -classpath "%cp%" jwap.java %1
java jwap.java
endlocal
pause
