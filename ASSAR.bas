B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
	
#End Region

Sub Process_Globals
	Private xui As XUI
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Dim pageSel As Int
	Private Downloader As RangeDownloader
	Private imgidx As Int
	Dim PlayTimer,DmTimer As Timer
	Dim pos As Long
	Dim changepos As Boolean
	Dim fileHttpPath As String
	Private ifSts As IFStatus
	Private SPPing As Ping
	
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private iprev,ishare,inext  As Button
	Private clv1 As CustomListView
	Private ImageView1,ImageView2  As ImageView
	Dim booklst As List
	Dim p,p1 As Panel
	Private bookName As Label
	Private bookPic As ImageView
	Private AsarPanel As Panel
	Private bookD As Label
	Private subButton As Button
	Dim SetData As AppSetting
	Private Playb As Button
	Private PlayBar As SeekBar
	Dim mp As MediaPlayer
	Private LIV1 As LoadingIndicatorView
	Dim mp3fileName As String
	Dim MatnStr As String
	Private downloadBar As ProgressBar
	Private prLabel As Label
	Dim dowloading As Boolean
	Dim tracker As RangeDownloadTracker
	
	Dim trCount As Int
	Private SimpleExoPlayerView1 As SimpleExoPlayerView
	Private player1 As SimpleExoPlayer
	Dim mp4Playing As Boolean
	Private FS As Label
	Private Panel1 As Panel
