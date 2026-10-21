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
	Private xui As XUI
	Dim toastTm As Timer
	Dim startTm As Timer
End Sub

Sub Globals
	Dim cur As Cursor
	Private Label1 As Label
	Dim JST As TeamEightJustifyBeta
	'Dim Report As Label
	Dim QK As Button
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
	
	Private Button1,Button3,Button4,CopyText,ShareText As Button
	Private ScrollView1 As ScrollView
	Dim EditCopy As ACEditText
	Dim sidxPidx As Int
	Dim LastFirstIndex As Int = 0
	Private pnl1 As Panel
	Private xui As XUI
	Private cvs As Canvas
	Private ShPanel As Panel
	Private ToastText As Label
	Dim LastToastTime As Int = 0
	Private NextB,PrevB,SearchB,NightM,AboutB,SettingB,CopyB   As Button
	Dim pvisible As Boolean = False
	Dim Mark As Boolean
	Dim refreshView As Boolean = False
End Sub

Sub Activity_Create(FirstTime As Boolean)
	If refreshView = False Then
		Activity.LoadLayout("l_matnha")
		CallSubDelayed(Me,"QK_Click")
		EditCopy.Initialize("EditCopy")
		EditCopy.Gravity = Gravity.TOP
		EditCopy.Padding = Array As Int (5%x,5%x,5%x,5%x)
		Dim jo = EditCopy As JavaObject
		jo.RunMethod("setCursorVisible",Array As Object(True))
		jo.RunMethod("setTextIsSelectable",Array As Object(True))
		ScrollView1.Panel.AddView(EditCopy,0,0,ScrollView1.Width,ScrollView1.Height)
		toastTm.Initialize("toastTm",1000)
		startTm.Initialize("StartTm",20)
		LIV1.IndicatorId = 17
		LIV1.IndicatorColor = Colors.Gray
		NightOrDayModeSel
		ScrollView1.Visible = False
		
		JSTLabel.Width = 90%x
		JSTLabel.Height = 76%y
		myf.setMatnfont(JSTLabel,clv1.sv.Width-7%x)
		
		myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
		cvs.Initialize(pnl1)
		myf.loadThemes(cvs,Main.nmode)
		myf.DatabesCopy(Main.s,"a.dat",True)
		Button3.Visible = True
		Button4.Visible = True
		clv1.Base_Resize(clv1.AsView.Width,100%y-5%y-23*100%x/642-(46*100%x/642+10%x+7*100%x/642))
		Label1.TextSize=20
		Label1.Typeface=Typeface.LoadFromAssets("adobearabicbold.ttf")
	End If
	clv1.Clear
	clv1.AnimationDuration = 0
	
	


	cur=Main.s.ExecQuery("select tindex from marktable where tindex="&onvanha.idonvan)
	If cur.RowCount = 1 Then Mark = True Else Mark = False
	cur.Close
	If Main.nmode Then
		Dim BMPA As NegativeImage
		If Mark Then
			Button3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bookmark.png")))
		Else
			Button3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bookmark-outline.png")))
		End If
		Button4.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"book.png")))
	Else
		If Mark Then
			Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark.png"))
		Else
			Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark-outline.png"))
		End If
		Button4.SetBackgroundImage(LoadBitmap(File.DirAssets,"book.png"))
	End If

	LIV1.Left = 140%x
	
	cur=Main.s.ExecQuery("select replace(ttext,'أ','أ') from table3 where tindex="&onvanha.idonvan)
	cur.Position=0
	MatnStr = cur.GetString2(0)
	cur.Close
	LastFirstIndex = 0
	searching = False
	insert_Items_to_clv
	
	If onvanha.search Then
		cur=Main.s.ExecQuery("select replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(ttext,'ِ','ـ'),'ٍ','ـ'),'ْ','ـ'),'ّ','ـ'),'ٌ','ـ'),'ُ','ـ'),'ً','ـ'),'َ','ـ'),'ى','ي'),'ی','ي'),'ك','ک'),'إ','ا'),'أ','اـ') from table3 where tindex="&onvanha.idonvan)
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
		If matnha.prevOnvan Then sIdx = idxCount-1
		matnha.nextOnvan = False
		matnha.prevOnvan = False
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
		If matnha.edameh = False Then
			searching = True
			LastFirstIndex = sidxPidx
			clv1.JumpToItem(sidxPidx)
			ToastMessageShow2("مورد "&(sIdx+1) &" از " & idxCount,False)
		End If
		
	Else if matnha.edameh = False Then
		clv1.JumpToItem(0)
	End If

	Label1.Text=onvanha.onvanSel
	Label1.Top = 46*100%x/642 + 5%x + 3.5*100%x/642 - Label1.Height/2
	Label1.Left = 50%x - Label1.Width/2
	startTm.Enabled = True
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
	Activity.Finish
	StartActivity(SearchM)
