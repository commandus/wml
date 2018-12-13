package com.aplpi.wapreview.wricproxy;

import java.net.*; 
import java.io.*; 
import java.util.*; 
import java.awt.Frame;
import java.awt.Component;

/**
 * 
 * see http://wapreview.sourceforge.net
 *
 * Copyright (C) 2000 Robert Fuller, Applepie Solutions Ltd. 
 *                    <robert.fuller@applepiesolutions.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *

 * The wapreview image converting proxy server.
 * This application allows the wapreview WML browser
 * to run locally.
 *
 */
public class wricproxy{

   static private wricproxy wrp;
   static public Frame graphicsContext;

  public String test(){
    return "tested sucessfully!!\n";
  }
  
  public static void main(String[] args){
    int port = 5000;

    graphicsContext = new Frame("WAP image converter by applepiesolutions.com");
    graphicsContext.setSize(0,0);
    graphicsContext.setMenuBar(null);
    //graphicsContext.setState(Frame.ICONIFIED);
    graphicsContext.show();
    graphicsContext.toBack();
    wrp = new wricproxy();
    wrp.serve(port);
   }



  public void serve(int thePort){
    wrhttp.prepare();
    ServerSocket ss;
    //int thePort; 
    
    try { 
      //thePort = 80; 
      ss = new ServerSocket(thePort); 
      ss.getLocalPort(); 
      System.err.println("aplpi wricproxy server "+wrhttp.here+":"+thePort);
      System.err.println("--accepting connections from "+wrhttp.here+" only!");
      System.err.println("point your web browser to:");
      System.err.println("http://"+wrhttp.here+":"+thePort);
      while (true) { 
        wrhttp j = new wrhttp(ss.accept());
        j.start(); 
      } 
    } 
    catch (IOException e){ 
      System.err.println("Could not listen on port "+thePort+"!");
      System.exit(-1);
    } 
  } 
} 

class wrhttp extends Thread { 

  public static String server = "aplpi.com wricproxy";
  public static String here;
  public static final String localhost = "127.0.0.1";
  private Frame graphicsContext;
  public static void prepare(){
    try{
      here = java.net.InetAddress.getLocalHost().getHostAddress();
    }
    catch(java.net.UnknownHostException e){
      System.err.println("Couldn't get localhost...");
      here = null;
    }
  }

   Socket theConnection; 
   public wrhttp(Socket s) {
     String from = s.getInetAddress().getHostAddress();
     if(from.equals(localhost) || (here != null && from.equals(here))){
       theConnection = s;
     }else{
       // refuse other connections.
       System.err.println("refusing connection from "+from);
       try{
         s.close();
       }catch(java.io.IOException e){
         System.err.println(e.toString());
       }
       theConnection=null;
     }
   } 
  

