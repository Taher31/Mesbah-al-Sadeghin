B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.5
@EndOfDesignText@

Sub Process_Globals
	Dim ssL As Int
	Dim FehrestFont = 1,AraFont=11,FarFont=1 As Int
	Dim FehrestSize = 21, AraSize=29,FarSize=22 As Float
	Dim ArLineSp = 11, FrLineSp =11 As Float
	Dim booklibAddress As String
	Dim SettingApp As SQL
End Sub

				  
Sub LogMemory
	Dim r As Reflector
	Dim iFreeMemory As Long
	Dim iMaxMemory As Long
	Dim iTotalMemory As Long
	Dim iUsedMemory   As Long
	Dim iTotalFreeMemory As Long
	Dim strPrompt As String

	r.Target = r.RunStaticMethod("java.lang.Runtime", "getRuntime", Null, Null)

	iFreeMemory = r.RunMethod("freeMemory")
	iMaxMemory = r.RunMethod("maxMemory")
	iTotalMemory = r.RunMethod("totalMemory")

	iUsedMemory   = iTotalMemory - iFreeMemory
	iTotalFreeMemory   = iMaxMemory - iUsedMemory

		  strPrompt =   "Max Memory  = " & NumberFormat2(iMaxMemory/(1024*1024),1,2,2,True) & " Mb" &  _
                 CRLF & "Total Free        = " & NumberFormat2(iTotalFreeMemory/(1024*1024),1,2,2,True) & " Mb" & _
                 CRLF & "Total Memory = " & NumberFormat2(iTotalMemory/(1024*1024),1,2,2,True) & " Mb" & _     
                 CRLF & "Used Memory = " & NumberFormat2(iUsedMemory/(1024*1024),1,2,2,True) & " Mb" & _
                 CRLF & "Free Memory  = " & NumberFormat2(iFreeMemory/(1024*1024),1,2,2,True)& " Mb"      

	ToastMessageShow(strPrompt,True)
	Log(strPrompt)

End Sub
Sub ChangeScrollbarColor(v As B4XView, Drawable As Object)
	Dim p As Phone
	If p.SdkVersion >= 29 Then
		v.As(JavaObject).RunMethod("setVerticalScrollbarThumbDrawable", Array(Drawable))
	End If
End Sub
Sub SetAnimation(InAnimation As String, OutAnimation As String)
	Dim r As Reflector
	Dim package As String
	Dim In, out As Int
	package = r.GetStaticField("anywheresoftware.b4a.BA", "packageName")
	In = r.GetStaticField(package & ".R$anim", InAnimation)
	out = r.GetStaticField(package & ".R$anim", OutAnimation)
	r.Target = r.GetActivity
	r.RunMethod4("overridePendingTransition", Array As Object(In, out), Array As String("java.lang.int", "java.lang.int"))
End Sub
Sub DatabesOpen(sql As SQL, path As String,DatabaseName As String,DatabesT_F As Boolean) As Boolean
	If File.Exists(path,DatabaseName) = False Then Return False
	sql.Initialize(path,DatabaseName,DatabesT_F)
	Return True
End Sub
Sub ChachNotUse
	If File.Exists(File.DirInternalCache,"noCache.txt") Then
		Dim tmp1 As Boolean
		tmp1 = File.ReadString(File.DirInternalCache,"noCache.txt")
		If tmp1 = False Then File.WriteString(File.DirInternalCache,"noCache.txt",True)
	End If
End Sub
Sub MyFileCopyFromApk(iPath As String,iFile As String,oPath As String,oFile As String)
	If Not(File.Exists(oPath ,oFile)) Then
		Try
			Dim bytes() As Byte = File.ReadBytes(iPath,iFile)
			For i = 0 To bytes.Length-1
				bytes(i) = Bit.Xor(bytes(i),0xff)
			Next
			File.WriteBytes(oPath,oFile,bytes)
		Catch
			Log(LastException)
		End Try
	End If
