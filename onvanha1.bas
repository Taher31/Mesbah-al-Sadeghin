B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=5.8
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: True
	#IncludeTitle: False
#End Region

Sub Process_Globals		
	Dim idonvan As Int
	Dim onvanSel As String
	Dim search As Boolean
	Private xui As XUI
End Sub

Sub Globals
	Dim cur As Cursor
'	Dim sm As SlidingMenu
	Private Button1 As Button
	Private Label1 As Label
	Dim EdT1 As ACEditText
	Private pnl1 As Panel
	Private cvs As Canvas
	Dim itemshow() As Boolean
	Dim tindex() As Int
	Dim tlevel() As Byte
	Dim ttext() As Byte
	Dim ttitle() As String
	Dim itemSize(Main.FitemNum) As Int
	Private clv1 As CustomListView
	Private Label1cel As Label
	Private LIV1 As LoadingIndicatorView
	Private img1,ImageView1 As ImageView
	Private ShPanel As Panel
	Private SearchB,NightM,AboutB,SettingB,CopyB,NextB,PrevB,MyApp  As Button
	Dim pvisible As Boolean = False
	Dim SearchItem As Boolean = False
	Private pos1 As ACSeekBar
End Sub

Sub Activity_Create(FirstTime As Boolean)
	myf.Loading
	Activity.LoadLayout("l_matnha")
	LIV1.IndicatorId = 17
	LIV1.IndicatorColor = Colors.Gray
	CopyB.Visible = False
	MyApp.Visible = True
	NextB.Visible = False
	PrevB.Visible = False
	Label1.Visible = False
	
	EdT1.Initialize("EdT1")
	Activity.AddView(EdT1,25*100%x/642,30*100%x/642,100%x-50*100%x/642,20*100%x/642+10%x)
	EdT1_FocusChanged(False)
	
	cvs.Initialize(pnl1)
	Activity.Color = Main.backColor
	
	If Main.FitemNum = 0 Then
		Dim cur=Main.s.ExecQuery("select COUNT(*) from table2 ") As Cursor
		cur.Position = 0
		Main.FitemNum = cur.GetInt2(0)
		cur.Close
	End If
	Dim itemshow(Main.FitemNum) As Boolean
	Dim tindex(Main.FitemNum) As Int
	Dim tlevel(Main.FitemNum) As Byte
	Dim ttext(Main.FitemNum) As Byte
	Dim ttitle(Main.FitemNum) As String
	Dim itemSize(Main.FitemNum) As Int
	For i =0 To itemshow.Length-1
		itemshow(i) = False
	Next
	cur= Main.s.ExecQuery("select * from table1")
	cur.Position = 0
	EdT1.Hint = cur.GetString2(0)
	cur.Close
	EdT1.TextSize=20
	EdT1.Height = 20*100%x/642+10%x
	EdT1.Typeface = Label1.Typeface
	EdT1.Gravity = Bit.Or(Gravity.CENTER_HORIZONTAL,Gravity.TOP)
	EdT1.SingleLine = True

	myf.loadThemes(cvs,Main.nmode)
	NightOrDayModeSel
	Dim tmpl As Label
	tmpl.Initialize("")
	tmpl.Text = "بسم الله"
	myf.setfrfont(tmpl,clv1.sv.Width-5%x-3%x)
	
	clv1.Base_Resize(clv1.AsView.Width,100%y-5%y-23*100%x/642-(46*100%x/642+10%x+7*100%x/642))
	cur=Main.s.ExecQuery("select * from table2")
	For i =0 To cur.RowCount-1
		cur.Position=i
		tindex(i) = cur.GetInt("tindex")
		tlevel(i) = cur.GetInt("tlevel")
		ttext(i)  = cur.GetInt("ttext")
		ttitle(i) = cur.GetString("ttitle")
		If tlevel(i) = 1 Then
			itemshow(tindex(i)-1) = True
		Else
			itemshow(tindex(i)-1) = False
		End If
		itemSize(i) = tmpl.Height
	Next
	cur.Close
	cur = Main.s.ExecQuery("select * from table2 where tlevel = 1")
	For i=0 To cur.RowCount-1
		cur.Position = i
		Dim p As B4XView = xui.CreatePanel("")
		p.Left = 0
		p.Top = 0
		p.Width = clv1.sv.Width
		p.Height = tmpl.Height
		p.Tag = 0
		clv1.InsertAt(i,p,$"${cur.GetInt("tindex")}"$)
	Next
	cur.Close
	clv1.Refresh

	pos1.Visible = False
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
	EdT1_FocusChanged(True)
	search = False
	Dim tmpl As Label
	tmpl.Initialize("")
	tmpl.Text = "بسم الله"
	myf.setfrfont(tmpl,clv1.sv.Width-5%x-3%x)
	
	If  EdT1.Text.Length > 0 Then
		SearchItem = True
		Dim searchStr = EdT1.Text As String
		
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
		
		cur=Main.s.ExecQuery("SELECT * FROM table2 WHERE (ttitle1 LIKE '%"&searchStr&"%')")
		clv1.Clear
		cur.Position=0
		Dim tindex(cur.RowCount) As Int
		Dim ttitle(cur.RowCount) As String
		For i =0 To cur.RowCount-1
			cur.Position=i
			tindex(i) = cur.GetInt("tindex")
			ttitle(i)  = cur.GetString("ttitle")
			Dim p As B4XView = xui.CreatePanel("")
			p.Tag = 0
			p.Left = 0
			p.Top = 0
			p.Width = clv1.sv.Width
			p.Height = tmpl.Height
			clv1.InsertAt(i,p,$"${tindex(i)}"$)
		Next
		cur.Close
	Else
		SearchItem = False
		clv1.Clear
		
		Dim itemshow(Main.FitemNum) As Boolean
		Dim tindex(Main.FitemNum) As Int
		Dim tlevel(Main.FitemNum) As Byte
		Dim ttext(Main.FitemNum) As Byte
		Dim ttitle(Main.FitemNum) As String
		Dim itemSize(Main.FitemNum) As Int
		For i =0 To itemshow.Length-1
			itemshow(i) = False
		Next
		cur= Main.s.ExecQuery("select * from table1")
		cur.Position = 0
		EdT1.Hint = cur.GetString2(0)
		cur.Close
		cur=Main.s.ExecQuery("select * from table2")
		For i =0 To cur.RowCount-1
			cur.Position=i
			tindex(i) = cur.GetInt("tindex")
			tlevel(i) = cur.GetInt("tlevel")
			ttext(i)  = cur.GetInt("ttext")
			ttitle(i) = cur.GetString("ttitle")
			If tlevel(i) = 1 Then
				itemshow(tindex(i)-1) = True
			Else
				itemshow(tindex(i)-1) = False
			End If
			itemSize(i) = tmpl.Height
		Next
		cur.Close
		cur = Main.s.ExecQuery("select * from table2 where tlevel = 1")
		For i=0 To cur.RowCount-1
			cur.Position = i
			Dim p As B4XView = xui.CreatePanel("")
			p.Left = 0
			p.Top = 0
			p.Width = clv1.sv.Width
			p.Height = tmpl.Height
			p.Tag = 0
			clv1.InsertAt(i,p,$"${cur.GetInt("tindex")}"$)
		Next
		cur.Close
		clv1.Refresh
	End If