'	Private WebView1 As WebView
	Private Agha As ImageView
	Private Provider As FileProvider
	Private Panel2 As Panel
	Private p2 As Panel
	Private Button1 As Button
	Private Img1 As ImageView
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	pageSel = 5
	Activity.RemoveAllViews
	myf.Loading(SetData)
	ifSts.Initialize(Me, "SPIFStatus")
	SPPing.Initialize(Me, "SPPing")
	
	Provider.Initialize
	matnha.klmc = False
	trCount = 0
	PlayTimer.Enabled = False
	DmTimer.Enabled = False
	
	If pageSel = 1 Then
		imgidx = 1
		Activity.LoadLayout("subMenu1")
		ImageView2.SetBackgroundImage(LoadBitmap(File.DirAssets,imgidx & ".jpg"))
		ImageView1.Width = 0
	else If pageSel = 2 Then
		Activity.LoadLayout("backSubMenu")
		Activity.LoadLayout("backClvSubMenu")
		subButton.SetBackgroundImage(LoadBitmap(File.DirAssets,"b3.png"))
		myf.booklibAddress = File.DirInternal & "/F.Matni/"
		booklst.Initialize
		Wait For (File.ListFilesAsync(myf.booklibAddress)) Complete (Success As Boolean, Files As List)
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
		Dim jo = clv1.sv As JavaObject
		jo.RunMethod("setVerticalScrollbarPosition", Array As Object (1))   ' position left
	
		Dim r As Reflector
		r.Target = clv1.sv
		r.Target = r.GetField("mScrollCache")
		r.Target = r.GetField("scrollBar")
		clv1.Clear
		Dim strFree As String = "  1. فرمایشات متنی"
		clv1.InsertAtTextItem(0,strFree,0)
		strFree = "  2. کلماتی چند"
		clv1.InsertAtTextItem(1,strFree,1)
		
	else If pageSel = 3 Then
		Activity.LoadLayout("mp3player")
		Dim jo = clv1.sv As JavaObject
		jo.RunMethod("setVerticalScrollbarPosition", Array As Object (1))   ' position left
		Dim r As Reflector
		r.Target = clv1.sv
		r.Target = r.GetField("mScrollCache")
		r.Target = r.GetField("scrollBar")
		Dim cd As ColorDrawable
		cd.Initialize(0x11FFFFFF, 5dip)
		myf.ChangeScrollbarColor(clv1.sv, cd)
		
		onvanha.idonvan = File.ReadString(File.DirInternalCache,"onvanha.txt")
		Dim path As String = File.ReadString(File.DirInternalCache,"bookAddr.txt")
		Dim DatabaseName As String = File.ReadString(File.DirInternalCache,"booksel.txt")
		Dim s1 As SQL
		myf.DatabesOpen(s1,path,DatabaseName,False)
		Dim cur As Cursor = s1.ExecQuery("select replace(ttext,'أ','أ') from table3 where tindex="&onvanha.idonvan)
		cur.Position=0
		MatnStr = cur.GetString2(0)
		
		fileHttpPath = MatnStr.SubString(MatnStr.IndexOf("@")+1)
		mp3fileName = MatnStr.SubString(MatnStr.LastIndexOf("/")+1)
		mp.Initialize
		
		clv1.Clear
		Dim strFree As String = MatnStr.SubString2(1,MatnStr.IndexOf("@")-1)
		clv1.InsertAtTextItem(0,strFree,0)
			
		If Starter.dowloading = False And File.Exists(File.DirRootExternal  & "/Sadeghin/" & "/mp3/",mp3fileName) Then
			PlayBar.Visible = True
			downloadBar.Visible = False
				LIV1.Left = 140%x
				mp.Load(File.DirRootExternal  & "/Sadeghin/" & "/mp3/",mp3fileName)
				Playb.SetBackgroundImage(LoadBitmap(File.DirAssets,"play.png"))
				Playb.Enabled = True
				PlayBar.Max = mp.Duration
				PlayTimer.Initialize("PlayTimer",500)
				PlayTimer.Enabled = False
				dowloading = False
		Else
			PlayBar.Visible = False
			dowloading = True
			If Starter.dowloading Then
				If Starter.fileHttpPath = fileHttpPath And Starter.mp3fileName = mp3fileName Then
					DmTimer.Initialize("DmTimer",1000)
					DmTimer.Enabled = True
					Starter.onvan = onvanha.onvanSel
					prLabel.Visible = True
				Else
					prLabel.Visible = True
					prLabel.Text = " در حال دانلود فایل قبلی  "
					If pageSel = 4 Then prLabel.Color = 0X55000000
					prLabel.Width = -2
				End If
				
			End If
			
			
		End If

	else If pageSel = 4 Then
		Activity.LoadLayout("mp4player")
		FS.Visible = False
		
		Dim jo = clv1.sv As JavaObject
		jo.RunMethod("setVerticalScrollbarPosition", Array As Object (1))   ' position left
		player1.Initialize("player")
		
		onvanha.idonvan = File.ReadString(File.DirInternalCache,"onvanha.txt")
		Dim path As String = File.ReadString(File.DirInternalCache,"bookAddr.txt")
		Dim DatabaseName As String = File.ReadString(File.DirInternalCache,"booksel.txt")
		Dim s1 As SQL
		myf.DatabesOpen(s1,path,DatabaseName,False)
		Dim cur As Cursor = s1.ExecQuery("select replace(ttext,'أ','أ') from table3 where tindex="&onvanha.idonvan)
		cur.Position=0
		MatnStr = cur.GetString2(0)
		
	
		fileHttpPath = MatnStr.SubString(MatnStr.IndexOf("@")+1)
		If DatabaseName = "301.book" Then mp3fileName = onvanha.idonvan & ".mp4"
		If DatabaseName = "303.book" Then mp3fileName = "m" & onvanha.idonvan & ".mp4"
		If DatabaseName = "302.book" Then mp3fileName = "k" & onvanha.idonvan & ".mp4"
		
		Panel1.Color = Colors.Black
		clv1.Clear
		Dim strFree As String = MatnStr.SubString2(1,MatnStr.IndexOf("@")-1)
		clv1.InsertAtTextItem(0,strFree,0)
		If DatabaseName = "301.book" Then
			If onvanha.idonvan <= 27 Then
				Img1.SetBackgroundImage(LoadBitmap(File.DirAssets,"V" & onvanha.idonvan & ".jpg"))
				Dim h1 As Int = LoadBitmap(File.DirAssets,"V" & onvanha.idonvan & ".jpg").Height
				Dim w1 As Int = LoadBitmap(File.DirAssets,"V" & onvanha.idonvan & ".jpg").Width
				Img1.Width = (Img1.Height * w1) / h1
				Img1.Left = SimpleExoPlayerView1.Width/2 - Img1.Width/2
			End If
		else if DatabaseName = "303.book" Then
			If onvanha.idonvan <= 16 Then
				Img1.SetBackgroundImage(LoadBitmap(File.DirAssets,"mV" & onvanha.idonvan & ".jpg"))
				Dim h1 As Int = LoadBitmap(File.DirAssets,"mV" & onvanha.idonvan & ".jpg").Height
				Dim w1 As Int = LoadBitmap(File.DirAssets,"mV" & onvanha.idonvan & ".jpg").Width
				Img1.Width = (Img1.Height * w1) / h1
				Img1.Left = SimpleExoPlayerView1.Width/2 - Img1.Width/2
			End If
		else if DatabaseName = "302.book" Then
			If onvanha.idonvan <= 26 Then
				Img1.SetBackgroundImage(LoadBitmap(File.DirAssets,"kV" & onvanha.idonvan & ".jpg"))
				Dim h1 As Int = LoadBitmap(File.DirAssets,"kV" & onvanha.idonvan & ".jpg").Height
				Dim w1 As Int = LoadBitmap(File.DirAssets,"kV" & onvanha.idonvan & ".jpg").Width
				Img1.Width = (Img1.Height * w1) / h1
				Img1.Left = SimpleExoPlayerView1.Width/2 - Img1.Width/2
			End If
		End If

		SimpleExoPlayerView1.Visible = False
		Img1.Visible = True
		If Starter.dowloading = False And File.Exists(File.DirRootExternal & "/Sadeghin/" & "/mp4/",mp3fileName) Then
			dowloading = False
			downloadBar.Visible = False
			FS.Visible = True
			LIV1.Left = 140%x
			Panel1.Visible = True
			Playb.Visible = False
			SimpleExoPlayerView1.Visible = True
			Img1.Visible = False
			Panel1.SetColorAnimated(100,0,0xff000000)
			Dim sources As List
			sources.Initialize
			sources.Add(player1.CreateFileSource(File.DirRootExternal & "/Sadeghin/" & "/mp4/",mp3fileName))
			player1.Prepare(player1.CreateListSource(sources))
			SimpleExoPlayerView1.Player = player1
			If changepos Then
				player1.Position = pos
				changepos = False
			End If