End Sub
Sub Loading(SetData As AppSetting)
	If Not(File.Exists(File.DirInternal,"/ASSAR/")) Then
		File.MakeDir(File.DirInternal,"/ASSAR/")
	End If

	If Not(File.Exists(File.DirInternal,Application.VersionCode&".ver")) Then
		If Main.change1book And File.Exists(File.DirInternal&"/ASSAR/","1.book") Then File.Delete(File.DirInternal&"/ASSAR/","1.book")
		If Main.change2book And File.Exists(File.DirInternal&"/ASSAR/","2.book") Then File.Delete(File.DirInternal&"/ASSAR/","2.book")
		If Main.change3book And File.Exists(File.DirInternal&"/ASSAR/","3.book") Then File.Delete(File.DirInternal&"/ASSAR/","3.book")
		If Main.change4book And File.Exists(File.DirInternal&"/ASSAR/","4.book") Then File.Delete(File.DirInternal&"/ASSAR/","4.book")
		File.WriteString(File.DirInternal,Application.VersionCode&".ver",Application.VersionName)
	End If
	MyFileCopyFromApk(File.DirAssets,"1.book",File.DirInternal&"/ASSAR/","1.book")
	MyFileCopyFromApk(File.DirAssets,"2.book",File.DirInternal&"/ASSAR/","2.book")
	MyFileCopyFromApk(File.DirAssets,"3.book",File.DirInternal&"/ASSAR/","3.book")
	MyFileCopyFromApk(File.DirAssets,"4.book",File.DirInternal&"/ASSAR/","4.book")
	
	SettingApp.Initialize(File.DirInternalCache,"SettingApp.txt",True)
	Dim cur As Cursor
	SettingApp.ExecNonQuery("CREATE TABLE if NOT EXISTS [STable] ([backColor] NUMERIC  NULL,[txtFont] NUMERIC NULL,[menuFont] NUMERIC NULL,[lineSpace] REAL NULL,[Menufontsize] NUMERIC NULL,[fontSize] NUMERIC NULL, [JSTType] NUMERIC NULL, [nmode] NUMERIC ,[ErColor] NUMERIC NULL,[BfontSize] NUMERIC NULL)")
	SettingApp.ExecNonQuery("CREATE TABLE if NOT EXISTS [fontTable] ([fehrestFont]Text Null, [ArFont]TEXT Null , [FrFont] TEXT Null,[fehrestSize] NUMERIC Null, [ArSize] NUMERIC Null, [FrSize] NUMERIC Null ,[ArLineSpace] NUMERIC Null, [FrLineSpace] NUMERIC Null)")
	cur=SettingApp.ExecQuery("select * from STable")
	If cur.RowCount = 0 Then
		SettingApp.ExecNonQuery("insert into STable VALUES(" & (0xFFe9e9f4) &",0,1,1.5,22,30,1,0,0,30)")
		Main.FirstStart = True
	Else
		Main.FirstStart = False
	End If
	cur.Close
	cur=SettingApp.ExecQuery("select * from STable ")
	cur.Position = 0

	SetData.backColor = 0xfffefcf0'0xfffdfbef'0xFFf6d9af
	SetData.TopbackColor =  0xFF021c1a'0xFF021c1a
	SetData.txtFont = cur.Getint("txtFont")
'	menuFont = cur.Getint("menuFont")
	SetData.lineSpace = cur.GetDouble("lineSpace")
	SetData.Menufontsize = cur.GetInt("Menufontsize")
	SetData.fontSize = cur.GetInt("fontSize")
	SetData.Bfontsize = cur.GetInt("BfontSize")
	SetData.JSTType = cur.GetInt("JSTType")
	Dim er As Int = cur.GetInt("ErColor")
	If er = 0 Then SetData.ErColor = False Else SetData.ErColor = True
	If SetData.JSTType = 3 Then SetData.Justify = False Else SetData.Justify = True
	Dim nmodeint As Int = cur.GetInt("nmode")	

	If nmodeint = 0 Then SetData.nmode = False Else SetData.nmode = True
	cur.Close
	
	cur=SettingApp.ExecQuery("select * from fontTable")
	If cur.RowCount = 0 Then
		SettingApp.ExecNonQuery("insert into fontTable VALUES(" & FehrestFont &","& AraFont &","& FarFont &","& FehrestSize &","& AraSize &","& FarSize &","& ArLineSp &","& FrLineSp &")")
	Else
		cur.Position = 0
		AraFont = cur.GetInt("ArFont")
		FarFont = cur.GetInt("FrFont")
		AraSize = cur.GetInt("ArSize")
		FarSize = cur.GetInt("FrSize")
		ArLineSp = cur.GetInt("ArLineSpace")
		FrLineSp = cur.GetInt("FrLineSpace")
		FehrestFont = cur.GetInt("fehrestFont")
		FehrestSize = cur.GetInt("fehrestSize")
	End If
	cur.Close
End Sub
Sub DatabesCopy(DatabesName As String,path As String,DatabesT_F As Boolean)
	If File.Exists(path,DatabesName) = False Then
		File.MakeDir(File.DirInternal,"/ASSAR/")
		File.MakeDir(File.DirInternal,"/F.Matni/")
		File.MakeDir(File.DirInternal,"/F.Soti/")
		File.MakeDir(File.DirInternal,"/F.Tasviri/")
		
		
		
'		ToastMessageShow("در حال بارگذاری فایلها" &CRLF & "لطفا کمی صبر کنید ...",True)
		File.Copy(File.DirAssets,DatabesName,path,DatabesName)
