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
	Dim booklibAddress As String
	Dim booklst As List
	Dim booklstTitle As String
	Private xui As XUI
	Dim toastTm As Timer
	Dim searchLib As Boolean
	Dim SearchText As String
End Sub

Sub Globals
	Dim cur As Cursor
	Private lastread,montakhab,fehrest As Button
	Private Label1 As Label
	Dim EdT1 As ACEditText
	Private pnl1 As Panel
	Dim panelbook As Panel
	Private cvs As Canvas
	Private clv1 As CustomListView
	Private Label1cel As Label
	Private Button3,Button4,Button1  As Button
	Private LIV1 As LoadingIndicatorView
	Private ShPanel As Panel
	Dim LastToastTime As Int
	Dim searchstr As String
	Private pos1 As ACSeekBar
'	Dim SearchItem As Boolean = False
	Dim booksel As Int
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("l_matnha")
	
	'pnl1.Color = Main.TopbackColor
	cvs.Initialize(pnl1)
	myf.loadThemes(cvs,Main.nmode)
	EdT1.Initialize("EdT1")
	Activity.AddView(EdT1,25*100%x/642,30*100%x/642,100%x-50*100%x/642,20*100%x/642+10%x)
	EdT1_FocusChanged(False)
	EdT1.TextSize=20
	EdT1.Height = 20*100%x/642+10%x
	EdT1.Typeface = Label1.Typeface
	EdT1.Gravity = Bit.Or(Gravity.CENTER_HORIZONTAL,Gravity.TOP)
	EdT1.SingleLine = True
	EdT1.TextColor = 0xFFC4A263
	EdT1.HintColor = 0xFFC4A263
	myf.Loading(Main.s)
'	Activity.LoadLayout("markneshan")
	searchLib = False
	Button3.Visible = True
	Button4.Visible = False
	Button1.Visible = False
		pos1.Visible = False
'	If Main.nmode Then
'		Dim BMPA As NegativeImage
'		Button3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"search.png")))
'	Else
	Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
	Button4.SetBackgroundImage(LoadBitmap(File.DirAssets,"clear1.png"))
'	End If
	Label1.Visible = False
	panelbook.Initialize("")
	panelbook.Left =  0%x
	panelbook.Top = 0%y
	panelbook.Width = 100%x
	panelbook.Height = 20%x
	panelbook.LoadLayout("bookitem")
	panelbook.Visible = False
	toastTm.Initialize("toastTm",2000)
	

	
	booklst.Initialize
	Wait For (File.ListFilesAsync(booklibAddress)) Complete (Success As Boolean, Files As List)
	booklst.AddAll(Files)
	
	Dim i As Int = 0
	Do While i < booklst.Size
		Dim path As String = booklst.Get(i)
		If path.SubString(path.Length-5) = ".book" Then
			i = i+1
		Else
			booklst.RemoveAt(i)
		End If
	Loop
	booklst.Sort(True)
	File.WriteList(File.DirInternalCache,"booklst.txt",booklst)
	EdT1.Hint = booklstTitle


	
	clv1.Clear
	Dim tmpl As Label
	tmpl.Initialize("")
	tmpl.Text = "بسم الله"
	myf.setfrfont(tmpl,clv1.sv.Width-5%x-3%x)

	clv1.Base_Resize(clv1.AsView.Width,94%y-clv1.AsView.Top)'-23*100%x/642-(46*100%x/642+10%x+7*100%x/642))
	Dim split As Boolean
	For i = 1 To booklst.Size-1
		split = False