End Sub
Sub AboutB_Click
	StartActivity(about)
End Sub
Sub SettingB_Click
	Setting.frParent = False
	StartActivity(Setting)
End Sub
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
	EditCopy.TextSize=JSTLabel.TextSize
	EditCopy.Width = ScrollView1.Width
	EditCopy.Left = 0
	EditCopy.Top = 0
			
	EditCopy.Typeface=JSTLabel.Typeface
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
	Label1.Text = "انتخاب جهت کپی و اشتراک گذاری"
	ToastMessageShow2("لطفا جهت کپي، متن مورد نظر را انتخاب نمایید",True)
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
	Button1.Visible = True
	Button3.Visible = True
	Button4.Visible = True
	CopyText.Visible = False
	ShareText.Visible = False
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
	Button1.Visible = True
	Button3.Visible = True
	Button4.Visible = True
	CopyText.Visible = False
	ShareText.Visible = False
	Label1.Text = onvanha.onvanSel
End Sub
Sub Label1cel_LongClick
	Dim v As View
	v = Sender
	If v.Tag >= 0 Then
		Dim endT As Int = clv1.GetPanel(v.tag).GetView(0).Text.IndexOf2(CRLF,0)
		If endT <= 0 Then endT = clv1.GetPanel(v.tag).GetView(0).Text.Length
		cur  = Main.s.ExecQuery("select * from NeshanehTable where (idonvan =" & onvanha.idonvan &" and ItemNumber="&v.Tag&")")

		If cur.RowCount > 0 Then
'				clv1.GetPanel(v.Tag).Color = Colors.Transparent
'				Main.s.ExecNonQuery("delete from NeshanehTable where (ItemNumber=" & v.Tag & " and idonvan=" & onvanha.idonvan &")")
'				ToastMessageShow2("نشانه انتخابی حذف شد",False)
		Else
			If Main.nmode Then clv1.GetPanel(v.Tag).Color = Bit.Xor(0x30000000,0x00ffffff) Else clv1.GetPanel(v.Tag).Color = 0x30000000
			Main.s.ExecNonQuery("insert into NeshanehTable VALUES(" & onvanha.idonvan & ",'" & clv1.GetPanel(v.tag).GetView(0).Text.SubString2(0,endT) & "',"& v.tag &")")
			ToastMessageShow2("نشانه افزوده شد",False)
		End If
		cur.Close
	End If
End Sub
Sub Button3_Click
	If Mark Then
		Mark = False
		Main.s.ExecNonQuery("delete from marktable where tindex=" & onvanha.idonvan)
		ToastMessageShow2("عنوان فعلی از فهرست منتخب حذف شد ",False)
	Else
		Mark = True
		Main.s.ExecNonQuery("insert into marktable VALUES(" & onvanha.idonvan & ")")
		ToastMessageShow2("عنوان فعلی به فهرست منتخب افزوده شد ",False)
	End If
	If Main.nmode Then
		Dim BMPA As NegativeImage
		If Mark Then
			Button3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bookmark.png")))
		Else
			Button3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bookmark-outline.png")))
		End If
	Else
		If Mark Then
			Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark.png"))
		Else
			Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark-outline.png"))
		End If
	End If