'		For i = 101 To 105
'			File.Copy(File.DirAssets,i & ".book",path ,i & ".book")
'		Next
'		For i = 201 To 202
'			File.Copy(File.DirAssets,i & ".book",path ,i & ".book")
'		Next
'		For i = 301 To 305
'			File.Copy(File.DirAssets,i & ".book",path ,i & ".book")
'		Next
'		For i = 401 To 403
'			File.Copy(File.DirAssets,i & ".book",path ,i & ".book")
'		Next
'		For i = 501 To 504
'			File.Copy(File.DirAssets,i & ".book",path ,i & ".book")
'		Next
'		For i = 601 To 602
'			File.Copy(File.DirAssets,i & ".book",path ,i & ".book")
'		Next
'		For i = 701 To 703
'			File.Copy(File.DirAssets,i & ".book",path ,i & ".book")
'		Next
'		For i = 801 To 805
'			File.Copy(File.DirAssets,i & ".book",path ,i & ".book")
'		Next
'		ToastMessageShow("فایلها بارگذاری شد" ,False)
	End If
'	If sql.IsInitialized=False Then
'		sql.Initialize(path,DatabesName,DatabesT_F)
'		'sql.Initialize(path,DatabesName,True,Application.PackageName & "AnisSoft!@#$%^&*()_+~|/\987654321.0","")
'	End If
'	ToastMessageShow(path,True)
End Sub
'Sub DatabesCopy(sql As SQL, DatabesName As String,DatabesT_F As Boolean)
''	Dim ru As RuntimePermissions
'	Dim path As String = ""
''	For i = 0 To ru.GetAllSafeDirsExternal("").Length
''		Dim aa As Int = ru.GetAllSafeDirsExternal("")(i).IndexOf("/Android/")
''		path = ru.GetAllSafeDirsExternal("")(i)
''		If aa > 0 Then path = ru.GetAllSafeDirsExternal("")(i).SubString2(0,aa+1)
''		Dim copyOk As Boolean = True
''		If File.Exists(path,DatabesName)=False Then
''			Try
''				File.Copy(File.DirAssets,DatabesName,path,DatabesName)
''			Catch
''				Log(LastException)
''				copyOk = False
''			End Try
''			If copyOk Then Exit
''		Else
''			Exit
''		End If
''		path = ""
''	Next
'	If path = "" Then path = File.DirInternal
'	If File.Exists(path,DatabesName)=False Then
'		File.Copy(File.DirAssets,DatabesName,path,DatabesName)	
'	End If
'	If sql.IsInitialized=False Then
'		sql.Initialize(path,DatabesName,DatabesT_F)
'		'sql.Initialize(path,DatabesName,True,Application.PackageName.SubString2(Application.PackageName.Length-4,Application.PackageName.Length),"")
'	End If
''	ToastMessageShow(path,True)
'End Sub
Sub SetTiledBackground(v As View, b As Bitmap,SetData As AppSetting)
	Dim bd As BitmapDrawable
	bd.Initialize(b)
	Dim r As Reflector
	r.Target = bd
	r.RunMethod3("setTileModeXY","REPEAT", "android.graphics.Shader$TileMode", _
   "REPEAT", "android.graphics.Shader$TileMode")   
	
	If SetData.nmode Then v.Background = Null Else v.Background = bd
End Sub

Sub loadThemes(cvs As Canvas,NightMode As Boolean,SetData As AppSetting)
	Dim mrect As Rect
'	Dim BMPA As NegativeImage
'	Dim bmp1 As Bitmap

	mrect.Initialize(0,0,100%x,100%y)
	cvs.DrawRect(mrect,Colors.Transparent,True,100%x)
	
	mrect.Left = 0
	mrect.Top = 0
	mrect.Width = 100%x
	mrect.Height= 46*100%x/642+10%x+7*100%x/642
'	If NightMode Then
'		cvs.DrawRect(mrect,Bit.xor(Main.TopbackColor,0x00FFFFFF),True,1)
'	Else
	cvs.DrawRect(mrect,SetData.TopbackColor,True,1)
	mrect.Initialize(0,100%y-6%y,100%x,100%y)
	cvs.DrawRect(mrect,SetData.TopbackColor,True,1)
'	mrect.Initialize(0,0,5%x,100%y)
'	cvs.DrawRect(mrect,Main.TopbackColor,True,1)
'	End If
	

'	bmp1.InitializeResize(File.DirAssets,"t1th.png",100%x,7*100%x/642,False)
'	mrect.Left= 0
'	mrect.Top = 46*100%x/642+10%x
'	mrect.Width = bmp1.Width
'	mrect.Height= bmp1.Height
'	
'	If NightMode Then
'		cvs.DrawBitmap(BMPA.NegativeBMP(bmp1),Null,mrect)
'	Else
'		cvs.DrawBitmap(bmp1,Null,mrect)
'	End If
'	
'	bmp1.InitializeResize(File.DirAssets,"Rth.png",23*100%x/642,211*100%x/642,False)
'	For i = 0 To 100%y/bmp1.Height
'		mrect.Left = 100%x-bmp1.Width
'		mrect.Top = i*bmp1.Height
'		mrect.Width = bmp1.Width
'		mrect.Height = bmp1.Height
'		If NightMode Then
'			cvs.DrawBitmap(BMPA.NegativeBMP(bmp1),Null,mrect)
'		Else
'			cvs.DrawBitmap(bmp1,Null,mrect)
'		End If
'	Next
'	
'	bmp1.InitializeResize(File.DirAssets,"Lth.png",23*100%x/642,211*100%x/642,False)
'	For i = 0 To 100%y/bmp1.Height
'		mrect.Left = 0
'		mrect.Top = i*bmp1.Height
'		mrect.Width = bmp1.Width
'		mrect.Height = bmp1.Height
'		If NightMode Then		
'			cvs.DrawBitmap(BMPA.NegativeBMP(bmp1),Null,mrect)
'		Else
'			cvs.DrawBitmap(bmp1,Null,mrect)
'		End If
'	Next
'	
'	bmp1.InitializeResize(File.DirAssets, "tth.png", 100%x,46*100%x/642, False)
'	mrect.Left = 0
'	mrect.Top = 0
'	mrect.Width = bmp1.Width
'	mrect.Height= bmp1.Height
'	If NightMode Then
'		cvs.DrawBitmap(BMPA.NegativeBMP(bmp1),Null,mrect)
'	Else
'		cvs.DrawBitmap(bmp1,Null,mrect)
'	End If
'	
'	bmp1.InitializeResize(File.DirAssets,"bth.png",100%x,37*100%x/642,False)
'	mrect.Left= 0
'	mrect.Top = 100%y-bmp1.Height
'	mrect.Width = bmp1.Width
'	mrect.Height= bmp1.Height
'	If NightMode Then
'		cvs.DrawBitmap(BMPA.NegativeBMP(bmp1),Null,mrect)
'	Else
'		cvs.DrawBitmap(bmp1,Null,mrect)
'	End If
End Sub
Sub setLineSpaceSL(leb As Label,lineSP As Float) As Float
	Dim ht As Float
	Dim Obj1 As Reflector
	leb.SingleLine = True

	Obj1.Target = leb
	Obj1.RunMethod3("setLineSpacing",1, "java.lang.float", lineSP, "java.lang.float") 'Change the space between lines
	Obj1.Target = leb
	ht = Obj1.RunMethod("getLineHeight")    'Get the height of line AFTER  you change it
	leb.Height = ht
	Return  ht
End Sub
Sub setLineSpace(leb As Label,lineSP As Float) As Float
	Dim before,after As Float
	Dim Obj1 As Reflector
	Dim ht As Float
	Dim strutil As StringUtils
	
	Dim tmpL As Label
	tmpL.Initialize("")
	tmpL.Text = leb.Text
	tmpL.Typeface = leb.Typeface
	tmpL.TextSize = leb.TextSize
	tmpL.Width = leb.Width
	tmpL.SingleLine = False
	tmpL.Padding = leb.Padding
	ht = strutil.MeasureMultilineTextHeight(tmpL , tmpL.Text)
	Obj1.Target = tmpL
	before = Obj1.RunMethod("getLineHeight")    'Get the height of line BEFORE you change it
	Obj1.Target = leb
	Obj1.RunMethod3("setLineSpacing",1, "java.lang.float", lineSP, "java.lang.float") 'Change the space between lines
	Obj1.Target = leb
	after = Obj1.RunMethod("getLineHeight")    'Get the height of line AFTER  you change it
	ht = ((after * ht)/before)
	leb.Height = ht
	Return  ht
'	Dim before,after As Float
'	Dim Obj1 As Reflector
'	Dim ht As Float
'	Dim strutil As StringUtils
'	
'	Dim tmpL As Label
'	tmpL.Initialize("")
'	tmpL.Text = leb.Text
'	tmpL.Typeface = leb.Typeface
'	tmpL.TextSize = leb.TextSize
'	tmpL.Width = leb.Width
'	tmpL.SingleLine = False
'	tmpL.Padding = leb.Padding
'	ht = strutil.MeasureMultilineTextHeight(tmpL , tmpL.Text)
'	Obj1.Target = tmpL
'	before = Obj1.RunMethod("getLineHeight")    'Get the height of line BEFORE you change it
'	Obj1.Target = leb
'	Obj1.RunMethod3("setLineSpacing",1, "java.lang.float", lineSP, "java.lang.float") 'Change the space between lines
'	Obj1.Target = leb
'	after = Obj1.RunMethod("getLineHeight")    'Get the height of line AFTER  you change it
'	ht = ((after * ht)/before)
'	leb.Height = ht
'	Return  ht
End Sub
Sub FixPersianText(lbl As Label)
	lbl.Text = lbl.Text.Replace(Chr(0x200c),Chr(0x202f))