   public void run() {
     if(theConnection==null){return;}
      String method; 
      String ct; 
      String version = "";
      String referer = null;
      String accept = "text/vnd.wap.wml, image/vnd.wap.wbmp, */*";
      String user_agent = "Nokia7110/1.0 (04.76) aplpi.com v0.5j";
      boolean urlIsFile = false;
      boolean convertWBMP = false;
      File theFile; 
      PrintStream os = null;
      try { 
         os =  new PrintStream(theConnection.getOutputStream());
         //DataInputStream is = new
         //DataInputStream(theConnection.getInputStream());
         InputStream inputstream= theConnection.getInputStream();
         InputStreamReader isr = new InputStreamReader(inputstream);
         BufferedReader is = new BufferedReader(isr);
 
         String get=null;
         for(int i=1; i<1000 && (get= is.readLine())==null;i++);
         if(get==null){
           System.err.println("no input...");
           os.close();
           theConnection.close();
           return;
         }
         System.err.println("get:"+get);
         StringTokenizer st = new StringTokenizer(get); 
         method = st.nextToken(); 
         if (!(method.equals("GET") ||  method.equals("POST"))){
           /* not equipped to handle other operations */
           return;
         }

         String file = st.nextToken();
         if(file.equals("/")){file="/index.html";}
         /* is the file a wbmp?  We'll convert it */
         if(file.toLowerCase().endsWith(".wbmp&.gif")){
           file = file.substring(0,file.length()-5);
           convertWBMP=true;
         }
         
         if (st.hasMoreTokens()) { 
           version = st.nextToken(); 
         } 
         
         // loop through the rest of the input headers 
         while ((get = is.readLine()) != null) { 
//System.err.println(get);
           if(get.toLowerCase().startsWith("referer: ")){
             referer=get.substring(9,get.length());
           }
           if (get.trim().equals("")) break; 
         }
         
         /*
          * If the URL begins with "/http:", then we will try to
          * retrieve the URL and return the contents.
          *
          * Otherwise, we will look for a file on the accesible
          * file system.
          * If the url starts with file:/(/), then remove this before
          * trying to open the file.  Try first to create a file from
          * the document root.  
          */
         URL url = null;
         if(file.toLowerCase().startsWith("/http:")){
           // simply proxy the file...
           //Creating a URL-object from the file
           url=new URL(file.substring(1,file.length()));
         }else{ // not a http url.  maybe a file?
           File f;
           if(file.toLowerCase().startsWith("/file://")){
             url = new URL(file.substring(1,file.length()));
             f =  new File(url.getFile());
             /* now redo the url to make it 'better' for windoze */
             url = new URL("file","",f.toString());

           }else { //?possibly a relative file reference???
             f = new File(URLDecode(file.substring(1,file.length())));
             //System.err.println("now ["+f.toString()+"]");
             String p = f.getAbsolutePath();
             boolean java2=false;
             if(java2){
               url = f.toURL(); // will work in java2 ...
             }else{
               p = p.replace(File.separatorChar, '/');
               while(!p.startsWith("//")) {
                 p = "/" + p;
               }
               if (!p.endsWith("/") && f.isDirectory()) {
                 p = p + "/";
               }
               url = new URL("file", "", p);
               f = new File(url.getFile());
               //System.err.println("1c. url is now["+f+"]");
             }
           }

           if(f.canRead()){
             urlIsFile = true;
             os.print("HTTP/1.0 200 OK\n"); 
             Date now = new Date(); 
             os.print("Date: " + now + "\n"); 
             os.print("Server: "+server+"\n"); 
             os.print("Content-length: " + f.length() + "\n"); 
             os.print("Connection: close\n");
             os.print("Content-type: " + guessContentType(f.toString())
                      + "\n\n"); 
           }else if(f.exists()){
             //System.err.println("file access not allowed:["+f+"]");
             //os.print("HTTP/1.0 403 Forbidden\n");
             os.print("HTTP/1.0 200 OK\n"); 
             Date now = new Date(); 
             os.print("Date: " + now + "\n"); 
             os.print("Server: "+server+"\n"); 
             os.print("Connection: close\n");
             os.print("Content-type: "+ guessContentType(".wml") 
                      + "\n\n"); 
             os.println("<wml><card>><title>Error!</title><p>Forbidden!</p></card></wml>"); 
             os.close();
             theConnection.close();
             return;
           }else{
             //System.err.println("file does not exist:["+f+"]");
             //os.print("HTTP/1.0 404 File Not Found\n");
             os.print("HTTP/1.0 200 OK\n"); 
             Date now = new Date(); 
             os.print("Date: " + now + "\n"); 
             os.print("Connection: close\n");
             os.print("Server: "+server+"\n"); 
             os.print("Content-type: "+ guessContentType(".wml") 
                      + "\n\n"); 
             os.println("<wml><card><title>Error!</title><p>File not found!</p></card></wml>"); 
             os.close();
             theConnection.close();               
             return;
           }
         }
         
         //System.err.println("2.url is "+url.toString());
         URLConnection connection = url.openConnection();
         if(connection!= null){
           connection.setRequestProperty("Accept", accept);
           connection.setRequestProperty("User-Agent", user_agent);
           if(referer != null){
             connection.setRequestProperty("Referer",referer); 
           }
           
           if(method.equals("POST")){
             /* faithfully post what has been posted */
             connection.setDoOutput(true);
             OutputStream cs = 
               connection.getOutputStream();
             while (is.ready()) {
               cs.write(is.read());
             }
             cs.close();
           }

           connection.connect();
           /* If the url is retrieved from another server,
              show the headers now... if it is a file, then
              we've already done so.
           */
           if(!urlIsFile){
             os.print("HTTP/1.0 200 OK\n"); 
             os.print("Connection: close\n");
             //boolean headers = false;
             boolean headers = true;
             for(int i=1;true;i++){
               String key = connection.getHeaderFieldKey(i);
               if(key == null) break;
               headers = true;
               String value = connection.getHeaderField(i);
               os.println(key+": "+value);
             }
             if(headers)os.print("\n");
           }
           
           String txtLine;
           //Setting up a BufferedReader
           InputStream in = connection.getInputStream();
           
           if(convertWBMP){
             /* convert the image */
             WBMPimg wbmp = new WBMPimg();
             wbmp.wbmp2gif(wricproxy.graphicsContext,in,os);
             os.close();
             theConnection.close();
             return;
           }else{
             /* send the file */
             int r;
             while((r=in.read())>=0){
               os.write(r);
             }
             os.close();
             //in.close();
           }
         }else{
           // no connection
           //System.err.println("no connection...");
         }
         os.close();
         //theConnection.close();         
         return;
      }
      catch (IOException e) {
        System.err.println(e);
        try{
          os.print("HTTP/1.0 200 OK\n"); 
          Date now = new Date(); 
          os.print("Date: " + now + "\n"); 
          os.print("Connection: close\n");
          os.print("Server: "+server+"\n"); 
          os.print("Content-type: "+ guessContentType(".wml") 
                   + "\n\n"); 
          os.println("<wml><card><title>Error!</title><p>"+e.toString()+"</p></card></wml>"); 
          os.close();
          theConnection.close(); 
        }catch (Exception xe) {
          // do nothing...
        } 
      }  
   }
  