End Sub
Sub Button4_Click
	StartActivity(NeshaneHa)
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
End Sub
Sub NightOrDayModeSel
	If Main.nmode Then
		EditCopy.TextColor = Colors.White
		Label1.TextColor=Colors.White
		Dim BMPA As NegativeImage
		ShPanel.Color = Bit.Xor(Main.TopbackColor,0x00FFFFFF)
		EditCopy.Color = Bit.Xor(Main.backColor,0x00FFFFFF)
		Activity.Color = Colors.Black
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"dmode.png"))
		NextB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"keyboard-arrow-left.png")))
		PrevB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"keyboard-arrow-right.png")))
		CopyText.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"content-copy.png")))
		SearchB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"search.png")))
		CopyB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"content-copy.png")))
		SettingB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"settings-applications.png")))
		ShareText.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"share.png")))
		AboutB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"about.png")))
		If Mark Then
			Button3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bookmark.png")))
		Else
			Button3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bookmark-outline.png")))
		End If
		Button4.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"book.png")))
	Else
		EditCopy.TextColor = Colors.Black
		Label1.TextColor=Colors.Black
		ShPanel.Color = Main.TopbackColor
		EditCopy.Color = Main.backColor
		Activity.Color = Main.backColor
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"nmode.png"))
		NextB.SetBackgroundImage(LoadBitmap(File.DirAssets,"keyboard-arrow-left.png"))
		PrevB.SetBackgroundImage(LoadBitmap(File.DirAssets,"keyboard-arrow-right.png"))
		CopyText.SetBackgroundImage(LoadBitmap(File.DirAssets,"content-copy.png"))
		SearchB.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
		CopyB.SetBackgroundImage(LoadBitmap(File.DirAssets,"content-copy.png"))
		SettingB.SetBackgroundImage(LoadBitmap(File.DirAssets,"settings-applications.png"))
		ShareText.SetBackgroundImage(LoadBitmap(File.DirAssets,"share.png"))
		AboutB.SetBackgroundImage(LoadBitmap(File.DirAssets,"about.png"))
		If Mark Then
			Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark.png"))
		Else
			Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark-outline.png"))
		End If
		Button4.SetBackgroundImage(LoadBitmap(File.DirAssets,"book.png"))
	End If
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
		Label1.TextColor = Colors.Black
		EditCopy.Color = Colors.White
		EditCopy.TextColor = Colors.Black
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"nmode.png"))
		NextB.SetBackgroundImage(LoadBitmap(File.DirAssets,"keyboard-arrow-left.png"))
		PrevB.SetBackgroundImage(LoadBitmap(File.DirAssets,"keyboard-arrow-right.png"))
		CopyText.SetBackgroundImage(LoadBitmap(File.DirAssets,"content-copy.png"))
		SearchB.SetBackgroundImage(LoadBitmap(File.DirAssets,"search.png"))
		CopyB.SetBackgroundImage(LoadBitmap(File.DirAssets,"content-copy.png"))
		SettingB.SetBackgroundImage(LoadBitmap(File.DirAssets,"settings-applications.png"))
		ShareText.SetBackgroundImage(LoadBitmap(File.DirAssets,"share.png"))
		AboutB.SetBackgroundImage(LoadBitmap(File.DirAssets,"about.png"))
		If Mark Then
			Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark.png"))
		Else
			Button3.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmark-outline.png"))
		End If
		Button4.SetBackgroundImage(LoadBitmap(File.DirAssets,"book.png"))
		Main.s.ExecNonQuery("update STable set nmode = 0")
	Else
		Dim BMPA As NegativeImage
		Main.nmode = True
		EditCopy.TextColor = Colors.White
		EditCopy.Color = Colors.Black
		Activity.Color = Colors.Black
		ShPanel.Color = Bit.Xor(Main.TopbackColor,0x00FFFFFF)
		Label1.TextColor = Colors.White
		NightM.SetBackgroundImage(LoadBitmap(File.DirAssets,"dmode.png"))
		NextB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"keyboard-arrow-left.png")))
		PrevB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"keyboard-arrow-right.png")))
		CopyText.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"content-copy.png")))
		SearchB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"search.png")))
		CopyB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"content-copy.png")))
		SettingB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"settings-applications.png")))
		ShareText.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"share.png")))
		AboutB.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"about.png")))
		If Mark Then
			Button3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bookmark.png")))
		Else
			Button3.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"bookmark-outline.png")))
		End If
		Button4.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"book.png")))
		Main.s.ExecNonQuery("update STable set nmode = 1")
	End If
	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
	myf.loadThemes(cvs,Main.nmode)
End Sub
Sub Label1_LongClick
	ToastMessageShow2(Label1.Text,True)
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
'			myf.setLineSpaceEDT(EditCopy,1.5)
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
	If KeyCode = KeyCodes.KEYCODE_MENU Then
		Button1_Click
		Return True
	End If
	
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		If ScrollView1.Visible = True Then
			ScrollView1.SetVisibleAnimated(100,False)
			Button1.Visible = True
			Button3.Visible = True
			Button4.Visible = True
			CopyText.Visible = False
			ShareText.Visible = False
			Label1.Text = onvanha.onvanSel
			Return True
		else if ShPanel.Visible = True Then
			Button1_Click
			Return True
		Else