'		If i = 0 Then split = True
		If i > 0 Then
			Dim s1,s2 As String
			s1 = booklst.Get(i)
			s2 = booklst.Get(i-1)
			s1 = s1.SubString2(0,s1.Length-5)
			s2 = s2.SubString2(0,s2.Length-5)
			Dim a1 As Int = s1
			Dim a2 As Int = s2
			If a1-a2 > 1 Then split = True
		End If
		myf.DatabesOpen(Main.s1,booklibAddress,booklst.Get(i),True)
		Dim bookname As String = ""
		cur = Main.s1.ExecQuery("select * from table1")
		cur.Position = 0
		bookname = cur.GetString2(0)
		
		Dim p As B4XView = xui.CreatePanel("")
		p.Left = 0
		p.Top = 0
		p.Width = clv1.sv.Width
		p.Height = 20%y
		p.LoadLayout("CellItem")
		Dim spl As ImageView
		spl.Initialize("")
		spl.Gravity = Gravity.FILL
		spl.Width = 5.4*8%x
		spl.Height = 8%x
		If Main.nmode Then
			Dim BMPA As NegativeImage
			spl.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"mbeyt.png")))
		Else
			spl.SetBackgroundImage(LoadBitmap(File.DirAssets,"mbeyt.png"))
		End If
		If split Then
			p.AddView(spl,50%x-spl.Width/2-4%x,0,spl.Width,spl.Height)
		End If
		myf.Rangbandi(Label1cel,bookname,False,0,True)
		If Main.nmode Then
			Label1cel.TextColor = Colors.White
		Else
			Label1cel.TextColor = Colors.Black
		End If
		Label1cel.Left = 0'5%x
		Label1cel.Top = 0
		myf.setfrfont(Label1cel,clv1.sv.Width)'-8%x)
		p.Width = clv1.sv.Width
'		If i Mod 2 = 0 Then
		If Main.nmode Then Label1cel.Color = 0x22888888 Else Label1cel.Color = 0x11000000
'		End If
		If split Then
			Label1cel.Top = 8%x+Label1cel.Height/4
			p.Height = 8%x+Label1cel.Height*1.5
		Else
			Label1cel.Top = Label1cel.Height/4
			p.Height = Label1cel.Height*1.5
		End If
		Label1cel.Gravity = Gravity.CENTER
'		Dim lr,mo As Button
'		lr.Initialize("lr")
'		lr.Width = Label1cel.Height*1.5
'		lr.Height = Label1cel.Height*1.5
'		lr.Tag = i
'		If Main.nmode Then
'			Dim BMPA As NegativeImage
'			lr.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"lastread.png")))
'		Else
'			lr.SetBackgroundImage(LoadBitmap(File.DirAssets,"lastread.png"))
'		End If
'		mo.Initialize("mo")
'		mo.Width = Label1cel.Height*1.5
'		mo.Height = Label1cel.Height*1.5
'		mo.Tag = i
'		If Main.nmode Then
'			Dim BMPA As NegativeImage
'			mo.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"montakhab.png")))
'		Else
'			mo.SetBackgroundImage(LoadBitmap(File.DirAssets,"montakhab.png"))
'		End If
'		p.AddView(lr,0,0,lr.Width,lr.Height)
'		p.AddView(mo,mo.Width,0,mo.Width,mo.Height)
		clv1.Add(p,$"${i}"$)
	Next
	clv1.Refresh
	NightOrDayModeSel	
