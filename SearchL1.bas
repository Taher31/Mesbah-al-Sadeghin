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
	Dim searchStr As String
	Private xui As XUI
	Dim tindex() As Int
	Dim ttitle() As String
	Dim tiSel As Int
	Dim toastTm As Timer
End Sub

Sub Globals
	Private Button2 As Button
	Private EditText1 As EditText
	Dim cur As Cursor
	Private clv1 As CustomListView
	Private Label1cel As Label
	Private LIV1 As LoadingIndicatorView
	Private pnl1 As Panel
	Private cvs As Canvas
	Private ToastText As Label
	Dim LastToastTime As Int = 0
End Sub

Sub Activity_Create(FirstTime As Boolean)
	myf.Loading
	Activity.LoadLayout("SearchL")
	toastTm.Initialize("toastTm",1000)
	If Not(searchStr = "") Then EditText1.Text = searchStr
	LIV1.IndicatorId = 17
	LIV1.IndicatorColor = Colors.Gray
	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
	cvs.Initialize(pnl1)
	myf.loadThemes(cvs,Main.nmode)
	NightOrDayModeSel
	If libview.searchLib Then
		Button2_click
	End If
End Sub
Sub NightOrDayModeSel
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
	If Main.nmode = False Then
		Activity.Color = Main.backColor
		EditText1.TextColor = Colors.Black
		Button2.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
	Else
		Dim BMPA As NegativeImage
		Activity.Color = Colors.Black
		EditText1.TextColor = Colors.White
		Button2.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"search.png")))
	End If
	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
	myf.loadThemes(cvs,Main.nmode)
End Sub
Sub NightM_Click
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
	If Main.nmode Then
		Main.nmode = False
		Activity.Color = Main.backColor
	Else
		Main.nmode = True
		Activity.Color = Colors.Black
	End If
	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
	myf.loadThemes(cvs,Main.nmode)
End Sub

Sub Button2_click
	If  EditText1.Text.Length > 2 Then
		onvanha.search = True
		LIV1.Left = 40%x
		LIV1.RequestFocus()
		Sleep(100)
		Dim ime2 As IME
		ime2.Initialize("")
		ime2.HideKeyboard
		'myf.DatabesCopy(Main.s,"a.dat",True)
		searchStr = EditText1.Text
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
		
		'searchQuary = "replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace (replace('"&searchStr&"', 'ِ', ''),'ٍ',''),'ْ',''),'ّ','' ),'ٌ',''),'ُ',''),'ً',''),'َ',''),'ي','ی'),'ى','ی'),'ك','ک') ,'إ','ا') ,'أ','ا')"
		'cur=Main.s.ExecQuery("SELECT *  FROM table3 WHERE " & searchQuary &" LIKE '%%%"&searchStr&"%%'")
		cur=Main.s.ExecQuery("select * from table2 where tindex IN(SELECT tindex FROM table3 WHERE ttext1 LIKE '%%%"&searchStr&"%%')")
		clv1.Clear
		cur.Position=0
		Dim tindex(cur.RowCount) As Int
		Dim ttitle(cur.RowCount) As String
		For i =0 To cur.RowCount-1
			cur.Position=i
'			Dim idx As Int =  cur.GetInt("tindex")
'			cur1 = Main.s.ExecQuery("select * from table2 where tindex =" & idx)
'			cur1.Position=0
			tindex(i) = cur.GetInt("tindex")
			ttitle(i)  = cur.GetString("ttitle")
			Dim p As B4XView = xui.CreatePanel("")
			p.Left = 0
			p.Top = 0
			p.Width = clv1.sv.Width
			p.Height = 5%x
			p.Tag = 0
			clv1.InsertAt(i,p,$"${tindex(i)}"$)
'			cur1.Close
		Next
		cur.Close
		LIV1.Left = 140%x
		ToastMessageShow2(cur.RowCount & " عنوان یافت شد",False)
	Else
		ToastMessageShow2("متن جستجو باید بیش از دو کاراکتر باشد",False)
	End If
End Sub
Sub clv1_ScrollChanged(Position As Int)
	Dim ime2 As IME
	ime2.Initialize("")
	ime2.HideKeyboard
End Sub
Sub CLV1_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 0
	Dim htt As Int = 0
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clv1.Size - 1)
		If clv1.GetPanel(i).Tag = 0 Then
			onvanMatnhaCLV(i,clv1.GetValue(i))
			htt = htt+clv1.GetPanel(i).Height
			If htt >= 135%y Then Exit
		End If
	Next
End Sub
Sub onvanMatnhaCLV(i As Int,ii As Int)
	Dim tmpl As Label
	tmpl.Initialize("")
	tmpl.Text = ttitle(i)
	myf.setfrfont(tmpl,94%x-5%x)
	Dim p As B4XView = xui.CreatePanel("")
	p.Left = 0
	p.Top = 0
	p.Width = clv1.sv.Width
	p.Height = tmpl.Height*1.2
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
	clv1.ReplaceAt(i,p,Label1cel.Height*1.2,$"${ii}"$)
End Sub

Sub clv1_ItemClick(Index As Int, Value As Object)
	Dim labelA As Label
	labelA = clv1.GetPanel(Index).GetView(0)
	onvanha.onvanSel = labelA.Text
	onvanha.idonvan = Value
	If Index Mod 2 = 0 Then
		If Main.nmode Then clv1.GetPanel(Index).Color = 0x22888888 Else clv1.GetPanel(Index).Color = 0x11000000
	End If
	tiSel = Index
	matnha.edameh = False
	matnha.nextOnvan = False
	matnha.prevOnvan = False
	myf.ChachNotUse
	StartActivity(matnha)
End Sub
Sub Activity_Resume
	NightOrDayModeSel
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub
Sub toastTm_Tick
	If DateTime.Now-LastToastTime > toastTm.Interval Then
		toastTm.Enabled = False
		ToastText.Visible = False
	End If
End Sub
Sub ToastMessageShow2(STR As String,LD As Boolean)
	ToastText.Color = Main.backColor
	ToastText.Width = 80%x
	ToastText.Text = "تست"
	myf.setLineSpace(ToastText,1.0)
	Dim lineH As Int = ToastText.Height+10
	ToastText.Text = STR
	ToastText.Height = 10%y
	Do While ToastText.Height < 80%y
		myf.setLineSpace(ToastText,1.0)
		ToastText.Height = ToastText.Height+10
		If ToastText.Height > lineH Then
			Exit
		Else
			If ToastText.Width > 10%x Then ToastText.Width = ToastText.Width -10%x
			myf.setLineSpace(ToastText,1.0)
			ToastText.Height = ToastText.Height+10
			If ToastText.Width = 10%x And ToastText.Height <= lineH Then Exit
			If ToastText.Height > lineH Then
				ToastText.Width = ToastText.Width + 10%x
				myf.setLineSpace(ToastText,1.0)
				ToastText.Height = ToastText.Height+10
				Exit
			End If
		End If
		
		If ToastText.Height > 80%y Then
			ToastText.Height = 80%y
			Exit
		End If
		If ToastText.Width > 80%x Then
			ToastText.Width = 80%x
			Exit
		End If
	Loop
	ToastText.Left = 50%x-ToastText.Width/2
	ToastText.Top = 70%y-ToastText.Height/2
	If LD Then
		toastTm.Interval = 4000
	Else
		toastTm.Interval = 2000
	End If
	If toastTm.Enabled Then toastTm.Enabled = False
	ToastText.Visible = True
	LastToastTime = DateTime.Now
	toastTm.Enabled = True
End Sub