'			PlayTimer.Initialize("PlayTimer",500)
'			PlayTimer.Enabled = False
		Else
			dowloading = True
			Playb.Visible = True
			prLabel.Visible = True
		End If
	else If pageSel = 5 Then
		
		Activity.LoadLayout("backSubMenu")
		Activity.LoadLayout("backClvSubMenu")
		subButton.SetBackgroundImage(LoadBitmap(File.DirAssets,"b5.png"))
		
		myf.Loading(SetData)
	If File.Exists(File.DirRootExternal & "/Sadeghin/","1.book") Then
			myf.booklibAddress = File.DirRootExternal & "/Sadeghin/"
	Else
			myf.booklibAddress = File.DirInternal & "/ASSAR/"
	End If
		
		
		booklst.Initialize
		Wait For (File.ListFilesAsync(myf.booklibAddress)) Complete (Success As Boolean, Files As List)
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
			cd.Initialize(0xffc4a263, 5dip)
		End If
		myf.ChangeScrollbarColor(clv1.sv, cd)
'		r.RunMethod4("setVerticalThumbDrawable", Array(cd), Array As String("android.graphics.drawable.Drawable"))
		Dim clvp As Panel
		clvp.Initialize("")
		clvp.Left = 0
		clvp.Width = 100%x
		clvp.Top = 0
		clvp.Height = 100%y
		clvp.LoadLayout("AsarItem")
		bookPic.SetBackgroundImage(LoadBitmap(File.DirAssets,"anis1.png"))
		bookName.Text = "انیس الصادقین"
		bookD.Text = "توصیه‌هایی از عالم ربانی حضرت آیت الله سید حسین یعقوبی قائنی در زمینه‌ی ادعیه و اذکار"
		clvp.RemoveAllViews
		clv1.Add(AsarPanel,$"${1}"$)
		clvp.LoadLayout("AsarItem")
		bookPic.SetBackgroundImage(LoadBitmap(File.DirAssets,"saffr.png"))
		bookName.Text = "سفینة الصادقین"
		bookD.Text = "شرح حال عالم ربانی آقای حاج سید حسین یعقوبی قائنی رضوان الله تعالی علیه"
		clvp.RemoveAllViews
		clv1.Add(AsarPanel,$"${2}"$)
		clvp.LoadLayout("AsarItem")
		bookPic.SetBackgroundImage(LoadBitmap(File.DirAssets,"safar.png"))
		bookName.Text = "سفینة الصادقین"
		bookD.Text = "سیرة حیاة العالم الربانی سماحة آیة الله السید حسین الیعقوبی القائنی رضوان الله تعالی علیه"
		clvp.RemoveAllViews
		clv1.Add(AsarPanel,$"${3}"$)
		
		File.WriteList(File.DirInternalCache,"booklst.txt",booklst)
	else If pageSel = 6 Then
		
	else If pageSel = 7 Then
		Activity.LoadLayout("backSubMenu")
		Activity.LoadLayout("backClvSubMenu")
		subButton.SetBackgroundImage(LoadBitmap(File.DirAssets,"b2.png"))
		Dim jo = clv1.sv As JavaObject
		jo.RunMethod("setVerticalScrollbarPosition", Array As Object (1))   ' position left
	
		Dim r As Reflector
		r.Target = clv1.sv
		r.Target = r.GetField("mScrollCache")
		r.Target = r.GetField("scrollBar")
		clv1.Clear
		Dim strFree As String = "  1. فرمایشات صوتی"
		clv1.InsertAtTextItem(0,strFree,0)
		strFree = "  2. سخنرانی‌ها"
		clv1.InsertAtTextItem(1,strFree,1)

	else If pageSel = 8 Then
		Activity.LoadLayout("backMadahi")
		Activity.LoadLayout("backClvSubMenu")
		subButton.SetBackgroundImage(LoadBitmap(File.DirAssets,"b4.png"))
		Dim jo = clv1.sv As JavaObject
		jo.RunMethod("setVerticalScrollbarPosition", Array As Object (1))   ' position left
	
		Dim r As Reflector
		r.Target = clv1.sv
		r.Target = r.GetField("mScrollCache")
		r.Target = r.GetField("scrollBar")
		clv1.Clear
		Dim strFree As String = "   1. پیغمبر اکرم صلی الله علیه وآله وسلم"
		clv1.InsertAtTextItem(0,strFree,0)
		strFree = "   2. امیرالمومنین علیه السلام"
		clv1.InsertAtTextItem(1,strFree,1)
		strFree = "   3. حضرت فاطمه زهرا سلام الله علیها"
		clv1.InsertAtTextItem(2,strFree,1)
		strFree = "   4. حضرت اباعبدالله الحسین علیه السلام"
		clv1.InsertAtTextItem(3,strFree,1)
		strFree = "   5. ماه محرم"
		clv1.InsertAtTextItem(4,strFree,1)
		strFree = "   6. حضرت علی بن موسی الرضا علیه السلام"
		clv1.InsertAtTextItem(5,strFree,1)
		strFree = "   7. امام زمان «عجل الله تعالی فرجه الشریف»"
		clv1.InsertAtTextItem(6,strFree,1)
		strFree = "   8. ادعیه و زیارات"
		clv1.InsertAtTextItem(7,strFree,1)
	Else If pageSel = 9 Then
		Activity.LoadLayout("backMadahi")
		Activity.LoadLayout("backClvSubMenu")
		subButton.SetBackgroundImage(LoadBitmap(File.DirAssets,"b6.png"))
		Dim jo = clv1.sv As JavaObject
		jo.RunMethod("setVerticalScrollbarPosition", Array As Object (1))   ' position left
	
		Dim r As Reflector
		r.Target = clv1.sv
		r.Target = r.GetField("mScrollCache")
		r.Target = r.GetField("scrollBar")
		clv1.Clear
		Dim strFree As String = "   1. فرمایشات تصویری"
		clv1.InsertAtTextItem(0,strFree,0)
		strFree = "   2. منتخب کلام"
		clv1.InsertAtTextItem(1,strFree,1)		
		strFree = "   3. مداحی تصویری"
		clv1.InsertAtTextItem(2,strFree,2)
	End If