End Sub
Sub clv1_ScrollChanged(Position As Int)
	Dim ime2 As IME
	ime2.Initialize("")
	ime2.HideKeyboard
	EdT1_FocusChanged(False)
End Sub
Sub NightOrDayModeSel
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
	If Main.nmode = False Then
		Activity.Color = Main.backColor
		ShPanel.Color = Main.TopbackColor
		EdT1.TextColor = Colors.Black
		EdT1.HintColor = Colors.Gray
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"nmode.png"))
		'ThemeCh.SetBackgroundImage(LoadBitmap(File.DirAssets,"palette.png"))
		SearchB.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
		CopyB.SetBackgroundImage(LoadBitmap(File.DirAssets,"content-copy.png"))
		SettingB.SetBackgroundImage(LoadBitmap(File.DirAssets,"settings-applications.png"))
		'ShareB.SetBackgroundImage(LoadBitmap(File.DirAssets,"share.png"))
		AboutB.SetBackgroundImage(LoadBitmap(File.DirAssets,"about.png"))
		MyApp.SetBackgroundImage(LoadBitmap(File.DirAssets,"apps.png"))
		
	Else
		Dim BMPA As NegativeImage
		Activity.Color = Colors.Black
		ShPanel.Color = Bit.Xor(Main.TopbackColor,0x00FFFFFF)
		EdT1.TextColor = Colors.White
		EdT1.HintColor = Colors.Gray
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"dmode.png"))
		'ThemeCh.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"palette.png")))
		SearchB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"search.png")))
		CopyB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"content-copy.png")))
		SettingB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"settings-applications.png")))
		'ShareB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"share.png")))
		AboutB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"about.png")))
		MyApp.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"apps.png")))
	End If
	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
	myf.loadThemes(cvs,Main.nmode)