End Sub
Sub setfrfont(lb1 As Label,width As Int,SetData As AppSetting)
	If FarFont <= 8 Then FixPersianText(lb1)
	SelectFrFont(lb1)
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.TOP)
	lb1.TextSize = FarSize
	lb1.Width = width
	lb1.SingleLine = False
	setLineSpace(lb1,1.2)
End Sub
Sub setBMatnfont(lb1 As Label,width As Int)
	If FarFont < 8 Then FixPersianText(lb1)
	SelectFrFont(lb1)
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lb1.TextSize = FarSize
	lb1.Width = width
	lb1.SingleLine = False
	setLineSpace(lb1,FrLineSp/10)
End Sub
Sub setBMatnEfont(lb1 As Label,width As Int)
	If FarFont < 8 Then FixPersianText(lb1)
'	FixPersianText(lb1)
	SelectFrFontE(lb1)
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lb1.TextSize = FarSize
	lb1.Width = width
	lb1.SingleLine = False
	setLineSpace(lb1,FrLineSp/10)
End Sub
Sub setEditCopyMatnfont(lb1 As Label,width As Int)
	lb1.Typeface = Typeface.LoadFromAssets("Vazirmatn-Regular.ttf")
'	SelectFrFont(lb1)
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lb1.TextSize = FarSize - 2
	lb1.Width = width
	lb1.SingleLine = False
	setLineSpace(lb1,FrLineSp/10)
End Sub
Sub setPMatnfont(lb1 As Label,width As Int)
	If FarFont <= 8 Then FixPersianText(lb1)
	SelectFrFont(lb1)
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lb1.TextSize = FarSize - 2
	lb1.Width = width
	lb1.SingleLine = False
	setLineSpace(lb1,1.1)
End Sub
Sub setOMatnfont(lb1 As Label,width As Int)
	If FarFont <= 8 Then FixPersianText(lb1)
	SelectFrFont(lb1)
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lb1.TextSize = FarSize
	lb1.Width = width
	lb1.SingleLine = False
	setLineSpace(lb1,FrLineSp/10)
End Sub
Sub setTMatnfont(lb1 As Label,width As Int)
	If FarFont <= 8 Then FixPersianText(lb1)
	SelectFrFont(lb1)
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lb1.TextSize = FarSize - 4
	lb1.Width = width
	lb1.SingleLine = False
	setLineSpace(lb1,1.1)
End Sub

Sub setFMatnfont(lb1 As Label,width As Int)
	If FarFont <= 8 Then FixPersianText(lb1)
	SelectFehrestFont(lb1)
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lb1.TextSize = FehrestSize
	lb1.Width = width
	lb1.SingleLine = False
	setLineSpace(lb1,1.0)
End Sub

Sub setFrMatnfont(lb1 As Label,width As Int)
	If FarFont <= 8 Then FixPersianText(lb1)
	SelectFehrestFont(lb1)
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lb1.TextSize = FehrestSize
	lb1.Width = width
	lb1.SingleLine = True
	setLineSpaceSL(lb1,1.3)
End Sub
Sub setMatnfont(lb1 As Label,width As Int)
	If FarFont <= 12 Then FixPersianText(lb1)
	SelectArFont(lb1)
'	lb1.Typeface = Typeface.LoadFromAssets("aNaskhb.ttf")
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lb1.TextSize = AraSize
	lb1.Width = width
	lb1.SingleLine = False
	setLineSpace(lb1,ArLineSp/10)
End Sub
Sub setEDArfont(lb1 As EditText,width As Int)
	If FarFont <= 12 Then FixPersianText(lb1)
	SelectArFont(lb1)
'	lb1.Typeface = Typeface.LoadFromAssets("aNaskhb.ttf")
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lb1.TextSize = AraSize
	lb1.Width = width
	lb1.SingleLine = False
End Sub
Sub setEDFrfont(lb1 As EditText,width As Int)
	If FarFont <= 8 Then FixPersianText(lb1)
	SelectFrFont(lb1)
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lb1.TextSize = FarSize
	lb1.Width = width
	lb1.SingleLine = False
End Sub
Sub setMatnEfont(lb1 As Label,width As Int)
	If FarFont <= 12 Then FixPersianText(lb1)
	SelectArFontE(lb1)