End Sub
Sub Button3_Click
	If  EdT1.Text.Length > 2 Then
		clv1.Clear
		Dim tmpl As Label
		tmpl.Initialize("")
		tmpl.Text = "بسم الله"
		myf.setfrfont(tmpl,clv1.sv.Width-5%x-3%x)
	
		clv1.Base_Resize(clv1.AsView.Width,94%y-clv1.AsView.Top)
	
		For i = 0 To booklst.Size-1
			myf.DatabesOpen(Main.s1,booklibAddress,booklst.Get(i),True)
			Dim bookname As String = ""
			cur = Main.s1.ExecQuery("select * from table1")
			cur.Position = 0
			bookname = cur.GetString2(0)
		
			Dim p As B4XView = xui.CreatePanel("")
			p.Left = 0
			p.Top = 0
			p.Width = clv1.sv.Width
			p.Height = 10%y
			p.LoadLayout("CellItem")
			myf.Rangbandi(Label1cel,bookname,False,0,True)
			If Main.nmode Then
				Label1cel.TextColor = Colors.White
			Else
				Label1cel.TextColor = Colors.Black
			End If
			Label1cel.Left = 5%x
			Label1cel.Top = 0
			myf.setfrfont(Label1cel,clv1.sv.Width-8%x)
			p.Width = clv1.sv.Width
			If i Mod 2 = 0 Then
				If Main.nmode Then Label1cel.Color = 0x22888888 Else Label1cel.Color = 0x11000000
			End If
			p.Height = Label1cel.Height
			clv1.Add(p,$"${i}"$)
		Next
		clv1.Refresh
		searchLib = True
		For i = 0 To clv1.Size-1
			myf.DatabesOpen(Main.s1,booklibAddress,booklst.Get(i),True)
			onvanha.search = True
			LIV1.Left = 40%x
			LIV1.RequestFocus()
			Sleep(100)
			Dim ime2 As IME
			ime2.Initialize("")
			ime2.HideKeyboard
			'myf.DatabesCopy(Main.s,"a.dat",True)
			searchstr = EdT1.Text
			searchstr = searchstr.Replace("ی","ي")
			searchstr = searchstr.Replace("ى","ي")
			searchstr = searchstr.Replace("ك","ک")
			searchstr = searchstr.Replace("إ","ا")
			searchstr = searchstr.Replace("أ","ا")
				
			searchstr = searchstr.Replace("۱","1")
			searchstr = searchstr.Replace("۲","2")
			searchstr = searchstr.Replace("۳","3")
			searchstr = searchstr.Replace("۴","4")
			searchstr = searchstr.Replace("۵","5")
			searchstr = searchstr.Replace("۶","6")
			searchstr = searchstr.Replace("۷","7")
			searchstr = searchstr.Replace("۸","8")
			searchstr = searchstr.Replace("۹","9")
			searchstr = searchstr.Replace("۰","0")
				
			'searchQuary = "replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace (replace('"&searchStr&"', 'ِ', ''),'ٍ',''),'ْ',''),'ّ','' ),'ٌ',''),'ُ',''),'ً',''),'َ',''),'ي','ی'),'ى','ی'),'ك','ک') ,'إ','ا') ,'أ','ا')"
			'cur=Main.s.ExecQuery("SELECT *  FROM table3 WHERE " & searchQuary &" LIKE '%%%"&searchStr&"%%'")
			If i = 0 Then
				cur=Main.s.ExecQuery("select COUNT(*) from table2 where tindex IN(SELECT tindex FROM Ntable3 WHERE ttext1 LIKE '%%%"&searchstr&"%%' or fttext1 LIKE '%%%"&searchstr&"%%')")
			Else
				cur=Main.s1.ExecQuery("select COUNT(*) from table2 where tindex IN(SELECT tindex FROM table3 WHERE ttext1 LIKE '%%%"&searchstr&"%%')")
			End If
			cur.Position=0
			Dim lb1 As Label
			lb1.Initialize("")
			lb1.Text = cur.GetInt2(0) & " عنوان یافت شد"
			cur.Close
			lb1.TextColor = Colors.Blue
			myf.setfrfont(lb1,50%x)
			lb1.Gravity = Gravity.LEFT
			clv1.GetPanel(i).AddView(lb1,3%x,0,50%x,10%y)
		Next
		LIV1.Left = 140%x
	Else
		ToastMessageShow("متن جستجو باید بیش از دو کاراکتر باشد",False)
	End If
End Sub
Sub EdT1_FocusChanged(HasFocus As Boolean)
	Dim jo = EdT1 As JavaObject
	If HasFocus = False Then
		jo.RunMethod("setCursorVisible",Array As Object(False))
	Else
		jo.RunMethod("setCursorVisible",Array As Object(True))
	End If
End Sub
Sub EdT1_TextChanged(old As String,new As String)
'	searchLib = False
	If EdT1.TextSize > 0 Then Button4.Visible = True Else Button4.Visible = False
End Sub
Sub Button4_Click
	EdT1.Text = ""
	Button4.Visible = False
End Sub
Sub clv1_ScrollChanged(Position As Int)
	Dim ime2 As IME
	ime2.Initialize("")
	ime2.HideKeyboard
	EdT1_FocusChanged(False)
End Sub
Sub NightOrDayModeSel

	If Main.nmode = False Then
		Activity.Color = Main.backColor