End Sub
Sub MyApp_Click
'	Try
'		Dim inte As Intent
'		inte.Initialize(inte.ACTION_VIEW,"bazaar://collection?slug=by_author&aid=ghasedak")
'		StartActivity(inte)
'	Catch
'		Dim p As PhoneIntents
'		StartActivity(p.OpenBrowser("https://cafebazaar.ir/developer/ghasedak/?l=fa"))
'	End Try
End Sub
Sub SearchB_Click
	StartActivity(SearchM)
End Sub
Sub AboutB_Click
	StartActivity(about)
End Sub
Sub SettingB_Click
	Setting.frParent = True
	StartActivity(Setting)
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
End Sub

Sub NightM_Click
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
	If Main.nmode Then
		Main.nmode = False	
		Activity.Color = Main.backColor
		ShPanel.Color = Main.TopbackColor
		EdT1.TextColor = Colors.Black
		EdT1.HintColor = Colors.Gray
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"nmode.png"))
		'ThemeCh.SetBackgroundImage(LoadBitmap(File.DirAssets,"palette.png"))
		SearchB.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
		CopyB.SetBackgroundImage(LoadBitmap(File.DirAssets,"content-copy.png"))
		SettingB.SetBackgroundImage(LoadBitmap(File.DirAssets,"settings-applications.png"))
		'ShareB.SetBackgroundImage(LoadBitmap(File.DirAssets,"share.png"))
		AboutB.SetBackgroundImage(LoadBitmap(File.DirAssets,"about.png"))
		MyApp.SetBackgroundImage(LoadBitmap(File.DirAssets,"apps.png"))
		Main.mySetting.ExecNonQuery("update STable set nmode = 0")
	Else
		Dim BMPA As NegativeImage
		Main.nmode = True
		Activity.Color = Colors.Black
		ShPanel.Color = Bit.Xor(Main.TopbackColor,0x00FFFFFF)
		EdT1.TextColor = Colors.White
		EdT1.HintColor = Colors.Gray
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"dmode.png"))
		'ThemeCh.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"palette.png")))
		SearchB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"search.png")))
		CopyB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"content-copy.png")))
		SettingB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"settings-applications.png")))
		'ShareB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"share.png")))
		AboutB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"about.png")))
		MyApp.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"apps.png")))
		Main.mySetting.ExecNonQuery("update STable set nmode = 1")
	End If
	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
	myf.loadThemes(cvs,Main.nmode)
