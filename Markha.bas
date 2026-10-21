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
	Private xui As XUI
	Dim s1 As SQL
End Sub

Sub Globals
	Private Label1 As Label
	Dim cur,cur1 As Cursor
	Private clv1 As CustomListView
	Private Label1cel As Label
	Private pnl1 As Panel
	Private cvs As Canvas
	Dim tindex() As Int
	Dim ttitle() As String
	Dim booksel As Int
	Dim SetData As AppSetting
End Sub

Sub Activity_Create(FirstTime As Boolean)
	myf.Loading(SetData)
	Activity.LoadLayout("MarkNeshan")
	pnl1.Color = SetData.TopbackColor
	Dim path As String = File.ReadString(File.DirInternalCache,"bookAddr.txt")
	Dim DatabaseName As String = File.ReadString(File.DirInternalCache,"booksel.txt")
	booksel = File.ReadString(File.DirInternalCache,"booktype.txt")
	myf.DatabesOpen(s1,path,DatabaseName,False)
'	cur = s1.ExecQuery("select val from prevTable where name = 'booknum'")
'	cur.Position = 0
'	booksel = cur.GetInt("val")
'	Label1.TextSize=20
	Label1.TextColor = 0xffc4a263
	cvs.Initialize(pnl1)
	NightOrDayModeSel
End Sub
Sub CLV1_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 0
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clv1.Size - 1)
		'If clv1.GetPanel(i).NumberOfViews = 0 Then
		If clv1.GetPanel(i).Tag = 0 Then
			onvanMatnhaCLV(i,clv1.GetValue(i))
		End If
		'End If
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
	p.LoadLayout("matncell")
	If i Mod 2 = 0 Then
		If SetData.nmode Then p.Color = 0x0Affffff Else p.Color = 0xfff1ebda'0xfff7f0df
	Else
		If SetData.nmode Then p.Color = 0x05ffffff Else p.Color = 0xfffdf8e5
	End If
	ttitle(i) = ttitle(i).Replace("أ","أ")
	myf.Rangbandi(Label1cel,ttitle(i),False,0,True,SetData)
	If SetData.nmode Then Label1cel.TextColor = Colors.White Else Label1cel.TextColor = 0xFF021c1a'1b1448'Colors.Black
	Label1cel.Left = 15%x
	Label1cel.Top = 0
	Label1cel.Ellipsize = "END"
	myf.setFrMatnfont(Label1cel,clv1.AsView.Width-25%x)
	p.Tag = 1
	Dim but As Button
	but.Initialize("DeleteN")
	but.Left = 0
	but.Top = 0
	but.Width = 10%x
	but.Height = 10%x
	
	but.SetBackgroundImage(LoadBitmap(File.DirAssets,"bookmarkclear.png"))
	but.Tag = i
	p.AddView(but,0,tmpl.Height/2 - 5%x,10%x,10%x)
	If booksel = 8 Then
		cur  = s1.ExecQuery("select * from NeshanehTable where idonvan =" & tindex(i))
	Else
		cur  = s1.ExecQuery("select * from NeshanehTable where idonvan =" & tindex(i) &" and bookidx="&booksel)
	End If
	If cur.RowCount > 0 Then
		Dim but1 As Button
		but1.Initialize("neshane")
		but1.Left = 0
		but1.Top = 0
		but1.Width = 10%x
		but1.Height = 10%x
		If SetData.nmode Then
			Dim BMPA As NegativeImage
			but1.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"neshane.png")))
		Else
			but1.SetBackgroundImage(LoadBitmap(File.DirAssets,"neshane.png"))
		End If
		p.AddView(but1,15%x + Label1cel.Width,tmpl.Height/2 - 5%x,10%x,10%x)
	End If
	clv1.ReplaceAt(i,p,tmpl.Height,$"${ii}"$)
End Sub

Sub neshane_Click
	
End Sub

Sub DeleteN_Click
	Dim v As View
	v = Sender
	If v.Tag >= 0 Then
		If booksel = 8 Then
			s1.ExecNonQuery("delete from marktable where tindex=" & tindex(v.Tag))
		Else
			s1.ExecNonQuery("delete from marktable where tindex=" & tindex(v.Tag) & " and bookidx="&booksel)
		End If
		NightOrDayModeSel
	End If
End Sub
Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Activity.Finish
		myf.SetAnimation("task_close_enter","task_close_exit")
		Return True
	End If
	Return False
