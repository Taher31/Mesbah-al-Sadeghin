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
	Private xui As XUI
	Dim frParent As Boolean
End Sub

Sub Globals
	Private Label1 As Label
	Private clv1 As CustomListView
	Private pnl1 As Panel
	Private cvs As Canvas
	Private CL1,CL2,CL3,CL4,CL5,Divider As Panel
	Private Justify As ACSwitch
	Private ToggleButton1 As ToggleButton
	Private Label1Cel,fntSize,LspSize As Label
	Private fontSize,LineSpace As SeekBar
	Dim changeSetting As Boolean = False
	Dim FirstR As Boolean
	Dim SetData As AppSetting
End Sub

Sub Activity_Create(FirstTime As Boolean)
	myf.Loading(Main.s,SetData)
	Activity.LoadLayout("MarkNeshan")
	Label1.TextSize=20
	Label1.Text = "تنظیمات برنامه"
'	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
'	cvs.Initialize(pnl1)
	FirstR = True
	NightOrDayModeSel
	changeSetting = False
End Sub
'Sub CLV1_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
'	Dim ExtraSize As Int = 0
'	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clv1.Size - 1)
'		If clv1.GetPanel(i).Tag = 0 Then
'			onvanMatnhaCLV(i,clv1.GetValue(i))
'		End If
'		'End If
'	Next
'End Sub
'Sub onvanMatnhaCLV(i As Int,ii As Int)
'	Dim tmpl As Label
'	tmpl.Initialize("")
'	tmpl.Text = ItemText(i)
'	tmpl.SingleLine = True
'	myf.setfrfont(tmpl,94%x-5%x)
'	Dim p As B4XView = xui.CreatePanel("")
'	Activity.AddView(p, 0, 0,clv1.AsView.Width, tmpl.Height)
'	p.LoadLayout("CellItem")
'	p.RemoveViewFromParent
'	If i Mod 2 = 0 Then p.Color = 0x11000000
'	ItemText(i) = ItemText(i).Replace("أ","أ")
'	myf.Rangbandi(Label1cel,ItemText(i),False,0)
'	If Main.nmode Then Label1cel.TextColor = Colors.White Else Label1cel.TextColor = Colors.Black
'	
'	Label1cel.Top = 0
'	Label1cel.SingleLine = True
'	Label1cel.Ellipsize = "END"
'	Label1cel.Left = 15%x
'	myf.setfrfont(Label1cel,clv1.AsView.Width - 20%x)
'	p.Height = tmpl.Height*1.2
'	Label1cel.Tag = ii
'	p.Tag = 1
'	Dim but As Button
'	but.Initialize("DeleteN")
'	but.Left = 0
'	but.Top = 0
'	but.Width = 10%x
'	but.Height = 10%x
'	
'	If Main.nmode Then
'		Dim BMPA As NegativeImage
'		but.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"clear.png")))
'	Else
'		but.SetBackgroundImage(LoadBitmap(File.DirAssets,"clear.png"))
'	End If
'	but.Tag = i
'	p.AddView(but,0,tmpl.Height/2 - 5%x,10%x,10%x)
'	clv1.ReplaceAt(i,p,tmpl.Height*1.2,$"${ii}"$)
'End Sub
'Sub DeleteN_Click
'	Dim v As View
'	v = Sender
'	If v.Tag >= 0 Then
'		Main.s.ExecNonQuery("delete from NeshanehTable where (ItemNumber=" & ItemNumber(v.Tag) & " and idonvan=" & onvanha.idonvan &")")
'		NightOrDayModeSel
'	End If
'End Sub
'Sub clv1_ItemClick(Index As Int, Value As Object)
'	If Index Mod 2 = 0 Then clv1.GetPanel(Index).Color = 0x11000000
'	matnha.edameh = True
'	matnha.startItem = ItemNumber(Index)
'	Activity.Finish
'	StartActivity(matnha)
'End Sub
'Sub Label1cel_LongClick
'	Dim Result As Int = Msgbox2("نشانه انتخابی حذف شود؟","","بلی","خیر","",Null)
'	If Result = DialogResponse.POSITIVE Then
'		Dim v As View
'		v = Sender
'		Main.s.ExecNonQuery("delete from NeshanehTable where (ItemNumber=" & v.Tag & "and idonvan=" & onvanha.idonvan &")")
'		NightOrDayModeSel
'	End If
'End Sub
Sub NightOrDayModeSel
	clv1.Clear
	pnl1.Color = Main.TopbackColor
	If Main.nmode Then 
		Activity.Color = Colors.DarkGray 
	Else 
		Activity.Color = Main.backColor
	End If

