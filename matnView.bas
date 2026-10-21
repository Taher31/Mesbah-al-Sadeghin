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
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private li1 As LoadingIndicatorView
	Private li2 As LoadingIndicatorView
	Private li3 As LoadingIndicatorView
	Private li4 As LoadingIndicatorView
	Private li5 As LoadingIndicatorView
	Private li6 As LoadingIndicatorView
	Private li7 As LoadingIndicatorView
	Private li8 As LoadingIndicatorView
	Private li9 As LoadingIndicatorView
	Private li10 As LoadingIndicatorView
	Private li11 As LoadingIndicatorView
	Private li12 As LoadingIndicatorView
	Private li13 As LoadingIndicatorView
	Private li14 As LoadingIndicatorView
	Private li15 As LoadingIndicatorView
	Private li16 As LoadingIndicatorView
	Private li17 As LoadingIndicatorView
	Private li18 As LoadingIndicatorView
	Private li19 As LoadingIndicatorView
	Private li20 As LoadingIndicatorView
	Private li21 As LoadingIndicatorView
	Private li22 As LoadingIndicatorView
	Private li23 As LoadingIndicatorView
	Private li24 As LoadingIndicatorView
	Private li25 As LoadingIndicatorView
	Private li26 As LoadingIndicatorView
	Private li27 As LoadingIndicatorView
	Private li28 As LoadingIndicatorView
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("Layout1")
	li1.IndicatorId = 0
	li1.IndicatorColor = Colors.Red
	li2.IndicatorId = 1
	li2.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li3.IndicatorId = 2
	li3.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li4.IndicatorId = 3
	li4.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li5.IndicatorId = 4
	li5.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li6.IndicatorId = 5
	li6.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li7.IndicatorId = 6
	li7.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li8.IndicatorId = 7
	li8.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li9.IndicatorId = 8
	li9.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li10.IndicatorId = 9
	li10.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li11.IndicatorId = 10
	li11.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li12.IndicatorId = 11
	li12.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li13.IndicatorId = 12
	li13.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li14.IndicatorId = 13
	li14.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li15.IndicatorId = 14
	li15.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li16.IndicatorId = 15
	li16.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li17.IndicatorId = 16
	li18.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li18.IndicatorId = 17
	li18.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li19.IndicatorId = 18
	li19.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li20.IndicatorId = 19
	li20.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li21.IndicatorId = 20
	li21.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li22.IndicatorId = 21
	li22.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li23.IndicatorId = 22
	li23.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li24.IndicatorId = 23
	li24.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li25.IndicatorId = 24
	li25.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li26.IndicatorId = 25
	li26.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li27.IndicatorId = 26
	li27.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li28.IndicatorId = 27
	li28.IndicatorColor = Colors.ARGB(255,Rnd(20, 800),Rnd(80, 160),Rnd(161, 255))
	li1.IndicatorColor = Colors.Red
End Sub

Sub Activity_Resume
	li1.IndicatorId = Rnd(0,27)
	li1.IndicatorColor = Colors.Red
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub
