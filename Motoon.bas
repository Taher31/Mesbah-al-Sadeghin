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
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Private xui As XUI
	Dim tm As Timer
'	Dim tm1 As Timer
	Dim toastTm As Timer
	Dim edameh As Boolean
	Dim startItem As Int
	Dim nextOnvan,prevOnvan As Boolean
	Dim sidx As Int = 0
	Dim s1,s2 As SQL
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private GD As GestureDetector
	Private et1,edd As Label
	Private clv1 As CustomListView
	Private Panel1,Panel2 As Panel
	Private Button1 As Button
	Private Label1 As Label
	Private Af,Ar,Fr As RadioButton
	Private p1 As Panel
	Private l1,lp1 As Label
	Private Label3,Label4 As Label
	Private fpp,fmm,Tafsir,CopyText,ShareText,NextB,PrevB As Button
	Dim cur As Cursor
	Dim matnIdx As Int
	Dim pagelist As List
	Dim menu As Boolean = False
	Dim menuIndex As Int = 0
	Dim mode As Int = 0
	Private mlongclick As Panel
	Private pnesh,pcopy As Button
	Dim Mark As Boolean
	Dim booksel,ItemPneshan As Int
	Private ToastText As Label
	Dim LastToastTime As Int = 0
	Private Button3,Button4 As Button
	Dim MatnStr() As String
	Dim NewMatnStr() As String
	Dim searching As Boolean
	Dim tpart,sPos As List
	Dim searchPos As Int
	Private ScrollView1 As ScrollView
	Dim EditCopy As EditText
	Dim JST As TeamEightJustifyBeta
	Dim JSTLabel As Label
	Dim iconAShow As Boolean
	Private ARmm As Button
	Private ARpp As Button
	Private FrLineSpace As SeekBar
	Private FRmm As Button
	Private FRpp As Button
	Private Label2 As Label
	Private NextArabi As Button
	Private NextFarsi As Button
	Private PrevArabi As Button
	Private PrevFarsi As Button
	Private ArLineSpace As SeekBar
	Private LtoR,RtoL As ImageView
	Dim x0,x1,y0,y1,xDrag,yDrag As Int
	Dim endTouch As Boolean = True
	Dim changeSetting As Boolean = False
	Private ArFname As Label
	Private FrFname As Label
	Dim SetData As AppSetting
	Private Artext As EditText
	Private Frtext As EditText
	Private LastFirstIndex As Int
	Private oldTarjomehView,TarjomehView As Int
	Private Tarjomeh As CheckBox
	Private sqlString As String
	Private Tabs As ASTabMenu
	Private araLbl As Label
	Private frLbl As Label
	Private ND As Button
	Private SearchB As Button
	Private DatabaseName As String
End Sub

Sub Activity_Create(FirstTime As Boolean)
	If File.Exists(File.DirInternal,"Tarjomeh") Then
		TarjomehView = 1'File.ReadString(File.DirInternal,"Tarjomeh")
		oldTarjomehView = TarjomehView
	End If
	
	myf.Loading(SetData)
	onvanha.idonvan = File.ReadString(File.DirInternalCache,"onvanha.txt")
	Dim path As String = File.ReadString(File.DirInternalCache,"bookAddr.txt")
	DatabaseName = File.ReadString(File.DirInternalCache,"booksel.txt")
	booksel = File.ReadString(File.DirInternalCache,"booktype.txt")
	myf.DatabesOpen(s1,path,DatabaseName,False)
	myf.DatabesOpen(s2,path,DatabaseName,False)
	


	Activity.LoadLayout("matnView")
	Activity.LoadLayout("mlongclick")
	

	
	Button1.Visible = False
	JSTLabel.Tag = 1
	JSTLabel.Width = 50%x
	JSTLabel.Height = 76%y
	myf.setBMatnfont(JSTLabel,50%x)
	
	Button3.Visible = True
	Button4.Visible = True
	NextB.Visible = True
	PrevB.Visible = True
	CopyText.Visible = False
	ShareText.Visible = False
	EditCopy.Initialize("EditCopy")
	EditCopy.Gravity = Gravity.TOP
	EditCopy.Padding = Array As Int (5%x,5%x,5%x,5%x)
	GD.SetOnGestureListener(clv1.sv, "Gesture")
	
	If onvanha.search Then
		SearchB.SetBackgroundImage(LoadBitmap(File.DirAssets,"Stopsearch.png"))
	Else
		SearchB.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
	End If
	
	Dim jo = EditCopy As JavaObject
	jo.RunMethod("setCursorVisible",Array As Object(True))
	jo.RunMethod("setTextIsSelectable",Array As Object(True))
	ScrollView1.Panel.AddView(EditCopy,0,0,ScrollView1.Width,ScrollView1.Height)
	ScrollView1.Visible = False

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
'	jo.RunMethod("setVerticalFadingEdgeEnabled", Array As Object (False))
'	Dim r As Reflector
'	r.Target = clv1.sv
'	r.RunMethod2("setVerticalScrollBarPosition",2,"java.lang.int")
'	Private r1 As Reflector
'	r1.Target = clv1.sv
'	r1.SetOnTouchListener("Clv1Touch")
	toastTm.Initialize("toastTm",1000)
	Dim cur1 As Cursor
' = s1.ExecQuery("select * from prevTable where name = 'booknum'")
'	If cur1.RowCount > 0 Then
'		s1.ExecNonQuery("update prevTable set val = 4  where name = 'booknum'")
'	Else
'		s1.ExecNonQuery("insert into prevTable VALUES(4,'booknum',4)")
'	End If
	booksel = 4
	mlongclick.Visible = False

	If SetData.nmode = False Then
		Activity.Color = SetData.backColor
		ND.SetBackgroundImage(LoadBitmap(File.DirAssets,"nmode.png"))
	Else
		Activity.Color = 0x002223
		ND.SetBackgroundImage(LoadBitmap(File.DirAssets,"dmode.png"))
	End If
	cur = s1.ExecQuery("select * from prevTable where name = 'tindex'")
	If cur.RowCount < 1 Then 
		Activity.Finish
	Else 
		cur.Position = 0
		matnIdx = cur.GetString("val")
	End If
	

	onvanha.idonvan = matnIdx
	File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
	
	cur=s1.ExecQuery("select tindex from marktable where tindex="& matnIdx & " and bookidx="&booksel)
	If cur.RowCount = 1 Then Mark = True Else Mark = False
	cur.Close
	If Mark Then
		Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark.png"))
	Else
		Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark-outline.png"))
	End If
	
	cur = s1.ExecQuery("select * from table2 where tindex =" & matnIdx)
	cur.Position = 0
	et1.Text = cur.GetString("ttitle")
	
'	cur = s1.ExecQuery("select DISTINCT tpage from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
'	pagelist.Initialize
'	For i = 0 To cur.RowCount-1
'		cur.Position = i
'		pagelist.Add(cur.GetString2(0))
'	Next
's2.BeginTransaction
'	Create_Ntable4
's2.EndTransaction

	
	
	
	If TarjomehView = 1 Then
		sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
	Else
		sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
	End If
	cur = s1.ExecQuery(sqlString)
	Dim MatnStr(cur.RowCount) As String
	For i = 0 To cur.RowCount-1
		cur.Position = i
		MatnStr(i) = cur.GetString("ttext")
	Next

	
	
'	tm1.Initialize("tm1",10)
'	tm1.Enabled = True
	If onvanha.search Then
		searching = True
		tpart.Initialize
		sPos.Initialize
		tpart.Clear
		sPos.Clear
		If TarjomehView = 1 Then
			sqlString = "SELECT tpart FROM Ntable3 WHERE ttext1 LIKE '%%%"&SearchM.searchStr&"%%' and tindex ="&matnIdx & " ORDER BY tpart"
		Else
			sqlString = "SELECT tpart FROM Ntable3 WHERE ttext1 LIKE '%%%"&SearchM.searchStr&"%%' and tindex ="&matnIdx & " and tType != 2 ORDER BY tpart"
		End If
		cur1=s1.ExecQuery(sqlString)
		If cur1.RowCount > 0 Then
			For i = 0 To cur1.RowCount-1
				cur1.Position = i
				Dim FindStr As String
				If TarjomehView = 1 Then
					sqlString = "select replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(ttext,'ِ','ـ'),'ٍ','ـ'),'ْ','ـ'),'ّ','ـ'),'ٌ','ـ'),'ُ','ـ'),'ً','ـ'),'َ','ـ'),'ى','ي'),'ی','ي'),'ك','ک'),'إ','ا'),'أ','ا'),'ٰ','ـ') from Ntable3 where tindex="&matnIdx &" and tpart="&(cur1.GetString2(0))
				Else
					sqlString = "select replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(ttext,'ِ','ـ'),'ٍ','ـ'),'ْ','ـ'),'ّ','ـ'),'ٌ','ـ'),'ُ','ـ'),'ً','ـ'),'َ','ـ'),'ى','ي'),'ی','ي'),'ك','ک'),'إ','ا'),'أ','ا'),'ٰ','ـ') from Ntable3 where tindex="&matnIdx &" and tType != 2 and tpart="&(cur1.GetString2(0))
				End If
				Dim cur2 As Cursor = s1.ExecQuery(sqlString)
				cur2.Position = 0
				FindStr = cur2.GetString2(0)
				cur2.Close