End Sub
Sub CLV1_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 0
	Dim htt As Int = 0
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clv1.Size - 1)
		If clv1.GetPanel(i).Tag = 0 Then
			If SearchItem Then SearchOnvanMatnhaCLV(i,clv1.GetValue(i)) Else ReplacOonvanMatnhaCLV(i,clv1.GetValue(i))
			htt = htt+clv1.GetPanel(i).Height
			clv1.GetPanel(i).Tag = 1
			If htt >= 135%y Then Exit
		End If
	Next
End Sub
Sub Activity_Resume
	NightOrDayModeSel
	Dim ime2 As IME
	ime2.Initialize("")
	ime2.HideKeyboard
	EdT1_FocusChanged(False)
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub Activity_KeyPress(KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_MENU Then
		Button1_Click
		Return True
	End If
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		EdT1_FocusChanged(False)
		If ShPanel.Visible = True Then
			Button1_Click
			Return True
		End If
	End If
	Return False
End Sub
Sub Button1_Click
	If pvisible = False Then
		pvisible = True
		ShPanel.Top = 100%y-23*100%x/642
		ShPanel.Visible = True
		clv1.Base_Resize(clv1.AsView.Width,100%y-5%y-8%y-23*100%x/642-(46*100%x/642+10%x+7*100%x/642))
		ShPanel.SetLayoutAnimated(313,ShPanel.Left,100%y-8%y-23*100%x/642,ShPanel.Width,ShPanel.Height)
		Button1.Visible = False
		Button1.Top = 100%y-5%y-23*100%x/642-8%y
		Button1.SetVisibleAnimated(500,True)
	Else
		pvisible = False
		clv1.Base_Resize(clv1.AsView.Width,100%y-5%y-23*100%x/642-(46*100%x/642+10%x+7*100%x/642))
		ShPanel.SetLayoutAnimated(313,ShPanel.Left,100%y-5%y-23*100%x/642,ShPanel.Width,ShPanel.Height)
		Button1.Visible = False
		Button1.Top = 100%y-5%y-23*100%x/642
		Button1.SetVisibleAnimated(500,True)
		Sleep(203)
		ShPanel.Visible = False
	End If
End Sub
Sub onvanMatnhaCLV(i As Int,ii As Int)
	Dim pColor As Boolean = False
	Dim showCount As Int = 0
	For j = 0 To ii-2
		If itemshow(j) Then showCount = showCount + 1
	Next
	If showCount Mod 2 = 0 Then pColor = True Else pColor = False
	clv1.Refresh
	Dim p As B4XView = xui.CreatePanel("")
	p.Left = 0
	p.Top = 0
	p.Width = clv1.sv.Width
	p.Height = 10%y
	p.LoadLayout("CellItem")
	myf.Rangbandi(Label1cel,ttitle(ii-1).Replace("أ","أ"),False,0,True)
	If Main.nmode Then 
		Label1cel.TextColor = Colors.White 
		If ttext(ii-1) = 1 Then
			img1.Color = Colors.White
			ImageView1.Color = Colors.White
		Else
			Dim BMPA As NegativeImage
			If itemshow(ii) = True Then
				ImageView1.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bu3.png")))
			Else
				ImageView1.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"l3.png")))
			End If
		End If
	Else 
		Label1cel.TextColor = Colors.Black
		If ttext(ii-1) = 1 Then
			img1.Color = Colors.Black
			ImageView1.Color = Colors.Black
		Else
			If itemshow(ii) = True Then
				ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,"bu3.png"))
			Else
				ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,"l3.png"))
			End If
		End If
	End If
	Label1cel.Left = 5%x
	Label1cel.Top = 0
	myf.setfrfont(Label1cel,clv1.sv.Width-5%x-(tlevel(ii-1)+1)*3%x)
	p.Width = clv1.sv.Width
	If itemshow(ii-1) = True Then
		p.Height = Label1cel.Height
		If pColor Then 
			If Main.nmode Then p.Color = 0x22888888 Else p.Color = 0x11000000
		End If
	Else
		p.Height = 0
	End If
	
	itemSize(ii-1) = Label1cel.Height
	clv1.InsertAt(i,p,$"${ii}"$)
	
	If ttext(ii-1) = 1 Then
		img1.Top = itemSize(ii-1)/2
		img1.Height = 1
		img1.Width = 1%x
		img1.Left = clv1.AsView.Width-(tlevel(ii-1)+1)*3%x+1%x
		ImageView1.Width = 1
		ImageView1.Height = itemSize(ii-1)/2
		If ii <itemshow.Length Then
			If ttext(ii) = 1 And tlevel(ii) = tlevel(ii-1) Then ImageView1.Height = itemSize(ii-1)
		End If
		ImageView1.Left = clv1.AsView.Width-(tlevel(ii-1)+1)*3%x+1%x+1%x
		ImageView1.Top = 0
	Else
		ImageView1.Width = 3%x
		ImageView1.Height = 3%x
		ImageView1.Left = clv1.AsView.Width-(tlevel(ii-1)+1)*3%x+1%x
		ImageView1.Top = itemSize(ii-1)/2-(3%x)/2
	End If
