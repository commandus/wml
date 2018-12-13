#!/bin/sh
cd public_html
java -classpath wricproxy.jar com.aplpi.wapreview.wricproxy.wricproxy &
#point your browser to:
netscape http://127.0.0.1:5000/