'		ShPanel.Color = Main.TopbackColor
		EdT1.TextColor = 0xFFC4A263
		EdT1.HintColor = 0xFFC4A263
		fehrest.SetBackgroundImage(LoadBitmap(File.DirAssets,"fehrest.png"))
		montakhab.SetBackgroundImage(LoadBitmap(File.DirAssets,"montakhab.png"))
		lastread.SetBackgroundImage(LoadBitmap(File.DirAssets,"lastread.png"))
		panelbook.Color = Colors.White
	Else
		Dim BMPA As NegativeImage
		Activity.Color = Colors.DarkGray
'		ShPanel.Color = Bit.Xor(Main.TopbackColor,0x00FFFFFF)
		EdT1.TextColor = 0xFFC4A263
		EdT1.HintColor = 0xFFC4A263
		fehrest.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"fehrest.png")))
		montakhab.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"montakhab.png")))
		lastread.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"lastread.png")))
		panelbook.Color = Colors.Black
	End If
'	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
'	myf.loadThemes(cvs,Main.nmode)
End Sub
Sub fehrest_Click
	If booksel = 0 Then
		StartActivity(KHOTAB)
		myf.SetAnimation("left_right","zoom_exit")
	Else
		StartActivity(onvanha)
		myf.SetAnimation("left_right","zoom_exit")
	End If
End Sub
Sub mo_Click
	Dim b1 As Button = Sender
	booksel = b1.Tag
	If booksel = 0 Then
		Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'booknum'")
		If cur1.RowCount > 0 Then
			Main.s.ExecNonQuery("update prevTable set val = 4  where name = 'booknum'")
		Else
			Main.s.ExecNonQuery("insert into prevTable VALUES(4,'booknum',4)")
		End If
		cur1.Close
	Else
		Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'booknum'")
		If cur1.RowCount > 0 Then
			Main.s.ExecNonQuery("update prevTable set val = 8  where name = 'booknum'")
		Else
			Main.s.ExecNonQuery("insert into prevTable VALUES(8,'booknum',8)")
		End If
		cur1.Close
	End If
	StartActivity(Markha)
	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub lr_Click
	Dim b1 As Button = Sender
	booksel = b1.Tag
	myf.DatabesOpen(Main.s1,booklibAddress,booklst.Get(booksel),True)
	File.WriteString(File.DirInternalCache,"booksel.txt",booklst.Get(booksel))
	If booksel = 0 Then
		Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'booknum'")
		If cur1.RowCount > 0 Then
			Main.s.ExecNonQuery("update prevTable set val = 4  where name = 'booknum'")
		Else
			Main.s.ExecNonQuery("insert into prevTable VALUES(4,'booknum',4)")
		End If
		cur1.Close
	Else
		Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'booknum'")
		If cur1.RowCount > 0 Then
			Main.s.ExecNonQuery("update prevTable set val = 8  where name = 'booknum'")
		Else
			Main.s.ExecNonQuery("insert into prevTable VALUES(8,'booknum',8)")
		End If
		cur1.Close
	End If
	If booksel = 0 Then
		Dim cur As Cursor = Main.s.ExecQuery("select * from Edameh")
		If cur.RowCount = 1 Then
			cur.Position = 0
			onvanha.search = False
			onvanha.idonvan = cur.GetInt("idonvan")
			onvanha.onvanSel = cur.GetString("onvanSel")
			Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'tindex'")
			If cur1.RowCount > 0 Then
				Main.s.ExecNonQuery("update prevTable set val = " & onvanha.idonvan &" where name = 'tindex'")
			Else
				Main.s.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& onvanha.idonvan&")")
			End If
			Motoon.edameh = True
			Motoon.startItem = cur.GetInt("ItemNumber")
			cur.Close
			StartActivity(Motoon)
			myf.SetAnimation("left_right","zoom_exit")
		End If
	Else
		Dim cur As Cursor = Main.s1.ExecQuery("select * from Edameh")
		If cur.RowCount > 0 Then
			cur.Position = 0
			onvanha.search = False
			onvanha.idonvan = cur.GetInt("idonvan")
			onvanha.onvanSel = cur.GetString("onvanSel")
			matnha.startItem = cur.GetInt("ItemNumber")
			matnha.edameh = True
		Else
			cur.Close
			cur = Main.s1.ExecQuery("select * from table2 where ttext = 1 ORDER BY tindex")
			cur.Position = 0
			onvanha.search = False
			onvanha.idonvan = cur.GetInt("tindex")
			onvanha.onvanSel = cur.GetString("ttitle")
			matnha.startItem = 0
			matnha.edameh = True
		End If
		cur.Close
		myf.ChachNotUse
		StartActivity(matnha)
		myf.SetAnimation("left_right","zoom_exit")
	End If

