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
	Dim searchStr As String
	Private xui As XUI
	Dim tindex() As Int
	Dim ttitle() As String
	Dim tiSel As Int
	Dim toastTm As Timer
	Dim startSearch As Boolean
	Dim s1 As SQL
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
	Dim booksel As Int
	Dim SetData As AppSetting
	Private sCount As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	myf.Loading(SetData)
	Activity.LoadLayout("SearchL")
	
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
	toastTm.Initialize("toastTm",1000)
	Dim path As String = File.ReadString(File.DirInternalCache,"bookAddr.txt")
	Dim DatabaseName As String = File.ReadString(File.DirInternalCache,"booksel.txt")
	booksel = File.ReadString(File.DirInternalCache,"booktype.txt")
	myf.DatabesOpen(s1,path,DatabaseName,False)
'	cur = s1.ExecQuery("select val from prevTable where name = 'booknum'")
'	cur.Position = 0
'	booksel = cur.GetInt2(0)
'	If booksel = 4 Then NJ.Checked = True
'	If booksel = 8 Then TQ.Checked = True
'	If booksel = 3 Then EM.Checked = True
'	cur.Close
	LIV1.IndicatorId = 17
	LIV1.IndicatorColor = Colors.Gray
'	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
	pnl1.Color = SetData.TopbackColor
'	cvs.Initialize(pnl1)
	'myf.loadThemes(cvs,SetData.nmode,SetData)
	If startSearch Then
		EditText1.Text = searchStr
		Button2_click
	End If
	NightOrDayModeSel
	Dim jo As JavaObject = EditText1
	jo.RunMethod("setImeOptions",Array As Object(3))
	EditText1.HintColor = 0xfff1e9d5
End Sub
Sub EditText1_EnterPressed
	If Button2.Enabled Then
		Button2.Enabled = False
		Button2_click
	End If
End Sub
Sub NJ_CheckedChange(Checked As Boolean)
	If Not(booksel = 4) Then
		booksel = 4
		Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'booknum'")
		If cur1.RowCount > 0 Then
			s1.ExecNonQuery("update prevTable set val = 4  where name = 'booknum'")
		Else
			s1.ExecNonQuery("insert into prevTable VALUES(4,'booknum',4)")
		End If
		
	End If
End Sub
Sub TQ_CheckedChange(Checked As Boolean)
	If Not(booksel = 8) Then
		booksel = 8
		Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'booknum'")
		If cur1.RowCount > 0 Then
			s1.ExecNonQuery("update prevTable set val = 8  where name = 'booknum'")
		Else
			s1.ExecNonQuery("insert into prevTable VALUES(8,'booknum',8)")
		End If
	End If
End Sub
'Sub EM_CheckedChange(Checked As Boolean)
'	If Not(booksel = 3) Then
'		booksel = 3
'		Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'booknum'")
'		If cur1.RowCount > 0 Then
'			s1.ExecNonQuery("update prevTable set val = 3  where name = 'booknum'")
'		Else
'			s1.ExecNonQuery("insert into prevTable VALUES(3,'booknum',3)")
'		End If
'	End If
'End Sub
Sub NightOrDayModeSel
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
	Button2.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
	If SetData.nmode = False Then
		Activity.Color = SetData.backColor
		sCount.TextColor =  0xFF021c1a
	Else
		Activity.Color = 0x002223
		sCount.TextColor = Colors.White
	End If
'	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
	'myf.loadThemes(cvs,SetData.nmode,SetData)
End Sub
Sub NightM_Click
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
	If SetData.nmode Then
		SetData.nmode = False
		Activity.Color = SetData.backColor
	Else
		SetData.nmode = True
		Activity.Color = 0x002223
	End If
'	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
	'myf.loadThemes(cvs,SetData.nmode,SetData)
End Sub
'Sub EditText1_TextChanged(old As String,new As String)
'	onvanha.search = False
'	If  EditText1.Text.Length > 1 Then
'		myf.DatabesCopy(s1,"a.dat",True)
'		searchStr = EditText1.Text
'		
'		searchStr = searchStr.Replace("ی","ي")
'		searchStr = searchStr.Replace("ى","ي")
'		searchStr = searchStr.Replace("ك","ک")
'		searchStr = searchStr.Replace("إ","ا")
'		searchStr = searchStr.Replace("أ","ا")
'		
'		searchStr = searchStr.Replace("۱","1")
'		searchStr = searchStr.Replace("۲","2")
'		searchStr = searchStr.Replace("۳","3")
'		searchStr = searchStr.Replace("۴","4")
'		searchStr = searchStr.Replace("۵","5")
'		searchStr = searchStr.Replace("۶","6")
'		searchStr = searchStr.Replace("۷","7")
'		searchStr = searchStr.Replace("۸","8")
'		searchStr = searchStr.Replace("۹","9")
'		searchStr = searchStr.Replace("۰","0")
'		
'		cur=s1.ExecQuery("SELECT * FROM table2 WHERE (ttitle1 LIKE '%"&searchStr&"%' and ttext = 1)")
'		clv1.Clear
'		cur.Position=0
'		Dim tindex(cur.RowCount) As Int
'		Dim ttitle(cur.RowCount) As String
'		For i =0 To cur.RowCount-1
'			cur.Position=i
'			tindex(i) = cur.GetInt("tindex")
'			ttitle(i)  = cur.GetString("ttitle")
'			Dim p As B4XView = xui.CreatePanel("")
'			Activity.AddView(p, 0, 0,100%x,2%y)
'			p.Tag = 0
'			p.RemoveViewFromParent
'			clv1.InsertAt(i,p,$"${tindex(i)}"$)
'		Next
'		cur.Close
'	End If
'End Sub
Sub Button2_click
	Button2.Enabled = False
	If  EditText1.Text.Length > 2 Then
		LIV1.Left = 40%x
		LIV1.RequestFocus()
		Sleep(100)
		Dim ime2 As IME
		ime2.Initialize("")
		ime2.HideKeyboard
		'myf.DatabesCopy(s1,"a.dat",True)
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
		'cur=s1.ExecQuery("SELECT *  FROM table3 WHERE " & searchQuary &" LIKE '%%%"&searchStr&"%%'")
		If booksel = 2 Then
			cur=s1.ExecQuery("select * from table2 where tindex IN(SELECT tindex FROM tftable3 WHERE ttext1 LIKE '%%%"&searchStr&"%%')")
		Else If booksel = 3 Then
			cur=s1.ExecQuery("select * from tf1table2 where tindex IN(SELECT tindex FROM tf1table3 WHERE ttext1 LIKE '%%%"&searchStr&"%%')")
		Else If booksel = 4 Then
			cur=s1.ExecQuery("select * from table2 where tindex IN(SELECT tindex FROM Ntable3 WHERE ttext1 LIKE '%%%"&searchStr&"%%')")
		Else If booksel = 8 Then
			cur=s1.ExecQuery("select * from table2 where tindex IN(SELECT tindex FROM table3 WHERE ttext1 LIKE '%%%"&searchStr&"%%')")'&"%%' or fttext1 LIKE '%%%"&searchStr&"%%')")
		End If
		
		clv1.Clear
		cur.Position=0
		Dim tindex(cur.RowCount) As Int
		Dim ttitle(cur.RowCount) As String
		For i =0 To cur.RowCount-1
			cur.Position=i
'			Dim idx As Int =  cur.GetInt("tindex")
'			cur1 = s1.ExecQuery("select * from table2 where tindex =" & idx)
'			cur1.Position=0
			tindex(i) = cur.GetInt("tindex")
			If booksel = 2 Then
				ttitle(i)  = cur.GetString("tfttitle")
			End If
			If booksel = 3 Then
				ttitle(i)  = cur.GetString("ttitle")
			End If
			If booksel = 4 Then
				ttitle(i)  = cur.GetString("ttitle")
			End If
			If booksel = 8 Then
				ttitle(i)  = cur.GetString("ttitle")
			End If
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
		sCount.Text = cur.RowCount & " عنوان یافت شد"
	Else
		sCount.Text = "متن جستجو باید بیش از دو کاراکتر باشد"
	End If
	Button2.Enabled = True
End Sub
Sub clv1_ScrollChanged(Position As Int)
'	If DJP.Visible Then DJP.SetVisibleAnimated(313,False)
'	Dim ime2 As IME
'	ime2.Initialize("")
'	ime2.HideKeyboard
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
	myf.setFrMatnfont(tmpl,94%x-5%x)
	Dim p As B4XView = xui.CreatePanel("")
	p.Left = 0
	p.Top = 0
	p.Width = clv1.sv.Width
	p.Height = tmpl.Height'*1.2
	p.LoadLayout("CellItem")
	If i Mod 2 = 0 Then
		If SetData.nmode Then p.Color = 0x0Affffff Else p.Color = 0xfff1ebda'0xfff7f0df
	Else
		If SetData.nmode Then p.Color = 0x05ffffff Else p.Color = 0xfffdf8e5
	End If
	ttitle(i) = ttitle(i).Replace("أ","أ")
	myf.Rangbandi(Label1cel,ttitle(i),False,0,True,SetData)
	If SetData.nmode Then Label1cel.TextColor = Colors.White Else Label1cel.TextColor = 0xFF021c1a'1b1448'Colors.Black
	Label1cel.Left = 5%x
	Label1cel.Top = 0
	myf.setFrMatnfont(Label1cel,clv1.AsView.Width-10%x)
	p.Tag = 1
	clv1.ReplaceAt(i,p,tmpl.Height,$"${ii}"$)'clv1.ReplaceAt(i,p,tmpl.Height*1.2,$"${ii}"$)
End Sub

Sub clv1_ItemClick(Index As Int, Value As Object)
	If booksel = 4 Then
		Dim labelA As Label
		labelA = clv1.GetPanel(Index).GetView(0)
		onvanha.onvanSel = labelA.Text
		onvanha.idonvan = Value
		File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
		Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'tindex'")
		If cur1.RowCount > 0 Then
			s1.ExecNonQuery("update prevTable set val = " & Value)
		Else
			s1.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& Value&")")
		End If
		If Index Mod 2 = 0 Then
			If SetData.nmode Then clv1.GetPanel(Index).Color = 0x22888888 Else clv1.GetPanel(Index).Color = 0x11000000
		End If
		tiSel = Index
		Motoon.edameh = False
		Motoon.nextOnvan = False
		Motoon.prevOnvan = False
		onvanha.search = True
		StartActivity(Motoon)
		myf.SetAnimation("task_close_enter","task_close_exit")
	Else
		Dim labelA As Label
		labelA = clv1.GetPanel(Index).GetView(0)
		onvanha.onvanSel = labelA.Text
		onvanha.idonvan = Value
		File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
		If Index Mod 2 = 0 Then
			If SetData.nmode Then clv1.GetPanel(Index).Color = 0x22888888 Else clv1.GetPanel(Index).Color = 0x11000000
		End If
		tiSel = Index
		matnha.edameh = False
		matnha.nextOnvan = False
		matnha.prevOnvan = False
		onvanha.search = True
		StartActivity(matnha)
		myf.SetAnimation("task_close_enter","task_close_exit")
	End If
End Sub
Sub Activity_Resume
	myf.Loading(SetData)
	NightOrDayModeSel
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then Activity.Finish
End Sub
Sub Activity_KeyPress(KeyCode As Int) As Boolean
'	If KeyCode = KeyCodes.KEYCODE_BACK And DJP.Visible = False Then
'		DJP.SetVisibleAnimated(313,True)
'		Return True
'	Else 
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Activity.Finish
		myf.SetAnimation("task_close_enter","task_close_exit")
	End If
	Return False
End Sub
Sub toastTm_Tick
	If DateTime.Now-LastToastTime > toastTm.Interval Then
		toastTm.Enabled = False
		ToastText.Visible = False
	End If
End Sub
Sub ToastMessageShow2(STR As String,LD As Boolean)
	ToastText.Color = SetData.backColor
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
