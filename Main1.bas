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
#Extends: android.support.v7.app.AppCompatActivity
'Activity module

Sub Process_Globals
'	Dim FitemNum As Int
'	Dim backColor As Int
'	Dim TopbackColor As Int
'	Dim txtFont As Int
'	Dim lineSpace As Double
'	Dim Menufontsize As Int
'	Dim fontSize As Int
'	Dim BfontSize As Int
'	Dim JSTType As Int
'	Dim nmode As Boolean
'	Dim ErColor As Boolean
'	Dim Justify As Boolean
'	Dim s,s1 As SQL
'	Dim FirstStart As Boolean
	Dim tm1 As Timer
	Dim toastTm As Timer
	Dim logoView As Boolean = True
End Sub

Sub Globals
	Private ImageView1,Agha As ImageView
	Private logo As ImageView
	Private Fehrest,Montakhb,LastRead,Abut As Button
	Private ToastText As Label
	'Private Label1,Label2,Label3,Label4 As Label
	Dim LastToastTime As Int
	Dim abPnl As Boolean = False
	Dim abpPnlIDX As Int = 0
	Private AboutB,SearchB As Button
	Dim libRootFolder = "" As String
	dim SetData as AppSetting
End Sub

Sub Activity_Create(FirstTime As Boolean)
	
	Activity.LoadLayout("Main")
	Activity.LoadLayout("logo")
	Dim split As Int = 80%y - 119.384%x
	Dim topOffset As Int = 10%y

	If split > 5 Then
		Agha.Top = topOffset + split/5
		topOffset = Agha.Top+Agha.Height+split/5
		LastRead.Top = topOffset
		topOffset = LastRead.Top+LastRead.Height+split/5
		Abut.Top = topOffset
		topOffset = Abut.Top+Abut.Height+split/5
		Montakhb.Top = topOffset
	End If
	
	SearchB.Visible = False
	AboutB.Visible = False
	tm1.Initialize("tm1",100)
	tm1.Enabled = True
	libview.booklstTitle = "دانشنامه علوی"
	Activity_Touch (Activity.ACTION_DOWN, 100, 100)
'	myf.LogMemory
'	ToastMessageShow2("نسخه آزمایشی"&CRLF&"لطفا این نسخه از برنامه را منتشر ننمایید",True)

End Sub
Sub AboutB_Click
'	Dim i As Int
'	i = Msgbox2("درباره ...","","درباره‌ی خانه نهج‌البلاغه","","درباره‌ی برنامه",Null)
'	Select i
'		Case DialogResponse.CANCEL
'			
'		Case DialogResponse.NEGATIVE
'			StartActivity(about1)
'			myf.SetAnimation("left_right","zoom_exit")
'		Case DialogResponse.POSITIVE
'			StartActivity(about)
'			myf.SetAnimation("left_right","zoom_exit")
'	End Select
End Sub
Sub tm1_Tick
	myf.Loading(Main.s,SetData)
	tm1.Enabled = False
	'NightOrDayModeSel
'	tm1.Enabled = False
'	ToastText.Visible = False
End Sub
Sub NightOrDayModeSel
'	If nmode Then
'		Dim BMPA As NegativeImage
'		Activity.Color = Colors.Black
'		Fehrest.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"menu_btn3.png")))
'		Fehrest.SetTextColorAnimated(100,Colors.White)
'		Montakhb.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"menu_btn3.png")))
'		Montakhb.SetTextColorAnimated(100,Colors.White)
'		LastRead.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"menu_btn3.png")))
'		LastRead.SetTextColorAnimated(100,Colors.White)
'	ImageView1.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"xxstart.png")))
'	Else
	If logoView = False Then
		'Activity.Color = 0xff7dce19
'		Fehrest.SetBackgroundImage(LoadBitmap(File.DirAssets,"menu_btn3.png"))
'		Fehrest.SetTextColorAnimated(100,Colors.Black)
'		Montakhb.SetBackgroundImage(LoadBitmap(File.DirAssets,"menu_btn3.png"))
'		Montakhb.SetTextColorAnimated(100,Colors.Black)
'		LastRead.SetBackgroundImage(LoadBitmap(File.DirAssets,"menu_btn3.png"))
'		LastRead.SetTextColorAnimated(100,Colors.Black)
'		Abut.SetBackgroundImage(LoadBitmap(File.DirAssets,"menu_btn3.png"))
'		Abut.SetTextColorAnimated(100,Colors.Black)
'		ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,"xxstarta.png"))
	End If
