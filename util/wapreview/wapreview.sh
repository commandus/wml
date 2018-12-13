#!/bin/sh
cd ${0}/../public_html
export CLASSPATH=${CLASSPATH}:wricproxy.jar
echo CLASSPATH=${CLASSPATH}
java com.aplpi.wapreview.wricproxy.wricproxy &
netscape http://127.0.0.1:5000/ &
exit 0