'				Log(FindStr)
				For j = 0  To FindStr.Length - 1
					Dim ch As Char = FindStr.CharAt(j)
					If ch = SearchM.searchStr.CharAt(0) Then
						Dim ii As Int = 1
						Dim jj As Int = 1
						Do While True
							If j+ii > FindStr.Length-1 Then Exit
							If FindStr.CharAt(j+ii) = "ـ" Then
								ii = ii + 1
							Else If FindStr.CharAt(j+ii) = SearchM.searchStr.CharAt(jj) Then
								ii = ii + 1
								jj = jj + 1
								If jj = SearchM.searchStr.Length Then
									tpart.Add(cur1.GetString2(0)-1)
									sPos.Add(j)
'									Log(cur1.GetString2(0)-1)
'									Log(j)
									j = j + ii
									ii = 1
									jj = 1
								End If
							Else
								Exit
							End If
						Loop
					End If
				Next
				
			Next
		End If

		If sPos.Size > 0 Then			
			sidx = 0
			If prevOnvan Then
				sidx = tpart.Size-1
				prevOnvan = False
			End If
			
			edameh = True
			searchPos = sPos.Get(sidx)
			startItem = tpart.Get(sidx)
			ToastMessageShow2("مورد "&(sidx+1) &" از " & tpart.Size,False)
		End If
	End If
	cur.Position = -1
	clv1.Clear

	tm.Initialize("tm",100)
	tm.Enabled = True
	edd.Visible = edameh
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
			If yDrag < 15%y And xDrag >  25%x Then NextB_Click
			If yDrag < 15%y And xDrag < -25%x Then PrevB_Click
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
'				If xDrag > 0 Then
'					LtoR.Left = -50%x + xDrag
'				Else 
'					RtoL.Left = 100%x + xDrag
'				End If
''			End If
'		Case Activity.ACTION_UP
''			Log("UP")
'			endTouch = True
'			RtoL.Left = 100%x
'			LtoR.Left = -50%x
'			If yDrag < 20%y And xDrag >  25%x Then NextB_Click 
'			If yDrag < 20%y And xDrag < -25%x Then PrevB_Click
'		End Select
'		Return False
'End Sub
Sub NextB_Click
	If onvanha.search Then
		If sidx < tpart.Size-1 Then
			clv1.GetPanel(tpart.Get(sidx)).Tag = -1
			sidx = sidx+1
			edameh = True
			startItem = tpart.Get(sidx)
			searchPos = sPos.Get(sidx)
			clv1.GetPanel(tpart.Get(sidx)).Tag = -1
			edd.Visible = True
			tm.Enabled = True
			clv1.Refresh
			ToastMessageShow2("مورد "&(sidx+1) &" از " & tpart.Size,False)
		Else
			If SearchM.tiSel < SearchM.tindex.Length-1 Then
				Try
					nextOnvan = True
					prevOnvan = False
					SearchM.tiSel = SearchM.tiSel+1
					onvanha.idonvan = SearchM.tindex(SearchM.tiSel)
					onvanha.onvanSel =  SearchM.ttitle(SearchM.tiSel)
					File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
					matnIdx = onvanha.idonvan
					onvanha.search = True
					Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'tindex'")
					If cur1.RowCount > 0 Then
						s1.ExecNonQuery("update prevTable set val = " & onvanha.idonvan)
					Else
						s1.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& onvanha.idonvan&")")
					End If
					
					clv1.Clear
					toastTm.Enabled = False
					ToastText.Visible = False
					Activity.RemoveAllViews
					Activity_Create(True)
				Catch
					Log(LastException)
				End Try
			Else
				ToastMessageShow2("به آخرین عنوان رسیده اید",False)
			End If			
		End If
		
	Else	
	
		Dim cur1 As Cursor = s1.ExecQuery("select * from table2 where (ttext = 1 and tindex > " & matnIdx & ") ORDER BY tindex")
			
		If cur1.RowCount > 0 Then
			tm.Enabled = False
			cur1.Position = 0
			onvanha.idonvan = cur1.GetInt("tindex")
			File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
			matnIdx = onvanha.idonvan

			cur=s1.ExecQuery("select tindex from marktable where tindex="& matnIdx & " and bookidx="&booksel)
			If cur.RowCount = 1 Then Mark = True Else Mark = False
			cur.Close
			If Mark Then
				Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark.png"))
			Else
				Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark-outline.png"))
			End If
		
			cur = s1.ExecQuery("select * from table2 where tindex =" & matnIdx)
			cur.Position = 0
			et1.Text = cur.GetString("ttitle")
			
			Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'tindex'")
			If cur1.RowCount > 0 Then
				s1.ExecNonQuery("update prevTable set val = " & onvanha.idonvan)
			Else
				s1.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& onvanha.idonvan&")")
			End If
			
			clv1.Clear
'			cur = s1.ExecQuery("select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
			If TarjomehView = 1 Then
				sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
			Else
				sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
			End If
			cur = s1.ExecQuery(sqlString)
			Dim MatnStr(cur.RowCount) As String
			For i = 0 To cur.RowCount-1
				cur.Position = i
				MatnStr(i) = cur.GetString("ttext")
			Next
			cur.Position = -1
			tm.Enabled = True
		Else 
			ToastMessageShow2("به آخرین عنوان رسیده اید",False)
		End If
	End If
End Sub
Sub PrevB_Click
	If onvanha.search Then
		If sidx > 0 Then
			clv1.GetPanel(tpart.Get(sidx)).Tag = -1
			sidx = sidx-1
			edameh = True
			startItem = tpart.Get(sidx)
			searchPos = sPos.Get(sidx)
			clv1.GetPanel(tpart.Get(sidx)).Tag = -1
			edd.Visible = True
			tm.Enabled = True
			clv1.Refresh
			ToastMessageShow2("مورد "&(sidx+1) &" از " & tpart.Size,False)
		Else
			If SearchM.tiSel > 0 Then
				Try
					nextOnvan = False
					prevOnvan = True
					SearchM.tiSel = SearchM.tiSel-1
					onvanha.idonvan = SearchM.tindex(SearchM.tiSel)
					onvanha.onvanSel =  SearchM.ttitle(SearchM.tiSel)
					File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
					matnIdx = onvanha.idonvan
					onvanha.search = True
					Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'tindex'")
					If cur1.RowCount > 0 Then
						s1.ExecNonQuery("update prevTable set val = " & onvanha.idonvan)
					Else
						s1.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& onvanha.idonvan&")")
					End If
					
					clv1.Clear
					toastTm.Enabled = False
					ToastText.Visible = False
					Activity.RemoveAllViews
					Activity_Create(True)
				Catch
					Log(LastException)
				End Try
			Else
				ToastMessageShow2("به اولین عنوان رسیده اید",False)
			End If
		End If
		
	Else
		Dim cur1 As Cursor = s1.ExecQuery("select * from table2 where (ttext = 1 and tindex < " & matnIdx & ") ORDER BY tindex ")
			
		If cur1.RowCount > 0 Then
			tm.Enabled = False
			cur1.Position = cur1.RowCount - 1
			onvanha.idonvan = cur1.GetInt("tindex")
			File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
			matnIdx = onvanha.idonvan

			cur=s1.ExecQuery("select tindex from marktable where tindex="& matnIdx & " and bookidx="&booksel)
			If cur.RowCount = 1 Then Mark = True Else Mark = False
			cur.Close
			If Mark Then
				Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark.png"))
			Else
				Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark-outline.png"))
			End If
		
			cur = s1.ExecQuery("select * from table2 where tindex =" & matnIdx)
			cur.Position = 0
			et1.Text = cur.GetString("ttitle")
			
			Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'tindex'")
			If cur1.RowCount > 0 Then
				s1.ExecNonQuery("update prevTable set val = " & onvanha.idonvan)
			Else
				s1.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& onvanha.idonvan&")")
			End If
			
			clv1.Clear
			'cur = s1.ExecQuery("select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
			If TarjomehView = 1 Then
				sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
			Else
				sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
			End If
			cur = s1.ExecQuery(sqlString)
			Dim MatnStr(cur.RowCount) As String
			For i = 0 To cur.RowCount-1
				cur.Position = i
				MatnStr(i) = cur.GetString("ttext")
			Next
			cur.Position = -1
			tm.Enabled = True
		Else 
			ToastMessageShow2("به اولین عنوان رسیده اید",False)
		End If
	End If
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
Sub Button4_Click
	StartActivity(NeshaneHa)
	myf.SetAnimation("task_open_enter","task_open_exit")