'	myf.loadThemes(cvs,Main.nmode)
'	Label1.Top = 46*100%x/642 + 5%x + 3.5*100%x/642 - Label1.Height/2
'	Label1.Left = 50%x - Label1.Width/2
'	If Main.nmode = False Then	
'		Dim p As B4XView = xui.CreatePanel("")
'		p.Left = 0
'		p.Top = 0
'		p.Width = 100%x
'		p.Height = 30%x
'		p.LoadLayout("ColorSel")
'		CL1.Color = 0xFFfbe7d9
'		CL2.Color = 0xFFc8cadc
'		CL3.Color = 0xFFe9e9f4
'		CL4.Color = 0xFFe9d7c9
'		CL5.Color = 0xFFf5efe1
'		Divider.Color = Colors.DarkGray
'		
'		clv1.Add(p,$"${0}"$)
'	End If
	
	Dim p As B4XView = xui.CreatePanel("")
	p.Left = 0
	p.Top = 0
	p.Width = 100%x
	p.Height = 60%x
	p.LoadLayout("FontSetting")
	clv1.Add(p,$"${1}"$)

	
	Dim p As B4XView = xui.CreatePanel("")
	p.Left = 0
	p.Top = 0
	p.Width = 100%x
	p.Height = 90%x
	p.LoadLayout("matnCell")
	
	Dim MatnStr As String = "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ (1) الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ (2) الرَّحْمَنِ الرَّحِيمِ (3) مَالِكِ يَوْمِ الدِّينِ (4) إِيَّاكَ نَعْبُدُ وَ إِيَّاكَ نَسْتَعِينُ (5) اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ (6) صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَ لَا الضَّالِّينَ (7)"
	myf.Rangbandi(Label1Cel,MatnStr,False,0,True)
	
	'Label1Cel.TextColor = Colors.Black
	If ToggleButton1.Checked Then myf.setLineSpace(Label1Cel,1.2) Else myf.setLineSpace(Label1Cel,Main.lineSpace)

	p.Left = 0
	p.Top = 0
	p.Width = clv1.sv.Width
	p.Height = Label1Cel.Height
	clv1.Add(p,$"${2}"$)
	
	ToggleButton1.Checked = frParent
	
	Justify.Checked = Main.Justify
	If ToggleButton1.Checked Then
		Justify.Enabled = False
		LineSpace.Enabled = False
		myf.setfrfont(Label1Cel,clv1.sv.Width-4%x)
		fontSize.Value = Main.Menufontsize-10
		fntSize.Text = Main.Menufontsize
	Else 
		Justify.Enabled = True
		LineSpace.Enabled = True
		
		myf.setMatnfont(Label1Cel,clv1.sv.Width-4%x)
		fontSize.Value = Main.fontSize-10
		fntSize.Text = Main.fontSize
	End If
	LineSpace.Value = (Main.lineSpace * 10)-10
	LspSize.Text = Main.lineSpace

	For Each v As View In Activity.GetAllViewsRecursive
		If GetType(v) = "android.widget.TextView" Then
			Dim lbl As Label = v
			If Main.nmode Then lbl.TextColor = Colors.White Else lbl.TextColor = Colors.Black
		End If
	Next
	Label1.TextColor = Colors.White
