B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=6.3
@EndOfDesignText@
'Class module
Sub Class_Globals
Private fileimg, folderimg As Bitmap
Dim cnvs As Canvas
Private maxright,lh, delta, TSize As Int
Dim TextColor(2),LblColor(2), num_lines, Pwidth As Int

Dim NULL_IMG As Int = 0
Dim FOLDER_IMG As Int = 1
Dim FILE_IMG As Int = 2
Dim DIR_FILE_IMG As Int = 3
Dim BMP_IMG As Int = 4

Dim DataList As List
Private rootnode, nd() As Node	
Dim  MyModule As Object
Private treeview As ScrollView2D
Private TText, TRoot As String
Type Data(Text As String,Tag As String, btntag As Boolean, ColorSet As Int, bmp As Bitmap,imgdir As String, imgfile As String, imgflag As Int)
End Sub

'Initializes the object.
'Module - the launching module
'Color - the color of the scrollview panel
'Defaults: line height - 40dip
'fontsize - 20, fontcolor white, label color black.
'To change the default use SetAppearance or specific methods.
'To change the images of the folder and file, replace the files "file.png" and folder2.png" with suitable image files.
Public Sub Initialize(Module As Object, Color As Int,  Eventname As String)
MyModule = Module
'Myeventname = Eventname
treeview.Initialize(-1,-1,"treeview")
treeview.Panel.Color = Color

Dim lv As LayoutValues
lv = GetDeviceLayoutValues
If lv.ApproximateScreenSize > 5 Then
	If 100%x > 100%y Then lh =  8%y Else lh = 4.8%y
Else
	If 100%x > 100%y Then lh =  12%y Else lh = 7.2%y
End If
TSize = 20
TextColor(0) = Colors.White
LblColor(0) = Colors.Black
TextColor(1) = Colors.yellow
LblColor(1) = Colors.DarkGray

fileimg.Initialize(File.DirAssets,"file.png")
folderimg.Initialize(File.DirAssets,"folder2.png")
		' to init a canvas on something, for the string length measurement
Dim p As Panel
p.Initialize("")
treeview.Panel.AddView(p,-10,-10,10,10)
cnvs.Initialize(p)
DataList.Initialize
End Sub



'Root is the root of the tree (i.e. File.DirRootExternal for file tree)
'Text is the name of the Root as will appear in the display.
Sub SetRoot(Root As String,Text As String, ColorSet As Int, bmp As Bitmap)
Dim lw As Int
TText = Text
TRoot = Root
Pwidth = treeview.width
lw = 3 * lh + cnvs.MeasureStringWidth(TText,Typeface.DEFAULT,TSize)
maxright = Max((lw + lh/2), treeview.width)
If maxright > treeview.Panel.Width Then treeview.Panel.Width = maxright
rootnode.Initialize(Me,Null,0,lw,lh,TText, TSize,  TextColor(ColorSet), LblColor(ColorSet),bmp,TRoot,True )
treeview.Panel.AddView(rootnode.AsView,0,0,lw,lh)
num_lines = 1
End Sub

'Opens the root node by code, to show its children.
'Should be called in activity_resume or later in the execution.
Public Sub OpenRoot
rootnode.btn_click
End Sub

'Returns the object reference as a view, which is a Scrollview2D
Sub AsView As View
Return  treeview
End Sub

Sub SetLineHeight(Value As Int) 'ignore
lh = Value
End Sub

Sub SetTextSize(Size As Int) 'ignore
TSize = Size
End Sub

'Defines two sets of label color and textcolor to emphsize special nodes.
'In GetData place TRUE in the ColorList item to use the second set, or FALSE for the first set.
Sub SetLabelColors(Textcolor1 As Int, lblcolor1 As Int, Textcolor2 As Int, lblcolor2 As Int) 'ignore
TextColor(0) = Textcolor1
LblColor(0) = lblcolor1
TextColor(1) = Textcolor2
LblColor(1) = lblcolor2
End Sub

'LineHeight refer to the node's panel height.
'Size is fontsize.
Sub SetLineSize( LineHeight As Int, Size As Int) 'ignore
lh = LineHeight
TSize = Size
End Sub

'Closes an open node
Sub Node_Close(tnode As Node)
Dim mx As Int
Dim p As Panel