End Sub
'Private Sub Track (tracker1 As RangeDownloadTracker)
'	downloadBar.Visible = True
'	Do While tracker1.Completed = False
'		Sleep(100)
'		prLabel.Text = "در حال دانلود فایل  ......  " & $"$1.2{tracker1.CurrentLength / 1024 / 1024}MB / $1.2{tracker1.TotalLength / 1024 / 1024}MB"$
'		downloadBar.Progress = tracker1.CurrentLength / tracker1.TotalLength * 100
'	Loop
'End Sub
'Sub Activity_Touch (Action As Int, X As Float, Y As Float)	
'	If Action = Activity.ACTION_DOWN Then
'		x2 = X
'		x3 = 0
'	
'	Else if Action = Activity.ACTION_MOVE Then
'		x3 = x - x2
'		Log(x3)
'	Else if Action = Activity.ACTION_UP Then
'		x3 = x - x2
'		Log(x3)
'		If x3 > 25%x Then	
'			If imgidx < 12 Then imgidx = imgidx+1
'		Else if x3 < -25%x Then
'			If imgidx > 1 Then imgidx = imgidx-1
'		End If
'		ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,imgidx & ".jpg"))
''		If p.Left > 250 Then
''			p.Enabled = False
'''			p.SetLayoutAnimated(400,p.Width,0,p.Width,p.Height)
'''			Sleep(400)
'''			Activity.Finish
''		Else
''		p.SetLayoutAnimated(400,0,0,p.Width,p.Height)
''		End If
'		
'	End If
'	
'End Sub
Sub iprev_Click
	ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,imgidx & ".jpg"))
	ImageView2.SetBackgroundImage(LoadBitmap(File.DirAssets,imgidx & ".jpg"))
	ImageView1.Width = 100%x
	ImageView2.Width = 100%x
	ImageView1.Left = 0
	ImageView2.Left = 0
	If imgidx > 1 Then imgidx = imgidx-1
	If imgidx = 1 Then iprev.Visible = False
	inext.Visible = True
	ImageView2.SetBackgroundImage(LoadBitmap(File.DirAssets,imgidx & ".jpg"))
	ImageView1.SetLayoutAnimated(300,0,50%y-75.048828125%x,1%x,150.09765625%x)
	Sleep(300)
	ImageView1.Width = 0
End Sub


Sub ishare_Click
	Dim FileName As String = imgidx & ".jpg"
	File.Copy(File.DirAssets, FileName, Provider.SharedFolder, FileName)
	Dim in As Intent
	in.Initialize(in.ACTION_SEND, "")
	in.SetType("image/jpg")
	in.PutExtra("android.intent.extra.STREAM", Provider.GetFileUri(FileName))
	in.Flags = 1 'FLAG_GRANT_READ_URI_PERMISSION
	StartActivity(in)
End Sub

Sub inext_Click
	ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,imgidx & ".jpg"))
	ImageView2.SetBackgroundImage(LoadBitmap(File.DirAssets,imgidx & ".jpg"))
	ImageView1.Width = 0
	ImageView2.Width = 100%x
	ImageView1.Left = 0
	ImageView2.Left = 0
	If imgidx < 12 Then imgidx = imgidx+1
	If imgidx = 12 Then inext.Visible = False
	iprev.Visible = True
	ImageView1.SetBackgroundImage(LoadBitmap(File.DirAssets,imgidx & ".jpg"))
	ImageView1.SetLayoutAnimated(300,0,50%y-75.048828125%x,100%x,150.09765625%x)
End Sub
Sub Anis1_Click
	myf.DatabesOpen(Main.s1,myf.booklibAddress,booklst.Get(0),True)
	File.WriteString(File.DirInternalCache,"bookAddr.txt",myf.booklibAddress)
	File.WriteString(File.DirInternalCache,"booksel.txt",booklst.Get(0))
	File.WriteString(File.DirInternalCache,"booktype.txt","4")
	StartActivity(onvanha)
	myf.SetAnimation("right_left1","right_left")
	Activity.Finish
End Sub
Sub SafAr_Click
	myf.DatabesOpen(Main.s1,myf.booklibAddress,booklst.Get(1),True)
	File.WriteString(File.DirInternalCache,"bookAddr.txt",myf.booklibAddress)
	File.WriteString(File.DirInternalCache,"booksel.txt",booklst.Get(1))
	File.WriteString(File.DirInternalCache,"booktype.txt","8")
	StartActivity(onvanha)
	myf.SetAnimation("right_left1","right_left")
	Activity.Finish
End Sub
Sub SafFr_Click
	myf.DatabesOpen(Main.s1,myf.booklibAddress,booklst.Get(2),True)
	File.WriteString(File.DirInternalCache,"bookAddr.txt",myf.booklibAddress)
	File.WriteString(File.DirInternalCache,"booksel.txt",booklst.Get(2))
	File.WriteString(File.DirInternalCache,"booktype.txt","8")
	StartActivity(onvanha)
	myf.SetAnimation("right_left1","right_left")
	Activity.Finish
End Sub
Sub Activity_Resume
'	Activity_Create(False)
End Sub

Sub Activity_Pause (UserClosed As Boolean)

	If UserClosed Then
		If pageSel = 3 Then
			If mp.IsPlaying Then
				mp.Stop
				mp.Release
			End If		
		else if pageSel = 4 Then
			If player1.IsPlaying Then
				player1.Pause
				player1.Release
			End If
		End If


		If pageSel = 3 Then	
'			If dowloading Then
'				File.Delete(File.DirRootExternal & "/Sadeghin/" & "/mp3/",mp3fileName)
'			End If
			Activity.Finish
			myf.SetAnimation("left_right","left_right1")
		else if pageSel = 4 Then
'			If dowloading Then
'				File.Delete(File.DirRootExternal & "/Sadeghin/" & "/mp4/",mp3fileName)
'			End If
			Activity.Finish
			myf.SetAnimation("left_right","left_right1")
		End If
	End If
End Sub
Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		If pageSel = 3 Or pageSel = 4 Then
			
		Else
			 StartActivity(Main)
		End If
		myf.SetAnimation("left_right","left_right1")
		ExitApplication
'		Activity.Finish
		Return True
	End If
	Return False
End Sub
Sub klmch_Click
	myf.DatabesOpen(Main.s1,myf.booklibAddress,booklst.Get(0),True)
	File.WriteString(File.DirInternalCache,"bookAddr.txt",myf.booklibAddress)
	File.WriteString(File.DirInternalCache,"booksel.txt",booklst.Get(0))
	File.WriteString(File.DirInternalCache,"booktype.txt","8")
	Dim cur=Main.s1.ExecQuery("select * from table1 ") As Cursor
	cur.Position = 0
	onvanha.onvanSel = cur.GetString2(0)
	onvanha.idonvan = 1
	File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
	cur.Close
	matnha.edameh = False
	matnha.klmc = True
	StartActivity(matnha)
	myf.SetAnimation("right_left1","right_left")
	Activity.Finish
'	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub F_Matni_Click
	myf.DatabesOpen(Main.s1,myf.booklibAddress,booklst.Get(1),True)
	File.WriteString(File.DirInternalCache,"bookAddr.txt",myf.booklibAddress)
	File.WriteString(File.DirInternalCache,"booksel.txt",booklst.Get(1))
	File.WriteString(File.DirInternalCache,"booktype.txt","8")
	StartActivity(onvanha)
	myf.SetAnimation("right_left1","right_left")
	Activity.Finish
'	myf.SetAnimation("left_right","zoom_exit")
End Sub
Sub clv1_ItemClick (Index As Int, Value As Object)
	If pageSel = 2 Then
		If Index = 0 Then
			F_Matni_Click
		else if Index = 1 Then
			klmch_Click
		End If
	else If pageSel = 5 Then
		If Index = 0 Then
			Anis1_Click
		else if Index = 1 Then
			SafFr_Click
		else if Index = 2 Then
			SafAr_Click
		End If
	else if pageSel = 7 Then
		F_Soti_Click((201+Index) & ".book")
	else if pageSel = 8 Then
		F_Soti_Click((203+Index) & ".book")
		
	else if pageSel = 9 Then
		F_Tasviri_Click((301+Index) & ".book")
	End If
End Sub
Private Sub F_Tasviri_Click(dbname As String)
	myf.booklibAddress = File.DirInternal & "/F.Tasviri/"
	File.WriteString(File.DirInternalCache,"bookAddr.txt",myf.booklibAddress)
	File.WriteString(File.DirInternalCache,"booksel.txt",dbname)
	File.WriteString(File.DirInternalCache,"booktype.txt","8")
	StartActivity(onvanha)
	myf.SetAnimation("right_left1","right_left")
	Activity.Finish
End Sub
Private Sub F_Soti_Click(dbname As String)
	myf.booklibAddress = File.DirInternal & "/F.Soti/"
	File.WriteString(File.DirInternalCache,"bookAddr.txt",myf.booklibAddress)
	File.WriteString(File.DirInternalCache,"booksel.txt",dbname)
	File.WriteString(File.DirInternalCache,"booktype.txt","8")
	StartActivity(onvanha)
	myf.SetAnimation("right_left1","right_left")
	Activity.Finish
End Sub
Private Sub PlayBar_ValueChanged (Value As Int, UserChanged As Boolean)
	If UserChanged Then
		mp.Position = Value
		Dim min1,sec1,min3,sec3 As String
		Dim min2,sec2,min4,sec4 As Int
		min2 = mp.Position / 60000
		If min2 < 10 Then
			min1 = "0" & min2
		Else
			min1 = min2
		End If
		sec2 = (mp.Position/1000) Mod 60
		If sec2 < 10 Then
			sec1 = "0" & sec2
		Else
			sec1 = sec2
		End If
		min4 = mp.Duration / 60000
		If min4 < 10 Then
			min3 = "0" & min4
		Else
			min3 = min4
		End If
		sec4 = (mp.Duration/1000) Mod 60
		If sec4 < 10 Then
			sec3 = "0" & sec4
		Else
			sec3 = sec4
		End If
		prLabel.Text = min1 & ":" & sec1 & " / " & min3 & ":" & sec3
		prLabel.Width = -2
	End If
End Sub

Private Sub PlayTimer_Tick
	If pageSel = 3 Then
		If mp.IsPlaying Then
			PlayBar.Value = mp.Position
			Dim min1,sec1,min3,sec3 As String
			Dim min2,sec2,min4,sec4 As Int
			min2 = mp.Position / 60000
			If min2 < 10 Then
				min1 = "0" & min2
			Else
				min1 = min2
			End If
			sec2 = (mp.Position/1000) Mod 60
			If sec2 < 10 Then
				sec1 = "0" & sec2
			Else
				sec1 = sec2
			End If
			min4 = mp.Duration / 60000
			If min4 < 10 Then
				min3 = "0" & min4
			Else
				min3 = min4
			End If
			sec4 = (mp.Duration/1000) Mod 60
			If sec4 < 10 Then
				sec3 = "0" & sec4
			Else
				sec3 = sec4
			End If
			prLabel.Text = min1 & ":" & sec1 & " / " & min3 & ":" & sec3
			prLabel.Width = -2
		Else
			mp.Pause
			Playb.SetBackgroundImage(LoadBitmap(File.DirAssets,"play.png"))
			PlayTimer.Enabled = False
			PlayBar.Value = 0
		End If
	else if pageSel = 4 Then
		If player1.IsPlaying And dowloading = False Then
			Dim min1,sec1,min3,sec3 As String
			Dim min2,sec2,min4,sec4 As Int
			min2 = player1.Position / 60000
			If min2 < 10 Then
				min1 = "0" & min2
			Else
				min1 = min2
			End If
			sec2 = (mp.Position/1000) Mod 60
			If sec2 < 10 Then
				sec1 = "0" & sec2
			Else
				sec1 = sec2
			End If
			min4 = player1.Duration / 60000
			If min4 < 10 Then
				min3 = "0" & min4
			Else
				min3 = min4
			End If
			sec4 = (player1.Duration/1000) Mod 60
			If sec4 < 10 Then
				sec3 = "0" & sec4
			Else
				sec3 = sec4
			End If
			prLabel.Text = min1 & ":" & sec1 & " / " & min3 & ":" & sec3
			prLabel.Width = -2
		End If
	End If

End Sub
Private Sub DmTimer_Tick
	If Starter.dowloading Then
		If Starter.fileHttpPath = fileHttpPath And Starter.mp3fileName = mp3fileName Then
			prLabel.Text = Starter.downStatus
			If pageSel = 4 Then prLabel.Color = 0X55000000
			prLabel.Width = -2
			downloadBar.Visible = True
		Else
			prLabel.Visible = True
			prLabel.Text = "  در حال دانلود فایل قبلی  "
			If pageSel = 4 Then prLabel.Color = 0X55000000
			prLabel.Width = -2
		End If
	Else
		Activity.RemoveAllViews
		Activity_Create(False)
	End If
End Sub
Private Sub Playb_Click
	If dowloading Then
		If Starter.conState Then	
			dowloading = True
			If Starter.dowloading = False Then
				downloadBar.Visible = True
				Starter.dowloading = True
				Starter.fileHttpPath = fileHttpPath
				Starter.mp3fileName = mp3fileName
				If pageSel = 3 Then
					Starter.trStr = File.DirRootExternal & "/Sadeghin/" & "/mp3/"
				else if pageSel = 4 Then
					Starter.trStr = File.DirRootExternal & "/Sadeghin/" & "/mp4/"
				End If
				Starter.DmTimer.Enabled = True
				DmTimer.Initialize("DmTimer",1000)
				DmTimer.Enabled = True
				Starter.onvan = onvanha.onvanSel
				prLabel.Visible = True
			End If
			
		Else
			prLabel.Visible = True
			prLabel.Text = "  اینترنت در دسترس نیست  "
			If pageSel = 4 Then prLabel.Color = 0X55000000
			prLabel.Width = -2
		End If
	Else
		If pageSel = 3 Then
			Try
				If mp.IsPlaying Then
					mp.Pause
					Playb.SetBackgroundImage(LoadBitmap(File.DirAssets,"play.png"))
					PlayTimer.Enabled = False
				Else
					mp.Play
					Playb.SetBackgroundImage(LoadBitmap(File.DirAssets,"stop.png"))
					PlayTimer.Enabled = True
				End If
		
			Catch
				Log(LastException)
			End Try
		End If
	End If
End Sub


Sub Player_Ready
	Log("Ready")
End Sub

Sub Player_Error (Message As String)
	Log("Error: " & Message)
End Sub

Sub Player_Complete
	Log("complete")
End Sub

Private Sub FS_Click
	changepos = False
	Mp3View.pos = player1.Position
	player1.Pause
	player1.Release
	StartActivity(Mp3View)
	Activity.Finish
'	Dim jo As JavaObjectac
'	Dim FullScreenIsDestination As Boolean = True
'	Dim player As Object = player1
'	jo.InitializeStatic("androidx.media.ui.PlayerView")
'	jo.RunMethod("switchTargetView", Array(player, IIf(FullScreenIsDestination,player1, SimpleExoPlayerView1), IIf(FullScreenIsDestination, SimpleExoPlayerView1, player1)))
'	Dim x As B4XView = Panel1
'	x.Rotation = 90
'	x.Left = 0
'	x.Width = 100%x
'	x.Top = 0
'	x.Height = 100%y
'	Dim player As JavaObject = player1
'	player.InitializeStatic("androidx.media3.ui.PlayerView")
'	player.RunMethod("switchTargetView", Array(player, IIf(FullScreenIsDestination, player1, SimpleExoPlayerView1), IIf(FullScreenIsDestination, SimpleExoPlayerView1, player1)))
End Sub

Private Sub clv1_ScrollChanged (Offset As Int)
	If pageSel = 3 Or pageSel = 4 Then
		If Offset = (clv1.sv.ScrollViewContentHeight-Panel2.Height+2%y+1) Then
			p1.Visible = False
		Else
			p1.Visible = True
		End If
		If Offset = 0 Then
			p2.Visible = False
		Else
			p2.Visible = True
		End If
	End If

End Sub

Private Sub Button1_Click
	If Starter.conState Then
		Downloader.Initialize
		dowloading = True
		DmTimer.Initialize("DmTimer",1000)
		DmTimer.Enabled = True
	Else
		ToastMessageShow("اینترنت در دسترس نیست",False)
	End If
'	If Not (ifSts.IPs.IsIfConnected) Then
'		ifSts.GetIfChanged(True)
'		ifSts.Start(0)
'		Log("no network")
'		ToastMessageShow("NO connection",False)
'	Else
'		ifSts.GetIfChanged(True)
'		Log(SPPing.pingResult.Success)
'		ToastMessageShow("connected",False)
'	End If

End Sub
'Private Sub SPPing_PingStarted
'
'End Sub
'
'Private Sub SPPing_PingFinished
'	If SPPing.pingResult.Success Then
'		Log("--- Ping info ---")
'		Log("Ping Success: " & SPPing.pingResult.Success)
'		Log("Ping To host: " & SPPing.pingResult.toHost)
'		Log("Ping To IP: " & SPPing.pingResult.toIP)
'		Log("Ping From host: " & SPPing.pingResult.fromDest)
'		For Each bteKey As Byte In SPPing.pingResult.mapResponse.Keys
'			Dim seqMap As Map = SPPing.pingResult.mapResponse.Get(bteKey)
'			Log("Ping Sequence " & bteKey & " - TTL : " & seqMap.Get("ttl") & " - Time : " & seqMap.Get("time"))
'		Next
'		Dim stats As Map = SPPing.pingResult.mapStatistics
'		Log("Internet connected?: " & SPPing.pingResult.Success)
'		Log("Ping Packets transmitted: " & stats.Get("packets transmitted"))
'		Log("Ping Packets received: " & stats.Get("received"))
'		Log("Ping Packets loss: " & stats.Get("packet loss"))
'		Log("Ping Round Trip Time (Minimum): " & stats.Get("rtt min"))
'		Log("Ping Round Trip Time (Average): " & stats.Get("rtt agv"))
'		Log("Ping Round Trip Time (Maximum): " & stats.Get("rtt max"))
'		Log("Ping Round Trip Time (Mean Deviation): " & stats.Get("rtt mdev"))
'	End If
'End Sub
'
'Private Sub SPPing_PingError(Msg As String)
'	Log(Msg)
'End Sub
'
'Private Sub SPIFStatus_SocketStarted (Port As Int)
'
'End Sub
'
'Private Sub SPIFStatus_SocketClosed
'
'End Sub
'
'Private Sub SPIFStatus_ConnectionStatusChanged (IPStatus As tpeIPs)
'	If ifSts.IPs.IsIfConnected Then
'		Log("--- Interface General info ---")
'		Log("Interface connected?: " & ifSts.IPs.IsIFConnected)
'		Log("Connection type: " & ifSts.IPs.ConnType)
'		Log("Local IP: " & ifSts.IPs.IP)
'		SPPing.Destination = "https://mesbah-sadeghin.ir/"
'		SPPing.Attempts = 1
'		SPPing.Timeout = 200
'		SPPing.Start
'	End If
'End Sub
'
'Private Sub SPIFStatus_Error (Msg As String)
'
'End Sub
