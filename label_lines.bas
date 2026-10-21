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
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.

	Private EditText1 As EditText
	Private Button1 As Button
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("lblW")

End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then
		Activity.Finish
		StartActivity(Main)
		myf.SetAnimation("left_right","zoom_exit")
	End If
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
Sub Button1_Click
	Dim oCS As CSBuilder
	Dim Linelist As List
	Linelist.Initialize
	Button1.Text = "Start"
	EditText1.Text = "CREATE TABLE [Ntable4] ([tindex] NUMERIC  NULL,[tpart] NUMERIC  NULL,[tType] NUMERIC  NULL,[ttext] TEXT  NULL,[ttext1] TEXT  NULL,[tpage] TEXT  NULL)CREATE TABLE [Ntable4] ([tindex] NUMERIC  NULL,[tpart] NUMERIC  NULL,[tType] NUMERIC  NULL,[ttext] TEXT  NULL,[ttext1] TEXT  NULL,[tpage] TEXT  NULL)CREATE TABLE [Ntable4] ([tindex] NUMERIC  NULL,[tpart] NUMERIC  NULL,[tType] NUMERIC  NULL,[ttext] TEXT  NULL,[ttext1] TEXT  NULL,[tpage] TEXT  NULL)CREATE TABLE [Ntable4] ([tindex] NUMERIC  NULL,[tpart] NUMERIC  NULL,[tType] NUMERIC  NULL,[ttext] TEXT  NULL,[ttext1] TEXT  NULL,[tpage] TEXT  NULL)CREATE TABLE [Ntable4] ([tindex] NUMERIC  NULL,[tpart] NUMERIC  NULL,[tType] NUMERIC  NULL,[ttext] TEXT  NULL,[ttext1] TEXT  NULL,[tpage] TEXT  NULL)CREATE TABLE [Ntable4] ([tindex] NUMERIC  NULL,[tpart] NUMERIC  NULL,[tType] NUMERIC  NULL,[ttext] TEXT  NULL,[ttext1] TEXT  NULL,[tpage] TEXT  NULL)"
	myf.setEDArfont(EditText1,EditText1.Width)
	EditText1.TextSize = myf.AraSize
'	EditText1.Initialize("")
Sleep(200)
	Log(EditText1.IsInitialized)
	Linelist = GetEditTextLines(EditText1, EditText1.Text, oCS)
	Button1.Text = Linelist.Size
End Sub
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


