#!/usr/local/bin/perl
###########################################################################
#
# This is a simple proxy server for use with the wapreview wml browser.
# see http://wapreview.sourceforge.net
#
# Copyright (C) 2000 Robert Fuller, Applepie Solutions Ltd. 
#                    <robert.fuller@applepiesolutions.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
###########################################################################
#

use LWP::UserAgent;
use strict;

# Create a user agent object
my $ua = new LWP::UserAgent;

my $url = $ENV{'PATH_INFO'};
my $method = $ENV{'REQUEST_METHOD'};
#Set the query string correctly
$url =~ s/(\?.*)?$/?$ENV{'QUERY_STRING'}/ 
    if $ENV{'QUERY_STRING'} ne '' ;
$url =~ s|^/||g;
# Create a request
my $req = new HTTP::Request  $method => "$url";

# Accept all types? wml types...
$req->header('Accept' => "text/vnd.wap.wml, image/vnd.wap.wbmp, */*");

# Pass on the Referer, Content-Length & set the User Agent
$req->header('Referer' => $ENV{'HTTP_REFERER'});
$req->header('Content-Length' => $ENV{'CONTENT_LENGTH'});
$ua->agent("Nokia7110/1.0 (04.76) aplpi.com v0.5");
# give the content type
$req->content_type($ENV{'CONTENT_TYPE'});

# NB: LWP::UserAgent $ua->redirect_ok will return a false value
# for POST methods, so we may actually want to subclass 
# LWP::UserAgent to get different behaviour... however we will
# leave it for the moment until we determine if this is a problem
# or not.

if ($method eq 'POST') {
  # Get the POSTed input
  my $input = join('',<STDIN>);
  # Give the request object the POSTed input
  $req->content($input);
}

# Retrieve the requested URL
my $response = $ua->request($req);
print $response->headers_as_string(), "\n";
if ($method ne 'HEAD'){
  my $content=join '', $response->content();
  
  #  If this is obviously a HTML page,
  #  replace it with a WML card containing an error message

  if($content=~/^\s*<html/i or $content=~/html>\s*$/i){
    $content="<wml><card><p align=\"center\"><b>Cannot Display!</b></p>The server returned html content which cannot be displayed by wap devices.<br/><br/>The url was:<br/>$url</card></wml>";
  }

  print $content;
}
exit 0;
