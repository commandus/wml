Attribute VB_Name = "AppManager"
' Passes the command line arguments to the first version of WAPreview.exe
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
'code based on:
'http://support.microsoft.com/support/kb/articles/Q176/0/58.ASP?LN=EN-US&SD=msdn&FR=1
Type COPYDATASTRUCT
              dwData As Long
              cbData As Long
              lpData As Long
      End Type

      Public Const GWL_WNDPROC = (-4)
      Public Const WM_COPYDATA = &H4A
      Global lpPrevWndProc As Long
      Global gHW As Long


      Private Declare Function FindWindow Lib "user32" Alias _
         "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName _
         As String) As Long

      Private Declare Function SendMessage Lib "user32" Alias _
         "SendMessageA" (ByVal hWnd As Long, ByVal wMsg As Long, ByVal _
         wParam As Long, lParam As Any) As Long

      'Copies a block of memory from one location to another.

      Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" _
         (hpvDest As Any, hpvSource As Any, ByVal cbCopy As Long)

      Declare Function CallWindowProc Lib "user32" Alias _
         "CallWindowProcA" (ByVal lpPrevWndFunc As Long, ByVal hWnd As _
         Long, ByVal Msg As Long, ByVal wParam As Long, ByVal lParam As _
         Long) As Long

      Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" _
         (ByVal hWnd As Long, ByVal nIndex As Long, ByVal dwNewLong As _
         Long) As Long
         

      Public Sub Hook()
          lpPrevWndProc = SetWindowLong(gHW, GWL_WNDPROC, _
          AddressOf WindowProc)
          Debug.Print lpPrevWndProc
      End Sub

      Public Sub Unhook()
          Dim temp As Long
          temp = SetWindowLong(gHW, GWL_WNDPROC, lpPrevWndProc)
      End Sub

      Function WindowProc(ByVal hw As Long, ByVal uMsg As Long, _
         ByVal wParam As Long, ByVal lParam As Long) As Long
          If uMsg = WM_COPYDATA Then
              Call mySub(lParam)
          End If
          WindowProc = CallWindowProc(lpPrevWndProc, hw, uMsg, wParam, _
             lParam)
      End Function

      Sub mySub(lParam As Long)
          Dim cds As COPYDATASTRUCT
          Dim buf(1 To 255) As Byte

          Call CopyMemory(cds, ByVal lParam, Len(cds))

          Select Case cds.dwData
           Case 1
              Debug.Print "got a 1"
           Case 2
              Debug.Print "got a 2"
           Case 3
              Call CopyMemory(buf(1), ByVal cds.lpData, cds.cbData)
              a$ = StrConv(buf, vbUnicode)
              a$ = Left$(a$, InStr(1, a$, Chr$(0)) - 1)
              'wrform.Print a$
              gotourl a$
          End Select
      End Sub
      Private Sub gotourl(myURL As String)
      'wrform.wapreview.Document
      'MsgBox ("going to:" + myURL)
      wrform.SetFocus
      wrform.wapreview.Navigate "javascript:setCard('" + myURL + "');"
      'MsgBox ("madeit!!!")
      End Sub
      ' Replace String in a String
      Public Function fixURL(ByVal url As String)
        If (((InStr(1, url, "http://", 1) <> 1) And (InStr(1, url, "http://", 1) <> 1))) Then
            url = "file://" + url
        End If
        fixURL = ReplaceStringinString(url, "\", "/")
      End Function
      
    Public Function ReplaceStringinString(ByVal sString As String, ByVal sReplaceThis As String, ByVal sReplaceWithThis As String) As String

    Dim sNew As String
    Dim sRest As String
    sRest = sString
    sNew = ""
    Do While InStr(sRest, sReplaceThis) <> 0
        sNew = sNew & Left$(sRest, InStr(sRest, sReplaceThis) - 1) & sReplaceWithThis
        sRest = Right$(sRest, Len(sRest) - InStr(sRest, sReplaceThis) - Len(sReplaceThis) + 1)
    Loop
    ReplaceStringinString = Trim$(sNew & sRest)
    End Function

      Public Sub Main()
      ChDir App.Path 'set the current working directory
      If (App.PrevInstance) Then
        'this is the second instance... show the URL
        'in the first window...
          Dim cds As COPYDATASTRUCT
          Dim ThWnd As Long
          Dim buf(1 To 255) As Byte
          If (Len(Command$) <= 0) Then
             MsgBox ("Call this program with a WAP URL")
             End
          End If
          ' Get the hWnd of the target application
          ThWnd = FindWindow(vbNullString, "aplpi wap browser demo")
          'a$ = "It Works!"
          'MsgBox (Command$)
          Dim wapurl As String
          wapurl = fixURL(Command$)
          'wapurl = ReplaceStringinString(wapurl, " ", "\ ")
      ' Copy the string into a byte array, converting it to ASCII
          Call CopyMemory(buf(1), ByVal wapurl, Len(wapurl))
          cds.dwData = 3
          cds.cbData = Len(wapurl) + 1
          cds.lpData = VarPtr(buf(1))
          i = SendMessage(ThWnd, WM_COPYDATA, 0, cds)
       ' exit the current instance
        End
      Else
        'this is the first instance
        ProxyManager.launchProxy
        wrform.Show
        Dim none As Variant
        none = "no"
        wrform.wapreview.Navigate ("http://127.0.0.1:5000/wapreview_local.html")
      End If
      End Sub
      