End Sub
Sub clv1_ItemClick(Index As Int, Value As Object)
	If Value > = 0 Then
		
		Dim labelA As Label
		labelA = clv1.GetPanel(Index).GetView(0)
		onvanha.onvanSel = labelA.Text
		onvanha.idonvan = tindex(Index)
		File.WriteString(File.DirInternalCache,"onvanha.txt",onvanha.idonvan)
		onvanha.search = False
		If Index Mod 2 = 0 Then clv1.GetPanel(Index).Color = 0x11000000
		matnha.edameh = False
		If booksel = 8 Then
			cur  = s1.ExecQuery("select * from NeshanehTable where idonvan =" & onvanha.idonvan)
		Else
			cur  = s1.ExecQuery("select * from NeshanehTable where idonvan =" & onvanha.idonvan&" and bookidx="&booksel)
		End If
		If cur.RowCount > 0 Then
			cur.Close
			If booksel = 4 Then
				Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'tindex'")
				If cur1.RowCount > 0 Then
					s1.ExecNonQuery("update prevTable set val = " & tindex(Index))
				Else
					s1.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& tindex(Index)&")")
				End If
				cur1.Close
				cur1 = s1.ExecQuery("select * from prevTable where name = 'booknum'")
				If cur1.RowCount > 0 Then
					s1.ExecNonQuery("update prevTable set val = 4  where name = 'booknum'")
				Else
					s1.ExecNonQuery("insert into prevTable VALUES(4,'booknum',4)")
				End If
				cur1.Close
			End If
			StartActivity(NeshaneHa)
			myf.SetAnimation("task_open_enter","task_open_exit")
		Else
			cur.Close
			If booksel = 4 Then
				Dim cur1 As Cursor = s1.ExecQuery("select * from prevTable where name = 'tindex'")
				If cur1.RowCount > 0 Then
					s1.ExecNonQuery("update prevTable set val = " & tindex(Index))
				Else
					s1.ExecNonQuery("insert into prevTable VALUES(1,'tindex',"& tindex(Index)&")")
				End If
				cur1.Close
				StartActivity(Motoon)
				myf.SetAnimation("task_open_enter","task_open_exit")
			Else 
				StartActivity(matnha)
				myf.SetAnimation("task_open_enter","task_open_exit")
			End If
			
		End If
	End If
End Sub
Sub NightOrDayModeSel
	clv1.Clear
	If SetData.nmode = False Then
		Activity.Color = SetData.backColor
	Else
		Activity.Color = 0x002223
	End If
'	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
'	myf.loadThemes(cvs,SetData.nmode,SetData)
	
'	cur  = s1.ExecQuery("select * from table2 where tindex IN (select * from marktable)")
'	cur.Position = 0
'	If cur.RowCount > 0 Then
'		Label1.Text = "فهرست منتخب"
'		Dim tindex(cur.RowCount) As Int
'		Dim ttitle(cur.RowCount) As String
'		For i = 0 To cur.RowCount-1
'			cur.Position = i
'			tindex(i) = cur.GetInt("tindex")
'			ttitle(i)  = cur.GetString("ttitle")
'		Next
'	Else
'		Label1.Text = "فهرست منتخب خالی است"
'	End If
'	cur.Close
	If booksel = 8 Then
		cur  = s1.ExecQuery("select * from marktable")
	Else
		cur  = s1.ExecQuery("select * from marktable where bookidx="&booksel)
	End If
	If cur.RowCount > 0 Then
		Label1.Text = "فهرست منتخب"
		Dim tindex(cur.RowCount) As Int
		Dim ttitle(cur.RowCount) As String
		For i = 0 To cur.RowCount-1
			cur.Position = i
			tindex(i) = cur.GetInt("tindex")
			If booksel = 2 Or booksel = 4 Then
				cur1 = s1.ExecQuery("select * from table2 where tindex="&tindex(i))
				cur1.Position = 0
				If booksel = 4 Then
					ttitle(i)  = cur1.GetString("ttitle")
				Else
					ttitle(i)  = cur1.GetString("tfttitle")
				End If
				
			else If booksel = 3 Then
				cur1 = s1.ExecQuery("select * from tf1table2 where tindex="&tindex(i))
				cur1.Position = 0
				ttitle(i)  = cur1.GetString("ttitle")
			else If booksel = 8 Then
				cur1 = s1.ExecQuery("select * from table2 where tindex="&tindex(i))
				cur1.Position = 0
				ttitle(i)  = cur1.GetString("ttitle")
			End If
			
			Dim p As B4XView = xui.CreatePanel("")
			p.Left = 0
			p.Top = 0
			p.Width = clv1.sv.Width
			p.Height = 5%x
			p.Tag = 0
			clv1.InsertAt(i,p,$"${cur.GetInt("tindex")}"$)
		Next
	Else
		Label1.Text = "فهرست منتخب خالی است"
		Dim p As B4XView = xui.CreatePanel("")
		p.Left = 0
		p.Top = 0
		p.Width = clv1.sv.Width
		p.Height = 10%y
		p.LoadLayout("matncell")
		Dim strFree As String = "جهت اضافه کردن آیتم به فهرست منتخب، بر روی کلید بوکمارک در قسمت متن کتاب کلیک نمایید."
		myf.Rangbandi(Label1cel,strFree,False,0,True,SetData)
		If SetData.nmode Then Label1cel.TextColor = Colors.White Else Label1cel.TextColor = 0xFF021c1a'1b1448'Colors.Black
		Label1cel.Gravity = Gravity.CENTER_HORIZONTAL
		Label1cel.Top = 0
		Label1cel.Ellipsize = "END"
		Label1cel.Left = 5%x
		myf.setFMatnfont(Label1cel,clv1.AsView.Width - 10%x)
		p.Height = Label1cel.Height
		Label1cel.Tag = -1
		p.Tag = -1
		clv1.InsertAt(i,p,$"${-1}"$)
	End If
	Label1.Top = 46*100%x/642 + 5%x + 3.5*100%x/642 - Label1.Height/2
	Label1.Left = 50%x - Label1.Width/2
	cur.Close
End Sub
Sub Activity_Resume
	myf.Loading(SetData)
	NightOrDayModeSel
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then 
		Activity.Finish
		myf.SetAnimation("task_close_enter","task_close_exit")
	End If
End Sub
