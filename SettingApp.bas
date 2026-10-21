B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: True
	#IncludeTitle: False
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Dim frParent As Boolean
End Sub

Sub Globals
	Private BackColor As Label
	Private fontSize As SeekBar
	Private Label1,Label2 As Label
	Private jst1,jst2,jst3 As RadioButton
	Dim changeSetting As Boolean
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("SettingL")
	Activity.Color = Main.backColor
	If frParent Then
		fontSize.Value = Main.Menufontsize-10
		myf.setfrfont(Label2,Label2.Width)
		Label1.Text = "تنظیم فونت فهرست:"
	Else
		fontSize.Value = Main.fontSize-10
		myf.setMatnfont(Label2,Label2.Width)
		Label1.Text = "تنظیم فونت متن:"
	End If
	Label2.Gravity = Gravity.CENTER_HORIZONTAL
	Select Main.JSTType
		Case 1:
			jst1.Checked = True
		Case 2: 
			jst2.Checked = True
		Case 3: 
			jst3.Checked = True
	End Select
	changeSetting = False
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)
	
End Sub
Sub fontSize_ValueChanged(Value As Int, UserChanged As Boolean)
	Label2.TextSize = Value+10
	If frParent Then
		If Main.Menufontsize = Value+10 Then changeSetting = True
		Main.Menufontsize = Value+10
	Else
		Main.fontSize = Value+10
	End If
	
End Sub
Sub BackColor_Click
	Dim cw As ColorWheelDialog
	cw.Initialize
	cw.ShowAsync(Me, "انتخاب رنگ زمینه")
	Wait For (cw) Color_Result(Success As Boolean)
	If Success Then
		Main.backColor = cw.ColorResult
		Activity.Color = Main.backColor
		changeSetting = True
	End If
End Sub
Sub jst1_CheckedChange(Checked As Boolean)
	If Checked Then
		Main.JSTType = 1
		changeSetting = True
	End If
End Sub
Sub jst2_CheckedChange(Checked As Boolean)
	If Checked Then
		Main.JSTType = 2
		changeSetting = True
	End If
End Sub
Sub jst3_CheckedChange(Checked As Boolean)
	If Checked Then
		Main.JSTType = 3
		changeSetting = True
	End If
End Sub
Sub Activity_KeyPress(KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_BACK And changeSetting Then
		Dim i As Int
		i = Msgbox2("آیا تغییرات ذخیره شود؟","ذخیره تنظیمات","ذخیره شود","","",Null)
		Select i
			Case DialogResponse.CANCEL
				Dim cur As Cursor
				cur=Main.s.ExecQuery("select * from STable")
				cur.Position = 0
				Main.BackColor = cur.GetInt("backColor")
				Main.txtFont = cur.GetString("txtFont")
				Main.menuFont = cur.GetString("menuFont")
				Main.lineSpace = cur.GetDouble("lineSpace")
				Main.Menufontsize = cur.GetInt("Menufontsize")
				Main.fontSize = cur.GetInt("fontSize")
				Main.JSTType = cur.GetInt("JSTType")
				cur.Close
				Activity.Finish
			Case DialogResponse.POSITIVE
				If frParent Then
					Main.s.ExecNonQuery("update STable set Menufontsize=" & Main.Menufontsize)
				Else
					Main.s.ExecNonQuery("update STable set fontSize=" & Main.fontSize)
				End If	
				Main.s.ExecNonQuery("update STable set backColor=" & Main.backColor)
				Main.s.ExecNonQuery("update STable set JSTType=" & Main.JSTType)
				Activity.Finish
		End Select
	End If
	Return False
End Sub