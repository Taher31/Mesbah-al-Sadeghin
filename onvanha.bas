B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=5.8
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: False
#End Region

#If JAVA
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;

@Override
protected void attachBaseContext(Context newBase) {
    Resources res = newBase.getResources();
    Configuration config = new Configuration(res.getConfiguration());

    // ۱. تنظیم فونت اسکیل روی ۱۰۰٪ (نادیده گرفتن تنظیمات "متن بزرگ")
    config.fontScale = 1.0f;

    // ۲. تثبیت چگالی (DPI) روی مقدار پیش‌فرض دستگاه
    // این کار از به هم ریختن چیدمان به دلیل تغییر اندازه نمایشگر" جلوگیری می‌کند
    config.densityDpi = res.getDisplayMetrics().densityDpi;

    Context context = newBase.createConfigurationContext(config);
    super.attachBaseContext(context);
}
#End If
Sub Process_Globals
	Dim idonvan As Int
	Dim onvanSel As String
	Dim search As Boolean
	Private xui As XUI
	Dim s1 As SQL
End Sub

Sub Globals
	Dim cur As Cursor
'	Dim sm As SlidingMenu
	Private Label1 As Label
	Dim EdT1 As EditText
	Private pnl1 As Panel
	Private cvs As Canvas
	Dim itemshow() As Boolean
	Dim tindex() As Int
	Dim tlevel() As Byte
	Dim ttext() As Byte
	Dim ttitle() As String
	Dim itemSize() As Int
	Private clv1 As CustomListView
	Private Label1cel As Label
	Private LIV1 As LoadingIndicatorView
	Private img1,ImageView1 As ImageView
	Private ShPanel As Panel
	Private SearchB,NightM,NextB,PrevB,fmm,fpp  As Button
	Dim pvisible As Boolean = False
	Dim SearchItem As Boolean = False
	Private pos1 As SeekBar
	Dim bookSel As Int = 0
	Dim FMON As Button
	Dim FitemNum As Int
	Dim SetData As AppSetting
	Dim DatabaseName As String
	Private SettingB As Button
	Private menu As Boolean = False
	Private menuIndex As Int
	Private changeSetting As Boolean = False


	
	
	Private ArFname As Label
	Private ArLineSpace As SeekBar
	Private ARmm As Button
	Private ARpp As Button
	Private FrFname As Label
	Private FrLineSpace As SeekBar
	Private FRmm As Button
	Private FRpp As Button
	Private Label4 As Label
	
	Private ND As Button
	
	Private NextArabi As Button
	Private NextFarsi As Button
	
	Private PrevArabi As Button
	Private PrevFarsi As Button
	Private Tarjomeh As CheckBox
	Private Label3 As Label
	Private Tabs As ASTabMenu
	Private Panel1 As Panel
	Private Panel2 As Panel
	Private Panel3 As Panel
	Private Panel4 As Panel
	Private araLbl As Label
	Private frLbl As Label
	Private FehrestFname As Label
	Private fehrestLbl As Label
	Private Fehrestmm As Button
	Private Fehrestpp As Button
	Private Label5 As Label
	Private nextFehrest As Button
	Private Panel5 As Panel
	Private topPanel As Panel
End Sub

Sub Activity_Create(FirstTime As Boolean)
	myf.Loading(SetData)
	s1.Close
	Dim path As String = File.ReadString(File.DirInternalCache,"bookAddr.txt")
	DatabaseName = File.ReadString(File.DirInternalCache,"booksel.txt")
	bookSel = File.ReadString(File.DirInternalCache,"booktype.txt")
	myf.DatabesOpen(s1,path,DatabaseName,False)	

	Activity.LoadLayout("l_matnha")
	topPanel.Color = SetData.TopbackColor
	ShPanel.Visible = True
	ShPanel.Color = SetData.TopbackColor
	SearchB.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
	NextB.Visible = False
	PrevB.Visible = False
	SettingB.Visible = True
	SettingB.SetBackgroundImage(LoadBitmap(File.DirAssets,"settings-applications.png"))
	LIV1.IndicatorId = 17
	LIV1.IndicatorColor = Colors.Gray
	Label1.Visible = False
	
	
	If Not(File.Exists(File.DirInternal,"Tarjomeh")) Then
		File.WriteString(File.DirInternal,"Tarjomeh","1")
	End If
	
	EdT1.Initialize("EdT1")
	Activity.AddView(EdT1,0,30*100%x/642,100%x,20*100%x/642+10%x)
	EdT1_FocusChanged(False)
	
'	cvs.Initialize(pnl1)
'	Activity.Color = Main.backColor
	Dim jo = clv1.sv As JavaObject
	jo.RunMethod("setVerticalScrollbarPosition", Array As Object (1))   ' position left
	
	Dim r As Reflector
	r.Target = clv1.sv
	r.Target = r.GetField("mScrollCache")
	r.Target = r.GetField("scrollBar")
	Dim cd As ColorDrawable
	If SetData.nmode Then
		cd.Initialize(Colors.Gray, 5dip)
	Else
		cd.Initialize(0xffe0bb92, 5dip)
	End If
	myf.ChangeScrollbarColor(clv1.sv, cd)
	Dim jo As JavaObject = clv1.sv
	jo.RunMethod("setScrollBarSize", Array(DipToCurrent(8)))
'	r.RunMethod4("setVerticalThumbDrawable", Array(cd), Array As String("android.graphics.drawable.Drawable"))
	Dim cur=s1.ExecQuery("select COUNT(*) from table2 ") As Cursor
	cur.Position = 0
	FitemNum = cur.GetInt2(0)
	cur.Close
	Dim itemshow(FitemNum) As Boolean
	Dim tindex(FitemNum) As Int
	Dim tlevel(FitemNum) As Byte
	Dim ttext(FitemNum) As Byte
	Dim ttitle(FitemNum) As String
	Dim itemSize(FitemNum) As Int
	For i =0 To itemshow.Length-1
		itemshow(i) = False
	Next
	
	