End Sub
Sub Abut_Click
	Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'booknum'")
	If cur1.RowCount > 0 Then
		Main.s.ExecNonQuery("update prevTable set val = 4  where name = 'booknum'")
	Else
		Main.s.ExecNonQuery("insert into prevTable VALUES(4,'booknum',4)")
	End If
	cur1.Close
	
	StartActivity(KHOTAB)
	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub Fehrest_Click
	Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'booknum'")
	If cur1.RowCount > 0 Then
		Main.s.ExecNonQuery("update prevTable set val = 2  where name = 'booknum'")
	Else
		Main.s.ExecNonQuery("insert into prevTable VALUES(2,'booknum',2)")
	End If
	
	cur1=Main.s.ExecQuery("select * from table2 ")
'	FitemNum = cur1.RowCount
	cur1.Close
	StartActivity(KHOTAB)
	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub Montakhb_Click
	Dim cur As Cursor = Main.s.ExecQuery("select * from Edameh")
	If cur.RowCount = 1 Then
		cur.Position = 0
		onvanha.search = False
		onvanha.idonvan = cur.GetInt("idonvan")
		onvanha.onvanSel = cur.GetString("onvanSel")
		Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'booknum'")
		If cur1.RowCount > 0 Then
			Main.s.ExecNonQuery("update prevTable set val = "&cur.GetString("bookidx")&"  where name = 'booknum'")
		Else
			Main.s.ExecNonQuery("insert into prevTable VALUES(3,'booknum',"&cur.GetString("bookidx")&")")
		End If
		Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'tindex'")
		If cur1.RowCount > 0 Then
			Main.s.ExecNonQuery("update prevTable set val = " & onvanha.idonvan)
		Else
			Main.s.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& onvanha.idonvan&")")
		End If
		If cur.GetString("bookidx") = 4 Then
			Motoon.edameh = True
			Motoon.startItem = cur.GetInt("ItemNumber")
			cur.Close
			StartActivity(Motoon)
			myf.SetAnimation("left_right","zoom_exit")
		Else
			matnha.edameh = True
			matnha.startItem = cur.GetInt("ItemNumber")
			cur.Close
			StartActivity(matnha)
			myf.SetAnimation("left_right","zoom_exit")
		End If
	End If
End Sub
Sub LastRead_Click
	Sleep(200)
	File.WriteString(File.DirInternalCache,"booklibAddress.txt",File.DirInternal & "/ASSAR/")
	File.WriteString(File.DirInternalCache,"booklstTitle.txt",libview.booklstTitle)
	Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'booknum'")
	If cur1.RowCount > 0 Then
		Main.s.ExecNonQuery("update prevTable set val = 8  where name = 'booknum'")
	Else
		Main.s.ExecNonQuery("insert into prevTable VALUES(8,'booknum',8)")
	End If
	StartActivity(libview)
	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub SearchB_Click
	Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'booknum'")
	If cur1.RowCount > 0 Then
		Main.s.ExecNonQuery("update prevTable set val = 4  where name = 'booknum'")
	Else
		Main.s.ExecNonQuery("insert into prevTable VALUES(4,'booknum',4)")
	End If
	
	cur1=Main.s.ExecQuery("select * from table2 ")

	StartActivity(SearchM)
	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub Activity_Resume
	NightOrDayModeSel
End Sub

Sub B01_Click
	Dim cur1 As Cursor = Main.s.ExecQuery("select * from prevTable where name = 'tindex'")
	If cur1.RowCount > 0 Then
		Main.s.ExecNonQuery("update prevTable set val = 1")
	Else
		Main.s.ExecNonQuery("insert into prevTable VALUES(1,'tindex',1)")
	End If
	StartActivity(Motoon)
	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub B02_Click
	StartActivity(KHOTAB)
	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub B03_Click
	StartActivity(Nameha)
	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub B04_Click
	StartActivity(hekam)
	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub B05_Click
	StartActivity(gharaeb)
	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub Activity_Pause(UserClosed As Boolean)
	If UserClosed Then ExitApplication
End Sub
Sub toastTm_Tick
	If DateTime.Now-LastToastTime > toastTm.Interval Then
		toastTm.Enabled = False
		ToastText.Visible = False
	End If
