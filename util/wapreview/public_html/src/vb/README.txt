| WAPreview.exe is a simple VB application wrapped around wapreview.  It has
| a dependency on Microsoft Internet Explorer (which is not supplied as part
| of this application).
|
| Copyright (C) 2000 Robert Fuller, Applepie Solutions Ltd  
|               <Robert.Fuller@applepiesolutions.com>
|
| This program is free software; you can redistribute it and/or modify
| it under the terms of the GNU General Public License as published by
| the Free Software Foundation; either version 2 of the License, or
| (at your option) any later version.
|
| This program is distributed in the hope that it will be useful,
| but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
| GNU General Public License for more details.
|
| You should have received a copy of the GNU General Public License
| along with this program; if not, write to the Free Software
| Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

WAPreview.exe launches the wricproxy server accepting connections from the
local host, and opens an Internet Explorer wapreview browser.  The browser
retrieves the url or file specified as a command line argument.

It should be placed in the public_html directory and run from there.  You
can use it to do clever things like set up a file association with your
.wml files so that you can view them with wapreview.

The exe provided is built with VB5... it could be better done in VB6 if
you want to give it a go.

usage:
WAPreview.exe c:\tmp\foo.wml
or
WAPreview.exe http://www.applepiesolutions.com

Because it launches the proxy server, you might find a 'jview' application
hanging in your process listing somewhere... this will exit if WAPreview.exe
exits normally.

You need to have Internet Explorer (v5.x?) installed to use WAPreview.exe .
You can find Internet Explorer at http://www.microsoft.com