'	cur = s.ExecQuery("select val from prevTable where name = 'booknum'")
'	cur.Position = 0
'	bookSel = cur.GetInt2(0)
'	cur= s.ExecQuery("select * from table1")
'	cur.Position = 0
'	If bookSel = 8 Then
		cur= s1.ExecQuery("select * from table1")
		cur.Position = 0
		EdT1.Hint = "جستجو در فهرست"'cur.GetString2(0)
		cur.Close
'	else If bookSel = 7 Then
'		cur= s.ExecQuery("select * from table1")
'		cur.Position = 0
'		EdT1.Hint = cur.GetString2(0)
'		cur.Close
'	End If
	EdT1.TextSize=20
	EdT1.Height = 20*100%x/642+10%x
	EdT1.Typeface = Label1.Typeface
	EdT1.Gravity = Bit.Or(Gravity.CENTER_HORIZONTAL,Gravity.TOP)
	EdT1.SingleLine = True
	EdT1.HintColor = 0xfff1e9d5
	EdT1.TextColor = 0xffc4a263


'	myf.loadThemes(cvs,SetData.nmode,SetData)
	NightOrDayModeSel
	Dim tmpl As Label
	tmpl.Initialize("")
	tmpl.Text = "بسم الله"
	myf.setFMatnfont(tmpl,clv1.sv.Width-5%x-3%x)
	
	clv1.Base_Resize(clv1.AsView.Width,100%y-16.5%y)'(46*100%x/642+10%x+7*100%x/642)-8%y)
	clv1.GetBase.Left = 50%x - clv1.GetBase.Width/2
'	If bookSel = 8 Then
		cur = s1.ExecQuery("select * from table2")
'	else If bookSel = 7 Then
'		cur = s.ExecQuery("select * from table2")	
'	End If
	
	Log(cur.RowCount)
	For i =0 To cur.RowCount-1
		cur.Position=i
		tindex(i) = cur.GetInt("tindex")
		tlevel(i) = cur.GetInt("tlevel")
		ttext(i)  = cur.GetInt("ttext")
		ttitle(i) = cur.GetString("ttitle")
		If tlevel(i) = 1 Then
			itemshow(i) = True
		Else
			itemshow(i) = False
		End If
		itemSize(i) = tmpl.Height
	Next
	cur.Close
	
'	If bookSel = 8 Then
		cur = s1.ExecQuery("select * from table2 where tlevel = 1")
'	else If bookSel = 7 Then
'		cur = s.ExecQuery("select * from table2 where tlevel = 1")
'	End If
	
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


	FMON.Initialize("FMON")
	FMON.SetBackgroundImage(LoadBitmap(File.DirAssets,"1-3.png"))
	Activity.AddView(FMON,0,5%y-7%x,14%x,14%x)
'	fmm.Initialize("FMM")
'	fmm.SetBackgroundImage(LoadBitmap(File.DirAssets,"fmm.png"))
'	Activity.AddView(fmm, 67%x,0.3%y,9.4%y,9.4%y)
'	fpp.Initialize("FPP")
'	fpp.SetBackgroundImage(LoadBitmap(File.DirAssets,"fpp.png"))
'	Activity.AddView(fpp,100%x-9.4%y,0.3%y,9.4%y,9.4%y)
	pos1.Visible = False
	EdT1.Left = 14%x
	EdT1.Width = 78%x
	EdT1.Gravity = Gravity.RIGHT
	Dim scale As Float = GetSystemFontScale
'	Log("System Font Scale: " & scale)
End Sub
Sub GetSystemFontScale As Float
	Dim r As Reflector
	r.Target = r.GetContext
	r.Target = r.RunMethod("getResources")
	r.Target = r.RunMethod("getConfiguration")
	Dim fontScale As Float = r.GetField("fontScale")
	Return fontScale
End Sub
Sub FMON_Click
	StartActivity(Markha)
	myf.SetAnimation("task_open_enter","task_open_exit")
End Sub
Sub FPP_Click
	If myf.FarSize < 48 Then
		myf.FarSize= myf.FarSize+1
		For i = 0 To clv1.Size-1
			clv1.GetPanel(i).Tag = 0
		Next
		clv1.Refresh
		myf.SettingApp.ExecNonQuery("update fontTable set fehrestFont ="& myf.FehrestFont & ",ArFont =" & myf.AraFont &",FrFont = "& myf.FarFont &",fehrestSize = "& myf.FehrestSize &",ArSize = "& myf.AraSize &",FrSize = "& myf.FarSize &",ArLineSpace = "& myf.ArLineSp &",FrLineSpace = "& myf.FrLineSp)
	End If
End Sub
Sub fmm_Click
	If myf.FarSize > 18 Then
		myf.FarSize = myf.FarSize-1
		For i = 0 To clv1.Size-1
			clv1.GetPanel(i).Tag = 0
		Next
		clv1.Refresh
		myf.SettingApp.ExecNonQuery("update fontTable set fehrestFont ="& myf.FehrestFont & ",ArFont =" & myf.AraFont &",FrFont = "& myf.FarFont &",fehrestSize = "& myf.FehrestSize &",ArSize = "& myf.AraSize &",FrSize = "& myf.FarSize &",ArLineSpace = "& myf.ArLineSp &",FrLineSpace = "& myf.FrLineSp)
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
	EdT1_FocusChanged(True)
	search = False
	Dim tmpl As Label
	tmpl.Initialize("")
	tmpl.Text = "بسم الله"
	myf.setFMatnfont(tmpl,clv1.sv.Width-5%x-3%x)
	
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
		
