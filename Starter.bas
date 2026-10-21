B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=9.85
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
'	Public phoneE As PhoneEvents
'	Dim conState As Boolean = False
'	Dim DmTimer As Timer
'	Dim fileHttpPath As String
'	Dim dowloading As Boolean
'	Dim tracker As RangeDownloadTracker
'	Private Downloader As RangeDownloader
'	Dim mp3fileName As String
'	Dim trStr As String
'	Dim trCount As Int
'	Dim downStatus As String
'	Dim onvan As String
End Sub

Sub Service_Create
'	'This is the program entry point.
'	'This is a good place to load resources that are not specific to a single activity.
'	phoneE.Initialize("phoneE")
'	DmTimer.Initialize("DmTimer",100)
'	Downloader.Initialize
'	DmTimer.Enabled = False
'	downStatus = ""
'	dowloading = False
End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	Return True
End Sub

Sub Service_Destroy

End Sub
'Private Sub phoneE_ConnectivityChanged (NetworkType As String, State As String, Intent As Intent)
'	If State = "CONNECTED" Then
'		conState = True
'	else if State = "DISCONNECTED" Then
'		conState = False
'	End If
'End Sub
'
'Private Sub DmTimer_Tick
'	If tracker.TotalLength = 0 And (trCount Mod 100 = 0) Then
'		trCount = trCount + 1
'		tracker = Downloader.CreateTracker
'		Downloader.Download(trStr, mp3fileName, fileHttpPath, tracker)
'	Else
'		trCount = trCount + 1
''		Track(tracker)
'		downStatus = "  در حال دانلود فایل  ......  " & $"$1.2{tracker.CurrentLength / 1024 / 1024}MB / $1.2{tracker.TotalLength / 1024 / 1024}MB  "$
'		If tracker.Completed Then
'			If tracker.TotalLength <= 0 Then
'				File.Delete(trStr,mp3fileName)
'				Log(tracker.TotalLength)
'				dowloading = False
'				DmTimer.Enabled = False
'				tracker.TotalLength = 0
'				tracker.Initialize
'				Downloader.Initialize
'			else If tracker.TotalLength = File.size(trStr,mp3fileName) Then
'				dowloading = False
'				DmTimer.Enabled = False
'			Else
'				File.Delete(trStr,mp3fileName)
'				downStatus = "  دانلود ناموفق -- در حال تلاش مجدد  "
''				dowloading = False
''				DmTimer.Enabled = False
'				tracker.TotalLength = 0
'			End If
'			
'		End If
'	End If
''	Dim cn As CustomNotification
''	cn.Initialize(3)
''	cn.AlertOnce = True
''	cn.Insistent = False
''	cn.Number = 1
''	cn.TickerText = onvan
''	cn.AutoCancel = False
''	cn.SetTextColor("title",Colors.Gray)
''	cn.SetProgress(1,100,0,False)
''	cn.Notify(1)
'
'End Sub
'Private Sub Track (tracker1 As RangeDownloadTracker)
''	downloadBar.Visible = True
'	Do While tracker1.Completed = False
'		Sleep(100)
'		downStatus = "در حال دانلود فایل  ......  " & $"$1.2{tracker1.CurrentLength / 1024 / 1024}MB / $1.2{tracker1.TotalLength / 1024 / 1024}MB"$
''		downloadBar.Progress = tracker1.CurrentLength / tracker1.TotalLength * 100
'	Loop
'End Sub