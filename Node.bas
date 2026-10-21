B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=6.3
@EndOfDesignText@
'Class module
Private Sub Class_Globals
Type NodeC(pnl As Panel, _
		   Btn As Button, _
		   lbl As Label, _
		   IMG As ImageView, _
		   tag As String, _
		   level As Int, _
		   parent As Node, _
		   children As List)
Dim TN As NodeC
Private plus,minus As Bitmap
Private lh,lw As Int
Private Cmodule As Tree	
End Sub

'Initializes the object. 
'Module is the calling module
'parent is the parent Node
'level is one more then the parent's level
'linewidth is the width of the node's panel
'lineheight Is the height of the Node's panel
'Text is the node's label text
'img is the bitmap of the node
'tag and tag1 are tags for use with the control of the tree.
'for file manager tag is keeping the path of the node and tag1 defines if the node is a directory hence will have +/- button, or a file and then the button is invisible.
'To change the bitmaps of + and - place image files named plus2.png and minus2.png in the file.DirAssets instead of the existing files.
Sub Initialize(Module As Tree, _
			   parent As Node, _
			   level As Int, _
			   linewidth As Int, _
			   lineheight As Int, _
			   Text As String, _
			   TextSize As Int, _
			   TextColor As Int, _
			   LabelColor As Int, _
			   img As Bitmap, _
			   tag As String, _
			   tag1 As String	 )

lh = lineheight
lw = linewidth 
plus.Initialize(File.DirAssets,"plus2.png")
minus.Initialize(File.DirAssets,"minus2.png")
Cmodule = Module

TN.Initialize
TN.pnl.Initialize("lbl")
TN.img.Initialize("lbl") ' will do the same action as the label.
TN.img.Gravity = Gravity.FILL
TN.Btn.Initialize("btn")

If tag1 = True Then  ' in case that the node is a directory, or has children
	TN.Btn.SetBackgroundImage(plus)
Else   ' A file, or no children.
	TN.Btn.Visible = False
End If
TN.Btn.tag = tag1
TN.lbl.Initialize("lbl")
TN.children.Initialize
If parent <> Null Then 
	TN.parent = parent
	TN.parent.TN.children.Add(Me)
End If
TN.lbl.Text = Text
TN.lbl.TextSize = TextSize
TN.lbl.TextColor = TextColor
TN.lbl.color = LabelColor

TN.tag = tag 
TN.level = 0 

TN.pnl.AddView(TN.Btn, 0.05*lh, 0.05*lh, 0.9*lh,    0.9*lh)
If img.IsInitialized Then 
	TN.img.SetBackgroundImage(img) 
	TN.pnl.AddView(TN.img, lh* 1.2, 0.05*lh, 0.9*lh,    0.9*lh)
	TN.pnl.AddView(TN.lbl, 2.5*lh,  0.05*lh, lw-2.5*lh, 0.9*lh)
Else
	TN.pnl.AddView(TN.lbl, 1.2*lh,  0.05*lh, lw-1.2*lh, 0.9*lh)
End If
TN.level = level
End Sub

'Gets the data stored in the node's tag.
Sub getTag As String
Return TN.tag
End Sub

'Returns the Node Object As View (a Panel)
Sub AsView As View
Return TN.pnl
End Sub

'Sets the text font size
Sub setTextSize(Size As Int)
TN.lbl.TextSize = Size
End Sub

'Opens or closes the node.
Sub Btn_Click
If TN.Btn.tag Then
	TN.Btn.SetBackgroundImage(minus)
	TN.Btn.tag = False
	Cmodule.Node_Open(Me)	
Else 
	TN.Btn.SetBackgroundImage(plus)
	TN.Btn.tag = True
	Cmodule.Node_close(Me)	

	' do nothing (actually the btn is not visible)
End If
End Sub


Private Sub lbl_click
'	Cmodule.Node_Click(Me)
End Sub


Private Sub lbl_longclick
	Cmodule.Node_longClick(Me)
End Sub