'		If bookSel = 8 Then
			cur=s1.ExecQuery("SELECT * FROM table2 WHERE (ttitle1 LIKE '%"&searchStr&"%')")
'		else If bookSel = 7 Then
'			cur=s.ExecQuery("SELECT * FROM table2 WHERE (tfttitle1 LIKE '%"&searchStr&"%')")
'		End If
		
		clv1.Clear
		cur.Position=0
		
		Dim tindex(cur.RowCount) As Int
		Dim ttitle(cur.RowCount) As String
		For i =0 To cur.RowCount-1
			cur.Position=i
			tindex(i) = cur.GetInt("tindex")
'			If bookSel = 2 Then
'				ttitle(i)  = cur.GetString("tfttitle")
'			End If
'			If bookSel = 7 Or bookSel = 8 Then
				ttitle(i)  = cur.GetString("ttitle")
'			End If
			
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
		
		Dim itemshow(FitemNum) As Boolean
		Dim tindex(FitemNum) As Int
		Dim tlevel(FitemNum) As Byte
		Dim ttext(FitemNum) As Byte
		Dim ttitle(FitemNum) As String
		Dim itemSize(FitemNum) As Int
		For i =0 To itemshow.Length-1
			itemshow(i) = False
		Next
		
'		If bookSel = 8 Then
			cur= s1.ExecQuery("select * from table1")
			cur.Position = 0
		EdT1.Hint = "جستجو در فهرست"'cur.GetString2(0)
			cur.Close
'		else If bookSel = 7 Then
'			cur= s.ExecQuery("select * from table1")
'			cur.Position = 0
'			EdT1.Hint = cur.GetString2(0)
'			cur.Close
'		End If
'		cur= s.ExecQuery("select * from table1")
'		cur.Position = 0
'		EdT1.Hint = cur.GetString2(0)
'		cur.Close
'		If bookSel = 8 Then
			cur=s1.ExecQuery("select * from table2")
'		else If bookSel = 7 Then
'			cur=s.ExecQuery("select * from table2")
'		End If
		
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
'		If bookSel = 8 Then
			cur = s1.ExecQuery("select * from table2 where tlevel = 1")
'		else If bookSel = 7 Then
'			cur = s.ExecQuery("select * from table2 where tlevel = 1")
'		End If
		
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
	If SetData.nmode = False Then
		Activity.Color = SetData.backColor
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"nmode.png"))
'		ShPanel.Color = Main.TopbackColor
'		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"nmode.png"))
'		'ThemeCh.SetBackgroundImage(LoadBitmap(File.DirAssets,"palette.png"))
'		SearchB.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
'		CopyB.SetBackgroundImage(LoadBitmap(File.DirAssets,"content-copy.png"))
'		SettingB.SetBackgroundImage(LoadBitmap(File.DirAssets,"settings-applications.png"))
'		'ShareB.SetBackgroundImage(LoadBitmap(File.DirAssets,"share.png"))
'		AboutB.SetBackgroundImage(LoadBitmap(File.DirAssets,"about.png"))
'		MyApp.SetBackgroundImage(LoadBitmap(File.DirAssets,"apps.png"))
		
	Else
'		Dim BMPA As NegativeImage
		Activity.Color = 0x002223
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"dmode.png"))
'		ShPanel.Color = Bit.Xor(Main.TopbackColor,0x00FFFFFF)
'		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"dmode.png"))
'		'ThemeCh.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"palette.png")))
'		SearchB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"search.png")))
'		CopyB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"content-copy.png")))
'		SettingB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"settings-applications.png")))
'		'ShareB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"share.png")))
'		AboutB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"about.png")))
'		MyApp.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"apps.png")))
	End If
'	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
'	myf.loadThemes(cvs,SetData.nmode,SetData)
End Sub
Sub MyApp_Click
'	Try
'		Dim inte As Intent
'		inte.Initialize(inte.ACTION_VIEW,"bazaar://collection?slug=by_author&aid=ghasedak")
'		StartActivity(inte)
'	Catch
'	Dim p As PhoneIntents
'	StartActivity(p.OpenBrowser("http://eitaa.com/AnisSoft"))
'	End Try
End Sub
Sub SearchB_Click
	StartActivity(SearchM)
	myf.SetAnimation("task_open_enter","task_open_exit")
End Sub
'Sub AboutB_Click
'	StartActivity(about)
'	myf.SetAnimation("left_right","zoom_exit")
'End Sub
'Sub SettingB_Click
'	Setting.frParent = True
'	StartActivity(Setting)
'	myf.SetAnimation("left_right","zoom_exit")
'	For i = 0 To clv1.Size-1
'		clv1.GetPanel(i).Tag = 0
'	Next
'	clv1.Refresh
'End Sub

Sub NightM_Click
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
	If SetData.nmode Then
		SetData.nmode = False
		Activity.Color = SetData.backColor
'		ShPanel.Color = Main.TopbackColor
'		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"nmode.png"))
'		'ThemeCh.SetBackgroundImage(LoadBitmap(File.DirAssets,"palette.png"))
'		SearchB.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
'		CopyB.SetBackgroundImage(LoadBitmap(File.DirAssets,"content-copy.png"))
'		SettingB.SetBackgroundImage(LoadBitmap(File.DirAssets,"settings-applications.png"))
'		'ShareB.SetBackgroundImage(LoadBitmap(File.DirAssets,"share.png"))
'		AboutB.SetBackgroundImage(LoadBitmap(File.DirAssets,"about.png"))
'		MyApp.SetBackgroundImage(LoadBitmap(File.DirAssets,"apps.png"))
		myf.SettingApp.ExecNonQuery("update STable set nmode = 0")
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"nmode.png"))
	Else