'	lb1.Typeface = Typeface.LoadFromAssets("aNaskhbn.ttf")
	lb1.Gravity= Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lb1.TextSize = AraSize
	lb1.Width = width
	lb1.SingleLine = False
	setLineSpace(lb1,ArLineSp/10)
End Sub
Sub SelectArFont(lb1 As Label)
	Select AraFont
		Case 1
			lb1.Typeface = Typeface.LoadFromAssets("w_Aziz.ttf")
		Case 2
			lb1.Typeface = Typeface.LoadFromAssets("w_Aziz Bold.ttf")
		Case 3
			lb1.Typeface = Typeface.LoadFromAssets("w_Badr.ttf")
		Case 4
			lb1.Typeface = Typeface.LoadFromAssets("w_Badr Bold.ttf")
		Case 5
			lb1.Typeface = Typeface.LoadFromAssets("w_Lotus.ttf")
		Case 6
			lb1.Typeface = Typeface.LoadFromAssets("w_Lotus Bold.ttf")
		Case 7
			lb1.Typeface = Typeface.LoadFromAssets("w_Mitra.ttf")
		Case 8
			lb1.Typeface = Typeface.LoadFromAssets("w_Mitra Bold.ttf")
		Case 9
			lb1.Typeface = Typeface.LoadFromAssets("w_Nazanin.ttf")
		Case 10
			lb1.Typeface = Typeface.LoadFromAssets("w_Nazanin Bold.ttf")
		Case 11
			lb1.Typeface = Typeface.LoadFromAssets("wm_Naskh Qurani.ttf")
		Case 12
			lb1.Typeface = Typeface.LoadFromAssets("aUtaha.ttf")
		Case 13
			lb1.Typeface = Typeface.LoadFromAssets("anaskh.ttf")
		Case 14
			lb1.Typeface = Typeface.LoadFromAssets("anaskhb.ttf")
		Case Else
			Log("Larger than 14")
	End Select
End Sub
Sub SelectFehrestFont(lb1 As Label)
	Select FehrestFont
		Case 1
			lb1.Typeface = Typeface.LoadFromAssets("Vazirmatn-Regular.ttf")
		Case 2
			lb1.Typeface = Typeface.LoadFromAssets("Vazirmatn-Bold.ttf")		
		Case 3
			lb1.Typeface = Typeface.LoadFromAssets("w_Zar.ttf")
		Case 4
			lb1.Typeface = Typeface.LoadFromAssets("w_Zar Bold.ttf")
		Case 5
			lb1.Typeface = Typeface.LoadFromAssets("w_Mitra.ttf")
		Case 6
			lb1.Typeface = Typeface.LoadFromAssets("w_Mitra Bold.ttf")
		Case 7
			lb1.Typeface = Typeface.LoadFromAssets("w_Nazanin.ttf")
		Case 8
			lb1.Typeface = Typeface.LoadFromAssets("w_Nazanin Bold.ttf")
		Case 9
			lb1.Typeface = Typeface.LoadFromAssets("anaskh.ttf")
		Case 10
			lb1.Typeface = Typeface.LoadFromAssets("anaskhb.ttf")
		Case Else
			Log("Larger than 8")
	End Select
End Sub

Sub SelectFehrestFontE(lb1 As Label)
	Select FehrestFont
		Case 1
			lb1.Typeface = Typeface.LoadFromAssets("Vazirmatn-Regular.ttf")
		Case 2
			lb1.Typeface = Typeface.LoadFromAssets("Vazirmatn-Bold.ttf")
		Case 3
			lb1.Typeface = Typeface.LoadFromAssets("w_Zar.ttf")
		Case 4
			lb1.Typeface = Typeface.LoadFromAssets("w_Zar Bold.ttf")
		Case 5
			lb1.Typeface = Typeface.LoadFromAssets("w_Mitra.ttf")
		Case 6
			lb1.Typeface = Typeface.LoadFromAssets("w_Mitra Bold.ttf")
		Case 7
			lb1.Typeface = Typeface.LoadFromAssets("w_Nazanin.ttf")
		Case 8
			lb1.Typeface = Typeface.LoadFromAssets("w_Nazanin Bold.ttf")
		Case 9
			lb1.Typeface = Typeface.LoadFromAssets("anaskh.ttf")
		Case 10
			lb1.Typeface = Typeface.LoadFromAssets("anaskhb.ttf")
		Case Else
			Log("Larger than 8")
	End Select
End Sub
Sub SelectFrFont(lb1 As Label)
	Select FarFont
		Case 1
			lb1.Typeface = Typeface.LoadFromAssets("Vazirmatn-Regular.ttf")
		Case 2
			lb1.Typeface = Typeface.LoadFromAssets("Vazirmatn-Bold.ttf")
		Case 3
			lb1.Typeface = Typeface.LoadFromAssets("w_Zar.ttf")
		Case 4
			lb1.Typeface = Typeface.LoadFromAssets("w_Zar Bold.ttf")
		Case 5
			lb1.Typeface = Typeface.LoadFromAssets("w_Mitra.ttf")
		Case 6
			lb1.Typeface = Typeface.LoadFromAssets("w_Mitra Bold.ttf")
		Case 7
			lb1.Typeface = Typeface.LoadFromAssets("w_Nazanin.ttf")
		Case 8
			lb1.Typeface = Typeface.LoadFromAssets("w_Nazanin Bold.ttf")
		Case 9
			lb1.Typeface = Typeface.LoadFromAssets("anaskh.ttf")
		Case 10
			lb1.Typeface = Typeface.LoadFromAssets("anaskhb.ttf")
		Case Else
			Log("Larger than 8")
	End Select
End Sub
Sub SelectArFontE(lb1 As Label)
	Select AraFont
		Case 1
			lb1.Typeface = Typeface.LoadFromAssets("w_AzizE.ttf")
		Case 2
			lb1.Typeface = Typeface.LoadFromAssets("w_Aziz BoldE.ttf")
		Case 3
			lb1.Typeface = Typeface.LoadFromAssets("w_BadrE.ttf")
		Case 4
			lb1.Typeface = Typeface.LoadFromAssets("w_Badr BoldE.ttf")
		Case 5
			lb1.Typeface = Typeface.LoadFromAssets("w_LotusE.ttf")
		Case 6
			lb1.Typeface = Typeface.LoadFromAssets("w_Lotus BoldE.ttf")
		Case 7
			lb1.Typeface = Typeface.LoadFromAssets("w_MitraE.ttf")
		Case 8
			lb1.Typeface = Typeface.LoadFromAssets("w_Mitra BoldE.ttf")
		Case 9
			lb1.Typeface = Typeface.LoadFromAssets("w_NazaninE.ttf")
		Case 10
			lb1.Typeface = Typeface.LoadFromAssets("w_Nazanin BoldE.ttf")
		Case 11
			lb1.Typeface = Typeface.LoadFromAssets("wm_Naskh QuraniE.ttf")
		Case 12
			lb1.Typeface = Typeface.LoadFromAssets("aUtahaE.ttf")
		Case 13
			lb1.Typeface = Typeface.LoadFromAssets("anaskhE.ttf")
		Case 14
			lb1.Typeface = Typeface.LoadFromAssets("anaskhbE.ttf")
		Case Else
			Log("Larger than 12")
	End Select
End Sub
Sub SelectFrFontE(lb1 As Label)
	Select FarFont
		Case 1
			lb1.Typeface = Typeface.LoadFromAssets("Vazirmatn-Regular.ttf")
		Case 2
			lb1.Typeface = Typeface.LoadFromAssets("Vazirmatn-Bold.ttf")
		Case 3
			lb1.Typeface = Typeface.LoadFromAssets("w_Zar.ttf")
		Case 4
			lb1.Typeface = Typeface.LoadFromAssets("w_Zar Bold.ttf")
		Case 5
			lb1.Typeface = Typeface.LoadFromAssets("w_Mitra.ttf")
		Case 6
			lb1.Typeface = Typeface.LoadFromAssets("w_Mitra Bold.ttf")
		Case 7
			lb1.Typeface = Typeface.LoadFromAssets("w_Nazanin.ttf")
		Case 8
			lb1.Typeface = Typeface.LoadFromAssets("w_Nazanin Bold.ttf")
		Case 9
			lb1.Typeface = Typeface.LoadFromAssets("anaskh.ttf")
		Case 10
			lb1.Typeface = Typeface.LoadFromAssets("anaskhb.ttf")
		Case Else
			Log("Larger than 8")
	End Select
End Sub
Sub setLineSpaceEDT(edt As EditText,lineSP As Float) As Float
	Dim before,after As Float
	Dim Obj1 As Reflector
	Dim ht As Float
	Dim strutil As StringUtils
	
	Dim tmpL As EditText
	tmpL.Initialize("")
	tmpL.Text = edt.Text
	tmpL.Typeface = edt.Typeface
	tmpL.TextSize = edt.TextSize
	tmpL.Width = edt.Width
	tmpL.SingleLine = False
	ht = strutil.MeasureMultilineTextHeight(tmpL , tmpL.Text)
	Obj1.Target = tmpL
	before = Obj1.RunMethod("getLineHeight")    'Get the height of line BEFORE you change it
	Obj1.Target = edt
	Obj1.RunMethod3("setLineSpacing",1, "java.lang.float", lineSP, "java.lang.float") 'Change the space between lines
	Obj1.Target = edt
	after = Obj1.RunMethod("getLineHeight")    'Get the height of line AFTER  you change it
	ht = ((after * ht)/before)
	edt.Height = ht
	Return  ht