End Sub
Sub SearchOnvanMatnhaCLV(i As Int,ii As Int)
	Dim tmpl As Label
	tmpl.Initialize("")
	tmpl.Text = ttitle(i)
	myf.setfrfont(tmpl,94%x-5%x)
	Dim p As B4XView = xui.CreatePanel("")
	p.Left = 0
	p.Top = 0
	p.Width = clv1.sv.Width
	p.Height = 10%y
	p.LoadLayout("CellItem")
	If i Mod 2 = 0 Then 
		If Main.nmode Then p.Color = 0x22888888 Else p.Color = 0x11000000
	End If
	ttitle(i) = ttitle(i).Replace("أ","أ")
	myf.Rangbandi(Label1cel,ttitle(i),False,0,True)
	If Main.nmode Then Label1cel.TextColor = Colors.White Else Label1cel.TextColor = Colors.Black
	Label1cel.Left = 5%x
	Label1cel.Top = 0
	myf.setfrfont(Label1cel,clv1.AsView.Width-10%x)
	p.Tag = 1
	clv1.ReplaceAt(i,p,tmpl.Height,$"${ii}"$)
End Sub
Sub ReplacOonvanMatnhaCLV(i As Int,ii As Int)
	Dim pColor As Boolean = False
	Dim showCount As Int = 0
	For j = 0 To ii-2
		If itemshow(j) Then showCount = showCount + 1
	Next
	If showCount Mod 2 = 0 Then pColor = True Else pColor = False
	clv1.Refresh
	Dim p As B4XView = xui.CreatePanel("")
	p.Left = 0
	p.Top = 0
	p.Width = clv1.sv.Width
	p.Height = 10%y
	p.LoadLayout("CellItem")
	myf.Rangbandi(Label1cel,ttitle(ii-1).Replace("أ","أ"),False,0,True)
	If Main.nmode Then 
		Label1cel.TextColor = Colors.White 
		If ttext(ii-1) = 1 Then
			img1.Color = Colors.White
			ImageView1.Color = Colors.White
		Else
			Dim BMPA As NegativeImage
			If itemshow(ii) = True Then
				ImageView1.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bu3.png")))
			Else
				ImageView1.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"l3.png")))
			End If
		End If
	Else 
		Label1cel.TextColor = Colors.Black
		If ttext(ii-1) = 1 Then
			img1.Color = Colors.Black
			ImageView1.Color = Colors.Black
		Else
			If itemshow(ii) = True Then
				ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,"bu3.png"))
			Else
				ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,"l3.png"))
			End If
		End If
	End If
	Label1cel.Left = 5%x
	Label1cel.Top = 0
	myf.setfrfont(Label1cel,clv1.sv.Width-5%x-(tlevel(ii-1)+1)*3%x)
	p.Width = clv1.sv.Width
	If itemshow(ii-1) = True Then
		p.Height = Label1cel.Height
		If pColor Then 
			If Main.nmode Then p.Color = 0x22888888 Else p.Color = 0x11000000
		End If
	Else
		p.Height = 0
	End If
	
	itemSize(ii-1) = Label1cel.Height
	clv1.ReplaceAt(i,p,itemSize(ii-1),$"${ii}"$)