'		Dim BMPA As NegativeImage
		SetData.nmode = True
		Activity.Color = 0x002223
'		ShPanel.Color = Bit.Xor(Main.TopbackColor,0x00FFFFFF)
'		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"dmode.png"))
'		'ThemeCh.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"palette.png")))
'		SearchB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"search.png")))
'		CopyB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"content-copy.png")))
'		SettingB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"settings-applications.png")))
'		'ShareB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"share.png")))
'		AboutB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"about.png")))
'		MyApp.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"apps.png")))
		myf.SettingApp.ExecNonQuery("update STable set nmode = 1")
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"dmode.png"))
	End If
'	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
	Dim r As Reflector
	r.Target = clv1.sv
	r.Target = r.GetField("mScrollCache")
	r.Target = r.GetField("scrollBar")
	Dim cd As ColorDrawable
	If SetData.nmode Then
		cd.Initialize(Colors.Gray, 5dip)
	Else
		cd.Initialize(0xffe0bb92, 5dip)
	End If
	myf.ChangeScrollbarColor(clv1.sv, cd)
'	r.RunMethod4("setVerticalThumbDrawable", Array(cd), Array As String("android.graphics.drawable.Drawable"))
	
'	myf.loadThemes(cvs,SetData.nmode,SetData)
	If menu Then
		If SetData.nmode = False Then
			Label3.Color = SetData.backColor
			Label4.Color = SetData.backColor
			Label5.Color = SetData.backColor
			Label3.TextColor = Colors.Black
			Label4.TextColor = Colors.Black
			Label5.TextColor = Colors.Black
		Else
			Label3.Color = Colors.DarkGray
			Label4.Color = Colors.DarkGray
			Label5.Color = Colors.DarkGray
			Label3.TextColor = Colors.White
			Label4.TextColor = Colors.White
			Label5.TextColor = Colors.White
		End If
	End If
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
	myf.Loading(SetData)
	NightOrDayModeSel
	Dim ime2 As IME
	ime2.Initialize("")
	ime2.HideKeyboard
	EdT1_FocusChanged(False)
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then Activity.Finish
End Sub
'Sub lv_ItemClick (Position As Int, Value As Object)
'	If Value = "item1" Then
'		sm.HideMenus
'		StartActivity(SearchM)
'	Else If Value = "item5" Then
'		sm.HideMenus
'		StartActivity(about)
'	Else If Value = "item2" Then
'		sm.HideMenus
'		SettingApp.frParent = True
'		StartActivity(SettingApp)
'	End If
'	
'End Sub

'Sub Activity_KeyUp (KeyCode As Int) As Boolean
'If KeyCode=KeyCodes.KEYCODE_BACK Then
'	StartActivity(Main)
'	Activity.Finish	
'	Return True
'End If
'	Return False
'End Sub

Sub Activity_KeyPress(KeyCode As Int) As Boolean
'	If KeyCode = KeyCodes.KEYCODE_MEDIA_PREVIOUS Then NightM_Click
'	If KeyCode = KeyCodes.KEYCODE_MENU Then
'		Button1_Click
'		Return True
'	End If
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		If menu Then
			SettingB_Click
			Return True
		Else
			StartActivity(Main)
			myf.SetAnimation("left_right","left_right1")
			Activity.Finish
		End If
		EdT1_FocusChanged(False)
'		If ShPanel.Visible = True Then

'		Else

'		End If
	End If
	Return False
End Sub
'Sub Button1_Click
'	If pvisible = False Then
'		pvisible = True
'		ShPanel.Top = 100%y-23*100%x/642
'		ShPanel.Visible = True
'		clv1.Base_Resize(clv1.AsView.Width,100%y-(46*100%x/642+10%x+7*100%x/642)-8%y)
'		ShPanel.SetLayoutAnimated(313,ShPanel.Left,100%y-8%y-23*100%x/642,ShPanel.Width,ShPanel.Height)
'		Button1.Visible = False
'		Button1.Top = 100%y-5%y-23*100%x/642-8%y
'		Button1.SetVisibleAnimated(500,True)
'	Else
'		pvisible = False
'		clv1.Base_Resize(clv1.AsView.Width,100%y-(46*100%x/642+10%x+7*100%x/642)-8%y)
'		ShPanel.SetLayoutAnimated(313,ShPanel.Left,100%y-5%y-23*100%x/642,ShPanel.Width,ShPanel.Height)
'		Button1.Visible = False
'		Button1.Top = 100%y-5%y-23*100%x/642
'		Button1.SetVisibleAnimated(500,True)
'		Sleep(203)
'		ShPanel.Visible = False
'	End If
'End Sub
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
	myf.Rangbandi(Label1cel,ttitle(ii-1).Replace("أ","أ"),False,0,True,SetData)
	If SetData.nmode Then
		Label1cel.TextColor = Colors.White
		If ttext(ii-1) = 1 Then
			img1.Color = Colors.White
			ImageView1.Color = Colors.White
		Else
			If itemshow(ii) = True Then
				ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,"bu3.png"))
			Else
				ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,"l3.png"))
			End If
'			Dim BMPA As NegativeImage
'			If itemshow(ii) = True Then
'				ImageView1.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bu3.png")))
'			Else
'				ImageView1.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"l3.png")))
'			End If
		End If
	Else
		Label1cel.TextColor = 0xFF021c1a'1b1448'Colors.Black
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
	myf.setFMatnfont(Label1cel,clv1.sv.Width-5%x-(tlevel(ii-1)+1)*5%x)
	p.Width = clv1.sv.Width
	If itemshow(ii-1) = True Then
		p.Height = Label1cel.Height
		If pColor Then
			If SetData.nmode Then p.Color = 0x0Affffff Else p.Color = 0xfff7f0df
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
		img1.Left = clv1.AsView.Width-(tlevel(ii-1)+1)*5%x+1%x
		ImageView1.Width = 1
		ImageView1.Height = itemSize(ii-1)/2
		If ii <itemshow.Length Then
			If ttext(ii) = 1 And tlevel(ii) = tlevel(ii-1) Then ImageView1.Height = itemSize(ii-1)
		End If
		ImageView1.Left = clv1.AsView.Width-(tlevel(ii-1)+1)*5%x+1%x+1%x
		ImageView1.Top = 0
	Else
		ImageView1.Width = 5%x
		ImageView1.Height = 5%x
		ImageView1.Left = clv1.AsView.Width-(tlevel(ii-1)+1)*5%x+1%x
		ImageView1.Top = itemSize(ii-1)/2-(5%x)/2
	End If
End Sub
Sub SearchOnvanMatnhaCLV(i As Int,ii As Int)
	Dim tmpl As Label
	tmpl.Initialize("")
	tmpl.Text = ttitle(i)
	myf.setFMatnfont(tmpl,94%x-5%x)
	Dim p As B4XView = xui.CreatePanel("")
	p.Left = 0
	p.Top = 0
	p.Width = clv1.sv.Width
	p.Height = 10%y
	p.LoadLayout("CellItem")
	If i Mod 2 = 0 Then
		If SetData.nmode Then Label1cel.Color = 0x0Affffff Else Label1cel.Color = 0xfff1ebda'0xfff7f0df
	Else
		If SetData.nmode Then Label1cel.Color = 0x05ffffff Else Label1cel.Color = 0xfffdf8e5
	End If
	ttitle(i) = ttitle(i).Replace("أ","أ")
	myf.Rangbandi(Label1cel,ttitle(i),False,0,True,SetData)
	If SetData.nmode Then Label1cel.TextColor = Colors.White Else Label1cel.TextColor = 0xFF021c1a'1b1448'Colors.Black
	Label1cel.Left = 5%x
	Label1cel.Top = 0
	myf.setFMatnfont(Label1cel,clv1.AsView.Width-10%x)
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
	myf.Rangbandi(Label1cel,ttitle(ii-1).Replace("أ","أ"),False,0,True,SetData)
	If SetData.nmode Then
		Label1cel.TextColor = Colors.White
		If ttext(ii-1) = 1 Then
			img1.Color = Colors.White
			ImageView1.Color = Colors.White
		Else
			If itemshow(ii) = True Then
				ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,"bu3.png"))
			Else
				ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,"l3.png"))
			End If
'			Dim BMPA As NegativeImage
'			If itemshow(ii) = True Then
'				ImageView1.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bu3.png")))
'			Else
'				ImageView1.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"l3.png")))
'			End If
		End If
	Else
		Label1cel.TextColor = 0xFF021c1a'1b1448'Colors.Black
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
	
	Label1cel.Left = 3%x
	Label1cel.Top = 0
	myf.setFMatnfont(Label1cel,clv1.sv.Width-3%x-(tlevel(ii-1)+1)*5%x)
	p.Width = clv1.sv.Width
	Label1cel.Height = Label1cel.Height + 5dip
	If itemshow(ii-1) = True Then
		p.Height = Label1cel.Height + 5dip
		If pColor Then
			If SetData.nmode Then Label1cel.Color = 0x0Affffff Else Label1cel.Color = 0xfff1ebda'0xfff7f0df
		Else
			If SetData.nmode Then Label1cel.Color = 0x05ffffff Else Label1cel.Color = 0xfffdf8e5
		End If
	Else
		p.Height = 0
	End If
	
	itemSize(ii-1) = Label1cel.Height + 5dip
	clv1.ReplaceAt(i,p,itemSize(ii-1),$"${ii}"$)
'	clv1.InsertAt(i,p,$"${ii}"$)
	
	If ttext(ii-1) = 1 Then
		'hazf shavad
		Dim cu1 As Cursor =  s1.ExecQuery("select * from table3 where tindex =" & tindex(ii-1))
		If cu1.RowCount > 0 Then
			cu1.Position = 0
			Dim MatnStr As String = cu1.GetString("ttext")
			Dim fileHttpPath As String = MatnStr.SubString(MatnStr.IndexOf("@")+1)
			If fileHttpPath.Length < 5 Then Label1cel.TextColor = Colors.Yellow
		End If
		'hazf shavad
		img1.Top = itemSize(ii-1)/2
		img1.Height = 1
		img1.Width = 1%x
		img1.Left = clv1.AsView.Width-(tlevel(ii-1)+1)*5%x+1%x
		ImageView1.Width = 1
		ImageView1.Height = itemSize(ii-1)/2
		If ii <itemshow.Length Then
			If ttext(ii) = 1 And tlevel(ii) = tlevel(ii-1) Then ImageView1.Height = itemSize(ii-1)
		End If
		ImageView1.Left = clv1.AsView.Width-(tlevel(ii-1)+1)*5%x+1%x+1%x
		ImageView1.Top = 0
	Else
		ImageView1.Width = 5%x
		ImageView1.Height = 5%x
		ImageView1.Left = clv1.AsView.Width-(tlevel(ii-1)+1)*5%x+1%x
		ImageView1.Top = itemSize(ii-1)/2-(5%x)/2
	End If
End Sub

Sub clv1_ItemClick(Index As Int, Value As Object)
	If menu Then Return
	EdT1_FocusChanged(False)
	idonvan=Value
	File.WriteString(File.DirInternalCache,"onvanha.txt",idonvan)
	search = False
	Dim i As Int = Value-1
	If ttext(i) = 1 Then
		Dim labelA As Label
		labelA = clv1.GetPanel(Index).GetView(0)
		onvanSel = labelA.Text
'		If Index Mod 2 = 0 Then
'			If Main.nmode Then clv1.GetPanel(Index).Color = 0x88888888 Else clv1.GetPanel(Index).Color = 0x88000000
'		End If
		matnha.edameh = False
		Dim dbSoti As Boolean = False
		For i = 201 To 210
'			If DatabaseName = i & ".book" Then
'				dbSoti = True
'				ASSAR.pageSel = 3
'				StartActivity(ASSAR)
'				myf.SetAnimation("right_left1","right_left")
'			End If
		Next

		If dbSoti Then
			
		else if DatabaseName = "301.book" Or DatabaseName = "302.book" Or DatabaseName = "303.book" Then
'			ASSAR.pageSel = 4
'			ASSAR.changepos = False
'			StartActivity(ASSAR)
			myf.SetAnimation("right_left1","right_left")
		else If bookSel = 8 Then
			StartActivity(matnha)
			myf.SetAnimation("right_left1","right_left")
		else if bookSel =4 Then
			Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'tindex'")
			If cur1.RowCount > 0 Then
				s1.ExecNonQuery("update prevTable set val = " & Value)
			Else
				s1.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& Value&")")
			End If
			Motoon.edameh = False
			StartActivity(Motoon)
			myf.SetAnimation("right_left1","right_left")
		End If
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
'		If SetData.nmode Then
'			Dim BMPA As NegativeImage
'			If imgtype Then
'				myimage.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bu3.png")))
'			Else
'				myimage.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"l3.png")))
'			End If
'		Else
			If imgtype Then
				myimage.SetBackgroundImage(LoadBitmap(File.DirAssets,"bu3.png"))
			Else
				myimage.SetBackgroundImage(LoadBitmap(File.DirAssets,"l3.png"))
			End If
'		End If
		
		clv1.Refresh
		LIV1.Left = 140%x
	Else
		cur.Close
'		If bookSel = 8 Then
			cur = s1.ExecQuery("select * from table2 where (tindex >"&idonvan&" and ttext = 1) ORDER BY tindex LIMIT 1")
'		else If bookSel = 7 Then
'			cur = s.ExecQuery("select * from table2 where (tindex >"&idonvan&" and ttext = 1) ORDER BY tindex LIMIT 1")
'		else If bookSel = 3 Then
'			cur = s.ExecQuery("select * from tf1table2 where (tindex >"&idonvan&" and ttext = 1) ORDER BY tindex LIMIT 1")
'		End If
		
		If cur.RowCount = 1 Then
			cur.Position = 0
			idonvan = cur.GetInt("tindex")
			If bookSel = 8 Then
				onvanSel = cur.GetString("ttitle")
				matnha.edameh = False
				StartActivity(matnha)
				myf.SetAnimation("right_left1","right_left")
			else if bookSel =4 Then
				Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'tindex'")
				If cur1.RowCount > 0 Then
					s1.ExecNonQuery("update prevTable set val = " & idonvan)
				Else
					s1.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& idonvan&")")
				End If
				Motoon.edameh = False
				StartActivity(Motoon)
				myf.SetAnimation("right_left1","right_left")
			End If
		End If

	End If
End Sub
Private Sub SettingB_Click
	If menu Then
		clv1.sv.SetVisibleAnimated(200,True)
'		TarjomehView = File.ReadString(File.DirInternal,"Tarjomeh").As(Int)
'		If Tarjomeh.IsInitialized Then 
'			If TarjomehView = 1 Then Tarjomeh.Checked = True Else Tarjomeh.Checked = False
'		End If
		Activity.GetView(menuIndex).SetVisibleAnimated(200,False)
		Sleep(200)
		Activity.RemoveViewAt(menuIndex)
		For i = 0 To clv1.Size-1
			clv1.GetPanel(i).Tag = 0
		Next
		clv1.Refresh
		menu = False
		If changeSetting Then
			myf.SettingApp.ExecNonQuery("update fontTable set fehrestFont ="& myf.FehrestFont & ",ArFont =" & myf.AraFont &",FrFont = "& myf.FarFont &",fehrestSize = "& myf.FehrestSize &",ArSize = "& myf.AraSize &",FrSize = "& myf.FarSize &",ArLineSpace = "& myf.ArLineSp &",FrLineSpace = "& myf.FrLineSp)
			changeSetting = False
		End If
	Else
		clv1.sv.SetVisibleAnimated(100,False)
		menuIndex = Activity.NumberOfViews
		Dim p As Panel
		p.Initialize("")
		p.LoadLayout("nMenu")
		
		Tabs.RemoveAllTabs
		Tabs.BeginUpdate
		If bookSel = 4 Then
			Tabs.AddTab(Colors.Transparent,"فونت متن",Tabs.FontToBitmap(Chr(0xF02D),False,30,SetData.TopbackColor),"")
			Tabs.AddTab(Colors.Transparent,"فونت ادعیه",Tabs.FontToBitmap(Chr(0xF02D),False,30,SetData.TopbackColor),"")
			Tabs.AddTab(Colors.Transparent,"فونت فهرست",Tabs.FontToBitmap(Chr(0xF02D),False,30,SetData.TopbackColor),"")
			Tabs.SetTab(2,True,True)
		Else
			Tabs.AddTab(Colors.Transparent,"فونت متن",Tabs.FontToBitmap(Chr(0xF02D),False,30,SetData.TopbackColor),"")
			Tabs.AddTab(Colors.Transparent,"فونت فهرست",Tabs.FontToBitmap(Chr(0xF02D),False,30,SetData.TopbackColor),"")
			Tabs.SetTab(1,True,True)
		End If
		
		Tabs_TabClick(Tabs.CurrentIndex)
		Tabs.EndUpdate
		If File.Exists(File.DirInternal,"Tarjomeh") Then
			Dim s11 As String
			s11 = File.ReadString(File.DirInternal,"Tarjomeh")
			If s11 = "1" Then
				Tarjomeh.Checked = True
			else if s11 = "0" Then
				Tarjomeh.Checked = False
			End If
		End If
		ArLineSpace.Value = myf.ArLineSp - 10
		FrLineSpace.Value = myf.FrLineSp - 10
		
		myf.setMatnfont(Label3,Label3.Width)
		myf.setOMatnfont(Label4,Label4.Width)
		myf.setFMatnfont(Label5,Label5.Width)
		
		Label3.Height = 36%y-20%x
		Label4.Height = 36%y-20%x
		Label5.Height = 36%y-20%x
		
		FrFname.Text = getFrFontName
		ArFname.Text = getArFontName
		FehrestFname.Text = getFhrestFontName
'		If bookSel = 4 Then
'			Activity.AddView(p,0,21.5%y,100%x,57%y)
'		Else
			Activity.AddView(p,0,26%y,100%x,48%y)
'		End If
		Activity.GetView(menuIndex).Left = 50%x
		Activity.GetView(menuIndex).Top = ShPanel.top
		Activity.GetView(menuIndex).Width = 0
		Activity.GetView(menuIndex).Height = 0
		Activity.GetView(menuIndex).SetLayoutAnimated(200,0,26%y,100%x,48%y)
'		Activity.GetView(menuIndex).Visible = False
'		Activity.GetView(menuIndex).SetVisibleAnimated(200,True)
		Activity.GetView(menuIndex).BringToFront
		If SetData.nmode = False Then
			Label3.Color = SetData.backColor
			Label4.Color = SetData.backColor
			Label5.Color = SetData.backColor
			Label3.TextColor = Colors.Black
			Label4.TextColor = Colors.Black
			Label5.TextColor = Colors.Black
		Else
			Label3.Color = Colors.DarkGray
			Label4.Color = Colors.DarkGray
			Label5.Color = Colors.DarkGray
			Label3.TextColor = Colors.White
			Label4.TextColor = Colors.White
			Label5.TextColor = Colors.White
		End If
		Sleep(200)
'		If mode = 0 Then Af.Checked = True
'		If mode = 1 Then Ar.Checked = True
'		If mode = 2 Then Fr.Checked = True
		menu = True
	End If
	'oldTarjomehView = TarjomehView
End Sub
Private Sub Tarjomeh_CheckedChange(Checked As Boolean)
	If Checked Then
		File.WriteString(File.DirInternal,"Tarjomeh","1")
		changeSetting = True
	Else
		File.WriteString(File.DirInternal,"Tarjomeh","0")
		changeSetting = True
	End If
End Sub
Private Sub Tabs_TabClick(index As Int)
	If bookSel = 4 Then
		If index = 0 Then
			Panel2.Visible = True
			Panel1.Visible = False
			Panel5.Visible = False
		Else if index = 2  Then
			Panel5.Visible = True
			Panel1.Visible = False
			Panel2.Visible = False
		Else if index = 1 Then
			Panel1.Visible = True
			Panel2.Visible = False
			Panel5.Visible = False
		End If
	Else
		If index = 0 Then
			Panel2.Visible = True
			Panel1.Visible = False
			Panel5.Visible = False
		Else if index = 1  Then
			Panel5.Visible = True
			Panel1.Visible = False
			Panel2.Visible = False
		End If
	End If

	If bookSel = 4 Then
		Panel3.Visible = False'true
		Panel4.Height = 48%y'57%y
	Else
		Panel3.Visible = False
		Panel4.Height = 48%y
	End If

	For Each v As B4XView In Tabs.BaseView.GetAllViewsRecursive
		If v Is Label Then
			Dim l1 As Label = v
			l1.Typeface = Typeface.LoadFromAssets("Vazirmatn-Light.ttf")
			l1.TextSize = 16
			l1.Top = Tabs.BaseView.Height / 2 - l1.Height / 2 - 5dip
'			Log("l1top="&l1.Height)
		else if v Is Panel And (v.Width < 2%x Or v.Height < 2%x) Then
'			v.Color = 0xFFDFAE7C
			If v.Height < 2%x Then v.Top = v.Top+5dip
		End If
	Next
End Sub
Sub getFhrestFontName As String
	Select myf.FehrestFont
		Case 1
			Return "وزیر"
		Case 2
			Return "وزیر درشت"
		Case 3
			Return "زر"
		Case 4
			Return "زر درشت"
		Case 5
			Return "میترا"
		Case 6
			Return "میترا درشت"
		Case 7
			Return "نازنین"
		Case 8
			Return "نازنین درشت"
		Case 9
			Return "نسخ"
		Case 10
			Return "نسخ درشت"
		Case Else
			Log("Larger than 10")
			Return ""
	End Select
End Sub


Sub getFrFontName As String
	Select myf.FarFont
		Case 1
			Return "وزیر"
		Case 2
			Return "وزیر درشت"
		Case 3
			Return "زر"
		Case 4
			Return "زر درشت"
		Case 5
			Return "میترا"
		Case 6
			Return "میترا درشت"
		Case 7
			Return "نازنین"
		Case 8
			Return "نازنین درشت"
		Case 9
			Return "نسخ"
		Case 10
			Return "نسخ درشت"
		Case Else
			Log("Larger than 10")
			Return ""
	End Select