'			cur=Main.s.ExecQuery("select * from Edameh")
'			If cur.RowCount = 0 Then
'			cur.Close
'				Main.s.ExecNonQuery("insert into Edameh VALUES(" & onvanha.idonvan &",'"& onvanha.onvanSel & "',"&LastFirstIndex&")")
'			Else
'				cur.Close
'			Main.s.ExecNonQuery("update Edameh set idonvan="  & onvanha.idonvan &",onvanSel='"&onvanha.onvanSel & "',ItemNumber=" &LastFirstIndex)
'			End If
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
		NextB.Visible = False
		PrevB.Visible = False
		Button1.Top = 100%y-5%y-23*100%x/642-8%y
		Button1.SetVisibleAnimated(500,True)
	Else
		pvisible = False
		clv1.Base_Resize(clv1.AsView.Width,100%y-5%y-23*100%x/642-(46*100%x/642+10%x+7*100%x/642))
		ShPanel.SetLayoutAnimated(313,ShPanel.Left,100%y-5%y-23*100%x/642,ShPanel.Width,ShPanel.Height)
		Button1.Visible = False
		Button1.Top = 100%y-5%y-23*100%x/642
		Button1.SetVisibleAnimated(500,True)
		NextB.SetVisibleAnimated(500,True)
		PrevB.SetVisibleAnimated(500,True)
		Sleep(203)
		ShPanel.Visible = False
	End If
End Sub

Sub Nextb_LongClick
	If onvanha.search Then
		If SearchM.tiSel < SearchM.tindex.Length-1 Then
			Dim Result As Int = Msgbox2("به عنوان بعد می روید؟","","بلی","خیر","",Null)
			If Result = DialogResponse.POSITIVE Then
				Try
					matnha.nextOnvan = True
					matnha.prevOnvan = False
					SearchM.tiSel = SearchM.tiSel+1
					onvanha.idonvan = SearchM.tindex(SearchM.tiSel)
					onvanha.onvanSel = SearchM.ttitle(SearchM.tiSel)
					onvanha.search = True
					Activity.Finish
					'myf.AnimationFromLeft2Right
					StartActivity(matnha)
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
					matnha.nextOnvan = False
					matnha.prevOnvan = True
					SearchM.tiSel = SearchM.tiSel-1
					onvanha.idonvan = SearchM.tindex(SearchM.tiSel)
					onvanha.onvanSel = SearchM.ttitle(SearchM.tiSel)
					onvanha.search = True
					Activity.Finish
					'myf.AnimationFromRight2Left
					StartActivity(matnha)
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
					matnha.nextOnvan = True
					matnha.prevOnvan = False
					SearchM.tiSel = SearchM.tiSel+1
					onvanha.idonvan = SearchM.tindex(SearchM.tiSel)
					onvanha.onvanSel = SearchM.ttitle(SearchM.tiSel)
					onvanha.search = True
					Activity.Finish
					'myf.AnimationFromLeft2Right
					StartActivity(matnha)
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
		cur = Main.s.ExecQuery("select * from table2 where (ttext = 1 and tindex > " & onvanha.idonvan & ") ORDER BY tindex")
		
		If cur.RowCount > 0 Then
			cur.Position = 0
			onvanha.idonvan = cur.GetInt("tindex")
			onvanha.onvanSel = cur.GetString("ttitle")
			LastFirstIndex = 0
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
					matnha.nextOnvan = False
					matnha.prevOnvan = True
					SearchM.tiSel = SearchM.tiSel-1
					onvanha.idonvan = SearchM.tindex(SearchM.tiSel)
					onvanha.onvanSel = SearchM.ttitle(SearchM.tiSel)
					onvanha.search = True
					Activity.Finish
					'myf.AnimationFromRight2Left
					StartActivity(matnha)
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
		matnha.nextOnvan = False
		ToastMessageShow2("مورد "&(sIdx+1) &" از " & idxCount,False)
	Else
		cur = Main.s.ExecQuery("select * from table2 where (ttext = 1 and tindex < " & onvanha.idonvan & ") ORDER BY tindex")
		If cur.RowCount > 0 Then
			cur.Position = cur.RowCount-1
			onvanha.idonvan = cur.GetInt("tindex")
			onvanha.onvanSel = cur.GetString("ttitle")
			LastFirstIndex = 0
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
'Sub clv1_ScrollChanged(Position As Int)
'	If Position > clv1.GetScrollSize - 200%y Then
'		Dim p As Panel
''		LastPindex = -1
''		For i = Position To clv1.GetSize
'		p = clv1.GetPanel(LastPindex)
''		If p.Height = 1%y Then
''				LastPindex = i
''				Exit
''			End If
''		Next
'		
'		If LastPindex > -1 And p.Height = 1%y Then
'			'clv1.SetScrollPos(clv1.GetScrollSize)
'			LIV1.Left = 40%x
'			
'			QK_Click
'		End If
'	End If
'End Sub
'Sub ThreadSub1
'	Dim Params(1) As Object
'	
'	Do While LastPindex < clv1.GetSize-1
'		Params(0) = LastPindex
'		Thread1.RunOnGuiThread("Update1", Params)
'		Lock1.Wait
'		LastPindex = LastPindex+1
'		If LastPindex = clv1.GetSize-1 Then 
'			Thread1.Interrupt
'			Exit
'		End If
'	Loop
'End Sub
'Sub Update1(Index As Int)
	