End Sub
Sub montakhab_Click
	StartActivity(Markha)
	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub lastread_Click
	If booksel = 0 Then
		Dim cur As Cursor = Main.s.ExecQuery("select * from Edameh")
		If cur.RowCount = 1 Then
			cur.Position = 0
			onvanha.search = False
			onvanha.idonvan = cur.GetInt("idonvan")
			onvanha.onvanSel = cur.GetString("onvanSel")
			Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'tindex'")
			If cur1.RowCount > 0 Then
				Main.s.ExecNonQuery("update prevTable set val = " & onvanha.idonvan)
			Else
				Main.s.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& onvanha.idonvan&")")
			End If
			Motoon.edameh = True
			Motoon.startItem = cur.GetInt("ItemNumber")
			cur.Close
			StartActivity(Motoon)
			myf.SetAnimation("left_right","zoom_exit")
		End If
	Else
		Dim cur As Cursor = Main.s1.ExecQuery("select * from Edameh")
		If cur.RowCount = 1 Then
			cur.Position = 0
			onvanha.search = False
			onvanha.idonvan = cur.GetInt("idonvan")
			onvanha.onvanSel = cur.GetString("onvanSel")
			matnha.startItem = cur.GetInt("ItemNumber")
			matnha.edameh = True
		Else
			cur.Close
			cur = Main.s1.ExecQuery("select * from table2 where ttext = 1 ORDER BY tindex")
			cur.Position = 0
			onvanha.search = False
			onvanha.idonvan = cur.GetInt("tindex")
			onvanha.onvanSel = cur.GetString("ttitle")
			matnha.startItem = 0
			matnha.edameh = True
		End If
		cur.Close
		myf.ChachNotUse
		StartActivity(matnha)
		myf.SetAnimation("left_right","zoom_exit")
	End If

End Sub
Sub Activity_Resume
'	panelbook.Visible = False
	NightOrDayModeSel
'	Dim ime2 As IME
'	ime2.Initialize("")
'	ime2.HideKeyboard
'	EdT1_FocusChanged(False)
	If Main.nmode = False Then
		Activity.Color = Main.backColor
	Else
		Activity.Color = Colors.DarkGray
	End If
	For i = 0 To clv1.Size-1

		If i Mod 2 = 0 Then
			If Main.nmode Then clv1.GetPanel(i).GetView(0).Color = 0x22888888 Else clv1.GetPanel(i).GetView(0).Color = 0x11000000
		End If
		If Main.nmode Then
			clv1.GetPanel(i).GetView(0).TextColor = Colors.White
		Else
			clv1.GetPanel(i).GetView(0).TextColor = Colors.Black
		End If
		If clv1.GetPanel(i).NumberOfViews = 4 And searchLib = False Then
'			clv1.GetPanel(i).GetView(3).
			Dim img3 As ImageView = clv1.GetPanel(i).GetView(3)
			img3.Gravity = Gravity.FILL
			img3.Width = 5.4*8%x
			img3.Height = 8%x

			If Main.nmode Then
				Dim BMPA As NegativeImage
				img3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"mbeyt.png")))
			Else
				img3.SetBackgroundImage(LoadBitmap(File.DirAssets,"mbeyt.png"))
			End If
		End If
	Next
'	clv1.Clear
'	clv1.Base_Resize(clv1.AsView.Width,94%y-clv1.AsView.Top)
'	Dim split As Boolean
'	For i = 0 To booklst.Size-1
'		split = False
'		If i > 0 Then
'			Dim s1,s2 As String
'			s1 = booklst.Get(i)
'			s2 = booklst.Get(i-1)
'			s1 = s1.SubString2(0,s1.Length-5)
'			s2 = s2.SubString2(0,s2.Length-5)
'			Dim a1 As Int = s1
'			Dim a2 As Int = s2
'			If a1-a2 > 1 Then split = True
'		End If
'		myf.DatabesOpen(Main.s1,booklibAddress,booklst.Get(i),True)
'		Dim bookname As String = ""
'		cur = Main.s1.ExecQuery("select * from table1")
'		cur.Position = 0
'		bookname = cur.GetString2(0)
'		
'		Dim p As B4XView = xui.CreatePanel("")
'		p.Left = 0
'		p.Top = 0
'		p.Width = clv1.sv.Width
'		p.Height = 20%y
'		p.LoadLayout("CellItem")
'		Dim spl As ImageView
'		spl.Initialize("")
'		spl.Gravity = Gravity.FILL
'		spl.Width = 5.4*8%x
'		spl.Height = 8%x
'		If Main.nmode Then
'			Dim BMPA As NegativeImage
'			spl.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"mbeyt.png")))
'		Else
'			spl.SetBackgroundImage(LoadBitmap(File.DirAssets,"mbeyt.png"))
'		End If
'		If split Then
'			p.AddView(spl,50%x-spl.Width/2-4%x,0,spl.Width,spl.Height)
'		End If
'		myf.Rangbandi(Label1cel,bookname,False,0,True)
'		If Main.nmode Then
'			Label1cel.TextColor = Colors.White
'		Else
'			Label1cel.TextColor = Colors.Black
'		End If
'		Label1cel.Left = 0'5%x
'		Label1cel.Top = 0
'		myf.setfrfont(Label1cel,clv1.sv.Width)'-8%x)
'		p.Width = clv1.sv.Width
''		If i Mod 2 = 0 Then
'		If Main.nmode Then Label1cel.Color = 0x22888888 Else Label1cel.Color = 0x11000000
''		End If
'		If split Then
'			Label1cel.Top = 8%x+Label1cel.Height/4
'			p.Height = 8%x+Label1cel.Height*1.5
'		Else
'			Label1cel.Top = Label1cel.Height/4
'			p.Height = Label1cel.Height*1.5
'		End If
'		Label1cel.Gravity = Gravity.CENTER
'		clv1.Add(p,$"${i}"$)
'	Next
'	clv1.Refresh

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub
Sub toastTm_Tick
	If DateTime.Now-LastToastTime > toastTm.Interval Then
		toastTm.Enabled = False
	End If
End Sub
Sub Activity_KeyPress(KeyCode As Int) As Boolean

	If KeyCode = KeyCodes.KEYCODE_BACK Then
		If searchLib Then
			searchLib = False
			clv1.Clear
			Dim tmpl As Label
			tmpl.Initialize("")
			tmpl.Text = "بسم الله"
			myf.setfrfont(tmpl,clv1.sv.Width-5%x-3%x)
	
			
			clv1.Base_Resize(clv1.AsView.Width,94%y-clv1.AsView.Top)
			Dim split As Boolean
			For i = 0 To booklst.Size-1
				split = False
				If i > 0 Then
					Dim s1,s2 As String
					s1 = booklst.Get(i)
					s2 = booklst.Get(i-1)
					s1 = s1.SubString2(0,s1.Length-5)
					s2 = s2.SubString2(0,s2.Length-5)
					Dim a1 As Int = s1
					Dim a2 As Int = s2
					If a1-a2 > 1 Then split = True
				End If
				myf.DatabesOpen(Main.s1,booklibAddress,booklst.Get(i),True)
				Dim bookname As String = ""
				cur = Main.s1.ExecQuery("select * from table1")
				cur.Position = 0
				bookname = cur.GetString2(0)
		
				Dim p As B4XView = xui.CreatePanel("")
				p.Left = 0
				p.Top = 0
				p.Width = clv1.sv.Width
				p.Height = 20%y
				p.LoadLayout("CellItem")
				Dim spl As ImageView
				spl.Initialize("")
				spl.Gravity = Gravity.FILL
				spl.Width = 5.4*8%x
				spl.Height = 8%x
				If Main.nmode Then
					Dim BMPA As NegativeImage
					spl.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"mbeyt.png")))
				Else
					spl.SetBackgroundImage(LoadBitmap(File.DirAssets,"mbeyt.png"))
				End If
				If split Then
					p.AddView(spl,50%x-spl.Width/2-4%x,0,spl.Width,spl.Height)
				End If
				myf.Rangbandi(Label1cel,bookname,False,0,True)
				If Main.nmode Then
					Label1cel.TextColor = Colors.White
				Else
					Label1cel.TextColor = Colors.Black
				End If
				Label1cel.Left = 0'5%x
				Label1cel.Top = 0
				myf.setfrfont(Label1cel,clv1.sv.Width)'-8%x)
				p.Width = clv1.sv.Width
