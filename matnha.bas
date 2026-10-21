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
'#if java
' import android.graphics.PorterDuff;
' import android.widget.SeekBar;
' public void ChangeColor(SeekBar seekbar,int Color,int Cl1)
' { 
'   seekbar.getProgressDrawable().setColorFilter(Color, PorterDuff.Mode.SRC_IN);
'   seekbar.getThumb().setColorFilter(Cl1, PorterDuff.Mode.SRC_IN);
' }
' #End If
Sub Process_Globals
	Private xui As XUI
	Dim startItem As Int
	Dim edameh As Boolean
	Dim toastTm As Timer
	Dim startTm As Timer
	Dim progressTm As Timer
	Dim prevOnvan As Boolean
	Dim nextOnvan As Boolean
	Dim klmc As Boolean
	Dim s1 As SQL
End Sub

Sub Globals
	Private GD As GestureDetector
	Dim cur As Cursor
	Private Label1 As Label
	Dim JST As TeamEightJustifyBeta
	'Dim Report As Label
'	Dim QK As Button
	Dim searching As Boolean
	Dim JSTLabel As Label
	Dim MatnStr As String
	Dim nextJustify As Boolean = True
	Dim endidx As Int = 0,startidx As Int = 0
	Private clv1 As CustomListView
	Private Label1cel,Label2cel As Label
	Private LIV1 As LoadingIndicatorView
	Dim searchPos(1000) As Int
	Dim sIdx,idxCount As Int
	Private Button3,Button4,CopyText,ShareText As Button
	Private ScrollView1 As ScrollView
	Dim EditCopy As EditText
	Dim sidxPidx As Int
	Dim LastFirstIndex As Int = 0
	Private pnl1 As Panel
	Private xui As XUI
	Private cvs As Canvas
	Private ShPanel As Panel
	Private ToastText As Label
	Dim LastToastTime As Int = 0
	Private NextB,PrevB,SearchB,NightM,AboutB,SettingB,CopyB,fpp,fmm   As Button
	Dim pvisible As Boolean = False
	Dim Mark As Boolean
	Dim refreshView As Boolean = False
	Private pos1 As SeekBar
	Dim booksel As Int
	Private mlongclick As Panel
	Private pnesh,pcopy As Button
	Private LtoR,RtoL As ImageView
	Dim x0,x1,y0,y1,xDrag,yDrag As Int
	Dim endTouch As Boolean = True
	Dim SetData As AppSetting
	
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
	Private topPanel As Panel
End Sub

Sub Activity_Create(FirstTime As Boolean)
	myf.Loading(SetData)
	s1.Close
	onvanha.idonvan = File.ReadString(File.DirInternalCache,"onvanha.txt")
	Dim path As String = File.ReadString(File.DirInternalCache,"bookAddr.txt")
	Dim DatabaseName As String = File.ReadString(File.DirInternalCache,"booksel.txt")
	booksel = File.ReadString(File.DirInternalCache,"booktype.txt")
	myf.DatabesOpen(s1,path,DatabaseName,False)
	
'	If myf.noCache = False Then
'		If File.Exists(File.DirInternalCache,"idonvan.txt") Then
'			edameh = True
'			search = False
'			onvanha.idonvan = File.ReadString(File.DirInternalCache,"idonvan.txt")
'			myf.onvanSel = File.ReadString(File.DirInternalCache,"onvanSel.txt")
'		End If
'		If File.Exists(File.DirInternalCache,"startItem.txt") Then
'			s1tartItem = File.ReadString(File.DirInternalCache,"startItem.txt")
'			edameh = True
'		End If
'		myf.noCache = True
'	End If
	If refreshView = False Then
		Activity.LoadLayout("l_matnha")
		topPanel.Color = SetData.TopbackColor
		If SetData.nmode Then Activity.Color = 0x0Affffff Else Activity.Color = 0xfff1ebda'0xfff7f0df
		SettingB.Visible = False
		ShPanel.Visible = True
		Activity.LoadLayout("mlongclick")
		mlongclick.Visible = False
		CallSubDelayed(Me,"QK_Click")
		EditCopy.Initialize("EditCopy")
		EditCopy.Gravity = Gravity.TOP
		EditCopy.Padding = Array As Int (5%x,5%x,5%x,5%x)
		GD.SetOnGestureListener(clv1.sv, "Gesture")
		Dim jo = EditCopy As JavaObject
		jo.RunMethod("setCursorVisible",Array As Object(True))
		jo.RunMethod("setTextIsSelectable",Array As Object(True))
		ScrollView1.Panel.AddView(EditCopy,0,0,ScrollView1.Width,ScrollView1.Height)
		toastTm.Initialize("toastTm",1000)
		startTm.Initialize("StartTm",20)
		progressTm.Initialize("progressTm",2000)
		LIV1.IndicatorId = 17
		LIV1.IndicatorColor = Colors.Gray
		NightOrDayModeSel
		ScrollView1.Visible = False
		
		JSTLabel.Width = 90%x
		JSTLabel.Height = 76%y
		myf.setBMatnfont(JSTLabel,clv1.sv.Width-7%x)

'		myf.setTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
		cvs.Initialize(pnl1)
'		myf.loadThemes(cvs,SetData.nmode,SetData)
		'myf.DatabesCopy(s1,"a.dat",True)
		Button3.Visible = True
		Button4.Visible = True
		clv1.Base_Resize(clv1.AsView.Width,100%y-16.5%y)'(46*100%x/642+10%x+7*100%x/642)-8%y)'-23*100%x/642-(46*100%x/642+10%x+7*100%x/642))
'		Label1.TextSize=20
'		Label1.Typeface=Typeface.LoadFromAssets("aNaskhB.ttf")
'		Dim r As Reflector
'		r.Target = clv1.sv
'		r.RunMethod2("setVerticalScrollBarEnabled",False,"java.lang.boolean")
		Dim jo = clv1.sv As JavaObject
		jo.RunMethod("setVerticalScrollbarPosition", Array As Object (1))   ' position left
'		Private r1 As Reflector
'		r1.Target = clv1.sv
'		r1.SetOnTouchListener("Clv1Touch")
		
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
'		clv1.sv.Left = 5dip
'		clv1.sv.Width = 100%x - 10dip
'		r.RunMethod4("setVerticalThumbDrawable", Array(cd), Array As String("android.graphics.drawable.Drawable"))
		pos1.Visible = False
		Dim x As B4XView = pos1
		x.Rotation = 90
		pos1.Width = 100%y -(46*100%x/642+10%x+7*100%x/642)-6%y'clv1.AsView.Height - 10%x
'		Dim jo As JavaObject
'		jo.InitializeContext
'		jo.RunMethod("ChangeColor",Array As Object(0xff1B1448,0xffc4a263))'Colors.LightGray))
		clv1.AnimationDuration = 0
	Else
		Dim cl1,cl2  As Int
		If SetData.nmode Then
			cl1 = Colors.DarkGray
			cl2 = Colors.DarkGray
		Else
			cl1 = SetData.backColor
			cl2 = SetData.backColor
		End If
		Activity.SetColorAnimated(400,cl1,cl2)
	End If
	clv1.Clear
	
	
'	cur = s1.ExecQuery("select val from prevTable where name = 'booknum'")
'	cur.Position = 0
'	booksel = cur.GetInt2(0)


	cur=s1.ExecQuery("select tindex from marktable where tindex="&onvanha.idonvan)
	If cur.RowCount = 1 Then Mark = True Else Mark = False
	cur.Close
	
	If Mark Then
		Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark.png"))
	Else
		Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark-outline.png"))
	End If
	Button4.SetBackgroundImage(LoadBitmap(File.DirAssets,"book.png"))

	LIV1.Left = 140%x

	If booksel = 8 Then
		cur=s1.ExecQuery("select replace(ttext,'أ','أ') from table3 where tindex="&onvanha.idonvan)
	else If booksel = 2 Then
		cur=s1.ExecQuery("select replace(ttext,'أ','أ') from tftable3 where tindex="&onvanha.idonvan)
	else If booksel = 3 Then
		cur=s1.ExecQuery("select replace(ttext,'أ','أ') from tf1table3 where tindex="&onvanha.idonvan)
	End If
	Log(onvanha.idonvan)
	cur.Position=0
	MatnStr = cur.GetString2(0)
	cur.Close
	LastFirstIndex = 0
	searching = False
	insert_Items_to_clv
	
	If onvanha.search Then
		If booksel = 8 Then
			cur=s1.ExecQuery("select replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(ttext,'ِ','ـ'),'ٍ','ـ'),'ْ','ـ'),'ّ','ـ'),'ٌ','ـ'),'ُ','ـ'),'ً','ـ'),'َ','ـ'),'ى','ي'),'ی','ي'),'ك','ک'),'إ','ا'),'أ','اـ') from table3 where tindex="&onvanha.idonvan)
		Else If booksel = 2 Then
			cur=s1.ExecQuery("select replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(ttext,'ِ','ـ'),'ٍ','ـ'),'ْ','ـ'),'ّ','ـ'),'ٌ','ـ'),'ُ','ـ'),'ً','ـ'),'َ','ـ'),'ى','ي'),'ی','ي'),'ك','ک'),'إ','ا'),'أ','اـ') from tftable3 where tindex="&onvanha.idonvan)
		Else If booksel = 3 Then
			cur=s1.ExecQuery("select replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(ttext,'ِ','ـ'),'ٍ','ـ'),'ْ','ـ'),'ّ','ـ'),'ٌ','ـ'),'ُ','ـ'),'ً','ـ'),'َ','ـ'),'ى','ي'),'ی','ي'),'ك','ک'),'إ','ا'),'أ','اـ') from tf1table3 where tindex="&onvanha.idonvan)
		End If
		
		cur.Position = 0
		Dim FindStr As String = cur.GetString2(0)
		cur.Close
		idxCount = 0
		sIdx = 0
		For i = 0  To FindStr.Length - 1
			Dim find As Boolean = False
			Dim ch As Char = FindStr.CharAt(i)
			If ch = SearchM.searchStr.CharAt(0) Then
				Dim ii As Int = 1
				Dim jj As Int = 1
				Do While Not(find)
					If i+ii = FindStr.Length Then Exit
					If FindStr.CharAt(i+ii) = "ـ" Then
						ii = ii + 1
					Else If FindStr.CharAt(i+ii) = SearchM.searchStr.CharAt(jj) Then
						ii = ii + 1
						jj = jj + 1
						If jj = SearchM.searchStr.Length Then
							find = True
							searchPos(idxCount) = i
							idxCount = idxCount+1
							i = i+ii
							Exit
						End If
					Else
						Exit
					End If
				Loop
			End If
		Next
		sIdx = 0
		sidxPidx = 0
		If prevOnvan Then sIdx = idxCount-1
		nextOnvan = False
		prevOnvan = False
		For i = 0 To clv1.Size-1
			Dim endP As Int
			If i = clv1.Size-1 Then
				endP = MatnStr.Length
			Else
				endP = clv1.GetValue(i+1)-1
			End If
		
			If searchPos(sIdx) >= clv1.GetValue(i) And searchPos(sIdx) < endP Then
				sidxPidx = i
				clv1.GetPanel(i).Tag = 0
				Exit
			End If
		Next
		If edameh = False Then
			searching = True
			LastFirstIndex = sidxPidx
			clv1.JumpToItem(sidxPidx)
			ToastMessageShow2("مورد "&(sIdx+1) &" از " & idxCount,False)
		End If
		
	Else if edameh = False Then
		clv1.JumpToItem(0)
	End If

	Label1.Text=onvanha.onvanSel
	Label1.Top = 46*100%x/642 + 5%x + 3.5*100%x/642 - Label1.Height/2
	Label1.Width = 80%x-46*100%x/642
	Label1.Left = 10%x+23*100%x/642
	Label1.TextColor = 0xffc4a263
	startTm.Enabled = True
	
	
	CopyText.SetBackgroundImage(LoadBitmap(File.DirAssets,"content-copy.png"))
	If onvanha.search Then
		SearchB.SetBackgroundImage(LoadBitmap(File.DirAssets,"Stopsearch.png"))
	Else
		SearchB.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
	End If
	CopyB.SetBackgroundImage(LoadBitmap(File.DirAssets,"content-copy.png"))
	SettingB.SetBackgroundImage(LoadBitmap(File.DirAssets,"settings-applications.png"))
	ShareText.SetBackgroundImage(LoadBitmap(File.DirAssets,"share.png"))
	AboutB.SetBackgroundImage(LoadBitmap(File.DirAssets,"about.png"))
	Button4.SetBackgroundImage(LoadBitmap(File.DirAssets,"book.png"))
	NextB.SetBackgroundImage(LoadBitmap(File.DirAssets,"keyboard-arrow-left.png"))
	PrevB.SetBackgroundImage(LoadBitmap(File.DirAssets,"keyboard-arrow-right.png"))

	ShPanel.Color = SetData.TopbackColor
	NextB.Visible = True
	PrevB.Visible = True
End Sub
Sub Gesture_onTouch(Action As Int, X As Float, Y As Float, MotionEvent As Object) As Boolean
'	''''log("onTouch action=" & Action & ", x=" & X & ", y=" & Y & ", ev=" & MotionEvent)
	Select Action
		Case Activity.ACTION_MOVE
'			''''log("ACTION_MOVE")
			If x0 = 0 And y0 = 0 Then
				x0 = X
				y0 = Y
				xDrag = 0
				yDrag = 0
			Else
				xDrag = X-x0
				yDrag = Y-y0
'				If yDrag < 0 Then yDrag = -yDrag
'				''''log(xDrag)
				If yDrag < 0 Then
					If yDrag > -15%y And xDrag > 0 Then
						LtoR.Left = -50%x + xDrag
					Else
						RtoL.Left = 100%x + xDrag
					End If
				Else
					If yDrag < 15%y And xDrag > 0 Then
						LtoR.Left = -50%x + xDrag
					Else
						RtoL.Left = 100%x + xDrag
					End If
				End If

			End If
		Case Activity.ACTION_UP
'			''''log("ACTION_UP")
			RtoL.Left = 100%x
			LtoR.Left = -50%x
			If yDrag < 0 Then yDrag = -yDrag
'			''''log(yDrag)
			If yDrag < 15%y And xDrag >  25%x Then Nextb_Click
			If yDrag < 15%y And xDrag < -25%x Then Prevb_Click
			x0 = 0
			y0 = 0
			
	End Select
	Return False
End Sub
'Private Sub Clv1Touch(Viewtag As Object, Action As Int, X As Float, Y As Float, MotionEvent As Object) As Boolean
'	Select Action
'		Case Activity.ACTION_DOWN
''			Log("DOWN")
'			If endTouch Then
'				x0 = X
'				y0 = Y
'				xDrag = 0
'				yDrag = 0
'				Log(x0)
'				endTouch = False
'			End If
'		Case Activity.ACTION_MOVE
''			Log("MOVE")
'			If endTouch Then
'				x0 = X
'				y0 = Y
'				xDrag = 0
'				yDrag = 0
''				Log(x0)
'				endTouch = False
'			Else
'				xDrag = X-x0
'				yDrag = Y-y0
'				If yDrag < 0 Then yDrag = -yDrag
'			End If
''			Log(xDrag)
''			Log(yDrag)
''			If yDrag < 10%y Then
'			If xDrag > 0 Then
'				LtoR.Left = -50%x + xDrag
'			Else
'				RtoL.Left = 100%x + xDrag
'			End If
''			End If
'		Case Activity.ACTION_UP
''			Log("UP")
'			endTouch = True
'			RtoL.Left = 100%x
'			LtoR.Left = -50%x
'			If yDrag < 20%y And xDrag >  14%x Then Nextb_Click
'			If yDrag < 20%y And xDrag < -14%x Then Prevb_Click
'	End Select
'	Return False
'End Sub

Sub pcopy_Click
	mlongclick.SetVisibleAnimated(313,False)
	CopyB_Click
End Sub
Sub pshar_Click
	Dim i1 As Intent
	i1.Initialize(i1.ACTION_SEND, "")
	i1.SetType("text/plain")
	i1.PutExtra("android.intent.extra.TEXT", MatnStr)
	i1.WrapAsIntentChooser("اشتراک گذاري مطلب با...")
	StartActivity(i1)
End Sub
Sub pnesh_Click
	mlongclick.SetVisibleAnimated(313,False)
	Dim v As View
	v = Sender
	If v.Tag >= 0 Then
		Dim endT As Int = clv1.GetPanel(v.tag).GetView(0).Text.IndexOf2(CRLF,0)
		If endT <= 0 Then endT = clv1.GetPanel(v.tag).GetView(0).Text.Length
		If booksel = 8 Then
			cur  = s1.ExecQuery("select * from NeshanehTable where (idonvan =" & onvanha.idonvan &" and ItemNumber="&v.Tag & ")")
		Else
			cur  = s1.ExecQuery("select * from NeshanehTable where (idonvan =" & onvanha.idonvan &" and ItemNumber="&v.Tag&" and bookidx="&booksel & ")")
		End If
		
	
		If cur.RowCount > 0 Then
			'				clv1.GetPanel(v.Tag).Color = Colors.Transparent
			'				s1.ExecNonQuery("delete from NeshanehTable where (ItemNumber=" & v.Tag & " and idonvan=" & onvanha.idonvan &")")
			'				ToastMessageShow2("نشانه انتخابی حذف شد",False)
		Else
			If SetData.nmode Then clv1.GetPanel(v.Tag).Color = Bit.Xor(0x30000000,0x00ffffff) Else clv1.GetPanel(v.Tag).Color = 0x30000000
			If booksel = 8 Then
				s1.ExecNonQuery("insert into NeshanehTable VALUES(" & onvanha.idonvan & ",'" & clv1.GetPanel(v.tag).GetView(0).Text.SubString2(0,endT) & "',"& v.tag &")")
			Else
				s1.ExecNonQuery("insert into NeshanehTable VALUES(" & onvanha.idonvan & ",'" & clv1.GetPanel(v.tag).GetView(0).Text.SubString2(0,endT) & "',"& v.tag &","& booksel&")")
			End If
			If Not(Mark) Then
				Mark = True
				If booksel = 8 Then
					s1.ExecNonQuery("insert into marktable VALUES(" & onvanha.idonvan &")")
				Else
					s1.ExecNonQuery("insert into marktable VALUES(" & onvanha.idonvan &","& booksel & ")")
				End If
				Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark.png"))
			End If
			ToastMessageShow2("نشانه افزوده شد",False)
		End If
		cur.Close
	End If
End Sub
Sub FPP_Click
	If myf.FarSize < 48 Then
		myf.FarSize= myf.FarSize+1
		myf.setBMatnfont(JSTLabel,clv1.sv.Width-7%x)
		For i = 0 To clv1.Size-1
			clv1.GetPanel(i).Tag = 0
		Next
		clv1.Refresh
		myf.SettingApp.ExecNonQuery("update fontTable set fehrestFont ="& myf.FehrestFont & ",ArFont =" & myf.AraFont &",FrFont = "& myf.FarFont &",fehrestSize = "& myf.FehrestSize &",ArSize = "& myf.AraSize &",FrSize = "& myf.FarSize &",ArLineSpace = "& myf.ArLineSp &",FrLineSpace = "& myf.FrLineSp)
	Else
		fpp.Visible = False
	End If
	If myf.FarSize > 18 Then fmm.Visible = True
End Sub
Sub fmm_Click
	If myf.FarSize > 18 Then
		myf.FarSize = myf.FarSize-1
		myf.setBMatnfont(JSTLabel,clv1.sv.Width-7%x)
		pos1.Max = clv1.sv.ScrollViewContentHeight - 85%y'clv1.sv.Height
		For i = 0 To clv1.Size-1
			clv1.GetPanel(i).Tag = 0
		Next
		clv1.Refresh
		myf.SettingApp.ExecNonQuery("update fontTable set fehrestFont ="& myf.FehrestFont & ",ArFont =" & myf.AraFont &",FrFont = "& myf.FarFont &",fehrestSize = "& myf.FehrestSize &",ArSize = "& myf.AraSize &",FrSize = "& myf.FarSize &",ArLineSpace = "& myf.ArLineSp &",FrLineSpace = "& myf.FrLineSp)
	Else
		fmm.Visible = False
	End If
	If myf.FarSize < 48 Then fpp.Visible = True
End Sub
'Sub FPP_Click
'	If SetData.BfontSize < 48 Then
'		SetData.BfontSize = SetData.BfontSize + 3
'	Else
'		fpp.Visible = False
'	End If
'	If SetData.BfontSize > 20 Then fmm.Visible = True
'	myf.setBMatnfont(JSTLabel,clv1.sv.Width-7%x,SetData)
'	For i = 0 To clv1.Size-1
'		clv1.GetPanel(i).Tag = 0
'	Next
'	clv1.Refresh
'	pos1.Max = clv1.sv.ScrollViewContentHeight - 85%y'clv1.sv.Height
'	myf.SettingApp.ExecNonQuery("update STable set BfontSize=" & SetData.Bfontsize)
'End Sub
'Sub fmm_Click
'	If SetData.BfontSize > 20 Then
'		SetData.BfontSize = SetData.BfontSize - 3
'	Else
'		fmm.Visible = False
'	End If
'	If SetData.BfontSize < 48 Then fpp.Visible = True
'	myf.setBMatnfont(JSTLabel,clv1.sv.Width-7%x,SetData)
'	For i = 0 To clv1.Size-1
'		clv1.GetPanel(i).Tag = 0
'	Next
'	clv1.Refresh
'	pos1.Max = clv1.sv.ScrollViewContentHeight - 85%y'clv1.sv.Height
'	myf.SettingApp.ExecNonQuery("update STable set BfontSize=" & SetData.Bfontsize)
'End Sub
Sub progressTm_Tick
	pos1.Enabled = False
	progressTm.Enabled = False
End Sub
Sub pos1_ValueChanged(Value As Int, UserChanged As Boolean)
	If UserChanged Then
		progressTm.Enabled = False
		clv1.sv.ScrollViewOffsetY = Value
		'clv1.JumpToItem(Value)
		clv1.Refresh
		progressTm.Enabled = True
	End If
End Sub
Sub startTm_Tick
	If searching Then
		LastFirstIndex = sidxPidx
		clv1.JumpToItem(sidxPidx)
	End If
	clv1.Refresh
	startTm.Enabled = False
End Sub
Sub SearchB_Click
	If onvanha.search Then
		onvanha.search = False
		SearchB.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
		ToastMessageShow2("از حالت جستجو خارج شدید",False)
	Else
		Activity.Finish
		StartActivity(SearchM)
		myf.SetAnimation("task_open_enter","task_open_exit")
	End If
End Sub
'Sub SettingB_Click
'	Setting.frParent = False
'	StartActivity(Setting)
'	myf.SetAnimation("left_right","zoom_exit")
'End Sub
Sub CopyB_Click
	Dim l0,l1 As Int
	l0 = clv1.GetValue(LastFirstIndex)
	If l0+3000 < MatnStr.Length Then
		l1 = MatnStr.IndexOf2(CRLF,l0+3000)
		If l1 <= l0 Then l1 = MatnStr.Length
	Else
		l1 = MatnStr.Length
	End If
'	Dim ari As AriaLib
'	ari.ClipboadText = MatnStr.SubString2(l0,l1)
'	ToastMessageShow2("متن در حافظه کپي شد",False)

	EditCopy.Text = MatnStr.SubString2(l0,l1)
	EditCopy.Text = EditCopy.Text.Replace(CRLF&"@",CRLF)
	EditCopy.Text = EditCopy.Text.Replace(CRLF&"@",CRLF)
	EditCopy.Text = EditCopy.Text.Replace(CRLF&"|",CRLF&"________"&CRLF)
	EditCopy.TextSize=JSTLabel.TextSize
	EditCopy.Width = ScrollView1.Width
	EditCopy.Left = 0
	EditCopy.Top = 0
	
	
	myf.setEditCopyMatnfont(EditCopy,clv1.sv.Width)
	myf.setLineSpace(EditCopy,1.5)
	If EditCopy.Height < 100%y Then
		ScrollView1.Panel.Height=100%y
		EditCopy.Height = 100%y
	Else
		ScrollView1.Panel.Height = EditCopy.Height
	End If
	ScrollView1.ScrollPosition = 0
	ScrollView1.SetVisibleAnimated(100,True)
	Button3.Visible = False
	Button4.Visible = False
	CopyText.Visible = True
	ShareText.Visible = True
	NextB.Visible = False
	PrevB.Visible = False
	Label1.Text = "انتخاب جهت کپی و اشتراک گذاری"
	ToastMessageShow2("لطفا جهت کپي، متن مورد نظر را انتخاب نمایید",False)
End Sub
Sub CopyText_Click
	Dim jo = EditCopy As JavaObject
	Dim j1 = jo.RunMethod("getSelectionStart",Null) As Int
	Dim j2 = jo.RunMethod("getSelectionEnd",Null) As Int
	Dim matnC As String
	Dim clip As BClipboard
	If j2-j1 = 0 Then matnC = EditCopy.Text Else matnC = EditCopy.Text.SubString2(j1,j2)
	clip.setText(matnC)
	ToastMessageShow2("متن در حافظه کپی شد",True)
	ScrollView1.SetVisibleAnimated(100,False)
	Button3.Visible = True
	Button4.Visible = True
	CopyText.Visible = False
	ShareText.Visible = False
	NextB.Visible = True
	PrevB.Visible = True
	Label1.Text = onvanha.onvanSel
End Sub
Sub ShareText_Click
	Dim jo = EditCopy As JavaObject
	Dim j1 = jo.RunMethod("getSelectionStart",Null) As Int
	Dim j2 = jo.RunMethod("getSelectionEnd",Null) As Int
	Dim matnC As String
	If j2-j1 = 0 Then matnC = EditCopy.Text Else matnC = EditCopy.Text.SubString2(j1,j2)
	Dim i1 As Intent
	i1.Initialize(i1.ACTION_SEND, "")
	i1.SetType("text/plain")
	i1.PutExtra("android.intent.extra.TEXT", matnC)
	i1.WrapAsIntentChooser("اشتراک گذاري مطلب با...")
	StartActivity(i1)
	ScrollView1.SetVisibleAnimated(100,False)
	Button3.Visible = True
	Button4.Visible = True
	CopyText.Visible = False
	ShareText.Visible = False
	NextB.Visible = True
	PrevB.Visible = True
	Label1.Text = onvanha.onvanSel
End Sub
Sub label1cel_Click
	pos1.Enabled = True
	progressTm.Enabled = True
	If mlongclick.Visible Then mlongclick.SetVisibleAnimated(313,False)
End Sub 
Sub Label1cel_LongClick
	Dim v As View
	v = Sender
	pnesh.Tag = v.Tag
	mlongclick.SetVisibleAnimated(313,True)
End Sub
Sub Button3_Click
	Dim b1 As Button = Button3
	Dim b1W As Int = b1.Width
	Dim b1H As Int = b1.Height
	b1.SetLayoutAnimated(150,b1.Left,b1.Top,b1W+2%x,b1H+2%x)
	Sleep(150)
	If Mark Then
		Mark = False
		If booksel = 8 Then
			s1.ExecNonQuery("delete from marktable where tindex=" & onvanha.idonvan)
		Else
			s1.ExecNonQuery("delete from marktable where tindex=" & onvanha.idonvan & " and bookidx ="& booksel)
		End If
		
		ToastMessageShow2("عنوان فعلی از فهرست منتخب حذف شد ",False)
	Else
		Mark = True
		If booksel = 8 Then
			s1.ExecNonQuery("insert into marktable VALUES(" & onvanha.idonvan &")")
		Else
			s1.ExecNonQuery("insert into marktable VALUES(" & onvanha.idonvan &","& booksel & ")")
		End If
		
		ToastMessageShow2("عنوان فعلی به فهرست منتخب افزوده شد ",False)
	End If
	If Mark Then
		Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark.png"))
	Else
		Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark-outline.png"))
	End If
	b1.SetLayoutAnimated(150,b1.Left,b1.Top,b1W,b1H)
End Sub
Sub Button4_Click
	StartActivity(NeshaneHa)
	myf.SetAnimation("task_open_enter","task_open_exit")
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
End Sub
Sub NightOrDayModeSel
	If SetData.nmode Then
		EditCopy.TextColor = Colors.White
		EditCopy.Color = Colors.Gray
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"dmode.png"))
	Else
		EditCopy.TextColor = Colors.Black
		EditCopy.Color = 0xfffff2df
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"nmode.png"))
	End If
	If SetData.nmode Then Activity.Color = 0x0Affffff Else Activity.Color = 0xfff1ebda'0xfff7f0df
End Sub
Sub NightM_Click
	If SetData.nmode Then
		SetData.nmode = False
		myf.SettingApp.ExecNonQuery("update STable set nmode = 0")
		EditCopy.Color = 0xfffff2df
		EditCopy.TextColor = Colors.Black
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"nmode.png"))
	Else
		SetData.nmode = True
		myf.SettingApp.ExecNonQuery("update STable set nmode = 1")
		EditCopy.TextColor = Colors.White
		EditCopy.Color = Colors.Gray
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"dmode.png"))
	End If
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

	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
	Dim cl1,cl2  As Int
	If SetData.nmode Then
		cl1 = Colors.DarkGray
		cl2 = Colors.DarkGray
	Else
		cl1 = SetData.backColor
		cl2 = SetData.backColor
	End If
	Activity.SetColorAnimated(400,cl1,cl2)
End Sub
Sub Label1_Click
	If ScrollView1.Visible  = False Then
		If booksel = 8 Then
			cur  = s1.ExecQuery("select * from table2 where tindex ="& onvanha.idonvan)
		else If booksel = 2 Then
			cur  = s1.ExecQuery("select * from table2 where tindex ="& onvanha.idonvan)
		else If booksel = 3 Then
			cur  = s1.ExecQuery("select * from tf1table2 where tindex ="& onvanha.idonvan)
		End If
		
		cur.Position = 0
		Dim lastLeveltidx = onvanha.idonvan As Int
		Dim level = cur.GetInt("tlevel")-1 As Int
		Dim l1 = level As Int
		Dim str1(10) As String
		Dim str2 = "" As String
		For i = 0 To 9
			str1(i) = ""
		Next
		Do While level > 0
			If booksel = 8 Then
				cur  = s1.ExecQuery("select * from table2 where (tlevel ="& level & " and tindex < " &lastLeveltidx & ") ORDER BY tindex")
			else If booksel = 2 Then
				cur  = s1.ExecQuery("select * from table2 where (tlevel ="& level & " and tindex < " &lastLeveltidx & ") ORDER BY tindex")
			else If booksel = 3 Then
				cur  = s1.ExecQuery("select * from tf1table2 where (tlevel ="& level & " and tindex < " &lastLeveltidx & ") ORDER BY tindex")
			End If
			
			cur.Position = cur.RowCount-1
			If booksel = 2 Then
				str1(level) = cur.GetString("tfttitle")
			else If booksel = 3 Or booksel = 8 Then
				str1(level) = cur.GetString("ttitle")
			End If
			
			level = level-1
			lastLeveltidx = cur.GetInt("tindex")
		Loop
		For i = 1 To l1
			str2 = str2 & str1(i) & CRLF
		Next
		str2 = str2 & Label1.Text
		
		EditCopy.Text = str2
		EditCopy.TextSize=JSTLabel.TextSize
		EditCopy.Width = ScrollView1.Width
		EditCopy.Left = 0
		EditCopy.Top = 0
				
		myf.setEditCopyMatnfont(EditCopy,clv1.sv.Width)
		myf.setLineSpace(EditCopy,1.5)
		If EditCopy.Height < 100%y Then
			ScrollView1.Panel.Height=100%y
			EditCopy.Height = 100%y
		Else
			ScrollView1.Panel.Height = EditCopy.Height
		End If
		ScrollView1.ScrollPosition = 0
		ScrollView1.SetVisibleAnimated(100,True)
		Button3.Visible = False
		Button4.Visible = False
		CopyText.Visible = True
		ShareText.Visible = True
		NextB.Visible = False
		PrevB.Visible = False
		Label1.Text = "مسیر فهرست"
	End If
End Sub
'Sub lv_ItemClick (Position As Int, Value As Object)
'	If Value = "item1" Then
'		sm.HideMenus
'		Activity.Finish
'		StartActivity(SearchM)
'	Else If Value = "item2" Then
'		sm.HideMenus
'		Setting.frParent = False
'		StartActivity(Setting)
'	Else If Value = "item3" Then
'		sm.HideMenus
'		Dim l0,l1 As Int
'		l0 = clv1.GetValue(LastFirstIndex)
'		If l0+3000 < MatnStr.Length-1 Then
'			l1 = MatnStr.IndexOf2(CRLF,l0+3000)
'			If l1 <= l0 Then l1 = MatnStr.Length-1
'		Else
'			l1 = MatnStr.Length-1
'		End If	
'		Dim Result As Int = Msgbox2("محدوده کپی متن، از پاراگراف اول که روی صفحه در حال نمایش است تا 3000 کاراکتر بعد می باشد."&CRLF&"لطفا گزینه مورد نظر را انتخاب نمایید"&CRLF&"در صورت عدم انتخاب گزینه های زیر، متن در حافظه کپی می شود","","ویرایش قبل از کپی","","اشتراک گذاری",Null)
'		If Result = DialogResponse.CANCEL Then
'			Dim ari As AriaLib
'			ari.ClipboadText = MatnStr.SubString2(l0,l1) 
'			ToastMessageShow2("متن در حافظه کپی شد",False)
'		else If Result = DialogResponse.NEGATIVE Then
'			File.Writestring(File.DirInternal,"test.txt",MatnStr.SubString2(l0,l1))
'			Dim i1 As Intent
'			i1.Initialize(i1.ACTION_SEND, "")
'			i1.SetType("text/plain")
'			i1.PutExtra("android.intent.extra.TEXT", File.ReadString(File.DirInternal,"test.txt"))
'			i1.WrapAsIntentChooser("اشتراک گذاری مطلب با...!")
'			StartActivity(i1)
'		else If Result = DialogResponse.POSITIVE Then
'		Dim l0,l1 As Int
'		l0 = clv1.GetValue(LastFirstIndex)
'		If l0+3000 < MatnStr.Length-1 Then
'			l1 = MatnStr.IndexOf2(CRLF,l0+3000)
'			If l1 <= l0 Then l1 = MatnStr.Length-1
'		Else
'			l1 = MatnStr.Length-1
'		End If	
'			EditCopy.Text = MatnStr.SubString2(l0,l1)
'			EditCopy.TextSize=JSTLabel.TextSize
'			EditCopy.Width = ScrollView1.Width
'			EditCopy.Left = 0
'			EditCopy.Top = 0
'			
'			EditCopy.Typeface=JSTLabel.Typeface
'			s1etLineSpaceEDT(EditCopy,1.5)
'			If EditCopy.Height < 100%y Then
'				ScrollView1.Panel.Height=100%y
'				EditCopy.Height = 100%y
'			Else
'				ScrollView1.Panel.Height = EditCopy.Height
'			End If
'	
'			ScrollView1.BringToFront
'			ScrollView1.ScrollPosition = 0
'			ScrollView1.SetVisibleAnimated(100,True)
'			Button1.Visible = False
'			ToastMessageShow2("حالت ویرایش فعال شد، لطفا جهت کپی متن مورد نظر را انتخاب کنید",True)		
'		End If
'	Else If Value = "item4" Then
'
'	End If
'End Sub
Sub Activity_KeyPress(KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_MEDIA_PLAY_PAUSE Then SearchB_Click
'	If KeyCode = KeyCodes.KEYCODE_MEDIA_PREVIOUS Then NightM_Click
'	If KeyCode = KeyCodes.KEYCODE_MENU Then
'		Button1_Click
'		Return True
'	End If
	
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		If mlongclick.Visible Then
			mlongclick.SetVisibleAnimated(313,False)
			Return True
		else If ScrollView1.Visible = True Then
			ScrollView1.SetVisibleAnimated(100,False)
			Button3.Visible = True
			Button4.Visible = True
			CopyText.Visible = False
			ShareText.Visible = False
			NextB.Visible = True
			PrevB.Visible = True
			Label1.Text = onvanha.onvanSel
			Return True
'		else if ShPanel.Visible = True Then
'			Button1_Click
'			Return True
		Else
			
'			cur=s1.ExecQuery("select * from Edameh")
'			If cur.RowCount = 0 Then
'				cur.Close
'				s1.ExecNonQuery("insert into Edameh VALUES(" & onvanha.idonvan &",'"& onvanha.onvanSel & "',"&LastFirstIndex&")")
'			Else
'				cur.Close
'				s1.ExecNonQuery("update Edameh set idonvan="  & onvanha.idonvan &",onvanSel='"&onvanha.onvanSel & "',ItemNumber=" &LastFirstIndex)
'			End If
			If klmc Then
				StartActivity(Main)
				myf.SetAnimation("left_right","left_right1")
			End If
			Activity.Finish
			myf.SetAnimation("left_right","left_right1")
		End If
	End If
	Return False
End Sub
'Sub Button1_Click
'	If pvisible = False Then
'		pvisible = True
'		ShPanel.Top = 100%y'-23*100%x/642
'		ShPanel.Visible = True
'		clv1.Base_Resize(clv1.AsView.Width,100%y-(46*100%x/642+10%x+7*100%x/642)-8%y)'-23*100%x/642-(46*100%x/642+10%x+7*100%x/642))
'		ShPanel.SetLayoutAnimated(313,ShPanel.Left,100%y-8%y,ShPanel.Width,ShPanel.Height)
'		Button1.Visible = False
'		NextB.Visible = False
'		PrevB.Visible = False
'		'Button1.Top = 100%y-5%y-8%y'-23*100%x/642
'		'Button1.SetVisibleAnimated(500,True)
'	Else
'		pvisible = False
'		clv1.Base_Resize(clv1.AsView.Width,100%y-(46*100%x/642+10%x+7*100%x/642)-8%y)'-23*100%x/642-(46*100%x/642+10%x+7*100%x/642))
'		ShPanel.SetLayoutAnimated(313,ShPanel.Left,100%y-5%y,ShPanel.Width,ShPanel.Height)'-23*100%x/642
'		Button1.Visible = False
''		Button1.Top = 100%y-5.5%y'-23*100%x/642
'		Button1.SetVisibleAnimated(500,True)
'		NextB.SetVisibleAnimated(500,True)
'		PrevB.SetVisibleAnimated(500,True)
'		Sleep(203)
'		ShPanel.Visible = False
'	End If
'End Sub

Sub Nextb_LongClick
	If onvanha.search Then
		If SearchM.tiSel < SearchM.tindex.Length-1 Then
			Dim Result As Int = Msgbox2("به عنوان بعد می روید؟","","بلی","خیر","",Null)
			If Result = DialogResponse.POSITIVE Then
				Try
					
					nextOnvan = True
					prevOnvan = False
					SearchM.tiSel = SearchM.tiSel+1
					onvanha.idonvan = SearchM.tindex(SearchM.tiSel)
					onvanha.onvanSel = SearchM.ttitle(SearchM.tiSel)
					File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
					onvanha.search = True
					Dim cl1,cl2  As Int
					If SetData.nmode Then
						cl1 = Colors.DarkGray
						cl2 = Colors.DarkGray
					Else
						cl1 = SetData.backColor
						cl2 = SetData.backColor
					End If
					Activity.SetColorAnimated(400,cl1,cl2)
					'Sleep(250)
					clv1.Clear
					refreshView = True
					Activity_Create(False)
					refreshView = False
'					Activity.Finish
'					'myf.AnimationFromLeft2Right
'					StartActivity(matnha1)
				Catch
					Log(LastException)
				End Try
				
			End If
		Else
			ToastMessageShow2("به آخرین عنوان رسیده اید",False)
		End If
	End If
End Sub
Sub Prevb_LongClick
	If onvanha.search Then
		If SearchM.tiSel > 0 Then
			Dim Result As Int = Msgbox2("به عنوان قبل می روید؟","","بلی","خیر","",Null)
			If Result = DialogResponse.POSITIVE Then
				Try
					nextOnvan = False
					prevOnvan = True
					SearchM.tiSel = SearchM.tiSel-1
					onvanha.idonvan = SearchM.tindex(SearchM.tiSel)
					onvanha.onvanSel = SearchM.ttitle(SearchM.tiSel)
					File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
					onvanha.search = True
					Dim cl1,cl2  As Int
					If SetData.nmode Then
						cl1 = Colors.DarkGray
						cl2 = Colors.DarkGray
					Else
						cl1 = SetData.backColor
						cl2 = SetData.backColor
					End If
					Activity.SetColorAnimated(400,cl1,cl2)
					'Sleep(250)
					clv1.Clear
					refreshView = True
					Activity_Create(False)
					refreshView = False
'					Activity.Finish
'					'myf.AnimationFromRight2Left
'					StartActivity(matnha1)
				Catch
					Log(LastException)
				End Try
			End If
		Else
			ToastMessageShow2("به اولین عنوان رسیده اید",False)
		End If
	End If
End Sub
Sub Nextb_Click
	If onvanha.search Then
		For i = 0 To clv1.Size-1
			Dim endP As Int
			If i = clv1.Size-1 Then
				endP = MatnStr.Length
			Else
				endP = clv1.GetValue(i+1)-1
			End If
			
			If searchPos(sIdx) >= clv1.GetValue(i) And searchPos(sIdx) < endP Then
				sidxPidx = i
				clv1.GetPanel(i).Tag = 0
				clv1.Refresh
				Exit
			End If
		Next
'		If ones And sIdx = 0 Then
'			sIdx = -1
'			 ones = False
'		End If
		If sIdx < idxCount-1 Then
			sIdx = sIdx + 1
			searching = True
		Else
			If SearchM.tiSel < SearchM.tindex.Length-1 Then
				Try
					nextOnvan = True
					prevOnvan = False
					SearchM.tiSel = SearchM.tiSel+1
					onvanha.idonvan = SearchM.tindex(SearchM.tiSel)
					onvanha.onvanSel =  SearchM.ttitle(SearchM.tiSel)
					File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
					onvanha.search = True
					Dim cl1,cl2  As Int
					If SetData.nmode Then
						cl1 = Colors.DarkGray
						cl2 = Colors.DarkGray
					Else
						cl1 = SetData.backColor
						cl2 = SetData.backColor
					End If
					Activity.SetColorAnimated(400,cl1,cl2)
					'Sleep(250)
					clv1.Clear
					refreshView = True
					Activity_Create(False)
					refreshView = False
'					Activity.Finish
'					'myf.AnimationFromLeft2Right
'					StartActivity(matnha1)
				Catch
					Log(LastException)
				End Try
			Else
				ToastMessageShow2("به آخرین عنوان رسیده اید",False)
			End If
		End If
		For i = 0 To clv1.Size-1
			Dim endP As Int
			If i = clv1.Size-1 Then
				endP = MatnStr.Length
			Else
				endP = clv1.GetValue(i+1)-1
			End If
			
			If searchPos(sIdx) >= clv1.GetValue(i) And searchPos(sIdx) < endP Then
				sidxPidx = i
				LastFirstIndex = sidxPidx
				clv1.JumpToItem(sidxPidx)
				clv1.GetPanel(i).Tag = 0
				clv1.Refresh
				Exit
			End If
		Next
		ToastMessageShow2("مورد "&(sIdx+1) &" از " & idxCount,False)
	Else
		If booksel = 8 Then
			cur = s1.ExecQuery("select * from table2 where (ttext = 1 and tindex > " & onvanha.idonvan & ") ORDER BY tindex")
		else If booksel = 2 Then
			cur = s1.ExecQuery("select * from table2 where (ttext = 1 and tindex > " & onvanha.idonvan & ") ORDER BY tindex")
		else If booksel = 3 Then
			cur = s1.ExecQuery("select * from tf1table2 where (ttext = 1 and tindex > " & onvanha.idonvan & ") ORDER BY tindex")
		End If
		
		
		If cur.RowCount > 0 Then
			cur.Position = 0
			onvanha.idonvan = cur.GetInt("tindex")
			File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
			If booksel = 2 Then
				onvanha.onvanSel = cur.GetString("tfttitle")
			else If booksel = 3 Or booksel = 8 Then
				onvanha.onvanSel = cur.GetString("ttitle")
			End If
			
			LastFirstIndex = 0
			Dim cl1,cl2  As Int
			If SetData.nmode Then
				cl1 = Colors.DarkGray
				cl2 = Colors.DarkGray
			Else
				cl1 = SetData.backColor
				cl2 = SetData.backColor
			End If
			Activity.SetColorAnimated(400,cl1,cl2)
			'Sleep(250)
			clv1.Clear
			refreshView = True
			Activity_Create(False)
			refreshView = False
		Else
			ToastMessageShow2("به آخرین عنوان رسیده اید",False)
		End If
		cur.Close
	End If
End Sub
Sub Prevb_Click
	If onvanha.search Then
		For i = 0 To clv1.Size-1
			Dim endP As Int
			If i = clv1.Size-1 Then
				endP = MatnStr.Length
			Else
				endP = clv1.GetValue(i+1)-1
			End If
			
			If searchPos(sIdx) >= clv1.GetValue(i) And searchPos(sIdx) < endP Then
				sidxPidx = i
				clv1.GetPanel(i).Tag = 0
				clv1.Refresh
				Exit
			End If
		Next
'		If ones And sIdx = 0 Then
'			sIdx = 1
'			ones = False
'		End If
		If sIdx > 0 Then
			sIdx = sIdx-1
			searching = True
		Else
			If SearchM.tiSel > 0 Then
				Try
					nextOnvan = False
					prevOnvan = True
					SearchM.tiSel = SearchM.tiSel-1
					onvanha.idonvan = SearchM.tindex(SearchM.tiSel)
					onvanha.onvanSel = SearchM.ttitle(SearchM.tiSel)
					File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
					onvanha.search = True
					Dim cl1,cl2  As Int
					If SetData.nmode Then
						cl1 = Colors.DarkGray
						cl2 = Colors.DarkGray
					Else
						cl1 = SetData.backColor
						cl2 = SetData.backColor
					End If
					Activity.SetColorAnimated(400,cl1,cl2)
					'Sleep(250)
					clv1.Clear
					refreshView = True
					Activity_Create(False)
					refreshView = False
'					Activity.Finish
'					'myf.AnimationFromRight2Left
'					StartActivity(matnha1)
				Catch
					Log(LastException)
				End Try
			Else
				ToastMessageShow2("به اولین عنوان رسیده اید",False)
			End If
		End If
		For i = 0 To clv1.Size-1
			Dim endP As Int
			If i = clv1.Size-1 Then
				endP = MatnStr.Length
			Else
				endP = clv1.GetValue(i+1)-1
			End If

			If searchPos(sIdx) >= clv1.GetValue(i) And searchPos(sIdx) < endP Then
				sidxPidx = i
				LastFirstIndex = sidxPidx
				clv1.JumpToItem(sidxPidx)
				clv1.GetPanel(i).Tag = 0
				clv1.Refresh
				Exit
			End If
		Next
		nextOnvan = False
		ToastMessageShow2("مورد "&(sIdx+1) &" از " & idxCount,False)
	Else
		If booksel = 8 Then
			cur = s1.ExecQuery("select * from table2 where (ttext = 1 and tindex < " & onvanha.idonvan & ") ORDER BY tindex")
		else If booksel = 2 Then
			cur = s1.ExecQuery("select * from table2 where (ttext = 1 and tindex < " & onvanha.idonvan & ") ORDER BY tindex")
		else If booksel = 3 Then
			cur = s1.ExecQuery("select * from tf1table2 where (ttext = 1 and tindex < " & onvanha.idonvan & ") ORDER BY tindex")
		End If
		
		If cur.RowCount > 0 Then
			cur.Position = cur.RowCount-1
			onvanha.idonvan = cur.GetInt("tindex")
			File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
			If booksel = 2 Then
				onvanha.onvanSel = cur.GetString("tfttitle")
			else If booksel = 3 Or booksel = 8 Then
				onvanha.onvanSel = cur.GetString("ttitle")
			End If
			LastFirstIndex = 0
			Dim cl1,cl2  As Int
			If SetData.nmode Then
				cl1 = Colors.DarkGray
				cl2 = Colors.DarkGray
			Else
				cl1 = SetData.backColor
				cl2 = SetData.backColor
			End If
			Activity.SetColorAnimated(400,cl1,cl2)
			'Sleep(250)
			clv1.Clear
			refreshView = True
			Activity_Create(False)
			refreshView = False
		Else
			ToastMessageShow2("به اولین عنوان رسیده اید",False)
		End If
		cur.Close
	End If
End Sub
'Sub clv1_ItemClick(Index As Int, Value As Object)
'	ToastMessageShow(clv1.GetPanel(Index).Tag &"-"&Index&":"&clv1.GetValue(Index), False)
'End Sub
Sub clv1_ScrollChanged(Position As Int)
	pos1.Max = clv1.sv.ScrollViewContentHeight - 85%y
	pos1.Value = clv1.sv.ScrollViewOffsetY
End Sub
Sub insert_Items_to_clv
	Dim itemnum As Int = 0
	Dim before,after As Float
	Dim Obj1 As Reflector
	Dim ht As Float
	Dim strutil As StringUtils
	
	Dim tmpL As Label
	tmpL.Initialize("")
	tmpL.Text = "بسم الله الرحمن الرحیم"&CRLF&"الحمدلله رب العالمین"
	'tmpL.Typeface = Typeface.LoadFromAssets("aNaskh.ttf")
	myf.SelectFrFont(tmpL)
	tmpL.Gravity= Bit.Or(Gravity.RIGHT,Gravity.TOP)
	tmpL.TextSize = SetData.fontSize-8
	tmpL.Width = clv1.sv.Width-7%x
	ht = strutil.MeasureMultilineTextHeight(tmpL , tmpL.Text)
	Obj1.Target = tmpL
	before = Obj1.RunMethod("getLineHeight")
	Obj1.Target = tmpL
	Obj1.RunMethod3("setLineSpacing",1, "java.lang.float", SetData.lineSpace, "java.lang.float") 'Change the space between lines
	Obj1.Target = tmpL
	after = Obj1.RunMethod("getLineHeight")
	
	nextJustify = True
	startidx = 0
	endidx = 0
	Do While nextJustify
		Dim gol As Boolean = False
		nextJustify = False
		If endidx > 0 Then startidx = endidx+1
		If startidx+1 < MatnStr.Length-1 Then
			endidx = MatnStr.IndexOf2(CRLF,startidx+1)
			nextJustify = True
		Else
			endidx = MatnStr.Length-1
			Exit
		End If
		If endidx < startidx Then
			endidx = MatnStr.Length-1
		End If
		If MatnStr.SubString2(startidx,startidx+2) = "@@" Then
			If endidx+2 <= MatnStr.Length Then
				If MatnStr.SubString2(endidx+1,endidx+2) = "@" Then
					gol = True
				Else
					endidx = MatnStr.IndexOf2(CRLF,endidx+1)
					If endidx < 0 Then endidx = MatnStr.Length - 1
				End If
			End If
			startidx = startidx + 2
		Else If MatnStr.SubString2(startidx,startidx+1) = "@" Or MatnStr.SubString2(startidx,startidx+1) = "|" Then
			gol = True
			startidx = startidx + 1
		End If
		Dim p As B4XView = xui.CreatePanel("")
		p.Tag = 0
		p.Left = 0
		p.Top = 0
		p.Width = clv1.sv.Width
		
		If gol Then
			tmpL.Text = ""
		Else
			tmpL.Text = MatnStr.SubString2(startidx,endidx-1)
		End If
		
'		Log(tmpL.Text)
		ht = strutil.MeasureMultilineTextHeight(tmpL , tmpL.Text)
		If gol Then
			p.Height = 1%x
			gol = False
		Else
			p.Height = ((after * ht)/before)
		End If
		clv1.InsertAt(itemnum,p,$"${startidx}"$)
		itemnum = itemnum+1
	Loop
End Sub
Sub CLV1_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim FirstIndex = clv1.FirstVisibleIndex , LastIndex = clv1.LastVisibleIndex As Int
	
	If edameh And FirstIndex = startItem Then
		edameh = False
		searching = False
	else If searching And  clv1.GetPanel(sidxPidx).Tag > 0 Then
		clv1.ScrollToItem(sidxPidx)
		searching = False
	End If
	
'	Dim httNotPass = True As Boolean
	For i = 0 To clv1.Size - 1
'		Dim htt As Int = 0
		Dim ExtraSize As Int = 0
		If clv1.Size > i And  i >=  Max(0, FirstIndex - ExtraSize) And i <= Min(LastIndex , clv1.Size - 1) Then
			Dim p As B4XView = xui.CreatePanel("")
			p.Left = 0
			p.Top = 0
			p.Width = clv1.sv.Width
			p.Height = clv1.GetPanel(i).Height
			If clv1.GetPanel(i).Tag = 0 Then
				Dim HighlightIndex As Int = searchPos(sIdx)-clv1.GetValue(i)
				Dim highlight As Boolean
				If sidxPidx = i And onvanha.search Then highlight = True Else highlight   = False
				p.Tag = 1
				
				p.LoadLayout("cellitemmatn")
				Dim endP As Int
				If i = clv1.Size-1 Then
					endP = MatnStr.Length
				Else
					endP = clv1.GetValue(i+1)-1
'					If MatnStr.SubString2(endP-1,endP) = "@" Or MatnStr.SubString2(endP-1,endP) = "|" Then 
'						endP = endP - 1
'					End If
				End If
						
				JSTLabel.Text = MatnStr.SubString2(clv1.GetValue(i),endP)
				If highlight = False Then
					QK_Click
				End If
				If JSTLabel.Text = "" Then JSTLabel.Text = MatnStr.SubString2(clv1.GetValue(i),endP)
			
				If Not(JSTLabel.Text.CharAt(JSTLabel.Text.Length-1) = CRLF)  Then
					myf.Rangbandi(Label1cel,JSTLabel.Text,highlight,HighlightIndex,False,SetData)
				Else
					myf.Rangbandi(Label1cel,JSTLabel.Text.SubString2(0,JSTLabel.Text.Length-1),highlight,HighlightIndex,False,SetData)
				End If
				myf.setBmatnEfont(Label1cel,clv1.sv.Width-4%x)
				p.Height = Label1cel.Height
				Label1cel.Tag = i
'				If Label1cel.Text.CharAt(Label1cel.Text.Length-1) = CRLF Then
'					Label1cel.Text.set
'					Label1cel.Text.Length = Label1cel.Text.Length-1
'				End If
				Dim RichStr As RichString
				RichStr.Initialize(Label1cel.Text)
				If highlight Then
					If HighlightIndex >= 0 And (HighlightIndex+myf.ssL) < RichStr.Length Then
						If SetData.nmode Then
							RichStr.BackColor(0x55f5f5f5,HighlightIndex,HighlightIndex+myf.ssL)
						Else
							RichStr.BackColor(0x550a0a0a,HighlightIndex,HighlightIndex+myf.ssL)
						End If
					End If
					Log(HighlightIndex)
				End If
				Label2cel.Text = RichStr
				Label1cel.Text = RichStr
				myf.setBMatnfont(Label2cel,Label1cel.Width)
				If SetData.nmode Then Label1cel.TextColor = 0xffe9e9e9 Else Label1cel.TextColor = 0xFF021c1a'1b1448'0xff0a0a0a
				If SetData.nmode Then Label2cel.TextColor = 0xFFff6f6f Else Label2cel.TextColor = 0xFF942b28'Colors.Red
				Label1cel.Left = 2%x
				Label2cel.Left = 2%x
				Label1cel.Top = 0
				Label2cel.Top = 0
				If clv1.GetValue(i)-2 >= 0 Then
					If MatnStr.SubString2(clv1.GetValue(i)-2,clv1.GetValue(i)) = "@@" Then
						Label1cel.Gravity = Gravity.CENTER_HORIZONTAL
						Label2cel.Gravity = Gravity.CENTER_HORIZONTAL
					End If
				End If
				If i = 0 Then
					Dim img3 As ImageView
					img3.Initialize("")
					img3.Gravity = Gravity.FILL
					img3.Width = 5.4*8%x
					img3.Height = 8%x
					If SetData.nmode Then
						Dim BMPA As NegativeImage
						img3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"mbeyt.png")))
					Else
						img3.SetBackgroundImage(LoadBitmap(File.DirAssets,"mbeyt.png"))
					End If
'					img4.Initialize("")
'					img4.Width = clv1.AsView.Width'-35*100%x/642
'					img4.Height = 10%x
'					If Main.nmode Then img4.Color = 0x22888888 Else img4.Color = 0x11000000
'					p.AddView(img4,0,0,img4.Width,img4.Height)
					p.Width = clv1.AsView.Width
					p.AddView(img3,50%x-img3.Width/2-5%x,2.5%x,img3.Width,img3.Height)
					p.Height = Label1cel.Height + img3.Height+6%x
					Label1cel.Top = img3.Height*2
					Label2cel.Top = img3.Height*2
				End If
				If clv1.GetValue(i)-1 >= 0 Then
					If MatnStr.SubString2(clv1.GetValue(i)-1,clv1.GetValue(i)) = "@" Or MatnStr.SubString2(clv1.GetValue(i)-1,clv1.GetValue(i)) = "|" Then
						Dim img3 As ImageView
						Dim img4 As ImageView
						img3.Initialize("")
						If MatnStr.SubString2(clv1.GetValue(i)-1,clv1.GetValue(i)) = "@" Then
							img3.Gravity = Gravity.FILL
							img3.Width = (161/41)*5%x
							img3.Height = 5%x
							If SetData.nmode Then
								Dim BMPA As NegativeImage
								img3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"mbeyt.png")))
							Else
								img3.SetBackgroundImage(LoadBitmap(File.DirAssets,"mbeyt.png"))
							End If
							img4.Initialize("")
							img4.Width = clv1.AsView.Width'-35*100%x/642
							img4.Height = 10%x
							If SetData.nmode Then img4.Color = 0x22888888 Else img4.Color = 0x11000000
							p.AddView(img4,0,0,img4.Width,img4.Height)
						End If
						If MatnStr.SubString2(clv1.GetValue(i)-1,clv1.GetValue(i)) = "|" Then
							img3.Gravity = Gravity.FILL
							img3.Width = 80%x
							img3.Height = 0.5%x
							If SetData.nmode Then
								Dim BMPA As NegativeImage
								img3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"pavaraghi.png")))
							Else
								img3.SetBackgroundImage(LoadBitmap(File.DirAssets,"pavaraghi.png"))
							End If
						End If
						p.Width = clv1.AsView.Width
						p.AddView(img3,p.Width/2+2%x-img3.Width/2,2.5%x,img3.Width,img3.Height)
						If Label1cel.Text = "" Then
							p.Height = 5%x
						Else
							p.Height = Label1cel.Height+10%x
						End If
						Label1cel.Top = img3.Height*2
						Label2cel.Top = img3.Height*2
					End If
				End If
'				If i = 0 Or clv1.GetValue(i)-1 >= 0 Then
'					If i = 0 Or MatnStr.SubString2(clv1.GetValue(i)-1,clv1.GetValue(i)) = "@" Then
'						Dim img3 As ImageView
'						Dim img4 As ImageView
'						img3.Initialize("")
'						img3.Gravity = Gravity.FILL
'						img3.Width = (161/41)*5%x
'						img3.Height = 5%x
'						If Main.nmode Then
'							Dim BMPA As NegativeImage
'							img3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"mbeyt.png")))
'						Else
'							img3.SetBackgroundImage(LoadBitmap(File.DirAssets,"mbeyt.png"))
'						End If
'						
'						
'						p.Width = clv1.AsView.Width
'						p.AddView(img3,p.Width/2-img3.Width/2,2.5%x,img3.Width,img3.Height)
'						img4.Initialize("")
'						img4.Width = clv1.AsView.Width'-35*100%x/642
'						img4.Height = 10%x
'						If Main.nmode Then img4.Color = 0x22888888 Else img4.Color = 0x11000000
'						p.AddView(img4,0,0,img4.Width,img4.Height)
'						p.Height = Label1cel.Height + 10%x
'						Label1cel.Top = img3.Height*2
'						Label2cel.Top = img3.Height*2
'					End If
'				End If
				Dim plastH As Int = clv1.GetPanel(i).Height
				'If Not(plastH = Label1cel.Height) Then clv1.ResizeItem(i,Label1cel.Height)
				
				If i = clv1.Size - 1 Then
					Dim h As Int
					For x = 0 To clv1.Size-1
						h = h+clv1.GetPanel(x).Height
					Next
'					Log(h)
'					Log(85%y)
					If 85%y - h > 0 Then
						p.Height = p.Height + (85%y - h)
					End If
					
				End If
				'				If i Mod 2 = 0 Then
				If SetData.nmode Then p.Color = 0x0Affffff Else p.Color = 0xfff1ebda'0xfff7f0df
'				Else
'					If SetData.nmode Then Label1cel.Color = 0x05ffffff Else Label1cel.Color = 0xfffdf8e5
'				End If
				clv1.ReplaceAt(i,p,p.Height,clv1.GetValue(i))
				If i < LastFirstIndex Then
					Dim delta As Int = Label1cel.Height-plastH
					clv1.sv.ScrollViewOffsetY = clv1.sv.ScrollViewOffsetY+delta
				End If
'				htt = htt+clv1.GetPanel(i).Height
'				If htt >= 100%y Then httNotPass = False
			End If
		Else
			If clv1.GetPanel(i).NumberOfViews > 0 Then
				clv1.GetPanel(i).RemoveAllViews
				clv1.GetPanel(i).Tag = 0
			End If
		End If
	Next
	If edameh Then
		LastFirstIndex = startItem
		clv1.JumpToItem(startItem)
		clv1.Refresh
		If LastIndex = clv1.Size-1 And clv1.GetPanel(LastIndex).NumberOfViews > 0 Then edameh = False
	Else
		LastFirstIndex = FirstIndex
	End If
	'pos1.Value = clv1.sv.ScrollViewOffsetY
	'pos1.Value = FirstIndex
End Sub
'Sub Thread1_Ended(fail As Boolean, error As String) 'An error or Exception has occurred in the Thread
'	LIV1.Left = 135%x
'ToastMessageShow("متن بارگیری شد",False)
'End Sub
Sub QK_Click
	If SetData.JSTType = 1 Then
		JST.Initialize
		JSTLabel.Text=JST.JustifyByAddSpace(JSTLabel,JSTLabel.Text,False,0.35)
	else if SetData.JSTType = 2 Then
		JST.Initialize
		JSTLabel.Text=JST.JustifyByExtendWords(JSTLabel,JSTLabel.Text,False,0.35,False)
	Else if SetData.JSTType = 3 Then
		'JSTLabel.Text=JST.JustifyByExtendWords(JSTLabel,JSTLabel.Text,False,0.65,False)
		'JSTLabel.Text = JSTLabel.Text.Replace("ـ","")
		Return
	End If
End Sub
Sub Activity_Resume
	myf.Loading(SetData)
	myf.setBMatnfont(JSTLabel,clv1.sv.Width-7%x)
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
	NightOrDayModeSel
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then
		cur=s1.ExecQuery("select * from Edameh")
		If cur.RowCount = 0 Then
			cur.Close
			s1.ExecNonQuery("insert into Edameh VALUES(" & onvanha.idonvan &",'"& onvanha.onvanSel & "',"&LastFirstIndex&")")
		Else
			cur.Close
			s1.ExecNonQuery("update Edameh set idonvan="  & onvanha.idonvan &",onvanSel='"&onvanha.onvanSel & "',ItemNumber=" &LastFirstIndex)
		End If

		If klmc Then

		Else
			Activity.Finish
		End If
		klmc = False
	End If
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

Private Sub SettingB_Click
	If menu Then
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
			myf.setBMatnfont(JSTLabel,clv1.sv.Width-7%x)
			changeSetting = False
		End If
	Else
		menuIndex = Activity.NumberOfViews
		Dim p As Panel
		p.Initialize("")
		p.LoadLayout("nMenu")
		
		Tabs.RemoveAllTabs
		Tabs.BeginUpdate
		Tabs.AddTab(Colors.Transparent,"تنظیمات فونت متن",Tabs.FontToBitmap(Chr(0xF02D),False,30,SetData.TopbackColor),"")
		Tabs.SetTab(0,True,True)
		
		Tabs_TabClick(Tabs.CurrentIndex)
		Tabs.EndUpdate
		
		ArLineSpace.Value = myf.ArLineSp - 10
		FrLineSpace.Value = myf.FrLineSp - 10
		myf.setMatnfont(Label3,Label3.Width)
		myf.setTMatnfont(Label4,Label4.Width)
		Label3.Height = 36%y-20%x
		Label4.Height = 36%y-20%x
		FrFname.Text = getFrFontName
		ArFname.Text = getArFontName
		Activity.AddView(p,0,49%y,100%x,84%y)
		Activity.GetView(menuIndex).Visible = False
		Activity.GetView(menuIndex).SetVisibleAnimated(200,True)
		Activity.GetView(menuIndex).BringToFront
		If SetData.nmode = False Then
			Label3.Color = SetData.backColor
			Label4.Color = SetData.backColor
			Label3.TextColor = Colors.Black
			Label4.TextColor = Colors.Black
		Else
			Label3.Color = Colors.DarkGray
			Label4.Color = Colors.DarkGray
			Label3.TextColor = Colors.White
			Label4.TextColor = Colors.White
		End If
		Sleep(200)
'		If mode = 0 Then Af.Checked = True
'		If mode = 1 Then Ar.Checked = True
'		If mode = 2 Then Fr.Checked = True
		menu = True
	End If
	'oldTarjomehView = TarjomehView
End Sub
Private Sub Tabs_TabClick(index As Int)
	If index = 0 Then
		Panel2.Visible = True
		Panel1.Visible = False
	Else
		Panel1.Visible = True
		Panel2.Visible = False
	End If
	Panel3.Visible = False
	Panel4.Height = 45%y
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
Sub getFrFontName As String
	Select myf.FarFont
		Case 1
			Return "Vazirmatn-Thin"
		Case 2
			Return "Vazirmatn-ExtraLight"
		Case 3
			Return "Vazirmatn-Light"
		Case 4
			Return "Vazirmatn-Regular"
		Case 5
			Return "Vazirmatn-Medium"
		Case 6
			Return "Vazirmatn-SemiBold"
		Case 7
			Return "Vazirmatn-Bold.ttf"
		Case 8
			Return "Vazirmatn-ExtraBold"
		Case 9
			Return "بدر"
		Case 10
			Return "میترا"
		Case 11
			Return "رویا"
		Case 12
			Return "نسخ"
		Case Else
			Log("Larger than 7")
	End Select
End Sub
Sub getArFontName As String
	Select myf.AraFont
		Case 1
			Return "w_Aziz"
		Case 2
			Return "w_Aziz Bold"
		Case 3
			Return "w_Badr"
		Case 4
			Return "w_Badr Bold"
		Case 5
			Return "w_Hasoob"
		Case 6
			Return "w_Hasoob Bold"
		Case 7
			Return "w_Homa"
		Case 8
			Return "w_Homa Bold"
		Case 9
			Return "w_Jalal"
		Case 10
			Return "w_Jalal Bold"
		Case 11
			Return "w_Karim"
		Case 12
			Return "w_Karim Bold"
		Case 13
			Return "w_Koodak"
		Case 14
			Return "w_Koodak Bold"
		Case 15
			Return "w_Lotus Light"
		Case 16
			Return "w_Lotus"
		Case 17
			Return "w_Lotus Semi Bold"
		Case 18
			Return "w_Lotus Bold"
		Case 19
			Return "w_Mitra"
		Case 20
			Return "w_Mitra Bold"
		Case 21
			Return "w_Mohanad"
		Case 22
			Return "w_Nazanin"
		Case 23
			Return "w_Nazanin Bold"
		Case 24
			Return "w_Roya"
		Case 25
			Return "w_Roya Bold"
		Case 26
			Return "w_Trafic"
		Case 27
			Return "w_Trafic Bold"
		Case 28
			Return "w_Yaghot"
		Case 29
			Return "w_Yaghot Bold"
		Case 30
			Return "w_Yasamin"
		Case 31
			Return "w_Yekan"
		Case 32
			Return "w_Yekan Bold"
		Case 33
			Return "w_Zar"
		Case 34
			Return "w_Zar Bold"
		Case 35
			Return "wm_Naskh Qurani"
		Case 36
			Return "عثمان طه"
		Case 37
			Return "بدر"
		Case 38
			Return "عثمان طه1"
		Case 39
			Return "لوتوس"
		Case 40
			Return "نبی"
		Case 41
			Return "نسخ"
		Case 42
			Return "نور"
		Case 43
			Return "قرآن"
		Case Else
			Log("Larger than 13")
	End Select
End Sub
Sub PrevFarsi_Click
	If myf.FarFont > 1 Then
		myf.FarFont = myf.FarFont - 1
		myf.setTMatnfont(Label4,Label4.Width)
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

Sub NextFarsi_Click
	If myf.FarFont < 12 Then
		myf.FarFont = myf.FarFont + 1
		myf.setTMatnfont(Label4,Label4.Width)
		Label4.Height = 36%y-20%x
		FrFname.Text = getFrFontName
		changeSetting = True
	End If
End Sub

Sub NextArabi_Click
	If myf.AraFont < 43 Then
		myf.AraFont = myf.AraFont + 1
'		If myf.AraFont = 3 Then myf.AraFont = 4
		myf.setMatnfont(Label3,Label3.Width)
		Label3.Height  = 36%y-20%x
		ArFname.Text = getArFontName
		changeSetting = True
	End If
End Sub

Sub FRpp_Click
	If myf.FarSize < 48 Then
		myf.FarSize= myf.FarSize+1
		myf.setTMatnfont(Label4,Label4.Width)
		frLbl.Text = myf.FarSize.As(Int)
		Label4.Height = 36%y-20%x
		changeSetting = True
	End If
End Sub

Sub FRmm_Click
	If myf.FarSize > 18 Then
		myf.FarSize = myf.FarSize-1
		myf.setTMatnfont(Label4,Label4.Width)
		frLbl.Text = myf.FarSize.As(Int)
		Label4.Height = 36%y-20%x
		changeSetting = True
	End If
End Sub

Sub FrLineSpace_ValueChanged (Value As Int, UserChanged As Boolean)
	If UserChanged Then
		myf.FrLineSp = 10+Value
		myf.setTMatnfont(Label4,Label4.Width)
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