End Sub
'Sub ErColor_CheckedChange(Checked As Boolean)
'		Dim index As Int = 2
'	If Main.nmode Then index = 1
'	If Not(Main.ErColor = Checked) Then changeSetting = True
'	Main.ErColor = Checked
'	Dim MatnStr As String = "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ (1) الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ (2) الرَّحْمَنِ الرَّحِيمِ (3) مَالِكِ يَوْمِ الدِّينِ (4) إِيَّاكَ نَعْبُدُ وَ إِيَّاكَ نَسْتَعِينُ (5) اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ (6) صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَ لَا الضَّالِّينَ (7)"
'	myf.Rangbandi(clv1.GetPanel(index).GetView(0),MatnStr,False,0,True)
'End Sub
Sub Justify_CheckedChange(Checked As Boolean)
	If Not(Main.Justify = Checked) Then changeSetting = True
	Main.Justify = Checked
	If Checked Then
		Main.JSTType = 1
	Else
		Main.JSTType = 3
	End If
End Sub
Sub ToggleButton1_CheckedChange(Checked As Boolean)
	Dim index As Int = 1'2
	'If Main.nmode Then index = 1
	If Checked Then
		LineSpace.Enabled = False
		Justify.Enabled = False
		myf.setfrfont(clv1.GetPanel(index).GetView(0),clv1.sv.Width-7%x)
		fontSize.Value = Main.Menufontsize-10
		fntSize.Text = Main.Menufontsize
		myf.setLineSpace(clv1.GetPanel(index).GetView(0),1.2)
	Else
		Justify.Enabled = True
		LineSpace.Enabled = True
		myf.setMatnfont(clv1.GetPanel(index).GetView(0),clv1.sv.Width-7%x)
		fontSize.Value = Main.fontSize-10
		fntSize.Text = Main.fontSize
		myf.setLineSpace(clv1.GetPanel(index).GetView(0),Main.lineSpace)
	End If
	clv1.GetPanel(index).Height = clv1.GetPanel(index).GetView(0).Height
	clv1.ResizeItem(index,clv1.GetPanel(index).GetView(0).Height)
End Sub
Sub FontList_ItemClick(Position As Int,Value As Object)
	Main.txtFont = Position
	changeSetting = True
End Sub
Sub CL1_Click
	If Main.nmode = False Then
		Main.backColor = 0xFFfbe7d9'0xFFfff9f3
		Activity.Color = Main.backColor
	Else
		Main.backColor = Bit.Xor(0xFF989898,0x00FFFFFF)
		Activity.Color = 0xFF989898
	End If	
		changeSetting = True
End Sub
Sub CL2_Click
	If Main.nmode = False Then
		Main.backColor = 0xFFc8cadc'0xFFdddeee
		Activity.Color = Main.backColor
	Else
		Main.backColor = Bit.Xor(0xFF818181,0x00FFFFFF)
		Activity.Color = 0xFF818181
	End If
	changeSetting = True
End Sub
Sub CL3_Click
	If Main.nmode = False Then
		Main.backColor = 0xFFe9e9f4'0xFFf0f8f1
		Activity.Color = Main.backColor
	Else
		Main.backColor = Bit.Xor(0xFF696969,0x00FFFFFF)
		Activity.Color = 0xFF696969
	End If
	changeSetting = True
End Sub
Sub CL4_Click
	If Main.nmode = False Then
		Main.backColor = 0xFFe9d7c9'0xFFfff9e6
		Activity.Color = Main.backColor
	Else
		Main.backColor = Bit.Xor(0xFF484848,0x00FFFFFF)
		Activity.Color = 0xFF484848
	End If
	changeSetting = True
End Sub
Sub CL5_Click
	If Main.nmode = False Then
		Main.backColor = 0xFFf5efe1'0xFFfffde7
		Activity.Color = Main.backColor
	Else
		Main.backColor = Bit.Xor(0xFF000000,0x00FFFFFF)
		Activity.Color = 0xFF000000
	End If
	changeSetting = True
End Sub
Sub Activity_Resume
	NightOrDayModeSel
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then 
		Activity.Finish
		myf.SetAnimation("right_left1", "zoom_exit")
	End If
End Sub
Sub LineSpace_ValueChanged(Value As Int, UserChanged As Boolean)
	Dim index As Int = 1'2
	'If Main.nmode Then index = 1
	If Not(Main.lineSpace = (10+LineSpace.Value)/10) Then changeSetting = True
	Main.lineSpace = (10+LineSpace.Value)/10
	LspSize.Text = Main.lineSpace
	myf.setLineSpace(clv1.GetPanel(index).GetView(0),Main.lineSpace)
	clv1.GetPanel(index).Height = clv1.GetPanel(index).GetView(0).Height
	clv1.ResizeItem(index,clv1.GetPanel(index).GetView(0).Height)