End Sub
Sub Button3_Click
	Dim b1 As Button = Button3
	Dim b1W As Int = b1.Width
	Dim b1H As Int = b1.Height
	b1.SetLayoutAnimated(150,b1.Left,b1.Top,b1W+2%x,b1H+2%x)
	Sleep(150)
	If Mark Then
		Mark = False
		s1.ExecNonQuery("delete from marktable where tindex=" & matnIdx & " and bookidx ="& booksel)
		ToastMessageShow2("عنوان فعلی از فهرست منتخب حذف شد ",False)
	Else
		Mark = True
		s1.ExecNonQuery("insert into marktable VALUES(" & matnIdx &","& booksel & ")")
		ToastMessageShow2("عنوان فعلی به فهرست منتخب افزوده شد ",False)
	End If
	If Mark Then
		Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark.png"))
	Else
		Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark-outline.png"))
	End If
	b1.SetLayoutAnimated(150,b1.Left,b1.Top,b1W,b1H)
End Sub
Sub pcopy_Click
	mlongclick.SetVisibleAnimated(313,False)
	Dim str As String = ""
	If clv1.Size > 0 Then
		For i = clv1.FirstVisibleIndex To clv1.Size-1
			str = str & MatnStr(i) & CRLF
		Next
	End If
	If SetData.nmode = False Then
		EditCopy.Color = 0xfffff2df
		EditCopy.TextColor = Colors.Black
	Else
		EditCopy.TextColor = Colors.White
		EditCopy.Color = Colors.Gray
	End If
	EditCopy.Text = str
	ScrollView1.Left = 0
	ScrollView1.Width = 100%x
	EditCopy.Width = ScrollView1.Width
	myf.setEditCopyMatnfont(EditCopy,clv1.sv.Width)
	
			
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
	NextB.Visible = False
	PrevB.Visible = False
	CopyText.Visible = True
	ShareText.Visible = True
	et1.Text = "انتخاب جهت کپی و اشتراک گذاری"
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
	Activity_KeyPress(KeyCodes.KEYCODE_BACK)
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
	Activity_KeyPress(KeyCodes.KEYCODE_BACK)
End Sub
Sub pshar_Click
	Dim i1 As Intent
	Dim str As String = ""
	If clv1.Size > 0 Then
		For i = 0 To clv1.Size-1
			If mode = 0 Then str = str & MatnStr(i) & CRLF
			If mode = 1 Then str = str & MatnStr(i*2) & CRLF
			If mode = 2 Then str = str & MatnStr((i*2)+1) & CRLF
		Next
	End If
	i1.Initialize(i1.ACTION_SEND, "")
	i1.SetType("text/plain")
	i1.PutExtra("android.intent.extra.TEXT", str)
	i1.WrapAsIntentChooser("اشتراک گذاري مطلب با...")
	StartActivity(i1)
End Sub
Sub pnesh_Click
	mlongclick.SetVisibleAnimated(313,False)
	Dim v As View
	v = Sender
	If v.Tag >= 0 Then
		Dim cur1 As Cursor = s1.ExecQuery("select * from NeshanehTable where (idonvan =" & matnIdx &" and ItemNumber="&v.Tag&" and bookidx="&booksel & ")")
	
		If cur1.RowCount > 0 Then
			'				clv1.GetPanel(v.Tag).Color = Colors.Transparent
			'				s1.ExecNonQuery("delete from NeshanehTable where (ItemNumber=" & v.Tag & " and idonvan=" & onvanha.idonvan &")")
			'				ToastMessageShow2("نشانه انتخابی حذف شد",False)
		Else
			If SetData.nmode Then clv1.GetPanel(v.Tag).Getview(0).Color = Bit.Xor(0x30000000,0x00ffffff) Else clv1.GetPanel(v.Tag).Getview(0).Color = 0x30000000
			s1.ExecNonQuery("insert into NeshanehTable VALUES(" &matnIdx & ",'" & clv1.GetPanel(v.tag).Getview(0).GetView(0).Text & "',"& v.tag &","& booksel&")")
			If Not(Mark) Then
				Mark = True
				s1.ExecNonQuery("insert into marktable VALUES(" & matnIdx &","& booksel & ")")
				Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark.png"))
			End If
			ToastMessageShow2("نشانه افزوده شد",False)
		End If
		cur1.Close
	End If
End Sub
Sub Tafsir_Click
	Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'booknum'")
	If cur1.RowCount > 0 Then
		s1.ExecNonQuery("update prevTable set val = 2  where name = 'booknum'")
	Else
		s1.ExecNonQuery("insert into prevTable VALUES(2,'booknum',2)")
	End If
	
	cur1=s1.ExecQuery("select * from table2 where tindex=" & matnIdx)
	If cur1.RowCount = 1 Then
		cur1.Position = 0
		onvanha.onvanSel = cur1.GetString("tfttitle")
		onvanha.idonvan = matnIdx
		File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
		onvanha.search = False
		matnha.edameh = False
		StartActivity(matnha)
		myf.SetAnimation("left_right","zoom_exit")
	End If
End Sub
Sub Af_Click
	If Not(mode = 0) And Af.Checked Then
		mode = 0
		tm.Enabled = False
		clv1.Clear
		'cur = s1.ExecQuery("select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
		If TarjomehView = 1 Then
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
		Else
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
		End If
		cur = s1.ExecQuery(sqlString)
		Dim MatnStr(cur.RowCount) As String
		For i = 0 To cur.RowCount-1
			cur.Position = i
			MatnStr(i) = cur.GetString("ttext")
		Next
		cur.Position = -1
		tm.Enabled = True
	End If
End Sub
Sub Ar_Click
If Not(mode = 1) And Ar.Checked Then
		mode = 1
		tm.Enabled = False
		clv1.Clear
		'cur = s1.ExecQuery("select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
		If TarjomehView = 1 Then
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
		Else
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
		End If
		cur = s1.ExecQuery(sqlString)
		
		Dim MatnStr(cur.RowCount) As String
		For i = 0 To cur.RowCount-1
			cur.Position = i
			MatnStr(i) = cur.GetString("ttext")
		Next
		cur.Position = -1
		tm.Enabled = True
	End If
End Sub
Sub Fr_Click
	If Not(mode = 2) And Fr.Checked Then
		mode = 2
		tm.Enabled = False
		clv1.Clear
		'cur = s1.ExecQuery("select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
		If TarjomehView = 1 Then
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
		Else
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
		End If
		cur = s1.ExecQuery(sqlString)
		
		Dim MatnStr(cur.RowCount) As String
		For i = 0 To cur.RowCount-1
			cur.Position = i
			MatnStr(i) = cur.GetString("ttext")
		Next
		cur.Position = -1
		tm.Enabled = True
	End If
End Sub
Sub ND_Click
	If SetData.nmode = False Then
		SetData.nmode = True
		ND.SetBackgroundImage(LoadBitmap(File.DirAssets,"dmode.png"))
		myf.SettingApp.ExecNonQuery("update STable set nmode = 1")
		
		'cur = s1.ExecQuery("select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
		If TarjomehView = 1 Then
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
		Else
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
		End If
		cur = s1.ExecQuery(sqlString)
		
	Else
		SetData.nmode = False
		ND.SetBackgroundImage(LoadBitmap(File.DirAssets,"nmode.png"))
		myf.SettingApp.ExecNonQuery("update STable set nmode = 0")
		'cur = s1.ExecQuery("select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
		If TarjomehView = 1 Then
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
		Else
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
		End If
		cur = s1.ExecQuery(sqlString)
	End If
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = -1
	Next
	clv1.Refresh
	If SetData.nmode = False Then
		Activity.Color = SetData.backColor
	Else
		Activity.Color = 0x002223
	End If
	If menu Then
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
End Sub
Sub NightDaySel
	If SetData.nmode Then
		If TarjomehView = 1 Then
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
		Else
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
		End If
		cur = s1.ExecQuery(sqlString)
	Else
		If TarjomehView = 1 Then
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
		Else
			sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
		End If
		cur = s1.ExecQuery(sqlString)
	End If
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = -1
	Next
	clv1.Refresh
