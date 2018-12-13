Attribute VB_Name = "ProxyManager"
' Handles launching and shutting down the wricproxy Server
' 
' Copyright (C) 2000 Robert Fuller, Applepie Solutions Ltd  
'               <Robert.Fuller@applepiesolutions.com>
'
' This program is free software; you can redistribute it and/or modify
' it under the terms of the GNU General Public License as published by
' the Free Software Foundation; either version 2 of the License, or
' (at your option) any later version.
'
' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU General Public License for more details.
'
' You should have received a copy of the GNU General Public License
' along with this program; if not, write to the Free Software
' Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
'
Option Explicit

      Private Type PROCESS_INFORMATION
         hProcess As Long
         hThread As Long
         dwProcessId As Long
         dwThreadId As Long
      End Type

      Private Type STARTUPINFO
         cb As Long
         lpReserved As String
         lpDesktop As String
         lpTitle As String
         dwX As Long
         dwY As Long
         dwXSize As Long
         dwYSize As Long
         dwXCountChars As Long
         dwYCountChars As Long
         dwFillAttribute As Long
         dwFlags As Long
         wShowWindow As Integer
         cbReserved2 As Integer
         lpReserved2 As Long
         hStdInput As Long
         hStdOutput As Long
         hStdError As Long
      End Type

      Private Declare Function CreateProcess Lib "kernel32" _
         Alias "CreateProcessA" _
         (ByVal lpApplicationName As String, _
         ByVal lpCommandLine As String, _
         lpProcessAttributes As Any, _
         lpThreadAttributes As Any, _
         ByVal bInheritHandles As Long, _
         ByVal dwCreationFlags As Long, _
         lpEnvironment As Any, _
         ByVal lpCurrentDriectory As String, _
         lpStartupInfo As STARTUPINFO, _
         lpProcessInformation As PROCESS_INFORMATION) As Long

      Private Declare Function OpenProcess Lib "kernel32.dll" _
         (ByVal dwAccess As Long, _
         ByVal fInherit As Integer, _
         ByVal hObject As Long) As Long

      Private Declare Function TerminateProcess Lib "kernel32" _
         (ByVal hProcess As Long, _
         ByVal uExitCode As Long) As Long

      Private Declare Function CloseHandle Lib "kernel32" _
         (ByVal hObject As Long) As Long

      Private Declare Function CreateFile Lib "kernel32.dll" _
                Alias "CreateFileA" _
                (ByVal lpFileName As String, _
                ByVal dwDesiredAccess As Long, _
                ByVal dwShareMode As Long, _
                ByVal lpSecurityAttributes As Long, _
                ByVal dwCreationDisposition As Long, _
                ByVal dwFlagsAndAttributes As Long, _
                ByVal hTemplateFile As Long) As Long
    'Declare Function CloseHandle Lib "kernel32.dll" (ByVal hObject As Long) As Long
    
    Const GENERIC_WRITE = &H40000000
    Const FILE_SHARE_READ = &H1
    Const FILE_SHARE_WRITE = &H2
    Const OPEN_ALWAYS = 4
    Const FILE_ATTRIBUTE_ARCHIVE = &H20
 
      Const SYNCHRONIZE = 1048576
      Const NORMAL_PRIORITY_CLASS = &H20&
      Const STARTF_USESTDHANDLES = &H100&

      Dim pInfo As PROCESS_INFORMATION
      Dim hFile As Long
      
Public Sub launchProxy()
         Dim sInfo As STARTUPINFO
         Dim sNull As String
         Dim lSuccess As Long
         Dim flog As Long
         
    
         ' next two lines will hide the window
         sInfo.wShowWindow = 0
         sInfo.dwFlags = &H1
                
         sInfo.cb = Len(sInfo)

         lSuccess = CreateProcess(sNull, _
                                 "jview /cp:a wricproxy.jar com.aplpi.wapreview.wricproxy.wricproxy", _
                                 ByVal 0&, _
                                 ByVal 0&, _
                                 1&, _
                                 STARTF_USESTDHANDLES Or NORMAL_PRIORITY_CLASS, _
                                 ByVal 0&, _
                                 sNull, _
                                 sInfo, _
                                 pInfo)
                                 
    'how do we know if the proxy is running?
    'probably would have to look through process list.
    'lSuccess will return success if jview ran, even if
    'the proxy wasn't started.
         'MsgBox "proxy has been launched!"
 
End Sub
Public Sub terminateProxy()
         Dim lRetValue As Long
         
         If (hFile > 0) Then
           CloseHandle hFile
         End If
         
         lRetValue = TerminateProcess(pInfo.hProcess, 0&)
         lRetValue = CloseHandle(pInfo.hThread)
         lRetValue = CloseHandle(pInfo.hProcess)
         'MsgBox "proxy has terminated!"
End Sub

