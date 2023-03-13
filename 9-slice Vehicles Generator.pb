;===========================
; 9-slice Vehicles Generator
;
; by DjPoke (c) 2023
;===========================

; encoders and decoders
UsePNGImageEncoder()
UsePNGImageDecoder()

; declarations
Declare ThrowError(e.s)
Declare UpdateSpriteLists()
Declare Draw9SliceSprite(n.i, w.i, h.i)
Declare UpdateCanvas()
Declare SaveSpriteAs()
Declare LoadGadgetImage(i.i)

; vars
Global Dim x.i(5)
Global Dim y.i(5)
Global Dim width.i(5)
Global Dim height.i(5)
Global Dim sx.i(5)
Global Dim sy.i(5)
Global Dim layerX(5)
Global Dim layerY(5)
Global Dim color(5)

Global Dim d$(5)
d$(1) = "Cockpit"
d$(2) = "Wings"
d$(3) = "Tail"
d$(4) = "Reactors"
d$(5) = "Weapons"

Global colorPreset = 0

; open the window
If OpenWindow(0, 0, 0, 800, 600, "9-slice Vehicles Generator", #PB_Window_SystemMenu|#PB_Window_TitleBar|#PB_Window_ScreenCentered|#PB_Window_MinimizeGadget)
  If CreateMenu(0, WindowID(0))
    MenuTitle("File")
    MenuItem(1, "New" + Chr(9) + "Ctrl+N")
    MenuItem(2, "Save As..." + Chr(9) + "Ctrl+S")
    MenuBar()
    MenuItem(9, "Quit" + Chr(9) + "Ctrl+Q")
  EndIf    
  
  ; create shortcuts
  AddKeyboardShortcut(0, #PB_Shortcut_Control|#PB_Shortcut_N, 1)
  AddKeyboardShortcut(0, #PB_Shortcut_Control|#PB_Shortcut_S, 2)
  AddKeyboardShortcut(0, #PB_Shortcut_Control|#PB_Shortcut_Q, 9)
  
  ; create color images
  For i = 3001 To 3005
    color(i - 3000) = RGB(255, 255, 255)
    CreateImage(i, 25, 25, 32, color(i - 3000))
  Next
  
  ; canvas
  CanvasGadget(1, 10, 10, 256, 256)
  
  ; edit bodyparts buttons
  PanelGadget(2, 276, 10, 514, 256)
  AddGadgetItem(2, -1, d$(1))
  ComboBoxGadget(3, 10, 10, 200, 25)
  TextGadget(20, 10, 42, 40, 25, "Scale:")
  SpinGadget(8, 50, 40, 40, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(9, 90, 40, 40, 25, 0, 7, #PB_Spin_Numeric)
  TextGadget(31, 140, 42, 35, 25, "Filter:")
  ButtonImageGadget(26, 175, 40, 25, 25, ImageID(3001))
  AddGadgetItem(2, -1, d$(2))
  ComboBoxGadget(4, 10, 10, 200, 25)
  TextGadget(21, 10, 42, 40, 25, "Scale:")
  SpinGadget(10, 50, 40, 40, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(11, 90, 40, 40, 25, 0, 7, #PB_Spin_Numeric)
  TextGadget(32, 140, 42, 35, 25, "Filter:")
  ButtonImageGadget(27, 175, 40, 25, 25, ImageID(3002))
  AddGadgetItem(2, -1, d$(3))
  ComboBoxGadget(5, 10, 10, 200, 25)
  TextGadget(22, 10, 42, 40, 25, "Scale:")
  SpinGadget(12, 50, 40, 40, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(13, 90, 40, 40, 25, 0, 7, #PB_Spin_Numeric)
  TextGadget(33, 140, 42, 35, 25, "Filter:")
  ButtonImageGadget(28, 175, 40, 25, 25, ImageID(3003))
  AddGadgetItem(2, -1, d$(4))
  ComboBoxGadget(6, 10, 10, 200, 25)
  TextGadget(23, 10, 42, 40, 25, "Scale:")
  SpinGadget(14, 50, 40, 40, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(15, 90, 40, 40, 25, 0, 7, #PB_Spin_Numeric)
  TextGadget(34, 140, 42, 35, 25, "Filter:")
  ButtonImageGadget(29, 175, 40, 25, 25, ImageID(3004))
  AddGadgetItem(2, -1, d$(5))
  ComboBoxGadget(7, 10, 10, 200, 25)
  TextGadget(24, 10, 42, 40, 25, "Scale:")
  SpinGadget(16, 50, 40, 40, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(17, 90, 40, 40, 25, 0, 7, #PB_Spin_Numeric)
  TextGadget(35, 140, 42, 35, 25, "Filter:")
  ButtonImageGadget(30, 175, 40, 25, 25, ImageID(3005))
  CloseGadgetList()
  
  TextGadget(18, 10, 282, 35, 25, "Scale:")
  SpinGadget(19, 45, 280, 40, 25, 1, 2, #PB_Spin_Numeric)
  
  ButtonGadget(25, 120, 280, 70, 25, "Lucky ?")
  
  TextGadget(36, 210, 282, 70, 25, "Color Preset:")
  SpinGadget(37, 280, 280, 40, 25, 0, 6, #PB_Spin_Numeric)

  ; set gadget texts to default value
  SetGadgetText(19, "1")
  SetGadgetText(37, "0")
  
  ; create render images
  For i = 11 To 15
    CreateImage(i, 256, 256, 32, #PB_Image_Transparent)
  Next
  
  ; update 9-slice sprites in all lists
  UpdateSpriteLists()
 
  ; select cockpit first
  SetGadgetState(2, 0)

  ; events loop
  Repeat
    ev = WaitWindowEvent()
    
    Select ev
      Case #PB_Event_Menu
        em = EventMenu()
        
        Select em
          Case 1
            ; replace render images by new ones
            For i = 11 To 15
              FreeImage(i)
              CreateImage(i, 256, 256, 32, #PB_Image_Transparent)
            Next
            
            ; clear the canvas
            StartDrawing(CanvasOutput(1))
            DrawingMode(#PB_2DDrawing_Default)
            Box(0, 0, 256, 256, RGB(255, 255, 255))
            StopDrawing()
            
            ; clear combobox
            For i = 3 To 7
              SetGadgetState(i, -1)
            Next
            
            ; clear values
            For i = 8 To 17
              SetGadgetText(i, "")
            Next
            
            ; reset color filters
            For i = 3001 To 3005
              FreeImage(i)
              color(i - 3000) = RGB(255, 255, 255)
              CreateImage(i, 25, 25, 32, color(i - 3000))
              SetGadgetAttribute(i - 3000 + 25, #PB_Button_Image, ImageID(i))
            Next
          Case 2
            SaveSpriteAs()
          Case 9
            Break
         EndSelect
      Case #PB_Event_CloseWindow
        Break
      Case #PB_Event_Gadget
        eg = EventGadget()
        et = EventType()
        
        Select eg
          Case 3, 4, 5, 6, 7
            If GetGadgetState(eg) > -1
              LoadGadgetImage(eg - 2)
            EndIf
          Case 8, 10, 12, 14, 16
            If GetGadgetState(((eg - 6) / 2) + 2) > -1
              sx((eg - 6) / 2) = Val(GetGadgetText(eg))
              x((eg - 6) / 2) = (256 - ((sx((eg - 6) / 2) + 2) * width((eg - 6) / 2))) / 2
            
              Draw9SliceSprite(((eg - 6) / 2), sx((eg - 6) / 2), sy((eg - 6) / 2))
              UpdateCanvas()
            EndIf
          Case 9, 11, 13, 15, 17
            If GetGadgetState(((eg - 7) / 2) + 2) > -1
              sy((eg - 7) / 2) = Val(GetGadgetText(eg))
              y((eg - 7) / 2) = (256 - ((sy((eg - 7) / 2) + 2) * height((eg - 7) / 2))) / 2
            
              Draw9SliceSprite(((eg - 7) / 2), sx((eg - 7) / 2), sy((eg - 7) / 2))
              UpdateCanvas()
            EndIf
          Case 19
            UpdateCanvas()
          Case 25
            ; load gadget images
            For i = 1 To 5
              SetGadgetState(i + 2, Random(CountGadgetItems(i + 2) - 1, 0))
              LoadGadgetImage(i)              
            Next
            
            ; random colors
            Select colorPreset
              Case 1, 4
                r.i = Random(255, 128)
                g.i = Random(255, 128)
                b.i = Random(255, 128)
                
                For i = 1 To 5
                  color(i) = RGB(r, g, b)
                  
                  StartDrawing(ImageOutput(i + 3000))
                  DrawingMode(#PB_2DDrawing_Default)
                  Box(0, 0, 25, 25, color(i))
                  StopDrawing()
                  
                  SetGadgetAttribute(i + 25, #PB_Button_Image, ImageID(i + 3000))
                Next
              Case 2, 5
                For i = 1 To 5
                  color(i) = RGB(Random(255, 192), Random(255, 192), Random(255, 192))
                  
                  StartDrawing(ImageOutput(i + 3000))
                  DrawingMode(#PB_2DDrawing_Default)
                  Box(0, 0, 25, 25, color(i))
                  StopDrawing()
                  
                  SetGadgetAttribute(i + 25, #PB_Button_Image, ImageID(i + 3000))
                Next
              Case 3, 6
                For i = 1 To 5
                  color(i) = RGB(Random(255, 64), Random(255, 64), Random(255, 64))
                  
                  StartDrawing(ImageOutput(i + 3000))
                  DrawingMode(#PB_2DDrawing_Default)
                  Box(0, 0, 25, 25, color(i))
                  StopDrawing()
                  
                  SetGadgetAttribute(i + 25, #PB_Button_Image, ImageID(i + 3000))
                Next
            EndSelect
            
            ; random sizes
            For i = 8 To 16 Step 2
              If GetGadgetState(((i - 6) / 2) + 2) > -1
                SetGadgetText(i, Str(Random(7, 0)))
                
                sx((i - 6) / 2) = Val(GetGadgetText(i))
                x((i - 6) / 2) = (256 - ((sx((i - 6) / 2) + 2) * width((i - 6) / 2))) / 2
                
                Draw9SliceSprite(((i - 6) / 2), sx((i - 6) / 2), sy((i - 6) / 2))
                UpdateCanvas()
              EndIf
            Next
            
            For i = 9 To 17 Step 2
              If GetGadgetState(((i - 7) / 2) + 2) > -1
                SetGadgetText(i, Str(Random(7, 0)))
                
                sy((i - 7) / 2) = Val(GetGadgetText(i))
                y((i - 7) / 2) = (256 - ((sy((i - 7) / 2) + 2) * height((i - 7) / 2))) / 2
                
                Draw9SliceSprite(((i - 7) / 2), sx((i - 7) / 2), sy((i - 7) / 2))
                UpdateCanvas()
              EndIf
            Next            
          Case 26, 27, 28, 29, 30
            color(eg - 25) = ColorRequester()
            
            StartDrawing(ImageOutput(eg - 25 + 3000))
            DrawingMode(#PB_2DDrawing_Default)
            Box(0, 0, 25, 25, color(eg - 25))
            StopDrawing()
            
            SetGadgetAttribute(eg, #PB_Button_Image, ImageID(eg - 25 + 3000))
            
            For i = 8 To 16 Step 2
              If GetGadgetState(((i - 6) / 2) + 2) > -1
                sx((i - 6) / 2) = Val(GetGadgetText(i))
                x((i - 6) / 2) = (256 - ((sx((i - 6) / 2) + 2) * width((i - 6) / 2))) / 2
                
                Draw9SliceSprite(((i - 6) / 2), sx((i - 6) / 2), sy((i - 6) / 2))
                UpdateCanvas()
              EndIf
            Next
            
            For i = 9 To 17 Step 2
              If GetGadgetState(((i - 7) / 2) + 2) > -1
                sy((i - 7) / 2) = Val(GetGadgetText(i))
                y((i - 7) / 2) = (256 - ((sy((i - 7) / 2) + 2) * height((i - 7) / 2))) / 2
                
                Draw9SliceSprite(((i - 7) / 2), sx((i - 7) / 2), sy((i - 7) / 2))
                UpdateCanvas()
              EndIf
            Next
          Case 37
            colorPreset = Val(GetGadgetText(37))
            
            For i = 8 To 16 Step 2
              If GetGadgetState(((i - 6) / 2) + 2) > -1
                sx((i - 6) / 2) = Val(GetGadgetText(i))
                x((i - 6) / 2) = (256 - ((sx((i - 6) / 2) + 2) * width((i - 6) / 2))) / 2
                
                Draw9SliceSprite(((i - 6) / 2), sx((i - 6) / 2), sy((i - 6) / 2))
                UpdateCanvas()
              EndIf
            Next
            
            For i = 9 To 17 Step 2
              If GetGadgetState(((i - 7) / 2) + 2) > -1
                sy((i - 7) / 2) = Val(GetGadgetText(i))
                y((i - 7) / 2) = (256 - ((sy((i - 7) / 2) + 2) * height((i - 7) / 2))) / 2
                
                Draw9SliceSprite(((i - 7) / 2), sx((i - 7) / 2), sy((i - 7) / 2))
                UpdateCanvas()
              EndIf
            Next
        EndSelect
    EndSelect
  ForEver
  
  CloseWindow(0)
Else
  ThrowError("Can't open the default window !")
EndIf

End

; procedures ================================================

; throw an error message
Procedure ThrowError(e.s)
  MessageRequester("Error", e.s, #PB_MessageRequester_Error)
  End
EndProcedure

; update sprites list for the selected panel
Procedure UpdateSpriteLists()
  For i = 3 To 7
    If CountGadgetItems(i) = 0
      If ExamineDirectory(0, d$(i - 2), "*.png")
        While NextDirectoryEntry(0)
          If DirectoryEntryType(0) = #PB_DirectoryEntry_File
            AddGadgetItem(i, -1, DirectoryEntryName(0))
          EndIf
        Wend
        
        FinishDirectory(0)
      EndIf
    EndIf
  Next
EndProcedure

; draw a 9-slice sprite
Procedure Draw9SliceSprite(n.i, w.i, h.i)
  FreeImage(10 + n)
  CreateImage(10 + n, 256, 256, 32, #PB_Image_Transparent)
  
  For i = 21 To 29
    If IsImage(i)
      FreeImage(i)
    EndIf
  Next
  
  GrabImage(n, 21, 0, 0, width(n), height(n))
  GrabImage(n, 22, width(n), 0, width(n), height(n))
  GrabImage(n, 23, 2 * width(n), 0, width(n), height(n))
  GrabImage(n, 24, 0, height(n), width(n), height(n))
  GrabImage(n, 25, width(n), height(n), width(n), height(n))
  GrabImage(n, 26, 2 * width(n), height(n), width(n), height(n))
  GrabImage(n, 27, 0, 2 * height(n), width(n), height(n))
  GrabImage(n, 28, width(n), 2 * height(n), width(n), height(n))
  GrabImage(n, 29, 2 * width(n), 2 * height(n), width(n), height(n))
  
  StartDrawing(ImageOutput(10 + n))
  DrawingMode(#PB_2DDrawing_AlphaBlend)
  
  DrawImage(ImageID(21), x(n), y(n), width(n), height(n))
  
  For x = 1 To w
    DrawImage(ImageID(22), x(n) + (x * width(n)), y(n))
  Next
  
  DrawImage(ImageID(23), x(n) + ((w + 1) * width(n)), y(n))
  
  For y = 1 To h
    DrawImage(ImageID(24), x(n), y(n) + (y * height(n)))
    
    For x = 1 To w
      DrawImage(ImageID(25), x(n) + (x * width(n)), y(n) + (y * height(n)))
    Next
    
    DrawImage(ImageID(26), x(n) + ((w + 1) * width(n)), y(n) + (y * height(n)))
  Next
  
  DrawImage(ImageID(27), x(n), y(n) + ((h + 1) * height(n)))
  
  For x = 1 To w
    DrawImage(ImageID(28), x(n) + (x * width(n)), y(n) + ((h + 1) * height(n)))
  Next
  
  DrawImage(ImageID(29), x(n) + ((w + 1) * width(n)), y(n) + ((h + 1) * height(n)))
  
  ; apply filter  
  If colorPreset > 0
    For y = 0 To 255
      For x = 0 To 255
        DrawingMode(#PB_2DDrawing_AlphaChannel)
        If Alpha(Point(x, y)) > 0
          DrawingMode(#PB_2DDrawing_Default)
          If colorPreset < 4
            col.i = Point(x, y) & color(n)
          Else
            col.i = Point(x, y) | color(n)
          EndIf
          Plot(x, y, col)
        EndIf
      Next
    Next
  EndIf
  
  StopDrawing()
EndProcedure

; update the canvas with all bodyparts
Procedure UpdateCanvas()
  scale = Val(GetGadgetText(19))
  
  For i = 11 To 15
    If ImageWidth(i) <> 256 * scale
      ResizeImage(i, 256 * scale, 256 * scale, #PB_Image_Raw)
    EndIf
  Next
  
  sx = ((scale - 1) * 256) / 2
  sy = ((scale - 1) * 256) / 2
  
  StartDrawing(CanvasOutput(1))
  DrawingMode(#PB_2DDrawing_AllChannels)
  Box(0, 0, 256, 256, RGBA(255, 255, 255, 255))
  DrawingMode(#PB_2DDrawing_AlphaBlend)
  DrawImage(ImageID(11), layerX(1) - sx, layerY(1) - sy)
  DrawImage(ImageID(12), layerX(2) - sx, layerY(2) - sy)
  DrawImage(ImageID(13), layerX(3) - sx, layerY(3) - sy)
  DrawImage(ImageID(14), layerX(4) - sx, layerY(4) - sy)
  DrawImage(ImageID(15), layerX(5) - sx, layerY(5) - sy)
  StopDrawing()  
EndProcedure

; render the sprite and export it
Procedure SaveSpriteAs()
  scale = Val(GetGadgetText(19))
  
  For i = 11 To 15
    If ImageWidth(i) <> 256 * scale
      ResizeImage(i, 256 * scale, 256 * scale, #PB_Image_Raw)
    EndIf
  Next
  
  sx = ((scale - 1) * 256) / 2
  sy = ((scale - 1) * 256) / 2

  sum.i = 0
  
  For i = 3 To 7
    If GetGadgetState(i) = -1
      sum + 1
    EndIf
  Next
  
  If sum = 5
    MessageRequester("Info", "No sprite to save...", #PB_MessageRequester_Info)
    ProcedureReturn
  EndIf
  
  CreateImage(1000, 256, 256, 32, #PB_Image_Transparent)
  
  StartDrawing(ImageOutput(1000))
  DrawingMode(#PB_2DDrawing_AlphaBlend)
  DrawImage(ImageID(11), layerX(1) - sx, layerY(1) - sy)
  DrawImage(ImageID(12), layerX(2) - sx, layerY(2) - sy)
  DrawImage(ImageID(13), layerX(3) - sx, layerY(3) - sy)
  DrawImage(ImageID(14), layerX(4) - sx, layerY(4) - sy)
  DrawImage(ImageID(15), layerX(5) - sx, layerY(5) - sy)
  StopDrawing()
  
  ; crop the sprite
  x1.i = 0
  x2.i = 255
  y1.i = 0
  y2.i = 255
  
  StartDrawing(ImageOutput(1000))
  DrawingMode(#PB_2DDrawing_AllChannels)
  
  ; find top
  For y = 0 To 255
    For x = 0 To 255
      If Alpha(Point(x, y)) > 0
        y1 = y
        
        Break(2)
      EndIf
    Next
  Next
  
  ; find bottom
  For y = 255 To 0 Step -1
    For x = 0 To 255
      If Alpha(Point(x, y)) > 0
        y2 = y
        
        Break(2)
      EndIf
    Next
  Next
  
  ; find left
  For x = 0 To 255
    For y = 0 To 255
      If Alpha(Point(x, y)) > 0
        x1 = x
        
        Break(2)
      EndIf
    Next
  Next
  
  ; find right
  For x = 255 To 0 Step -1
    For y = 0 To 255
      If Alpha(Point(x, y)) > 0
        x2 = x
        
        Break(2)
      EndIf
    Next
  Next
  
  StopDrawing()
  
  w1 = x2 - x1 + 1
  h1 = y2 - y1 + 1
  
  ; grab cropped image
  GrabImage(1000, 2000, x1, y1, w1, h1)
  
  ; save the sprite
  f$ = SaveFileRequester("Save the rendered sprite...", "Sprite.png", "*.png", 0)
  
  If f$ <> ""
    SaveImage(2000, f$, #PB_ImagePlugin_PNG)
  EndIf
  
  FreeImage(2000)
  FreeImage(1000)
  
EndProcedure

; load gadget image
Procedure LoadGadgetImage(i.i)
  LoadImage(i, d$(i) + "\" + GetGadgetItemText(i + 2, GetGadgetState(i + 2)))
  
  width(i) = ImageWidth(i) / 3
  height(i) = ImageHeight(i) / 3
  sx(i) = 1
  sy(i) = 1
  x(i) = (256 - ((sx(i) + 2) * width(i))) / 2
  y(i) = (256 - ((sy(i) + 2) * height(i))) / 2
  
  Draw9SliceSprite(i, sx(i), sy(i))
  UpdateCanvas()
  
  SetGadgetText(((i) * 2) + 6, Str(sx(i)))
  SetGadgetText(((i) * 2) + 7, Str(sy(i)))
EndProcedure
; IDE Options = PureBasic 6.01 LTS (Windows - x64)
; CursorPosition = 51
; FirstLine = 33
; Folding = --
; EnableXP
; DPIAware
; UseIcon = Icons\Icon.ico
; Executable = 9-slice Vehicles Generator.exe