End Sub
Sub Activity_Touch (Action As Int, X As Float, Y As Float)
	If Action = Activity.ACTION_DOWN  And logoView = True Then
		logo.SetVisibleAnimated(626,False)
		ImageView1.SetVisibleAnimated(313,True)
		Sleep(313)
		toastTm.Initialize("toastTm",2000)
		logoView = False
'		Dim b As Bitmap
'		b.Initialize(File.DirAssets,"menu_btn3.png")
'		Dim hwz As Float = b.Width/b.Height
'		Dim topoff As Float = ((100%y-110%x)/2-((80%x/hwz)*3.6)/2)
'		Abut.SetLayout(10%x,topoff+48%y,80%x,80%x/hwz)
		Abut.SetVisibleAnimated(313,True)
'		Fehrest.SetLayout(10%x,topoff+48%y+Abut.Height*1.3,80%x,80%x/hwz)
'		Fehrest.SetVisibleAnimated(313,True)
'		Montakhb.SetLayout(10%x, topoff+48%y+Abut.Height*2.6,80%x,80%x/hwz)
		Montakhb.SetVisibleAnimated(313,True)
'		LastRead.SetLayout(10%x, topoff+48%y+Abut.Height*3.9,80%x,80%x/hwz)
		LastRead.SetVisibleAnimated(313,True)
		AboutB.Visible = True
		SearchB.Visible = True
'		Dim r As Reflector
'		r.Target = Fehrest
'		r.SetOnTouchListener("Fehrest_Touch")
'		r.Target = Montakhb
'		r.SetOnTouchListener("Montakhb_Touch")
'		r.Target = LastRead
'		r.SetOnTouchListener("LastRead_Touch")
'		r.Target = Abut
'		r.SetOnTouchListener("Abut_Touch")
		NightOrDayModeSel
'		tm1.Initialize("tm1",100)
'		tm1.Enabled = True
'		Label1.Top = (Fehrest.Top + Fehrest.Height/2) - Label1.Height/2
'		Label1.SetVisibleAnimated(1000,True)
'		Label1.TextColor = Colors.Black
'		Label2.Top = (Montakhb.Top + Montakhb.Height/2) - Label2.Height/2
'		Label2.SetVisibleAnimated(1000,True)
'		Label2.TextColor = Colors.Black
'		Label3.Top = (LastRead.Top + LastRead.Height/2) - Label3.Height/2
'		Label3.SetVisibleAnimated(1000,True)
'		Label3.TextColor = Colors.Black
'		Label4.Top = (Abut.Top + Abut.Height/2) - Label4.Height/2
'		Label4.SetVisibleAnimated(1000,True)
'		Label4.TextColor = Colors.Black
	
'	ToastMessageShow2("در حال بارگذاری برنامه...",True)
'	Sleep(5)
		myf.Loading(Main.s,SetData)

	End If
End Sub
Sub Activity_KeyPress(KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		If logoView Then
			Activity_Touch(Activity.ACTION_DOWN,0,0)
		Else if abPnl Then
			abPnl = False
			Abut.Visible = True
'			Fehrest.Visible = True
			Montakhb.Visible = True
			LastRead.Visible = True
			Activity.RemoveViewAt(abpPnlIDX)
'		else if ToastText.Visible = False Then
'			LastToastTime = DateTime.Now
'			toastTm.Enabled = True
'			ToastMessageShow2("جهت خروج دوباره کلیک کنید",True)
'		Else if toastTm.Enabled Then
		Else
			Activity.Finish
			myf.SetAnimation("right_left1", "zoom_exit")
		End If
		
'		Dim i As Int
'		i = Msgbox2("جهت خروج دوباره کلیک کنید","","","","",Null)
'		Select i
'			Case DialogResponse.CANCEL  
'				Activity.Finish
'			Case DialogResponse.NEGATIVE  
'				'Return True
'			Case DialogResponse.POSITIVE 
		''				Try
		''					Dim inte As Intent
		''					inte.Initialize(inte.ACTION_EDIT,"bazaar://details?id=" & Application.PackageName)
		''					StartActivity(inte)
		''				Catch
		''					Dim p As PhoneIntents
		''					StartActivity(p.OpenBrowser("https://cafebazaar.ir/app/" & Application.PackageName & "/?l=fa"))
		''				End Try
		''				Return True
'		End Select
	End If
	Return True
End Sub

Sub ToastMessageShow2(STR As String,LD As Boolean)
	ToastText.Color = Colors.White
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
	ToastText.Top = 35%y+ToastText.Height/2
	ToastText.Visible = True
End Sub