delta = 0   ' a counter for collapsed lines       
remove_children(tnode)
move_nodes( tnode.AsView.Top ,-delta) ' move lower nodes up
			' re-adjust treeview.panel.width to the minimum required
mx = 0  
For i = 0 To treeview.Panel.NumberOfViews - 1
	p = treeview.Panel.GetView(i)
	mx = Max(mx,p.Left+p.Width)	
Next
maxright = Max(mx,Pwidth)
treeview.Panel.Width = maxright
treeview.HorizontalScrollPosition = 0
End Sub

'Expands a node and creates new nodes as children nodes.
Sub Node_Open(tnode As Node)
Dim tbmp As Bitmap
Dim lw, shift, col1,col2 As Int

Dim Da As Data

If SubExists(MyModule,"GetData") Then
	DataList.Initialize
	CallSub3(MyModule,"GetData",Me,tnode.TN.tag)
Else
	Return
End If
If DataList.IsInitialized = False Then Return
If DataList.Size > 100 Then ProgressDialogShow("Wait for Node to populate")
Dim nd(DataList.Size) As Node
num_lines = num_lines + DataList.Size
move_nodes( tnode.TN.pnl.Top ,DataList.Size)
For i = 0 To DataList.Size-1         ' assign data items to new nodes

	Da = DataList.Get(i)
	lw = 3 * lh + cnvs.MeasureStringWidth(Da.Text,Typeface.DEFAULT,TSize)
	shift = (tnode.TN.level + 1) * lh
	If lw + shift > maxright Then maxright = lw + shift + lh/2
	If maxright > treeview.Panel.Width Then treeview.Panel.Width = maxright
	col1 = TextColor(Da.ColorSet)
	col2 = LblColor(Da.ColorSet)
	
	Select Da.imgflag
		Case NULL_IMG  ' = 0
			tbmp = Null
		Case FOLDER_IMG  ' =1
			tbmp = folderimg
		Case FILE_IMG  ' =2
			tbmp = fileimg
		Case DIR_FILE_IMG  ' =3
			tbmp = LoadBitmap(Da.imgdir,Da.imgfile)
		Case BMP_IMG  ' =4
			tbmp = Da.bmp
	End Select
	
	
	nd(i).Initialize(Me,tnode,tnode.TN.level + 1,lw,lh,Da.text,TSize,col1,col2,tbmp,Da.tag,Da.BtnTag )
	treeview.Panel.AddView(nd(i).AsView, nd(i).TN.level*lh,tnode.AsView.Top +(i+1)*lh,lw,lh)
	If i < 30 Then DoEvents
Next
ProgressDialogHide
End Sub

Private Sub move_nodes( top As Int,lines As Int)
Dim v As View
treeview.Panel.Height =  Max(100%y, (num_lines+1) *lh ) ' change panel height to fit number of lines.
For j = 0 To treeview.Panel.NumberOfViews - 1  
	v = treeview.Panel.GetView(j)
	If v.top  > top Then
		v.top = v.top + lines * lh
	End If
Next
End Sub

Private Sub remove_children(Rnode As Node)  ' close a node
Dim delnode As Node
num_lines = num_lines - Rnode.TN.children.Size
For i =  Rnode.TN.children.Size - 1 To 0 Step - 1
	delta = delta + 1
 	delnode = Rnode.TN.children.Get(i)
								 ' recursion if the sub node is open
	If delnode.TN.Btn.tag = False Then remove_children(delnode) 
	delnode.TN.pnl.RemoveView  ' then delete it
Next
Rnode.TN.children.Clear  ' zero the child list in the closing node
End Sub

'Reacts to Node LongClick event
'What to do is defined by the launching activity's sub "NodeLongClicked"
Sub Node_LongClick(tnode As Node)
If SubExists(MyModule,"NodeLongClicked") Then
	CallSubDelayed3(MyModule,"NodeLongClicked",Me,tnode.TN.tag)
End If
End Sub

'Remove all nodes from the tree, including the root.
Sub ClearTree
rootnode.TN.Btn.Tag = False
rootnode.btn_click
rootnode.TN.pnl.RemoveView
treeview.HorizontalScrollPosition = 0
DataList.Initialize
End Sub