End Sub
Sub Rangbandi(lb1 As Label,str1 As String,Highlight As Boolean,HighlightIndex As Int,FrFont As Boolean,SetData As AppSetting)
	If str1 = Null Then Return
	Dim RichStr As RichString
	RichStr.Initialize(str1)
	
		For j = 0  To str1.Length - 1
		Dim ch As Char = str1.CharAt(j)
		Dim ascc As Int = Asc(ch)
'		Dim ch1 As Char = 0
'		If j+1 < str1.Length-1 Then ch1 = str1.CharAt(j+1)
		
'		Dim ascc1 As Int
		
'		ascc1 = Asc(ch1)
'		Dim cT1,cT2 As Boolean = False
'		If Main.ErColor Then 
'			Select ascc
'				Case 0x64b,0x64c,0x64d,0x64e,0x64f,0x650,0x651,0x652,0x653,0x654,0x655,0x656,0x670,0x660,0x661,0x662,0x663,0x664,0x665,0x666,0x667,0x668,0x669,0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39
'					cT1 = True
'					Select ascc1
'						Case 0x64b,0x64c,0x64d,0x64e,0x64f,0x650,0x651,0x652,0x653,0x654,0x655,0x656,0x670,0x660,0x661,0x662,0x663,0x664,0x665,0x666,0x667,0x668,0x669,0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39
'							cT2 = True
'					End Select
'					If cT2 And cT1 And j+2 < RichStr.Length Then
'						If Main.nmode Then RichStr.Color(0xFFff6f6f,j,j+2) Else RichStr.Color(Colors.Red,j,j+2)
'						j = j+1
'					Else
'						If Main.nmode Then RichStr.Color(0xFFff6f6f,j,j+1) Else RichStr.Color(Colors.Red,j,j+1)
'					End If
'					
'				Case 0xab,0xbb,0x28,0x29,0x5b,0x5d,0x2f,0x2d,0x2a,0x60c,0x61b,0x3a,0x2e,0x21,0x61f
'					If Main.nmode Then RichStr.Color(0xFF40c4ff,j,j+1) Else RichStr.Color(Colors.Blue,j,j+1)
'			End Select
'		Else
		If FrFont Then
			Select ascc
				Case 0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39
					If SetData.nmode Then RichStr.Color(0xFFff6f6f,j,j+1) Else RichStr.Color(0xff942b28,j,j+1)'Colors.Red
					
'				Case 0xab,0xbb,0x28,0x29,0x5b,0x5d,0x2f,0x2d,0x2a,0x60c,0x61b,0x3a,0x2e,0x21,0x61f,0xfd3e,0xfd3f
'					If SetData.nmode Then RichStr.Color(0xFF69acca,j,j+1) Else RichStr.Color(lb1.TextColor,j,j+1)
			End Select
'		Else
'			Select ascc
'				Case 0xab,0xbb,0x28,0x29,0x5b,0x5d,0x2f,0x2d,0x2a,0x60c,0x61b,0x3a,0x2e,0x21,0x61f,0xfd3e,0xfd3f
'					If SetData.nmode Then RichStr.Color(0xFF69acca,j,j+1) Else RichStr.Color(Colors.Blue,j,j+1)
'			End Select
		End If
	Next
	
	If Highlight Then
		str1 = str1.Replace("ی","ي")
		str1 = str1.Replace("ى","ي")
		str1 = str1.Replace("ك","ک")
		str1 = str1.Replace("إ","ا")
		str1 = str1.Replace("أ","ا")
		ssL = 0
		Dim k As Int = 0
		Dim inloop As Boolean = True
		Do While inloop
			If str1.CharAt(ssL+HighlightIndex) = SearchM.searchStr.CharAt(k) Then
				ssL = ssL + 1
				k = k + 1
				If k = SearchM.searchStr.Length Then inloop = False
				If ssL+HighlightIndex = str1.Length Then inloop = False
			Else
				ssL = ssL + 1
				If ssL+HighlightIndex = str1.Length Then inloop = False
			End If
		Loop
		If HighlightIndex >= 0 And (HighlightIndex+ssL) <= RichStr.Length Then 
			If SetData.nmode Then
				RichStr.Color(Colors.Yellow,HighlightIndex,HighlightIndex+ssL)
				RichStr.BackColor(0x55f5f5f5,HighlightIndex,HighlightIndex+ssL)
			Else
				RichStr.BackColor(0x550a0a0a,HighlightIndex,HighlightIndex+ssL)
				RichStr.Color(Colors.White,HighlightIndex,HighlightIndex+ssL)
			End If
		End If
	End If
	lb1.Text = RichStr
End Sub