'		If i Mod 2 = 0 Then
				If Main.nmode Then Label1cel.Color = 0x22888888 Else Label1cel.Color = 0x11000000
'		End If
				If split Then
					Label1cel.Top = 8%x+Label1cel.Height/4
					p.Height = 8%x+Label1cel.Height*1.5
				Else
					Label1cel.Top = Label1cel.Height/4
					p.Height = Label1cel.Height*1.5
				End If
				Label1cel.Gravity = Gravity.CENTER
				clv1.Add(p,$"${i}"$)
			Next
'
'			For i = 0 To booklst.Size-1
'				myf.DatabesOpen(Main.s1,booklibAddress,booklst.Get(i),True)
'				Dim bookname As String = ""
'				cur = Main.s1.ExecQuery("select * from table1")
'				cur.Position = 0
'				bookname = cur.GetString2(0)
'		
'				Dim p As B4XView = xui.CreatePanel("")
'				p.Left = 0
'				p.Top = 0
'				p.Width = clv1.sv.Width
'				p.Height = 10%y
'				p.LoadLayout("CellItem")
'				myf.Rangbandi(Label1cel,bookname,False,0,True)
'				If Main.nmode Then
'					Label1cel.TextColor = Colors.White
'				Else
'					Label1cel.TextColor = Colors.Black
'				End If
'				Label1cel.Left = 5%x
'				Label1cel.Top = 0
'				myf.setfrfont(Label1cel,clv1.sv.Width-8%x)
'				p.Width = clv1.sv.Width
'				If i Mod 2 = 0 Then
'					If Main.nmode Then p.Color = 0x22888888 Else p.Color = 0x11000000
'				End If
'				p.Height = Label1cel.Height
'				clv1.Add(p,$"${i}"$)
'			Next
			clv1.Refresh
			Return True
		Else
			EdT1_FocusChanged(False)
			Activity.Finish
			myf.SetAnimation("right_left1", "zoom_exit")
		End If
	End If
	If KeyCode = KeyCodes.KEYCODE_BACK And panelbook.Visible Then
		panelbook.Visible = False
		panelbook.RemoveView
		Return True
	End If
	Return False
End Sub
Sub clv1_ItemClick(Index As Int, Value As Object)
'	If Index = 0 Then
'		Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'booknum'")
'		If cur1.RowCount > 0 Then
'			Main.s.ExecNonQuery("update prevTable set val = 4  where name = 'booknum'")
'		Else
'			Main.s.ExecNonQuery("insert into prevTable VALUES(4,'booknum',4)")
'		End If
'		cur1.Close
'	Else
		Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'booknum'")
		If cur1.RowCount > 0 Then
			Main.s.ExecNonQuery("update prevTable set val = 8  where name = 'booknum'")
		Else
			Main.s.ExecNonQuery("insert into prevTable VALUES(8,'booknum',8)")
		End If
		cur1.Close
'	End If
	myf.DatabesOpen(Main.s1,booklibAddress,booklst.Get(Value),True)
	File.WriteString(File.DirInternalCache,"booksel.txt",booklst.Get(Value))

	If searchLib Then
		SearchM.searchStr = searchstr
		SearchM.startSearch = True
		StartActivity(SearchM)
		myf.SetAnimation("left_right","zoom_exit")
	Else
'		Dim ime2 As IME
'		ime2.Initialize("")
'		ime2.HideKeyboard
'		EdT1_FocusChanged(False)
'		fehrest.Tag = Value
		
		booksel = Index
		If booksel = 0 Then
			StartActivity(KHOTAB)
			myf.SetAnimation("left_right","zoom_exit")
		Else
			StartActivity(onvanha)
			myf.SetAnimation("left_right","zoom_exit")
		End If
	End If

End Sub

