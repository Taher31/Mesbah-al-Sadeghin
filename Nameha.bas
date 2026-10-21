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
	Dim tm1 As Timer
	Private xui As XUI
End Sub

Sub Globals
	Private et1,et2 As ACEditText
	Private clv1 As CustomListView
	Dim cur As Cursor
	Dim tm1F As Int = 0
	Private pp As Panel
	Private l1 As Label
	Private num As Label
	Private B1,B2,B3,B4,frmark,FPP,FMM As Button
	Dim booksel As Int
End Sub

Sub Activity_Create(FirstTime As Boolean)
	myf.Loading(Main.s)
	Activity.LoadLayout("KH")
	B2.TextColor = 0xffc4a263
	B2.Enabled = False
	et1.Color = 0xff13372b'2B1673
	Activity_Resume
	
	cur = Main.s.ExecQuery("select val from prevTable where name = 'booknum'")
	cur.Position = 0
	booksel = cur.GetInt("val")
	cur.Close
	If booksel = 2 Then
		et1.Hint = "تنبیه الغافلین"
	End If
	cur = Main.s.ExecQuery("select * from table2 where tindex >= 246 and tindex <= 325")
	For i = 0 To cur.RowCount-1
		cur.Position = i
		Dim p1 As B4XView = xui.CreatePanel("")
		p1.Left = 0
		p1.Top = 0
		p1.Width = 100%x
		p1.Height = 14%y
		p1.Tag = 0
		clv1.InsertAt(i,p1,$"${cur.GetInt("tindex")}"$)
	Next
	tm1.Initialize("tm1",500)
End Sub
Sub FPP_Click
	If Main.menufontSize < 48 Then
		Main.menufontSize = Main.menufontSize + 3
	Else
		FPP.Visible = False
	End If
	If Main.menufontSize > 20 Then FMM.Visible = True
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
	Main.s.ExecNonQuery("update STable set Menufontsize=" & Main.Menufontsize)
End Sub
Sub fmm_Click
	If Main.menufontSize > 20 Then
		Main.menufontSize = Main.menufontSize - 3
	Else
		FMM.Visible = False
	End If
	If Main.menufontSize < 48 Then FPP.Visible = True
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
	Main.s.ExecNonQuery("update STable set Menufontsize=" & Main.Menufontsize)
End Sub
Sub CLV1_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 14
	For i = 0 To clv1.Size-1
		If FirstIndex >= 0 And i >= Max(0, FirstIndex - ExtraSize) And i <= Min(LastIndex + ExtraSize, clv1.Size - 1) Then
			If clv1.GetPanel(i).Tag = 0 Then
				Create_loading(i)
			End If
		Else
			If clv1.GetPanel(i).NumberOfViews > 0 Then
				clv1.GetPanel(i).RemoveAllViews
				clv1.GetPanel(i).Tag = 0
			End If
		End If
	Next
End Sub
Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Activity.Finish
		myf.SetAnimation("right_left1", "zoom_exit")
		Return True
	End If
	Return False
End Sub
Sub B1_Click
	Activity.Finish
	StartActivity(KHOTAB)
	myf.SetAnimation("right_left1", "right_left")
End Sub
'Sub B2_Click
'	Activity.Finish
'	StartActivity(Nameha)
'	myf.SetAnimation("left_right", "left_right1")
'End Sub
Sub B3_Click
	Activity.Finish
	StartActivity(hekam)
	myf.SetAnimation("left_right", "left_right1")
End Sub
Sub B4_Click
	Activity.Finish
	StartActivity(gharaeb)
	myf.SetAnimation("left_right", "left_right1")
End Sub
Sub Create_loading(i As Int)
	cur.Position = i
	Dim str As String = cur.GetString("fttitle")
	Dim idxxx As Int = cur.GetInt("tindex")-246
	
	Dim p1 As B4XView = xui.CreatePanel("")
	p1.Width = 100%x
	p1.Height = 100%y
	p1.Tag = 1
	p1.LoadLayout("fehrestitem")
	If idxxx >= 100 Then
		l1.Text = str.SubString(5)
	Else if idxxx >= 10 Then
		l1.Text = str.SubString(4)
	Else if idxxx >0 Then
		l1.Text = str.SubString(3)
	else if idxxx = 0 Then
		l1.Text = str
	End If
	
	If Main.nmode Then
		l1.TextColor = Colors.LightGray
	Else
		l1.TextColor = 0xFF13372b'1b1448
	End If
	l1.Tag = "l1"
	myf.setfrfont(l1,l1.Width)
	If l1.Height < 10%x Then l1.Height = 10%x
	pp.Height = l1.Height+2%x
	pp.Color = 0x22000000
	p1.Height = pp.Height
	If idxxx = 0 Then
		num.Text = ""
		num.Visible = False
	Else
		num.Text = idxxx
	End If 
	clv1.ReplaceAt(i,p1,p1.Height,$"${clv1.GetValue(i)}"$)