'	If SetData.nmode = False Then
'		Activity.Color = SetData.backColor
'	Else
'		Activity.Color = 0x002223
'	End If
'	If menu Then
'		If SetData.nmode = False Then
'			Label3.Color = SetData.backColor
'			Label4.Color = SetData.backColor
'			Label3.TextColor = Colors.Black
'			Label4.TextColor = Colors.Black
'		Else
'			Label3.Color = Colors.DarkGray
'			Label4.Color = Colors.DarkGray
'			Label3.TextColor = Colors.White
'			Label4.TextColor = Colors.White
'		End If
'	End If
'	Dim r As Reflector
'	r.Target = clv1.sv
'	r.Target = r.GetField("mScrollCache")
'	r.Target = r.GetField("scrollBar")
'	Dim cd As ColorDrawable
'	If SetData.nmode Then
'		cd.Initialize(Colors.Gray, 5dip)
'	Else
'		cd.Initialize(0xffe0bb92, 5dip)
'	End If
'	myf.ChangeScrollbarColor(clv1.sv, cd)
'	r.RunMethod4("setVerticalThumbDrawable", Array(cd), Array As String("android.graphics.drawable.Drawable"))	
End Sub


Sub fpp_Click
	startItem = clv1.FirstVisibleIndex
	edd.Visible = True
	If SetData.fontSize < 48 Then
		SetData.fontSize = SetData.fontSize + 3
	Else
		fpp.Visible = False
	End If
	If SetData.fontSize > 20 Then fmm.Visible = True
	tm.Enabled = False
	clv1.Clear
	'cur = s1.ExecQuery("select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
	If TarjomehView = 1 Then
		sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
	Else
		sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
	End If
	cur = s1.ExecQuery(sqlString)
	tm.Enabled = True
	myf.SettingApp.ExecNonQuery("update STable set fontsize=" & SetData.fontsize)
	edameh = True
End Sub
Sub fmm_Click
	startItem = clv1.FirstVisibleIndex
	edd.Visible = True
	If SetData.fontSize > 20 Then
		SetData.fontSize = SetData.fontSize - 3
	Else 
		fmm.Visible = False
	End If
	If SetData.fontSize < 48 Then fpp.Visible = True
	tm.Enabled = False
	clv1.Clear
	'cur = s1.ExecQuery("select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
	If TarjomehView = 1 Then
		sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
	Else
		sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
	End If
	cur = s1.ExecQuery(sqlString)
	tm.Enabled = True
	myf.SettingApp.ExecNonQuery("update STable set fontsize=" & SetData.fontsize)
	edameh = True
End Sub

Sub Button1_Click
	If menu Then
'		TarjomehView = File.ReadString(File.DirInternal,"Tarjomeh").As(Int)
'		If Tarjomeh.IsInitialized Then 
'			If TarjomehView = 1 Then Tarjomeh.Checked = True Else Tarjomeh.Checked = False
'		End If
		Activity.GetView(menuIndex).SetVisibleAnimated(200,False)
		Sleep(200)
		Activity.RemoveViewAt(menuIndex)
		startItem = clv1.FirstVisibleIndex
		For i = 0 To clv1.Size-1
			clv1.GetPanel(i).Tag = -1
		Next
		clv1.Refresh
		If onvanha.search Then
			searchPos = sPos.Get(sidx)
			startItem = tpart.Get(sidx)
		End If
		edd.Visible = True
		edameh = True
		tm.Enabled = True
		menu = False
		If changeSetting Then
			myf.SettingApp.ExecNonQuery("update fontTable set fehrestFont ="& myf.FehrestFont & ",ArFont =" & myf.AraFont &",FrFont = "& myf.FarFont &",fehrestSize = "& myf.FehrestSize &",ArSize = "& myf.AraSize &",FrSize = "& myf.FarSize &",ArLineSpace = "& myf.ArLineSp &",FrLineSpace = "& myf.FrLineSp)
'			If oldTarjomehView <> TarjomehView Then
'				s1.ExecNonQuery("delete from NeshanehTable where idonvan=" & onvanha.idonvan)
'				Activity.Finish
'				myf.SetAnimation("left_right","left_right1")
'			End If
			changeSetting = False
		End If
	Else
		tm.Enabled = False
		menuIndex = Activity.NumberOfViews
		Dim p As Panel
		p.Initialize("")
		p.LoadLayout("nMenu")
		Tabs.RemoveAllTabs
		Tabs.BeginUpdate
		Tabs.AddTab(Colors.Transparent,"تنظیمات فونت متن",Tabs.FontToBitmap(Chr(0xF02D),False,30,SetData.TopbackColor),"")
		Tabs.AddTab(Colors.Transparent,"تنظیمات فونت ادعیه",Tabs.FontToBitmap(Chr(0xF02D),False,30,SetData.TopbackColor),"")
		Tabs.SetTab(1,True,True)
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
		Else
			File.WriteString(File.DirInternal,"Tarjomeh","1")
			Tarjomeh.Checked = True
		End If
'		Log("Tr:"&Tarjomeh.Checked)
'		TarjomehView = File.ReadString(File.DirInternal,"Tarjomeh").As(Int)
'		If Tarjomeh.IsInitialized Then
'			If TarjomehView = 1 Then Tarjomeh.Checked = True Else Tarjomeh.Checked = False
'		End If
		If SetData.nmode = False Then
			Activity.Color = SetData.backColor
			Label3.Color = SetData.backColor
			Label4.Color = SetData.backColor
			Label3.TextColor = Colors.Black
			Label4.TextColor = Colors.Black
		Else
			Activity.Color = 0x002223
			Label3.Color = Colors.DarkGray
			Label4.Color = Colors.DarkGray
			Label3.TextColor = Colors.White
			Label4.TextColor = Colors.White
		End If
		ArLineSpace.Value = myf.ArLineSp - 10
		FrLineSpace.Value = myf.FrLineSp - 10
		myf.setMatnfont(Label3,Label3.Width)
		myf.setTMatnfont(Label4,Label4.Width)
		Label3.Height  = 36%y-20%x
		Label4.Height = 36%y-20%x
		FrFname.Text = getFrFontName
		ArFname.Text = getArFontName
		Activity.AddView(p,0,39%y,100%x,84%y)
		Activity.GetView(menuIndex).Visible = False
		Activity.GetView(menuIndex).SetVisibleAnimated(200,True)
		Sleep(200)
'		If mode = 0 Then Af.Checked = True
'		If mode = 1 Then Ar.Checked = True
'		If mode = 2 Then Fr.Checked = True
		menu = True
	End If
	oldTarjomehView = TarjomehView
End Sub
'Sub NextP_Click
'	If pageIndex < pagelist.Size-1 Then
'		pageIndex = pageIndex+1
'		tm.Enabled = False
'		clv1.Clear
'		cur = s1.ExecQuery("select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
'		tm.Enabled = True
'	End If
'End Sub
'Sub PrevP_Click
'	If pageIndex > 0 Then
'		pageIndex = pageIndex-1
'		clv1.Clear
'		cur = s1.ExecQuery("select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
'		tm.Enabled = True
'	End If
'End Sub

Sub tm_Tick
	'Log(cur.RowCount)
	If clv1.Size = cur.RowCount Then
		If edameh And startItem < clv1.Size Then
			clv1.JumpToItem(startItem)
			clv1.Refresh
		End If
		If startItem > clv1.FirstVisibleIndex And startItem < clv1.LastVisibleIndex Then tm.Enabled = False
	Else
		If Not(edameh) Then tm.Enabled = False
		Dim lll As Label
		lll.Initialize("")
		lll.Text = "   "
		myf.setTMatnfont(lll,lll.Width)

		For i = 0 To cur.RowCount-1
			Dim p As B4XView = xui.CreatePanel("PanelMatn")
			cur.Position = i
			lll.Text = cur.GetString("ttext")
			lll.Width = 95%x
'			Select cur.GetInt("tType")
'				Case 1:
'					myf.setMatnEfont(lll,lll.Width)
'					p.Height = lll.Height + 2%y
'				Case 2:
'					myf.setTMatnfont(lll,lll.Width)
'					p.Height = lll.Height
'				Case 3:
'					myf.setTMatnfont(lll,lll.Width)
'					p.Height = lll.Height + 2%y
'				Case Else
'					myf.setTMatnfont(lll,lll.Width)
			p.Height = lll.Height
'			End Select
			p.Tag = -1
			p.Width = 98%x
			p.Left = 0
			p.Top = 0
			clv1.InsertAt(i,p,$"${-1}"$)
		Next
'		tm.Enabled = True
	End If

'	Create_loading
End Sub
'Sub tm1_Tick
'	tm1.Enabled = False
'	Create_Ntable4
'End Sub
'Sub QK_Click
'
'	Select JSTLabel.Tag
'		Case 1:
'			myf.setMatnfont(JSTLabel,JSTLabel.Width)
'		Case 2:
'			myf.setTMatnfont(JSTLabel,JSTLabel.Width)
'		Case 3:
'			myf.setOMatnfont(JSTLabel,JSTLabel.Width)
'		Case 4:
'			myf.setPMatnfont(JSTLabel,JSTLabel.Width)
'		Case Else
'			myf.setOMatnfont(JSTLabel,JSTLabel.Width)
'	End Select
'	JST.Initialize
'	If Main.JSTType = 1 Then
'		JSTLabel.Text=JST.JustifyByAddSpace(JSTLabel,JSTLabel.Text,False,0.35)
'	else if Main.JSTType = 2 Then
'		JSTLabel.Text=JST.JustifyByExtendWords(JSTLabel,JSTLabel.Text,False,0.35,False)
'	Else if Main.JSTType = 3 Then
'		JSTLabel.Text=JST.JustifyByExtendWords(JSTLabel,JSTLabel.Text,False,0.35,False)
'	End If
'End Sub
Sub CLV1_VisibleRangeChanged(FirstIndex As Int, LastIndex As Int)
	Dim ExSize = 5 As Int
	If clv1.Size = cur.RowCount Then
		For i = Max(0, FirstIndex) To Min(clv1.Size-1,LastIndex + ExSize)
			If clv1.Size > i And clv1.size > 0 Then
				
			If clv1.GetPanel(Min(i,clv1.Size-1)).Tag < 0 Then
				
				cur.Position = i
			 
				Dim pp As B4XView = xui.CreatePanel("PanelMatn")
	'		pp.Initialize("PanelMatn")
				pp.Width = 98%x
				pp.Height = 1%y
				pp.Left = 0
				pp.LoadLayout("pPanel")


				l1.Padding = Array As Int(5dip,0,5dip,0)
				lp1.Padding = Array As Int(5dip,0,5dip,0)
					
					l1.Text =  cur.GetString("ttext").Replace("ک","ك")
					lp1.Text = cur.GetString("ttext").Replace("ک","ك")
				
				Select cur.GetInt("tType")
					Case 1:
						
						If SetData.nmode Then l1.TextColor = 0xffe9e9e9 Else l1.TextColor = 0xFF021c1a'1b1448'0xff0a0a0a
						If SetData.nmode Then lp1.TextColor = 0xFFff7f6f Else lp1.TextColor = 0xff942b28'Colors.Red
						myf.setMatnfont(lp1,l1.Width)
							myf.setMatnEfont(l1,l1.Width)
'							If SetData.nmode Then p1.Color = 0x0Affffff Else p1.Color = 0x11000000
							If SetData.nmode Then p1.Color = 0x0Affffff Else p1.Color = 0xfff1ebda'xfffdf8e5

							If DatabaseName = "4.book" Then
								pp.Height = l1.Height + 2%y
								p1.Height = l1.Height
								p1.Top = 1%y
								l1.Gravity = Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
								lp1.Gravity = Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
							Else
								pp.Height = l1.Height + 2
								p1.Height = l1.Height
								p1.Top = 1
								l1.Gravity = Bit.Or(Gravity.CENTER_HORIZONTAL,Gravity.CENTER_VERTICAL)
								lp1.Gravity = Bit.Or(Gravity.CENTER_HORIZONTAL,Gravity.CENTER_VERTICAL)
							End If

						
						Case 2:
							
'							If SetData.nmode Then l1.TextColor = 0xffe9e9e9 Else l1.TextColor = Colors.DarkGray'0xff3b465c'0xFF021c1a'1b1448'0xff0a0a0a
'							If SetData.nmode Then lp1.TextColor = 0xFFff6f6f Else lp1.TextColor = Colors.DarkGray'Colors.Red
							If SetData.nmode Then l1.TextColor = Colors.LightGray Else l1.TextColor = Colors.DarkGray'0xff3b465c'0xFF021c1a'1b1448'0xff0a0a0a
							If SetData.nmode Then lp1.TextColor =Colors.LightGray Else lp1.TextColor = Colors.DarkGray'Colors.Red
							myf.setTMatnfont(lp1,l1.Width)
						myf.setTMatnfont(l1,l1.Width)
							If SetData.nmode Then p1.Color = 0x08ffffff Else p1.Color = 0xfffdf8e5'0xFFfdf8e5
						pp.Height = l1.Height+2
						p1.Height = l1.Height
						p1.Top = 1
						l1.Gravity = Bit.Or(Gravity.CENTER_HORIZONTAL,Gravity.CENTER_VERTICAL)
						lp1.Gravity = Bit.Or(Gravity.CENTER_HORIZONTAL,Gravity.CENTER_VERTICAL)
						
					Case 3:
							
						iconAShow = True
						If SetData.nmode Then l1.TextColor = 0xffe9e9e9 Else l1.TextColor = 0xFF021c1a'1b1448'0xff0a0a0a
						If SetData.nmode Then lp1.TextColor = 0xFFff6f6f Else lp1.TextColor = 0xff942b28'Colors.Red
							If SetData.nmode Then 
								p1.Color = 0x20ffffff
							Else 
								p1.Color = 0xfffcf5e2'0x40c4a263
							End If
'						If SetData.nmode Then p1.Color = 0x55d79548 Else p1.Color = 0xffc4a263'Colors.ARGB(50,0,200,200)
						myf.setOMatnfont(lp1,l1.Width)
						myf.setOMatnfont(l1,l1.Width)
					
						If iconAShow Then
							Dim iconA As ImageView
							iconA.Initialize("")
							iconA.Gravity = Gravity.FILL
							iconA.SetLayout(0,0,12%x,12%x)
							iconA.SetBackgroundImage(LoadBitmap(File.DirAssets,"iconAgha.png"))
							pp.Height = l1.Height+14%x
							p1.Height = l1.Height
							p1.Top = 14%x
							pp.AddView(iconA,pp.Width-13%x,1%x,12%x,12%x)
							iconAShow = False
						Else
							pp.Height = l1.Height + 2%y
							p1.Height = l1.Height
							p1.Top = 1%y
						End If

					
						l1.Gravity = Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
						lp1.Gravity = Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
						
					Case 4:
							If SetData.nmode Then l1.TextColor = Colors.White Else l1.TextColor = SetData.TopbackColor
							If SetData.nmode Then lp1.TextColor = Colors.White Else lp1.TextColor = SetData.TopbackColor
						
						'If SetData.nmode Then l1.TextColor = 0xffe9e9e9 Else l1.TextColor = 0xFF021c1a'1b1448'0xff0a0a0a
						'If SetData.nmode Then lp1.TextColor = 0xFFff6f6f Else lp1.TextColor = 0xff942b28'Colors.Red
							'If SetData.nmode Then l1.Color = 0x1866CDAA Else l1.Color = 0x3566CDAA
						myf.setPMatnfont(lp1,l1.Width)
						myf.setPMatnfont(l1,l1.Width)
							Private p1color As Int 
							If SetData.nmode Then 
								p1.Color = 0x1866CDAA
								p1color =  0x1866CDAA
							Else
								p1.Color = 0x2566CDAA
								p1color =  0x2566CDAA
							End If
'							If SetData.nmode Then p1.Color = 0x00ffffff Else p1.Color = 0x00000000
						
							If i-1 > 0 And clv1.Size > i-1 Then
								If clv1.GetPanel(i-1).GetView(0).Color <> p1color Then
									p1.Top = 3%x
									p1.Height = l1.Height
									pp.Height = l1.Height + 3%x
								Else													
									p1.Top = 1
									p1.Height = l1.Height
									pp.Height = l1.Height + 2
								End If
							End If


						l1.Gravity = Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
						lp1.Gravity = Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
							
					Case Else
							
						l1.Padding = Array As Int(0dip,0,0dip,0)
						lp1.Padding = Array As Int(0dip,0,0dip,0)
						If SetData.nmode Then l1.TextColor = 0xffe9e9e9 Else l1.TextColor = 0xFF021c1a'1b1448'0xff0a0a0a
						If SetData.nmode Then lp1.TextColor = 0xFFff6f6f Else lp1.TextColor = 0xff942b28'Colors.Red
						myf.setOMatnfont(lp1,l1.Width)
						myf.setOMatnfont(l1,l1.Width)
						If SetData.nmode Then p1.Color = 0x00ffffff Else p1.Color = 0x00000000
						pp.Height = l1.Height + 4
						p1.Height = l1.Height
						p1.Top = 4
						l1.Gravity = Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
						lp1.Gravity = Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
						
				End Select
						
				pp.Tag = i
				p1.Tag = i

				
				Dim plastH As Int = clv1.GetPanel(i).Height
					clv1.ReplaceAt(i,pp,pp.Height,$"${i}"$)
				

				If i < FirstIndex Then
					Dim delta As Int = pp.Height-plastH
					clv1.sv.ScrollViewOffsetY = clv1.sv.ScrollViewOffsetY+delta
					End If
				

					Try
						If clv1.Size > i Then
							Private str1 As String = clv1.GetPanel(i).GetView(0).GetView(0).Text
							Private str2 As String = clv1.GetPanel(i).GetView(0).GetView(1).Text
							JST.Initialize
							Sleep(10)
							If (searching And startItem = i And mode = 0)Then
								myf.Rangbandi(clv1.GetPanel(i).GetView(0).GetView(0),clv1.GetPanel(i).GetView(0).GetView(0).Text,True,searchPos,True,SetData)
								myf.Rangbandi(clv1.GetPanel(i).GetView(0).GetView(1),clv1.GetPanel(i).GetView(0).GetView(1).Text,True,searchPos,True,SetData)
							Else
								clv1.GetPanel(i).GetView(0).GetView(0).Text = JST.JustifyByAddSpace(clv1.GetPanel(i).GetView(0).GetView(0),clv1.GetPanel(i).GetView(0).GetView(0).Text,False,0.45)
								clv1.GetPanel(i).GetView(0).GetView(1).Text = JST.JustifyByAddSpace(clv1.GetPanel(i).GetView(0).GetView(1),clv1.GetPanel(i).GetView(0).GetView(1).Text,False,0.45)
								myf.Rangbandi(clv1.GetPanel(i).GetView(0).GetView(0) ,clv1.GetPanel(i).GetView(0).GetView(0).Text,False,0,True,SetData)
								myf.Rangbandi(clv1.GetPanel(i).GetView(0).GetView(1),clv1.GetPanel(i).GetView(0).GetView(1).Text,False,0,True,SetData)
							End If
							If clv1.GetPanel(i).GetView(0).GetView(0).Text = "" Then clv1.GetPanel(i).GetView(0).GetView(0).Text = str1
							If clv1.GetPanel(i).GetView(0).GetView(1).Text = "" Then clv1.GetPanel(i).GetView(0).GetView(1).Text = str2
						End If
				Catch
					Log(LastException)
				End Try
					

			End If
			End If
		Next
		
		
		If edameh And clv1.GetPanel(startItem).Tag >= 0 Then
			edameh = False
			edd.SetVisibleAnimated(313,edameh)
			If tm.Enabled Then 
'				Sleep(100)
				If startItem < clv1.Size Then clv1.JumpToItem(startItem)
			End If
			tm.Enabled = False
		End If
	End If
	LastFirstIndex = FirstIndex
End Sub
Sub Create_loading
	If cur.Position < cur.RowCount-1 Then
		Dim i = cur.Position+1 As Int
		cur.Position = i	

		
		Dim p As B4XView = xui.CreatePanel("")
		p.Tag = i
		p.Width = 96%x
		p.Height = 10%y
		p.Left = 0
		p.Top = 0
		clv1.InsertAt(i,p,$"${i}"$)
		
	Else
		tm.Enabled = False	
			
	End If
		
'		If mode = 0 Or mode = 2 Then
'			Dim string1 As String = cur.GetString("fttext")
'			
'			If Not(string1 = Null) Then 
'				If string1.CharAt(0) = "|" Then
'			
'					string1 = string1.SubString(1) 
'					Dim img3 As ImageView
'					img3.Initialize("PanelMatn")
'					img3.Tag = 0
'					img3.Gravity = Gravity.FILL
'					img3.Width = 80%x
'					img3.Height = 0.5%x
'					If Main.nmode Then
'						Dim BMPA As NegativeImage
'						img3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"pavaraghi.png")))
'					Else
'						img3.SetBackgroundImage(LoadBitmap(File.DirAssets,"pavaraghi.png"))
'					End If
'				End If
'			End If
'
'			Dim p1 As B4XView = xui.CreatePanel("")
'			Dim l2 As Label
'			l2.Initialize("PanelMatn")
'			l2.Width = 90%x
'			If searching And startItem = (i*pn)+1 And mode = 0 Then
'				myf.Rangbandi(l2,string1,True,searchPos,True)
'			Else
'				myf.Rangbandi(l2,string1,False,0,True)
'			End If
'			
'			If Main.nmode Then l2.TextColor = Colors.White Else l2.TextColor = 0xFF021c1a'1b1448'Colors.Black
'			l2.Left = 0
'			l2.Top = 0
'			myf.setTMatnfont(l2,l2.Width)
'			p1.Height = l2.Height
'			p1.Width = 90%x
'			l2.Gravity = Bit.Or(Gravity.CENTER_HORIZONTAL,Gravity.CENTER_VERTICAL)
'			p1.AddView(l2,5%x,0,l2.Width,l2.Height)
'			If Not(string1 = Null) Then
'				If cur.GetString("fttext").CharAt(0) = "|" Then p1.AddView(img3,clv1.AsView.Width/2-img3.Width/2,2.5%x,img3.Width,img3.Height)
'			Else
'				p1.Height = 0
'			End If
'			If mode = 2 Then
'				If cur.getint("tvasat") = 0 Or cur.Position = 0 Then l2.Gravity = Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
'				l2.Tag = i
'				clv1.InsertAt(i,p1,$"${cur.GetString("tpage")}"$)
'			Else
'				l2.Tag = (i*pn)+1
'				clv1.InsertAt((i*pn)+1,p1,$"${cur.GetString("tpage")}"$)
'			End If
'		End If

'		If i = 0 Then
'			Dim img3 As ImageView
'			img3.Initialize("PanelMatn")
'			img3.Tag = 0
'			img3.Gravity = Gravity.FILL
'			img3.Width = 5.4*8%x
'			img3.Height = 8%x
'			If Main.nmode Then
'				Dim BMPA As NegativeImage
'				img3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"mbeyt.png")))
'			Else
'				img3.SetBackgroundImage(LoadBitmap(File.DirAssets,"mbeyt.png"))
'			End If
'			
'			Dim hht As Int = clv1.GetPanel(0).Height
'			
'			clv1.ResizeItem(0,hht + img3.Height+5%x)
'			For i = 0 To clv1.GetPanel(0).NumberOfViews-1
'				clv1.GetPanel(0).GetView(i).Top = img3.Height+5%x
'			Next
'			
'			clv1.GetPanel(0).AddView(img3,clv1.AsView.Width/2-img3.Width/2,2.5%x,img3.Width,img3.Height)
'			If mode = 0 Then
'				If Main.nmode Then clv1.GetPanel(0).Color = 0x22ffffff Else clv1.GetPanel(0).Color = 0x11000000
'			End If
'		End If
'	End If
	If edameh And startItem < clv1.Size Then
		clv1.JumpToItem(startItem)
		clv1.Refresh
		If clv1.FirstVisibleIndex = startItem Or clv1.LastVisibleIndex = clv1.Size-1 Then
			edameh = False
			edd.SetVisibleAnimated(313,edameh)
		End If
	End If
End Sub
Sub PanelMatn_Click
	If mlongclick.Visible Then mlongclick.SetVisibleAnimated(313,False)
End Sub
Sub PanelMatn_LongClick
	Dim v As View
	v = Sender
	pnesh.Tag = v.Tag
	mlongclick.SetVisibleAnimated(313,True)
End Sub
'Sub et1_TextChanged(old As String,new As String)
'	tm.Enabled = False
'	tm1.Enabled = True
'	clv1.Clear
'	Dim sqlSt As String
'	If new.Length > 0 Then
'		Dim searchStr = new As String
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
'		sqlSt = "SELECT * FROM table2 where ((fttitle1 LIKE '%"&searchStr&"%') and (tindex >= 3 and tindex <= 244))"
'	Else
'		sqlSt = "select * from table2 where tindex >= 3 and tindex <= 244"
'	End If
'	cur = s1.ExecQuery(sqlSt)
'	For i = 0 To Min(20,cur.RowCount-1)
'		cur.Position = i
'		Dim l1 As Label
'		l1.Initialize("")
'		l1.Width = 90%x
'		myf.Rangbandi(l1,cur.GetString("fttitle"),False,0,True)
'		If Main.nmode Then l1.TextColor = Colors.White Else l1.TextColor = Colors.Black
'		l1.Left = 0
'		l1.Top = 0
'		myf.setfrfont(l1,l1.Width)
'		clv1.InsertAt(i,l1,$"${cur.GetInt("tindex")}"$)
'		clv1.GetPanel(i).Width = 90%x
'		clv1.GetPanel(i).Left = 5%x
'		If i Mod 2 = 0 Then
'			If Main.nmode Then clv1.GetPanel(i).Color = 0x22888888 Else clv1.GetPanel(i).Color = 0x11000000
'		End If
'	Next
'	tm.Enabled = True
'End Sub
'Sub clv1_ScrollChanged(Position As Int)
''	If tm1.Enabled = False Then NoFocus
'	
'End Sub
'Sub CLV1_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
'	If clv1.Size > 0 Then 
'		Dim str As String = clv1.GetValue(FirstIndex)
'		Label1.Text = str.Replace("[","").Replace("]","")
'	End If
'	Panel1.RemoveAllViews
'	Dim lp2 As Label
'	lp2.Initialize("")
'	lp2.Width = 90%x
'	lp2.Text = clv1.GetValue(FirstIndex)
'	If Main.nmode Then lp2.TextColor = Colors.White Else lp2.TextColor = Colors.Black
'	myf.setNotefont(lp2,lp2.Width)
'	lp2.Color = 0x00ffffff
'	lp2.Left = 0
'	lp2.Top = 0
'	lp2.Height = Panel1.Height
'	Panel1.AddView(lp2,50%x-lp2.Width/2,0,lp2.Width,lp2.Height)
'End Sub
'Sub clv1_ReachEnd
'	
'End Sub
'Sub NoFocus
'	Dim ime2 As IME
'	ime2.Initialize("")
'	ime2.HideKeyboard
'	et2.RequestFocus
'End Sub
Sub Activity_KeyPress(KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_MEDIA_PLAY_PAUSE Then Button1_Click
	If KeyCode = KeyCodes.KEYCODE_MEDIA_PREVIOUS Then 
		startItem = clv1.FirstVisibleIndex
		For i = 0 To clv1.Size-1
			clv1.GetPanel(i).Tag = -1
		Next
		clv1.Refresh
		If onvanha.search Then
			searchPos = sPos.Get(sidx)
			startItem = tpart.Get(sidx)
		End If
		edd.Visible = True
		edameh = True
		tm.Enabled = True
	End If
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		If ScrollView1.Visible = True Then
			ScrollView1.SetVisibleAnimated(100,False)
			CopyText.Visible = False
			ShareText.Visible = False
			Button3.Visible = True
			Button4.Visible = True
			NextB.Visible = True
			PrevB.Visible = True
			Dim cur1 As Cursor = s1.ExecQuery("select * from table2 where tindex =" & matnIdx)
			cur1.Position = 0
			et1.Text = cur1.GetString("ttitle")
			NightDaySel
			Return True
		else If mlongclick.Visible Then
			mlongclick.SetVisibleAnimated(313,False)
			Return True
		else If menu Then
			Button1_Click
			Return True
		Else 
			Activity.Finish
			myf.SetAnimation("left_right","left_right1")
		End If
	End If
	Return False
End Sub
'Sub PanelMatn_Click
'	If Panel1.Visible Then
'		Panel1.Visible = False
'		Panel2.Visible = False
'	Else
'		Panel1.Visible = True
'		Panel2.Visible = True
'	End If
'	ToastMessageShow("Af_Click",False)
'End Sub
'Sub clv1_ItemClick(Index As Int, Value As Object)
'
''	Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'tindex'")
''	If cur1.RowCount > 0 Then
''		s1.ExecNonQuery("update prevTable set val = " & Value)
''	Else
''		s1.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& Value&")")
''	End If
'
'
''	NoFocus
'End Sub
Sub Activity_Resume
	myf.Loading(SetData)
	NightDaySel
	If edameh Then edd.Visible = edameh
	If edameh And startItem < clv1.Size Then
		clv1.JumpToItem(startItem)
		clv1.Refresh
		If clv1.FirstVisibleIndex = startItem Or clv1.LastVisibleIndex = clv1.Size-1 Then
			edameh = False
			edd.SetVisibleAnimated(313,edameh)
		End If
	End If
'	If searching And searchItem(sidx) < clv1.Size Then
'		clv1.JumpToItem(startItem)
'		clv1.Refresh
'		If clv1.FirstVisibleIndex = startItem Or clv1.LastVisibleIndex = clv1.Size-1 Then
'			edameh = False
'			edd.SetVisibleAnimated(313,edameh)
'		End If
'	End If
'	If Main.nmode = False Then
'		Activity.Color = Main.backColor
'		For i = 0 To clv1.Size-1
'			If clv1.GetPanel(i).NumberOfViews > 1 And mode = 0 Then
'				clv1.GetPanel(i).GetView(1).TextColor = 0xFF021c1a'1b1448
'				clv1.GetPanel(i).GetView(0).TextColor = 0xff942b28
'				If i Mod 2 = 0 Then
'					If Main.nmode Then clv1.GetPanel(i).Color = 0x22ffffff Else clv1.GetPanel(i).Color = 0x11000000
'				End If
'			Else
'				clv1.GetPanel(i).GetView(0).GetView(0).TextColor = 0xFF021c1a'1b1448
'			End If
'		Next
'	Else
'		Activity.Color = 0x002223
'		For i = 0 To clv1.Size-1
'			
'			If clv1.GetPanel(i).NumberOfViews > 1 And mode = 0 Then
'				clv1.GetPanel(i).GetView(1).TextColor = Colors.White
'				clv1.GetPanel(i).GetView(0).TextColor = 0xFFff6f6f
'				If i Mod 2 = 0 Then
'					If Main.nmode Then clv1.GetPanel(i).Color = 0x22ffffff Else clv1.GetPanel(i).Color = 0x11000000
'				End If
'			Else
'				clv1.GetPanel(i).GetView(0).TextColor = Colors.White
'			End If
'			
'		Next
'	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then
		onvanha.search = False
		cur=s1.ExecQuery("select * from Edameh")
		If cur.RowCount = 0 Then
			cur.Close
			s1.ExecNonQuery("insert into Edameh VALUES(" & matnIdx &",'"& et1.Text & "',"&clv1.FirstVisibleIndex&","&booksel&")")
		Else
			cur.Close
			s1.ExecNonQuery("update Edameh set idonvan="  & matnIdx &",onvanSel='"&et1.Text & "',ItemNumber=" &clv1.FirstVisibleIndex & ",bookidx=" & booksel)
		End If
		Activity.Finish
'		myf.SetAnimation("left_right","left_right1")
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
Sub toastTm_Tick
	If DateTime.Now-LastToastTime > toastTm.Interval Then
		toastTm.Enabled = False
		ToastText.Visible = False
	End If
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
'Sub Create_Ntable4
'	Dim offs As Long = DateTime.Now
'	Dim pp As Panel
'	pp.Initialize("")
'	pp.Width = 98%x
'	pp.Height = 1%y
'	pp.Left = 0
'	pp.LoadLayout("pp1")
'	Activity.AddView(pp,100%x,0,100%x,100%y)
'	Artext.Padding = Array As Int(5dip,0,5dip,0)
'	Frtext.Padding = Array As Int(5dip,0,5dip,0)
'	myf.setEDArfont(Artext,Artext.Width)
'	myf.setEDFrfont(Frtext,Frtext.Width)
'	Sleep(1000)
''	s1.BeginTransaction
''	s2.ExecNonQuery("delete from Ntable4")
''	s1.EndTransaction
'	'cur = s1.ExecQuery("select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart")
'	If TarjomehView = 1 Then
'		sqlString = "select * from Ntable3 where tindex =" & matnIdx & " ORDER BY tpart"
'	Else
'		sqlString = "select * from Ntable3 where tindex =" & matnIdx & " and tType != 2 ORDER BY tpart"
'	End If
'	cur = s1.ExecQuery(sqlString)
'	Dim ntindex,ntpart = 1,ntType As Int
'	Dim cur1 As Cursor
''	s1.BeginTransaction
'	For i = 0 To cur.RowCount-1
'		cur.Position = i
'		ntindex = cur.GetInt("tindex")
'		ntType  = cur.GetInt("tType")
'		Dim elseText As String = cur.GetString("ttext")
'		Artext.Text = ""
'		Frtext.Text = ""
'		If ntType = 1 Then
'			If cur.Position < cur.RowCount-1 Then
'				i = i+1
'				cur.Position = i
'				If cur.GetInt("tType") = 2 Then
'					Artext.Text = elseText
'					Frtext.Text = cur.GetString("ttext")
'					elseText = ""
'				Else
'					i = i-1
'					cur.Position = i
'				End If
'			End If
'		End If
'		If elseText == "" Then
'			Dim oCS1,oCS2 As CSBuilder
'			Dim ArLinelist,FrLinelist As List
'			ArLinelist.Initialize
'			FrLinelist.Initialize
'			ArLinelist = GetEditTextLines(Artext, Artext.Text, oCS1)
'			FrLinelist = GetEditTextLines(Frtext, Frtext.Text, oCS2)
'			Dim begin1,end1,begin2,end2 As Int
'			For j = 0 To Min(ArLinelist.Size,FrLinelist.Size)
'				
'				If j = 0 Then
'					begin1 = 0
'					begin2 = 0
'				Else
'					begin1 = ArLinelist.Get(j-1)
'					begin2 = FrLinelist.Get(j-1)
'				End If
'				If j = ArLinelist.Size Then
'					end1 = Artext.Text.Length
'				Else
'					end1 = ArLinelist.Get(j)
'				End If
'				If j = FrLinelist.Size Then
'					end2 = Frtext.Text.Length
'				Else
'					end2 = FrLinelist.Get(j)
'				End If
'				
'				cur1 = s2.ExecQuery("insert into Ntable4 VALUES("& matnIdx &","& ntpart &",1,'"& Artext.Text.SubString2(begin1,end1) & "','',0)")
'				ntpart = ntpart + 1
'				cur1 = s2.ExecQuery("insert into Ntable4 VALUES("& matnIdx &","& ntpart &",2,'"& Frtext.Text.SubString2(begin2,end2) & "','',0)")
'				ntpart = ntpart + 1
'				'Log(Artext.Text.SubString2(begin1,end1))
'				'Log(Frtext.Text.SubString2(begin2,end2))
'			Next
'			For j = 1 + Min(ArLinelist.Size,FrLinelist.Size) To Max(ArLinelist.Size,FrLinelist.Size)
'				If ArLinelist.Size > FrLinelist.Size Then
'					If j = 0 Then
'						begin1 = 0
'					Else
'						begin1 = ArLinelist.Get(j-1)
'					End If
'					If j = ArLinelist.Size Then
'						end1 = Artext.Text.Length
'					Else
'						end1 = ArLinelist.Get(j)
'					End If
'					cur1 = s2.ExecQuery("insert into Ntable4 VALUES("& matnIdx &","& ntpart &",1,'"& Artext.Text.SubString2(begin1,end1) & "','',0)")
'					ntpart = ntpart + 1
'					'Log(Artext.Text.SubString2(begin1,end1))
'				End If
'				If ArLinelist.Size < FrLinelist.Size Then
'					If j = 0 Then
'						begin2 = 0
'					Else
'						begin2 = FrLinelist.Get(j-1)
'					End If
'					If j = FrLinelist.Size Then
'						end2 = Frtext.Text.Length
'					Else
'						end2 = FrLinelist.Get(j)
'					End If
'					cur1 = s2.ExecQuery("insert into Ntable4 VALUES("& matnIdx &","& ntpart &",2,'"& Frtext.Text.SubString2(begin2,end2) & "','',0)")
'					ntpart = ntpart + 1
'					'Log(Frtext.Text.SubString2(begin2,end2))
'				End If
'			Next
''			ntpart = ntpart + ArLinelist.Size+1 + FrLinelist.Size+1
'		Else
'			cur1 = s2.ExecQuery("insert into Ntable4 VALUES("& matnIdx &","& ntpart &","& ntType &",'"& elseText & "','',0)")
'			ntpart = ntpart + 1
'		End If
'	Next
''	s1.ExecNonQuery("update Ntable3 set ttext1 = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace (replace(ttext,'ٰ',''), 'ِ', ''),'ٍ',''),'ْ',''),'ّ','' ),'ٌ',''),'ُ',''),'ً',''),'َ',''),'ى', 'ي'),'ی','ي'),'ك','ک') ,'إ','ا') ,'أ','ا')")
'	'Log(ntpart)
'	'Log(DateTime.Now-offs)
'End Sub
Sub GetEditTextLines(edt As EditText, strText As String, oCS As CSBuilder) As List
	Dim i As Int
	Dim xy() As Int
	Dim iYOld As Int
	Dim lstLineStarts As List
   
	If oCS.IsInitialized Then
		strText = oCS.ToString
	End If
	lstLineStarts.Initialize
	For i = 0 To strText.Length
		SetSelection(edt, i, i)
		xy = GetEditTextXYCursor(edt)
		If xy(1) > iYOld Then
			lstLineStarts.Add(i)
		End If
		iYOld = xy(1)
	Next
	Return lstLineStarts
End Sub
'Selects the text between the two indexes. 
Sub SetSelection(edt As EditText, StartIndex As Int, EndIndex As Int)
	Dim jo = edt As JavaObject
	jo.RunMethod("setSelection", Array As Object(StartIndex, EndIndex))
End Sub
'gets the x and y coordinates of the cursor in an EditText view 
Sub GetEditTextXYCursor(edt As EditText) As Int()
	Dim joEditText As JavaObject
	Dim joLayout As JavaObject
	Dim PaddingLeft As Int
	Dim PaddingTop As Int
	Dim ScrollY As Int
	Dim Pos As Int
	Dim Line As Int
	Dim LineBaseline As Int
	Dim xy(2) As Int
	joEditText = edt
	PaddingLeft = joEditText.RunMethod("getPaddingLeft", Null)
	PaddingTop = joEditText.RunMethod("getPaddingTop", Null)
	ScrollY = joEditText.RunMethod("getScrollY", Null)
	Pos = joEditText.RunMethod("getSelectionStart", Null)
	joLayout = joEditText.RunMethod("getLayout", Null)
	Line = joLayout.RunMethod("getLineForOffset", Array As Object(Pos)) 'line number
	LineBaseline = joLayout.RunMethod("getLineBaseline", Array As Object(Line))
	xy(0) = joLayout.RunMethod("getPrimaryHorizontal", Array As Object(Pos)) + PaddingLeft
	xy(1) = LineBaseline + PaddingTop - ScrollY 'base line
	Return xy
End Sub

Private Sub et1_Click
	If ScrollView1.Visible  = False Then
'		If booksel = 1 Then
		cur  = s1.ExecQuery("select * from table2 where tindex ="& onvanha.idonvan)
'		else If booksel = 2 Then
'			cur  = s1.ExecQuery("select * from table2 where tindex ="& onvanha.idonvan)
'		else If booksel = 3 Then
'			cur  = s1.ExecQuery("select * from tf1table2 where tindex ="& onvanha.idonvan)
'		End If
		
		cur.Position = 0
		Dim lastLeveltidx = onvanha.idonvan As Int
		Dim level = cur.GetInt("tlevel")-1 As Int
		Dim l11 = level As Int
		Dim str1(10) As String
		Dim str2 = "" As String
		For i = 0 To 9
			str1(i) = ""
		Next
		Do While level > 0
'			If booksel = 8 Then
			cur  = s1.ExecQuery("select * from table2 where (tlevel ="& level & " and tindex < " &lastLeveltidx & ") ORDER BY tindex")
'			else If booksel = 2 Then
'				cur  = s1.ExecQuery("select * from table2 where (tlevel ="& level & " and tindex < " &lastLeveltidx & ") ORDER BY tindex")
'			else If booksel = 3 Then
'				cur  = s1.ExecQuery("select * from tf1table2 where (tlevel ="& level & " and tindex < " &lastLeveltidx & ") ORDER BY tindex")
'			End If
			
			cur.Position = cur.RowCount-1

			str1(level) = cur.GetString("ttitle")
			
			level = level-1
			lastLeveltidx = cur.GetInt("tindex")
		Loop
		For i = 1 To l11
			str2 = str2 & str1(i) & CRLF
		Next
		str2 = "مسیر فهرست" & CRLF & str2 & et1.Text
		
		ScrollView1.Width = 100%x
		ScrollView1.Left = 0
		EditCopy.Text = str2
		EditCopy.TextSize=JSTLabel.TextSize
		EditCopy.Width = ScrollView1.Width
		
		EditCopy.Left = 0
		EditCopy.Top = 0
		EditCopy.TextColor = Colors.Black
		EditCopy.Color = SetData.backColor


		myf.setEditCopyMatnfont(EditCopy,clv1.sv.Width)
		EditCopy.Gravity = Bit.Or(Gravity.TOP, Gravity.RIGHT)
		myf.setLineSpace(EditCopy,1.5)
		If EditCopy.Height < 100%y Then
			ScrollView1.Panel.Height=100%y
			EditCopy.Height = 100%y
		Else
			ScrollView1.Panel.Height = EditCopy.Height
		End If
		ScrollView1.ScrollPosition = 0
		ScrollView1.SetVisibleAnimated(100,True)

		Button1.Visible = False
		Button3.Visible = False
		Button4.Visible = False
		CopyText.Visible = True
		ShareText.Visible = True
		NextB.Visible = False
		PrevB.Visible = False
	End If
End Sub

Private Sub Tarjomeh_CheckedChange(Checked As Boolean)
		If Checked Then
			File.WriteString(File.DirInternal,"Tarjomeh","1")
			TarjomehView = 1
			changeSetting = True
		Else
			File.WriteString(File.DirInternal,"Tarjomeh","0")
			TarjomehView = 0
			changeSetting = True
		End If
	If oldTarjomehView <> TarjomehView Then
		ToastMessageShow("با تغییر حالت نمایش ترجمه، نشانه‌های درج شده حذف خواهد شد.",True)
	End If
End Sub

Private Sub Tabs_TabClick(index As Int)
	If index = 0 Then
		Panel2.Visible = True
		Panel1.Visible = False
	Else
		Panel1.Visible = True
		Panel2.Visible = False
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