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
	Dim cur As Cursor
	Private clv1 As CustomListView
	Private Label1cel As Label
	Private pnl1 As Panel
'	Private cvs As Canvas
	Dim ItemNumber() As Int
	Dim ItemText() As String
	Dim booksel As Int
	Dim SetData As AppSetting
End Sub

Sub Activity_Create(FirstTime As Boolean)
	myf.Loading(SetData)
	Activity.LoadLayout("MarkNeshan")
'	Label1.TextSize=20
	Label1.TextColor = 0xffc4a263
	Dim path As String = File.ReadString(File.DirInternalCache,"bookAddr.txt")
	Dim DatabaseName As String = File.ReadString(File.DirInternalCache,"booksel.txt")
	booksel = File.ReadString(File.DirInternalCache,"booktype.txt")
	myf.DatabesOpen(s1,path,DatabaseName,False)
'	cur = s1.ExecQuery("select val from prevTable where name = 'booknum'")
'	cur.Position = 0
'	booksel = cur.GetInt2(0)
'	cvs.Initialize(pnl1)
	pnl1.Color = SetData.TopbackColor
	If SetData.nmode Then
		Activity.Color = 0x002223
	Else
		Activity.Color = SetData.backColor
	End If
	NightOrDayModeSel
End Sub
Sub CLV1_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 0
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clv1.Size - 1)
		If clv1.GetPanel(i).Tag = 0 Then
			onvanMatnhaCLV(i,clv1.GetValue(i))
		End If
		'End If
	Next
End Sub
Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Activity.Finish
		myf.SetAnimation("task_close_enter","task_close_exit")
		Return True
	End If
	Return False
End Sub
Sub onvanMatnhaCLV(i As Int,ii As Int)
	Dim tmpl As Label
	tmpl.Initialize("")
	tmpl.Text = ItemText(i)
	myf.setFrMatnfont(tmpl,94%x-5%x)
	tmpl.Ellipsize = "END"
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
	ItemText(i) = ItemText(i).Replace("أ","أ")
	myf.Rangbandi(Label1cel,ItemText(i),False,0,True,SetData)
	If SetData.nmode Then Label1cel.TextColor = Colors.White Else Label1cel.TextColor = 0xFF021c1a'1b1448'Colors.Black
	
	Label1cel.Top = 0
	Label1cel.Ellipsize = "END"
	Label1cel.Left = 15%x
	myf.setFrMatnfont(Label1cel,clv1.AsView.Width - 20%x)
	Label1cel.Tag = ii
	p.Tag = 1
	Dim but As Button
	but.Initialize("DeleteN")
	but.Left = 0
	but.Top = 0
	but.Width = 10%x
	but.Height = 10%x
	
'	If SetData.nmode Then 
'		Dim BMPA As NegativeImage
'		but.SetBackgroundImage(BMPA.NegativeBMP(LoadBitmap(File.DirAssets,"clear.png")))
'	Else 
		but.SetBackgroundImage(LoadBitmap(File.DirAssets,"nDel.png"))
'	End If
	but.Tag = i
	p.AddView(but,0,tmpl.Height/2 - 5%x,10%x,10%x)
	clv1.ReplaceAt(i,p,tmpl.Height,$"${ii}"$)'clv1.ReplaceAt(i,p,tmpl.Height*1.2,$"${ii}"$)
End Sub
Sub DeleteN_Click
	Dim v As View
	v = Sender
	If v.Tag >= 0 Then
		If booksel = 8 Then
			s1.ExecNonQuery("delete from NeshanehTable where (ItemNumber=" & ItemNumber(v.Tag) & " and idonvan=" & onvanha.idonvan &")")
		Else
			s1.ExecNonQuery("delete from NeshanehTable where (ItemNumber=" & ItemNumber(v.Tag) & " and idonvan=" & onvanha.idonvan & ")")
		End If
		NightOrDayModeSel
	End If
End Sub
Sub clv1_ItemClick(Index As Int, Value As Object)
	If Value >= 0 Then
		If booksel = 4 Then
			If Index Mod 2 = 0 Then clv1.GetPanel(Index).Color = 0x11000000
			Dim itnm As Int = ItemNumber(Index)
			Motoon.edameh = True
			Motoon.startItem = itnm
			Activity.Finish
			StartActivity(Motoon)
			myf.SetAnimation("task_close_enter","task_close_exit")
		Else
			If Index Mod 2 = 0 Then clv1.GetPanel(Index).Color = 0x11000000
			Dim itnm As Int = ItemNumber(Index)
			matnha.edameh = True
			matnha.startItem = itnm
			Activity.Finish
			StartActivity(matnha)
			myf.SetAnimation("task_close_enter","task_close_exit")
		End If
	End If
End Sub
'Sub Label1cel_LongClick
'	Dim Result As Int = Msgbox2("نشانه انتخابی حذف شود؟","","بلی","خیر","",Null)
'	If Result = DialogResponse.POSITIVE Then
'		Dim v As View
'		v = Sender
'		s1.ExecNonQuery("delete from NeshanehTable where (ItemNumber=" & v.Tag & "and idonvan=" & onvanha.idonvan &")")
'		NightOrDayModeSel
'	End If
'End Sub
Sub NightOrDayModeSel
	clv1.Clear
	pnl1.Color = SetData.TopbackColor
	If SetData.nmode Then
		Activity.Color = 0x002223
	Else
		Activity.Color = SetData.backColor
	End If
'	myf.SetTiledBackground(clv1.AsView,LoadBitmapResize(File.DirAssets,"b.png",60%x,60%x,False))
'	myf.loadThemes(cvs,Main.nmode)
	If booksel = 8 Then
		cur  = s1.ExecQuery("select * from NeshanehTable where idonvan =" & onvanha.idonvan)
	Else
		cur  = s1.ExecQuery("select * from NeshanehTable where idonvan =" & onvanha.idonvan &" and bookidx=" &booksel)
	End If
	cur.Position = 0
	If cur.RowCount > 0 Then
		Label1.Text = "نشانه ها"
		Dim ItemNumber(cur.RowCount) As Int
		Dim ItemText(cur.RowCount) As String
		For i = 0 To cur.RowCount-1
			cur.Position = i
			ItemNumber(i) = cur.GetInt("ItemNumber")
			ItemText(i)  = cur.GetString("ItemText")
			Dim p As B4XView = xui.CreatePanel("")
			p.Left = 0
			p.Top = 0
			p.Width = clv1.sv.Width
			p.Height = 10%y
			p.Tag = 0
			clv1.InsertAt(i,p,$"${cur.GetInt("ItemNumber")}"$)
		Next
		cur.Close
	Else
		Label1.Text = "نشانه ها خالی است"
		Dim p As B4XView = xui.CreatePanel("")
		p.Left = 0
		p.Top = 0
		p.Width = clv1.sv.Width
		p.Height = 10%y
		p.LoadLayout("matncell")
		Dim strFree As String = "جهت درج نشانه، در قسمت متن کتاب، پاراگراف مورد نظر را به مدت طولانی لمس نمایید."
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