@echo off;
cd public_html
set CLASSPATH=wricproxy.jar

REM start the proxy server using jview
REM (jview comes with internet explorer)
start /m jview com.aplpi.wapreview.wricproxy.wricproxy

REM if jview didn't work, start the proxy
REM using java ... this will fail and exit
REM if jview started
start /m java com.aplpi.wapreview.wricproxy.wricproxy

REM raise http://127.0.0.1:5000/index.html file in the web browser.
REM To do this, raise redirect.html in the web browser.
cd ..
rundll32.exe url.dll,FileProtocolHandler redirect.html