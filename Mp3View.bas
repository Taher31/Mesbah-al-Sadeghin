B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=12.2
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

Sub Process_Globals
	Dim s1 As SQL
	Dim pos As Long
End Sub

Sub Globals
	Private SimpleExoPlayerView1 As SimpleExoPlayerView
	Private player1 As SimpleExoPlayer
	Dim mp4Playing As Boolean
	Private FS As Label
	Private Panel1 As Panel
	Dim MatnStr As String
'	Private WebView1 As WebView
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Dim p As Phone
	If p.SdkVersion >= 28 Then
		Dim ctxt As JavaObject
		ctxt.InitializeContext
		ctxt.RunMethodJO("getWindow", Null).RunMethodJO("getAttributes", Null).SetField("layoutInDisplayCutoutMode", 1)
	End If
	GetRealSize
	Activity_WindowFocusChanged(True)
	Dim lv As LayoutValues = GetRealSize
	Dim jo As JavaObject = Activity
	jo.RunMethod("setBottom", Array(lv.Height))
	jo.RunMethod("setRight", Array(lv.Width))
	Activity.Height = lv.Height
	Activity.Width = lv.Width
	Activity.LoadLayout("mp4FS")
'	WebView1.LoadHtml($"${ASSAR.fileHttpPath}"$)
	
	player1.Initialize("player")
	SimpleExoPlayerView1.Visible = True
	onvanha.idonvan = File.ReadString(File.DirInternalCache,"onvanha.txt")
	Dim sources As List
	Dim mp3fileName As String
	Dim DatabaseName As String = File.ReadString(File.DirInternalCache,"booksel.txt")
	sources.Initialize
	If DatabaseName = "301.book" Then mp3fileName = onvanha.idonvan & ".mp4"
	If DatabaseName = "303.book" Then mp3fileName = "m" & onvanha.idonvan & ".mp4"
	If DatabaseName = "302.book" Then mp3fileName = "k" & onvanha.idonvan & ".mp4"
	sources.Add(player1.CreateFileSource(File.DirRootExternal & "/Sadeghin/" & "/mp4/",mp3fileName))
	player1.Prepare(player1.CreateListSource(sources))
	SimpleExoPlayerView1.Player = player1
	player1.Position = pos
	player1.Play
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then
		FS_Click
	End If
End Sub


Private Sub FS_Click
	ASSAR.pos = player1.Position
	ASSAR.changepos = True
	player1.Pause
	player1.Release
	ASSAR.pageSel = 4
	Activity.Finish
	myf.SetAnimation("right_left1","right_left")
	StartActivity(ASSAR)
End Sub

Sub GetRealSize As LayoutValues
	Dim lv As LayoutValues
	Dim ctxt As JavaObject
	ctxt.InitializeContext
	Dim WindowManager As JavaObject = ctxt.RunMethodJO("getSystemService", Array("window"))
	Dim display As JavaObject = WindowManager.RunMethod("getDefaultDisplay", Null)
	Dim point As JavaObject
	point.InitializeNewInstance("android.graphics.Point", Null)
	display.RunMethod("getRealSize", Array(point))
	lv.Width = point.GetField("x")
	lv.Height = point.GetField("y")
	
	Dim r As Rect
	r.Initialize(0,0,0,0)
	Dim WindowVisibleDisplayFrame As JavaObject = ctxt.RunMethodJO("getWindow", Null)
	WindowVisibleDisplayFrame = WindowVisibleDisplayFrame.RunMethodJO("getDecorView", Null)
	WindowVisibleDisplayFrame = WindowVisibleDisplayFrame.RunMethodJO("getWindowVisibleDisplayFrame",Array(r))

	If GetDeviceLayoutValues.Width > GetDeviceLayoutValues.Height Then
		lv.Width = lv.Width
	Else
		lv.Height = lv.Height
		
	End If
	'log(lv.Height)
	lv.Scale = 100dip / 100
	Return lv
End Sub

Sub Activity_WindowFocusChanged(HasFocus As Boolean)
	'log(HasFocus)
	If HasFocus Then
		Try
			Dim jo As JavaObject = Activity
'			Sleep(300)
			jo.RunMethod("setSystemUiVisibility", Array As Object(5894)) '3846 - non-sticky
		Catch
			'log("error")
			''log(LastException) 'This can cause another error
		End Try 'ignore
		
	End If
End Sub

Private Sub clv1_ScrollChanged (Offset As Int)
	
End Sub