'	clv1.InsertAt(i,p,$"${ii}"$)
	
	If ttext(ii-1) = 1 Then
		img1.Top = itemSize(ii-1)/2
		img1.Height = 1
		img1.Width = 1%x
		img1.Left = clv1.AsView.Width-(tlevel(ii-1)+1)*3%x+1%x
		ImageView1.Width = 1
		ImageView1.Height = itemSize(ii-1)/2
		If ii <itemshow.Length Then
			If ttext(ii) = 1 And tlevel(ii) = tlevel(ii-1) Then ImageView1.Height = itemSize(ii-1)
		End If
		ImageView1.Left = clv1.AsView.Width-(tlevel(ii-1)+1)*3%x+1%x+1%x
		ImageView1.Top = 0
	Else
		ImageView1.Width = 3%x
		ImageView1.Height = 3%x
		ImageView1.Left = clv1.AsView.Width-(tlevel(ii-1)+1)*3%x+1%x
		ImageView1.Top = itemSize(ii-1)/2-(3%x)/2
	End If
End Sub

Sub clv1_ItemClick(Index As Int, Value As Object)
	EdT1_FocusChanged(False)
	idonvan=Value
	search = False
	Dim i As Int = Value-1
	If ttext(i) = 1 Then
		Dim labelA As Label
		labelA = clv1.GetPanel(Index).GetView(0)
		onvanSel = labelA.Text
		If Index Mod 2 = 0 Then 
			If Main.nmode Then clv1.GetPanel(Index).Color = 0x22888888 Else clv1.GetPanel(Index).Color = 0x11000000
		End If
		matnha.edameh = False
		myf.ChachNotUse
		StartActivity(matnha)
	Else if SearchItem = False Then
		LIV1.Left = 40%x
		Dim lj = 0 As Int
		Dim imgtype As Boolean
		For j = i+1 To tindex.Length-1
			If tlevel(j) <= tlevel(i) Then Exit
			If itemshow(j) Then
				imgtype = False
				itemshow(j) = False
				clv1.RemoveAt(Index+1)
			Else if tlevel(j) = tlevel(i)+1 Then
				imgtype = True
				itemshow(j) = True
				Dim p As B4XView = xui.CreatePanel("")
				p.Left = 0
				p.Top = 0
				p.Width = clv1.sv.Width
				p.Height = 5%x
				p.Tag = 0
				clv1.InsertAt(Index+1+lj,p,$"${tindex(j)}"$)
				lj = lj+1
			End If
		Next
		Dim myimage As ImageView = clv1.GetPanel(Index).GetView(1)
		If Main.nmode Then
			Dim BMPA As NegativeImage
			If imgtype Then
				myimage.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bu3.png")))
			Else
				myimage.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"l3.png")))
			End If
		Else
			If imgtype Then
				myimage.SetBackgroundImage(LoadBitmap(File.DirAssets,"bu3.png"))
			Else
				myimage.SetBackgroundImage(LoadBitmap(File.DirAssets,"l3.png"))
			End If
		End If
		
		clv1.Refresh
		LIV1.Left = 140%x
	Else
		cur.Close
		cur = Main.s.ExecQuery("select * from table2 where (tindex >"&idonvan&" and ttext = 1) ORDER BY tindex LIMIT 1")
		If cur.RowCount = 1 Then
			cur.Position = 0
			idonvan = cur.GetInt("tindex")
			onvanSel = cur.GetString("ttitle") 
			If Index Mod 2 = 0 Then 
				If Main.nmode Then clv1.GetPanel(Index).Color = 0x22888888 Else clv1.GetPanel(Index).Color = 0x11000000
			End If
			matnha.edameh = False
			myf.ChachNotUse
			StartActivity(matnha)
		End If

	End If
End Sub