  public String guessContentType(String fname) {
/* these should really be in a properties file... move them there. */
    String name = fname.toLowerCase();
    if (name.endsWith(".wml")) return "text/vnd.wap.wml";
    if (name.endsWith(".wmls")) return "text/vnd.wap.wmlscript";
    if (name.endsWith(".wmlc")) return "application/vnd.wap.wmlc";
    if (name.endsWith(".wmlsc")) return "application/vnd.wap.wmlscriptc";
    if (name.endsWith(".wbmp")) return "image/vnd.wap.wbmp";
    if (name.endsWith(".html"))  return "text/html";
    if (name.endsWith(".htm")) return "text/html"; 
    if (name.endsWith(".txt")) return "text/plain";
    if (name.endsWith(".htm")) return "text/html"; 
    if (name.endsWith(".gif")) return "image/gif"; 
    if (name.endsWith(".class")) return "application/octet-stream"; 
    if (name.endsWith(".jar")) return "application/octet-stream"; 
    if (name.endsWith(".jpg")) return "image/jpeg";
    if (name.endsWith(".jpeg")) return "image/jpeg"; 
    if (name.endsWith(".js")) return "application/x-javascript";
    if (name.endsWith(".doc")) return "application/msword";
    return "text/plain"; 
  } 



/**
 * This method decodes the given urlencoded string.
 * 
 * <p>This method is taken from Codec.java in HTTPClient 2.0 distributed
 * under LGPL by Ronald Tschalaer.
 *
 * @param  str the url-encoded string
 * @return the decoded string
 * @exception IllegalArgumentException If a '%' is not followed by a valid
 *                           2-digit hex number.
 */
/** this method would not be required if java 1.2 classes were available */
  public final static String URLDecode(String str)
  {
    if (str == null)  return  null;
    
    char[] res  = new char[str.length()];
    int    didx = 0;
    
    for (int sidx=0; sidx<str.length(); sidx++)
    {
      char ch = str.charAt(sidx);
 	    if (ch == '+')
        res[didx++] = ' ';
 	    else if (ch == '%')
 	    {
        try
        {
          res[didx++] = (char)
            Integer.parseInt(str.substring(sidx+1,sidx+3), 16);
          sidx += 2;
        }
        catch (NumberFormatException e)
        {
 		    throw new IllegalArgumentException(str.substring(sidx,sidx+3) +
                                           " is an invalid code");
        }
      }
 	    else
        res[didx++] = ch;
  	}
    
   	return String.valueOf(res, 0, didx);;
  }
}
