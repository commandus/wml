VERSION 5.00
Object = "{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}#1.1#0"; "SHDOCVW.DLL"
Begin VB.Form wrform 
   Appearance      =   0  'Flat
   BackColor       =   &H80000005&
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "wrform"
   ClientHeight    =   7515
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   2850
   LinkTopic       =   "wrform"
   NegotiateMenus  =   0   'False
   ScaleHeight     =   7515
   ScaleWidth      =   2850
   StartUpPosition =   2  'CenterScreen
   Begin SHDocVwCtl.WebBrowser wapreview 
      Height          =   7530
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   2775
      ExtentX         =   4895
      ExtentY         =   13282
      ViewMode        =   0
      Offline         =   0
      Silent          =   0
      RegisterAsBrowser=   0
      RegisterAsDropTarget=   1
      AutoArrange     =   0   'False
      NoClientEdge    =   0   'False
      AlignLeft       =   0   'False
      ViewID          =   "{0057D0E0-3573-11CF-AE69-08002B2E1262}"
      Location        =   "res://C:\WINDOWS\SYSTEM\SHDOCLC.DLL/dnserror.htm#http:///"
   End
End
Attribute VB_Name = "wrform"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim loadedfirstarg As Integer
Private Sub Form_Load()
          loadedfirstarg = 0
          gHW = Me.hWnd
          Hook
          Me.Caption = "aplpi wap browser demo"
          Me.Show
          'Label1.Caption = Hex$(gHW)
      End Sub

      Private Sub Form_Unload(Cancel As Integer)
          ProxyManager.terminateProxy
          Unhook
      End Sub


Private Sub wapreview_DocumentComplete(ByVal pDisp As Object, url As Variant)
    If (pDisp Is wapreview.Object) Then
        'MsgBox "Document is finished loading." + Command$
        If (loadedfirstarg <= 0) Then
           loadedfirstarg = 1
            If (Len(Command$)) Then
             wapreview.Navigate ("javascript:setCard('" + fixURL(Command$) + "');")
            End If
        End If
    End If
End Sub