''	If nextJustify Then
''		nextJustify = False
''		If endidx > 0 Then startidx = endidx+1
''		If startidx+1 < MatnStr.Length Then
''			endidx = MatnStr.IndexOf2(CRLF,startidx+1)
''			nextJustify = True
''		Else
''			endidx = MatnStr.Length
''			Thread1.Interrupt		
''		End If
''		
''		If endidx < startidx Then 
''			endidx = MatnStr.Length
''			Thread1.Interrupt
''		End If
'		'JSTLabel.Text = MatnStr.SubString2(startidx,endidx)
'		
'		'myf.setLineSpace(JSTLabel,1.5)
'	
'	Dim startIndex,endIndex As Int
'	If LastPindex = 0 Then
'		startIndex = 0
'	Else
'		startIndex = clv1.GetValue(LastPindex)
'	End If
'	If(LastPindex+1) < clv1.GetSize-1 Then
'		endIndex = clv1.GetValue(LastPindex+1)-1
'	Else
'		endIndex = MatnStr.Length
'	End If
'	If Main.JSTType = 1 Then
'		JST.Initialize
'		JSTLabel.Text=JST.JustifyByAddSpace(JSTLabel,MatnStr.SubString2(startIndex,endIndex),False,0.65)
'	else if Main.JSTType = 2 Then
'		JST.Initialize
'		JSTLabel.Text=JST.JustifyByExtendWords(JSTLabel,MatnStr.SubString2(startIndex,endIndex),False,0.65,False)
'	Else if Main.JSTType = 3 Then
'		JSTLabel.Text = ""
'	End If
'		
'	If JSTLabel.Text = "" Then 
'		JSTLabel.Text = MatnStr.SubString2(startIndex,endIndex)
'	End If
'	myf.setLineSpace(JSTLabel,1.5)
'
'	
''   clv1.InsertAtExistTextItem(LastPindex,JSTLabel, $"${startIndex}"$,JSTLabel.Height)
'	
'		'clv1.AddTextItem(JSTLabel,MatnStr.SubString2(startidx,endidx), $"${startidx}"$)
'	'clv1.Add(CreateListItem(JSTLabel.Text, 100%x, JSTLabel.Height),JSTLabel.Height, $"${startidx}"$)
'
'	Lock1.Unlock
'End Sub
Sub insert_Items_to_clv
	Dim itemnum As Int = 0
	Dim tmpl As Label
	tmpl.Initialize("")
	nextJustify = True
	startidx = 0
	endidx = 0
	Do While nextJustify
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
		Dim p As B4XView = xui.CreatePanel("")
		Activity.AddView(p, 0, 0,100%x, 10%y)
		p.Tag = 0
		p.RemoveViewFromParent
		'clv1.AddTextItem(MatnStr.SubString2(startidx,endidx-1),$"${startidx}"$)
		clv1.InsertAt(itemnum,p,$"${startidx}"$)
		itemnum = itemnum+1
	Loop
End Sub