End Sub
Sub fontSize_ValueChanged(Value As Int, UserChanged As Boolean)
	Dim index As Int = 1'2
	'If Main.nmode Then index = 1
	clv1.GetPanel(index).GetView(0).TextSize = Value+10
	
	If ToggleButton1.Checked = True Then myf.setLineSpace(clv1.GetPanel(index).GetView(0),1.2) Else  myf.setLineSpace(clv1.GetPanel(index).GetView(0),Main.lineSpace)
	clv1.GetPanel(index).Height = clv1.GetPanel(index).GetView(0).Height
	clv1.ResizeItem(index,clv1.GetPanel(index).GetView(0).Height)
	If ToggleButton1.Checked Then
		If Not(Main.Menufontsize = Value+10) Then changeSetting = True
		Main.Menufontsize = Value+10
		fntSize.Text = Main.Menufontsize
	Else
		If Not(Main.fontSize = Value+10) Then changeSetting = True
		Main.fontSize = Value+10
		fntSize.Text = Main.fontSize
	End If
End Sub
'Sub BackColor_Click
'	Dim cw As ColorWheelDialog
'	cw.Initialize
'	cw.ShowAsync(Me, "انتخاب رنگ زمینه")
'	Wait For (cw) Color_Result(Success As Boolean)
'	If Success Then
'		If Not(Main.backColor = cw.ColorResult) Then changeSetting = True
'		Main.backColor = cw.ColorResult
'		Activity.Color = Main.backColor
'	End If
'End Sub
Sub jst1_CheckedChange(Checked As Boolean)
	If Checked Then
		If Not(Main.JSTType = 1) Then changeSetting = True
		Main.JSTType = 1
	End If
End Sub
Sub jst2_CheckedChange(Checked As Boolean)
	If Checked Then
		If Not(Main.JSTType = 2) Then changeSetting = True
		Main.JSTType = 2
	End If
End Sub
Sub jst3_CheckedChange(Checked As Boolean)
	If Checked Then
		If Not(Main.JSTType = 3) Then changeSetting = True
		Main.JSTType = 3
	End If
End Sub
Sub Activity_KeyPress(KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_BACK And changeSetting Then
		Dim i As Int
		i = Msgbox2("آیا تغییرات ذخیره شود؟","ذخیره تنظیمات","ذخیره شود","","",Null)
		Select i
			Case DialogResponse.CANCEL
				Dim cur As Cursor
				cur=Main.s.ExecQuery("select * from STable")
				cur.Position = 0
				'Main.BackColor = cur.GetInt("backColor")
				Main.txtFont = cur.Getint("txtFont")
'				Main.menuFont = cur.Getint("menuFont")
				Main.lineSpace = cur.GetDouble("lineSpace")
				Main.Menufontsize = cur.GetInt("Menufontsize")
				Main.fontSize = cur.GetInt("fontSize")
				Main.JSTType = cur.GetInt("JSTType")
				Dim er As Int = cur.GetInt("ErColor")
				If er = 0 Then Main.ErColor = False Else Main.ErColor = True
				cur.Close
				Activity.Finish
			Case DialogResponse.POSITIVE
				Main.s.ExecNonQuery("update STable set Menufontsize=" & Main.Menufontsize)
				If Main.ErColor Then Main.s.ExecNonQuery("update STable set ErColor=1") Else Main.s.ExecNonQuery("update STable set ErColor=0")
				Main.s.ExecNonQuery("update STable set fontSize=" & Main.fontSize)
				Main.s.ExecNonQuery("update STable set txtFont=" & Main.txtFont)
				'Main.s.ExecNonQuery("update STable set backColor=" & Main.backColor)
				Main.s.ExecNonQuery("update STable set JSTType=" & Main.JSTType)
				Main.s.ExecNonQuery("update STable set lineSpace=" & Main.lineSpace)
'				matnha.refreshclv1 = True
				Activity.Finish
		End Select
	End If
	Return False
End Sub