End Sub
Sub et1_TextChanged(old As String,new As String)
	tm1.Enabled = True
	clv1.Clear
	Dim sqlSt As String
	If new.Length > 0 Then
		Dim searchStr = new As String
		searchStr = searchStr.Replace("ی","ي")
		searchStr = searchStr.Replace("ى","ي")
		searchStr = searchStr.Replace("ك","ک")
		searchStr = searchStr.Replace("إ","ا")
		searchStr = searchStr.Replace("أ","ا")
		
		searchStr = searchStr.Replace("۱","1")
		searchStr = searchStr.Replace("۲","2")
		searchStr = searchStr.Replace("۳","3")
		searchStr = searchStr.Replace("۴","4")
		searchStr = searchStr.Replace("۵","5")
		searchStr = searchStr.Replace("۶","6")
		searchStr = searchStr.Replace("۷","7")
		searchStr = searchStr.Replace("۸","8")
		searchStr = searchStr.Replace("۹","9")
		searchStr = searchStr.Replace("۰","0")
		sqlSt = "SELECT * FROM table2 where ((fttitle1 LIKE '%"&searchStr&"%') and (tindex >= 246 and tindex <= 325))"
	Else
		sqlSt = "select * from table2 where tindex >= 246 and tindex <= 325"
	End If
	cur = Main.s.ExecQuery(sqlSt)
	For i = 0 To cur.RowCount-1
		cur.Position = i
		Dim p1 As B4XView = xui.CreatePanel("")
		p1.Left = 0
		p1.Top = 0
		p1.Width = 100%x
		p1.Height = 14%y
		p1.Tag = 0
		clv1.InsertAt(i,p1,$"${cur.GetInt("tindex")}"$)
	Next
End Sub
Sub clv1_ScrollChanged(Position As Int)
	If tm1.Enabled = False Then NoFocus
End Sub
Sub clv1_ReachEnd
	
End Sub
Sub NoFocus
	et2.RequestFocus
	Dim ime2 As IME
	ime2.Initialize("")
	ime2.HideKeyboard
End Sub
Sub clv1_ItemClick(Index As Int, Value As Object)
	If booksel = 2 Then
		Dim cur1 As Cursor
		cur1=Main.s.ExecQuery("select * from table2 where tindex=" & Value)
		If cur1.RowCount = 1 Then
			cur1.Position = 0
			onvanha.onvanSel = cur1.GetString("tfttitle")
			onvanha.idonvan = Value
			onvanha.search = False
			matnha.edameh = False
			tm1F = 1
			tm1.Enabled = True
		End If
	Else
		Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'tindex'")
		If cur1.RowCount > 0 Then
			Main.s.ExecNonQuery("update prevTable set val = " & Value)
		Else
			Main.s.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& Value&")")
		End If
		tm1F = 1
		tm1.Enabled = True
	End If
	NoFocus
End Sub
Sub frmark_Click
	StartActivity(Markha)
	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub tm1_Tick
	If tm1F = 1 Then
		Motoon.edameh = False
		If booksel = 2 Then
			StartActivity(matnha)
			myf.SetAnimation("left_right","zoom_exit")
		Else
			StartActivity(Motoon)
			myf.SetAnimation("left_right","zoom_exit")
		End If
	End If
	tm1.Enabled = False
	tm1F = 0
End Sub
Sub Activity_Resume
	Dim viewidx As Int = -1
	If clv1.Size > 0 Then
		If clv1.GetPanel(clv1.FirstVisibleIndex).NumberOfViews > 0 Then
			For i= 0 To clv1.GetPanel(clv1.FirstVisibleIndex).GetView(0).NumberOfViews - 1
				If clv1.GetPanel(clv1.FirstVisibleIndex).GetView(0).GetView(i).Tag = "l1" Then viewidx = i
			Next
		End If
	End If
	If Main.nmode = False Then
		Activity.Color = Main.backColor
		clv1.AsView.Color = 0xffF6D9AF
		If  viewidx >= 0 Then
			For i = 0 To clv1.Size-1
				If clv1.GetPanel(i).NumberOfViews > 0 Then clv1.GetPanel(i).GetView(0).GetView(viewidx).TextColor = 0xFF13372b'1b1448
			Next
		End If
	Else
		Activity.Color = Colors.DarkGray
		clv1.AsView.Color = Colors.DarkGray
		If  viewidx >= 0 Then
			For i = 0 To clv1.Size-1
				If clv1.GetPanel(i).NumberOfViews > 0 Then clv1.GetPanel(i).GetView(0).GetView(viewidx).TextColor = Colors.LightGray
			Next
		End If
	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub