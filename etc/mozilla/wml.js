/* ***** BEGIN LICENSE BLOCK *****
 * Version: NPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Netscape Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/NPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is JavaScript for Wireless Markup Language emulation
 *
 * Contributor(s):
 *      Raoul Nakhmanson-Kulish <manko@zhurnal.ru>
 *      Matthew Wilson <matthew@mjwilson.demon.co.uk>
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or 
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the NPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the NPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */

/**
 * Extract a value from the document. Expects to find the value in either
 * an "input" or "select" element.
 * @param val Element ID to look for in document
 * @param mode "href" or "value". If mode is "href", URL-escapes the values,
 * and separates multiple select values by "name=". If mode is "value",
 * performs no URL-escaping, and separates * multiple select values by ",".
 * @param name Parameter name used in constructing multiple select values
 * when the mode is "href". Unused otherwise.
 */
function nsWMLgetValue(val,mode,name) {
    var valSrcElement = self.document.getElementById(val);
    if (valSrcElement) {
        switch(valSrcElement.nodeName.toLowerCase()) {
            case "input":
                if (mode == "href") {
                    return encodeURIComponent(valSrcElement.value);
                } else {
                    return valSrcElement.value;
                }
            case "select":
                var retVal = "";
                for (var i = 0; i < valSrcElement.options.length; i++) {
                    if (valSrcElement.options[i].selected) {
                        if (retVal!="") {
                            retVal+= (mode == "value") ? "," : ( "&" + name + "=" ) ;
                        }
                        if (mode == "href") {
                            retVal += encodeURIComponent(valSrcElement.options[i].value)
                        } else {
                            retVal += valSrcElement.options[i].value
                        }
                    }
                }
                return retVal;
        }
    } else return "";
}

// Convert a value according to the allowed escapings noesc, escape, and
// unesc.
function nsWMLescape (str, escaping) {
    if (escaping.toLowerCase() == "escape") {
        return str.escape();
    } else if (escaping.toLowerCase() == "unesc") {
        return str.unescape();
    } else {
        // noesc or mis-understood escaping
        return str;
    }
}

function nsWMLreplaceValues(str,mode) {
    mode = (mode) ? mode : "href";

    // Match either:
    // an optional = character (only used when mode=href)
    // $*( followed by a variable name optionally followed by an escaping option and then )
    // or
    // $ followed by repeated alpha-numeric characters
    var matcher = /(=?)(?:(\$)?\$\((.*?)(:noesc|:escape|:unesc)?\))|(\$)?\$([\w\d]+)/ig;
    while (matcher.exec (str)) {

        // Skip this match if it is has $$
        if (RegExp.$2 == "$" || RegExp.$5 == "$") { continue; } 

        // RegExp.$1 is the opening equals sign, if it is present
        var optionalEquals = RegExp.$1;
        // valName is the name of part of $(name) or $(name:noesc) or $name
        var valName     = (RegExp.$3 == "") ? RegExp.$6 : RegExp.$3;
        // valEscaping is the noesc part of $(name:noesc)
        var valEscaping = RegExp.$4;
        // If we are constructing a URL of the form
        // http://domain/path/file?parameter=$value, then extract the
        // parameter name ("parameter" in the example above), so that it can
        // be used to build up the URL if there is a multiple select element
        var valFormName = valName;
        if (mode == "href" && optionalEquals == "=") {
            var allowedNameChars = /(\w|\.|-|%[\dA-Fa-f]{2})+$/;
            var namesArray = allowedNameChars.exec(RegExp.leftContext);
            if (namesArray.length) valFormName = namesArray[0];
        };
        var valValue = (valName != "") ? nsWMLgetValue(valName,mode,valFormName) : "";
        valValue = nsWMLescape (valValue, valEscaping);

        str = str.replace (matcher, optionalEquals + valValue);
    }

    // Replace $$ with $
    matcher = /\$\$/;
    while (str.match (matcher)) {
        str = str.replace (matcher, "$");
    }

    return str;
}

function nsWMLcheckSelect(selectElement) {
    var inputIvalueElement = selectElement.nextSibling;
    while (inputIvalueElement && inputIvalueElement.nodeType != 1) {
        inputIvalueElement = inputIvalueElement.nextSibling
    }
    if (inputIvalueElement &&
                inputIvalueElement.nodeName.toLowerCase() == "input" &&
                inputIvalueElement.className == "ivalue") {
        var iValue = "";
        for (var i = 0; i < selectElement.options.length; i++) {
            if (selectElement.options[i].selected) {
                if (iValue != "") iValue += ",";
                iValue += i
            }
        }
        inputIvalueElement.value = iValue
    }
}

function nsWMLcheckLink(linkElement) {
    linkElement.href = nsWMLreplaceValues(linkElement.href, "href");
    return true
}

function nsWMLresetForms() {
    var inputsArray=document.getElementsByTagName("input")
    for (var i = 0; i < inputsArray.length; i++) {
        inputsArray[i].value = inputsArray[i].defaultValue
    }
    var selectsArray=document.getElementsByTagName("select")
    for (var i = 0; i < selectsArray.length; i++) with (selectsArray[i]) {
        for (var j = 0; j < options.length; j++) {
            options[j].selected = options[j].defaultSelected
        }
    }
}

function nsWMLcheckForm(formElement) {
    var actionIsPost = (formElement.action.toLowerCase() == "post");
    formElement.action = nsWMLreplaceValues(formElement.action, "href");
    try {
        with (formElement) for (var i = 0; i < elements.length; i++) {
            if (elements[i].type == "hidden" && elements[i].name) {
                elements[i].name  = nsWMLreplaceValues(elements[i].name,"value");
                elements[i].value = nsWMLreplaceValues(elements[i].getAttribute("origValue"),"value");
                if (!actionIsPost) {
                    if (formElement.action.indexOf("?") < 0) {
                        formElement.action += "?";
                    } else {
                        formElement.action += "&";
                    }
                    formElement.action += encodeURIComponent(elements[i].name) + "=" + encodeURIComponent(elements[i].value);
                }
            }
        }
    } catch (e) {
        window.alert ("Problem in wmlbrowser extension processing: " + e);
    }
    if (!actionIsPost) location.href=formElement.action;
    return actionIsPost;
}

// TODO multiple onevents, one timer per card
var onevents = {} ;
var wmlTimer;
function nsWMLStartTimer (timerValue) {
    // Timer values are specified in tenths of a second; parameters to
    // setTimeout are specified in ms
    wmlTimer = window.setTimeout (nsWMLTimerExpired, timerValue * 100);
}

function nsWMLTimerExpired () {
    if (onevents.go != undefined) {
        window.location = nsWMLreplaceValues (onevents.go, "href");
    }
}

function nsWMLRegisterTimer (action, target) {
    onevents[action] = target;
}