Sub CLV1_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	If matnha.edameh And FirstIndex = matnha.startItem Then
		matnha.edameh = False
		searching = False
	else If searching And  clv1.GetPanel(sidxPidx).Tag > 0 Then
		clv1.ScrollToItem(sidxPidx)
		searching = False
	End If
	For i = 0 To clv1.Size - 1
		Dim ExtraSize As Int = 0
		If i >=  Max(0, FirstIndex - ExtraSize) And i <= Min(LastIndex + ExtraSize, clv1.Size - 1) Then
			Dim p As B4XView = xui.CreatePanel("")
			If clv1.GetPanel(i).Tag = 0 Then
				Dim highlight As Boolean
				If sidxPidx = i And onvanha.search Then highlight = True Else highlight = False
				p.Tag = 1
				p.LoadLayout("cellitemmatn")
				Dim endP As Int
				If i = clv1.Size-1 Then
					endP = MatnStr.Length
				Else
					endP = clv1.GetValue(i+1)-1
				End If
						
				JSTLabel.Text = MatnStr.SubString2(clv1.GetValue(i),endP)
				If highlight = False Then
					QK_Click
				End If
				If JSTLabel.Text = "" Then JSTLabel.Text = MatnStr.SubString2(clv1.GetValue(i),endP)
			
				If JSTLabel.Text.Length = MatnStr.Length Or endP = MatnStr.Length Then
					myf.Rangbandi(Label1cel,JSTLabel.Text,highlight,searchPos(sIdx)-clv1.GetValue(i),False)
				Else
					myf.Rangbandi(Label1cel,JSTLabel.Text.SubString2(0,JSTLabel.Text.Length-1),highlight,searchPos(sIdx)-clv1.GetValue(i),False)
				End If
				myf.setmatnEfont(Label1cel,clv1.sv.Width-4%x)
				
				Label1cel.Tag = i
				Label2cel.Text = Label1cel.Text
				myf.setmatnfont(Label2cel,Label1cel.Width)
				If Main.nmode Then Label1cel.TextColor = 0xffe9e9e9 Else Label1cel.TextColor = 0xff0a0a0a
				If Main.nmode Then Label2cel.TextColor = 0xFFff6f6f Else Label2cel.TextColor = Colors.Red
				Label1cel.Left = 2%x
				Label2cel.Left = 2%x
				Label1cel.Top = 0
				Label2cel.Top = 0
				Dim plastH As Int = clv1.GetPanel(i).Height
				clv1.ReplaceAt(i,p,Label1cel.Height,clv1.GetValue(i))
				If i = FirstIndex And FirstIndex < LastFirstIndex And FirstIndex > 0 Then
					Dim delta As Int = Label1cel.Height-plastH
					clv1.sv.ScrollViewOffsetY = clv1.sv.ScrollViewOffsetY+delta
				End If
			End If
		Else
			If clv1.GetPanel(i).NumberOfViews > 0 Then
				clv1.GetPanel(i).RemoveAllViews
				clv1.GetPanel(i).Tag = 0
			End If
		End If
	Next
	If matnha.edameh Then
		LastFirstIndex = matnha.startItem
		clv1.JumpToItem(matnha.startItem)
	Else
		LastFirstIndex = FirstIndex
	End If
End Sub
'Sub Thread1_Ended(fail As Boolean, error As String) 'An error or Exception has occurred in the Thread
'	LIV1.Left = 135%x
'ToastMessageShow("متن بارگیری شد",False)
'End Sub
Sub QK_Click
	If Main.JSTType = 1 Then
		JST.Initialize
		JSTLabel.Text=JST.JustifyByAddSpace(JSTLabel,JSTLabel.Text,False,0.65)
	else if Main.JSTType = 2 Then
		JST.Initialize
		JSTLabel.Text=JST.JustifyByExtendWords(JSTLabel,JSTLabel.Text,False,0.65,False)
	Else if Main.JSTType = 3 Then
		'JSTLabel.Text=JST.JustifyByExtendWords(JSTLabel,JSTLabel.Text,False,0.65,False)
		'JSTLabel.Text = JSTLabel.Text.Replace("ـ","")
		Return
	End If
End Sub
Sub Activity_Resume
	myf.setMatnfont(JSTLabel,clv1.sv.Width-7%x)
	For i = 0 To clv1.Size-1
		clv1.GetPanel(i).Tag = 0
	Next
	clv1.Refresh
	NightOrDayModeSel
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then
		cur=Main.s.ExecQuery("select * from Edameh")
		If cur.RowCount = 0 Then
		cur.Close
			Main.s.ExecNonQuery("insert into Edameh VALUES(" & onvanha.idonvan &",'"& onvanha.onvanSel & "',"&LastFirstIndex&")")
		Else
			cur.Close
		Main.s.ExecNonQuery("update Edameh set idonvan="  & onvanha.idonvan &",onvanSel='"&onvanha.onvanSel & "',ItemNumber=" &LastFirstIndex)
		End If
		Activity.Finish
	End If
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