End Sub
Sub getArFontName As String
	Select myf.AraFont
		Case 1
			Return "عزیز"
		Case 2
			Return "عزیز درشت"
		Case 3
			Return "بدر"
		Case 4
			Return "بدر درشت"
		Case 5
			Return "لوتوس"
		Case 6
			Return "لوتوس درشت"
		Case 7
			Return "میترا"
		Case 8
			Return "میترا درشت"
		Case 9
			Return "نازنین"
		Case 10
			Return "نازنین درشت"
		Case 11
			Return "نسخ قرآنی"
		Case 12
			Return "طه"
		Case 13
			Return "نسخ"
		Case 14
			Return "نسخ درشت"
		Case Else
			Return ""
			Log("Larger than 14")
	End Select
End Sub

Sub prevFehrest_Click
	If myf.FehrestFont > 1 Then
		myf.FehrestFont = myf.FehrestFont - 1
		myf.setFMatnfont(Label5,Label5.Width)
		Label5.Height = 36%y-20%x
		FehrestFname.Text = getFhrestFontName
		changeSetting = True
	End If
End Sub
Sub PrevFarsi_Click
	If myf.FarFont > 1 Then
		myf.FarFont = myf.FarFont - 1
		myf.setOMatnfont(Label4,Label4.Width)
		Label4.Height = 36%y-20%x
		FrFname.Text = getFrFontName
		changeSetting = True
	End If
End Sub

Sub PrevArabi_Click
	If myf.AraFont > 1 Then
		myf.AraFont = myf.AraFont - 1
'		If myf.AraFont = 3 Then myf.AraFont = 2
		myf.setMatnfont(Label3,Label3.Width)
		Label3.Height  = 36%y-20%x
		ArFname.Text = getArFontName
		changeSetting = True
	End If
End Sub

Sub nextFehrest_Click
	If myf.FehrestFont < 10 Then
		myf.FehrestFont = myf.FehrestFont + 1
		myf.setFMatnfont(Label5,Label5.Width)
		Label5.Height = 36%y-20%x
		FehrestFname.Text = getFhrestFontName
		changeSetting = True
	End If
End Sub
Sub NextFarsi_Click
	If myf.FarFont < 10 Then
		myf.FarFont = myf.FarFont + 1
		myf.setOMatnfont(Label4,Label4.Width)
		Label4.Height = 36%y-20%x
		FrFname.Text = getFrFontName
		changeSetting = True
	End If
End Sub

Sub NextArabi_Click
	If myf.AraFont < 14 Then
		myf.AraFont = myf.AraFont + 1
'		If myf.AraFont = 3 Then myf.AraFont = 4
		myf.setMatnfont(Label3,Label3.Width)
		Label3.Height  = 36%y-20%x
		ArFname.Text = getArFontName
		changeSetting = True
	End If
End Sub


Sub Fehrestpp_Click
	If myf.FehrestSize < 48 Then
		myf.FehrestSize= myf.FehrestSize+1
		myf.setFMatnfont(Label5,Label5.Width)
		fehrestLbl.Text = myf.FehrestSize.As(Int)
		Label5.Height = 36%y-20%x
		changeSetting = True
	End If
End Sub

Sub Fehrestmm_Click
	If myf.FehrestSize > 18 Then
		myf.FehrestSize= myf.FehrestSize-1
		myf.setFMatnfont(Label5,Label5.Width)
		fehrestLbl.Text = myf.FehrestSize.As(Int)
		Label5.Height = 36%y-20%x
		changeSetting = True
	End If
End Sub

Sub FRpp_Click
	If myf.FarSize < 48 Then
		myf.FarSize= myf.FarSize+1
		myf.setOMatnfont(Label4,Label4.Width)
		frLbl.Text = myf.FarSize.As(Int)
		Label4.Height = 36%y-20%x
		changeSetting = True
	End If
End Sub

Sub FRmm_Click
	If myf.FarSize > 18 Then
		myf.FarSize = myf.FarSize-1
		myf.setOMatnfont(Label4,Label4.Width)
		frLbl.Text = myf.FarSize.As(Int)
		Label4.Height = 36%y-20%x
		changeSetting = True
	End If
End Sub

Sub FrLineSpace_ValueChanged (Value As Int, UserChanged As Boolean)
	If UserChanged Then
		myf.FrLineSp = 10+Value
		myf.setOMatnfont(Label4,Label4.Width)
		Label4.Height = 36%y-20%x
		changeSetting = True
	End If
End Sub

Sub ARpp_Click
	If myf.AraSize < 48 Then
		myf.AraSize = myf.AraSize+1
		myf.setMatnfont(Label3,Label3.Width)
		araLbl.Text = myf.AraSize.As(Int)
		Label3.Height  = 36%y-20%x
		changeSetting = True
	End If
End Sub

Sub ARmm_Click
	If myf.AraSize > 20 Then
		myf.AraSize = myf.AraSize-1
		myf.setMatnfont(Label3,Label3.Width)
		araLbl.Text = myf.AraSize.As(Int)
		Label3.Height  = 36%y-20%x
		changeSetting = True
	End If
End Sub

Sub ArLineSpace_ValueChanged (Value As Int, UserChanged As Boolean)
	If UserChanged Then
		myf.ArLineSp = 10+Value
		myf.setMatnfont(Label3,Label3.Width)
		Label3.Height  = 36%y-20%x
		changeSetting = True
	End If
End Sub