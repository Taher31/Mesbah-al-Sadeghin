B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: False
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private Label_matnha As Label
	Private ScrollView1 As ScrollView
	Private pnl1 As Panel
	Dim JST As TeamEightJustifyBeta
	Dim AboutText As String
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("about")
	AboutText = File.GetText(File.DirAssets,"about.txt")
	pnl1.Color = Main.TopbackColor
	CallSubDelayed(Me,"QK_Click")
	If Main.nmode Then Activity.Color = Colors.DarkGray Else Activity.Color = Main.backColor
'	Activity.Color = Main.backColor
	ScrollView1.Panel.LoadLayout("l_matn_manabe")
	myf.Rangbandi(Label_matnha,AboutText,False,0,True)
	If Main.nmode Then Label_matnha.TextColor = Colors.White Else Label_matnha.TextColor = Colors.Black
	myf.setBMatnfont(Label_matnha,Label_matnha.Width)
	Label_matnha.Gravity = Bit.Or(Gravity.CENTER_HORIZONTAL,Gravity.CENTER_VERTICAL)
	myf.setLineSpace(Label_matnha,1.5)
	ScrollView1.Panel.Height=Label_matnha.Height

End Sub
Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Activity.Finish
		myf.SetAnimation("right_left1", "zoom_exit")
		Return True
	End If
	Return False
End Sub
Sub QK_Click
	JST.Initialize
	Label_matnha.Text=JST.JustifyByAddSpace(Label_matnha,Label_matnha.Text,False,0.65)
	If Label_matnha.Text = "" Then
		myf.Rangbandi(Label_matnha,AboutText,False,0,True)
	Else
		myf.Rangbandi(Label_matnha,Label_matnha.Text,False,0,True)
	End If
End Sub
Sub Activity_Resume
	AboutText = File.GetText(File.DirAssets,"about.txt")
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then 
		Activity.Finish
		myf.SetAnimation("right_left1", "zoom_exit")
	End If
End Sub
