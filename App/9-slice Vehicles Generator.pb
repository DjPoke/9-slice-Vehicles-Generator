;===========================
; 9-slice Vehicles Generator
;
; by DjPoke (c) 2023
;===========================

; constants
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  #SLASH = "\"
CompilerElse
  #SLASH = "/"
CompilerEndIf

#render = 10
#finalRender = 1000
#croppedRender = 2000
#ImgBtn = 3000

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
Declare UpdateLayers()

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

Global dir$ = GetCurrentDirectory()

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
  
  ; create color images for image buttons
  For i = 1 To 5
    color(i) = RGB(255, 255, 255)
    CreateImage(i + #ImgBtn, 25, 25, 32, color(i))
  Next
  
  ; canvas
  CanvasGadget(1, 10, 10, 256, 256)
  
  ; edit bodyparts gadgets
  PanelGadget(2, 276, 10, 514, 256)
  ; =======================================================
  AddGadgetItem(2, -1, d$(1))
  ; =======================================================
  ComboBoxGadget(3, 10, 10, 200, 25)
  TextGadget(20, 15, 45, 40, 25, "Scale:")
  TextGadget(43, 15, 85, 40, 25, "YMove:")
  SpinGadget(8, 70, 40, 60, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(9, 130, 40, 60, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(38, 70, 80, 60, 25, -8, 8, #PB_Spin_Numeric)
  TextGadget(31, 210, 45, 35, 25, "Filter:")
  ButtonImageGadget(26, 260, 40, 25, 25, ImageID(3001))
  ; =======================================================
  AddGadgetItem(2, -1, d$(2))
  ; =======================================================
  ComboBoxGadget(4, 10, 10, 200, 25)
  TextGadget(21, 15, 45, 40, 25, "Scale:")
  TextGadget(44, 15, 85, 40, 25, "YMove:")
  SpinGadget(10, 70, 40, 60, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(11, 130, 40, 60, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(39, 70, 80, 60, 25, -8, 8, #PB_Spin_Numeric)
  TextGadget(32, 210, 45, 35, 25, "Filter:")
  ButtonImageGadget(27, 260, 40, 25, 25, ImageID(3002))
  ; =======================================================
  AddGadgetItem(2, -1, d$(3))
  ; =======================================================
  ComboBoxGadget(5, 10, 10, 200, 25)
  TextGadget(22, 15, 45, 40, 25, "Scale:")
  TextGadget(45, 15, 85, 40, 25, "YMove:")
  SpinGadget(12, 70, 40, 60, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(13, 130, 40, 60, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(40, 70, 80, 60, 25, -8, 8, #PB_Spin_Numeric)
  TextGadget(33, 210, 45, 35, 25, "Filter:")
  ButtonImageGadget(28, 260, 40, 25, 25, ImageID(3003))
  ; =======================================================
  AddGadgetItem(2, -1, d$(4))
  ; =======================================================
  ComboBoxGadget(6, 10, 10, 200, 25)
  TextGadget(23, 15, 45, 40, 25, "Scale:")
  TextGadget(46, 15, 85, 40, 25, "YMove:")
  SpinGadget(14, 70, 40, 60, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(15, 130, 40, 60, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(41, 70, 80, 60, 25, -8, 8, #PB_Spin_Numeric)
  TextGadget(34, 210, 45, 35, 25, "Filter:")
  ButtonImageGadget(29, 260, 40, 25, 25, ImageID(3004))
  ; =======================================================
  AddGadgetItem(2, -1, d$(5))
  ; =======================================================
  ComboBoxGadget(7, 10, 10, 200, 25)
  TextGadget(24, 15, 45, 40, 25, "Scale:")
  TextGadget(47, 15, 85, 40, 25, "YMove:")
  SpinGadget(16, 70, 40, 60, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(17, 130, 40, 60, 25, 0, 7, #PB_Spin_Numeric)
  SpinGadget(42, 70, 80, 60, 25, -8, 8, #PB_Spin_Numeric)
  TextGadget(35, 210, 45, 35, 25, "Filter:")
  ButtonImageGadget(30, 260, 40, 25, 25, ImageID(3005))
  ; =======================================================
  CloseGadgetList()
  
  TextGadget(18, 10, 285, 70, 25, "Full Scale:")
  SpinGadget(19, 80, 280, 60, 25, 1, 2, #PB_Spin_Numeric)
  
  ButtonGadget(25, 500, 270, 70, 40, "Lucky ?")
  
  TextGadget(36, 150, 285, 90, 25, "Color Preset:")
  SpinGadget(37, 240, 280, 60, 25, 0, 6, #PB_Spin_Numeric)

  ; set spin gadget texts to default value
  SetGadgetText(19, "1")
  SetGadgetText(37, "0")
  SetGadgetText(38, "0")
  SetGadgetText(39, "0")
  SetGadgetText(40, "0")
  SetGadgetText(41, "0")
  SetGadgetText(42, "0")
  
  ; create render images
  For i = 1 To 5
    CreateImage(i + #render, 256, 256, 32, #PB_Image_Transparent)
  Next
  
  ; update 9-slice sprites in all lists
  UpdateSpriteLists()
 
  ; select cockpit first
  SetGadgetState(2, 0)
  
  ; clear events queue
  While WindowEvent()
  Wend

  ; events loop
  Repeat
    ev = WaitWindowEvent()

    Select ev
      Case #PB_Event_Menu
        em = EventMenu()
        
        Select em
          Case 1
            ; replace render images by new ones
            For i = 1 To 5
              FreeImage(i + #render)
              CreateImage(i + #render, 256, 256, 32, #PB_Image_Transparent)
            Next
            
            ; clear the canvas
            StartDrawing(CanvasOutput(1))
            DrawingMode(#PB_2DDrawing_Default)
            Box(0, 0, 256, 256, RGB(255, 255, 255))
            StopDrawing()
            
            ; clear combobox
            For i = 3 To 7
              SetGadgetState(i, 0)
            Next
            
            ; clear values
            For i = 8 To 17
              SetGadgetText(i, "")
            Next
            
            ; reset Y move values
            For i = 38 To 42
              SetGadgetText(i, "0")
            Next            
            
            ; reset color filters
            For i = 1 To 5
              FreeImage(i + #ImgBtn)
              color(i) = RGB(255, 255, 255)
              CreateImage(i + #ImgBtn, 25, 25, 32, color(i))
              SetGadgetAttribute(i + 25, #PB_Button_Image, ImageID(i + #ImgBtn))
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
              ; change the current limb sprite
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
                  
                  StartDrawing(ImageOutput(i + #ImgBtn))
                  DrawingMode(#PB_2DDrawing_Default)
                  Box(0, 0, 25, 25, color(i))
                  StopDrawing()
                  
                  SetGadgetAttribute(i + 25, #PB_Button_Image, ImageID(i + #ImgBtn))
                Next
              Case 2, 5
                For i = 1 To 5
                  color(i) = RGB(Random(255, 192), Random(255, 192), Random(255, 192))
                  
                  StartDrawing(ImageOutput(i + #ImgBtn))
                  DrawingMode(#PB_2DDrawing_Default)
                  Box(0, 0, 25, 25, color(i))
                  StopDrawing()
                  
                  SetGadgetAttribute(i + 25, #PB_Button_Image, ImageID(i + #ImgBtn))
                Next
              Case 3, 6
                For i = 1 To 5
                  color(i) = RGB(Random(255, 64), Random(255, 64), Random(255, 64))
                  
                  StartDrawing(ImageOutput(i + #ImgBtn))
                  DrawingMode(#PB_2DDrawing_Default)
                  Box(0, 0, 25, 25, color(i))
                  StopDrawing()
                  
                  SetGadgetAttribute(i + 25, #PB_Button_Image, ImageID(i + #ImgBtn))
                Next
            EndSelect
            
            ; random sizes
            For i = 8 To 16 Step 2
              If GetGadgetState(((i - 6) / 2) + 2) > -1
                SetGadgetText(i, Str(Random(7, 0)))
              EndIf
            Next
            
            For i = 9 To 17 Step 2
              If GetGadgetState(((i - 7) / 2) + 2) > -1
                SetGadgetText(i, Str(Random(7, 0)))
              EndIf
            Next            
                                    
            ; reset Y move values
            For i = 38 To 42
              SetGadgetText(i, "0")
            Next            

            ; update each layer
            UpdateLayers()
          Case 26, 27, 28, 29, 30
            ; get the new color
            color(eg - 25) = ColorRequester()
            
            ; replace it images on the pressed button
            StartDrawing(ImageOutput(eg - 25 + #ImgBtn))
            DrawingMode(#PB_2DDrawing_Default)
            Box(0, 0, 25, 25, color(eg - 25))
            StopDrawing()
            
            SetGadgetAttribute(eg, #PB_Button_Image, ImageID(eg - 25 + #ImgBtn))
            
            ; update each layer
            UpdateLayers()
          Case 37
            ; get color preset value in its variable
            colorPreset = Val(GetGadgetText(37))
            
            ; update each layer
            UpdateLayers()
          Case 38, 39, 40, 41, 42
            ; update each layer
            UpdateLayers()
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
      AddGadgetItem(i, -1, "Not selected yet")
      
      If ExamineDirectory(0, d$(i - 2), "*.png")
        While NextDirectoryEntry(0)
          If DirectoryEntryType(0) = #PB_DirectoryEntry_File
            AddGadgetItem(i, -1, DirectoryEntryName(0))
          EndIf
        Wend
        
        FinishDirectory(0)
      EndIf
    EndIf
    
    SetGadgetState(i, 0)
  Next
EndProcedure

; draw a 9-slice sprite
Procedure Draw9SliceSprite(n.i, w.i, h.i)
  FreeImage(#render + n)
  CreateImage(#render + n, 256, 256, 32, #PB_Image_Transparent)
  
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
  
  StartDrawing(ImageOutput(#render + n))
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
    ; scan all the area of pixels
    For y = 0 To 255
      For x = 0 To 255
        DrawingMode(#PB_2DDrawing_AlphaChannel)
        
        ; if the pixel is not transparent...
        If Alpha(Point(x, y)) > 0
          DrawingMode(#PB_2DDrawing_Default)
          
          ; apply filter
          If colorPreset < 4
            col.i = Point(x, y) & color(n)
          Else
            col.i = Point(x, y) | color(n)
          EndIf
          
          ; replace it
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
  
  For i = #render + 1 To #render + 5
    If ImageWidth(i) <> 256 * scale
      ResizeImage(i, 256 * scale, 256 * scale, #PB_Image_Raw)
    EndIf
  Next
  
  ; apply scale offset
  sx = ((scale - 1) * 256) / 2
  sy = ((scale - 1) * 256) / 2
  
  StartDrawing(CanvasOutput(1))
  DrawingMode(#PB_2DDrawing_AllChannels)
  Box(0, 0, 256, 256, RGBA(255, 255, 255, 255))
  DrawingMode(#PB_2DDrawing_AlphaBlend)
  DrawImage(ImageID(11), layerX(1) - sx, layerY(1) - sy - (height(1) * scale * Val(GetGadgetText(38))))
  DrawImage(ImageID(12), layerX(2) - sx, layerY(2) - sy - (height(2) * scale * Val(GetGadgetText(39))))
  DrawImage(ImageID(13), layerX(3) - sx, layerY(3) - sy - (height(3) * scale * Val(GetGadgetText(40))))
  DrawImage(ImageID(14), layerX(4) - sx, layerY(4) - sy - (height(4) * scale * Val(GetGadgetText(41))))
  DrawImage(ImageID(15), layerX(5) - sx, layerY(5) - sy - (height(5) * scale * Val(GetGadgetText(42))))
  StopDrawing()  
EndProcedure

; render the sprite and export it
Procedure SaveSpriteAs()
  scale = Val(GetGadgetText(19))
  
  For i = #render + 1 To #render + 5
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
  
  CreateImage(#finalRender, 256, 256, 32, #PB_Image_Transparent)
  
  StartDrawing(ImageOutput(#finalRender))
  DrawingMode(#PB_2DDrawing_AlphaBlend)
  DrawImage(ImageID(11), layerX(1) - sx, layerY(1) - sy - (height(1) * scale * Val(GetGadgetText(38))))
  DrawImage(ImageID(12), layerX(2) - sx, layerY(2) - sy - (height(2) * scale * Val(GetGadgetText(39))))
  DrawImage(ImageID(13), layerX(3) - sx, layerY(3) - sy - (height(3) * scale * Val(GetGadgetText(40))))
  DrawImage(ImageID(14), layerX(4) - sx, layerY(4) - sy - (height(4) * scale * Val(GetGadgetText(41))))
  DrawImage(ImageID(15), layerX(5) - sx, layerY(5) - sy - (height(5) * scale * Val(GetGadgetText(42))))
  StopDrawing()
  
  ; crop the sprite
  x1.i = 0
  x2.i = 255
  y1.i = 0
  y2.i = 255
  
  StartDrawing(ImageOutput(#finalRender))
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
  GrabImage(#finalRender, #croppedRender, x1, y1, w1, h1)
  
  ; save the sprite
  f$ = SaveFileRequester("Save the rendered sprite...", "Sprite.png", "*.png", 0)
  
  If f$ <> ""
    SaveImage(#croppedRender, f$, #PB_ImagePlugin_PNG)
  EndIf
  
  FreeImage(#croppedRender)
  FreeImage(#finalRender)
  
EndProcedure

; load gadget image
Procedure LoadGadgetImage(i.i)
  If GetGadgetState(i + 2) > 0
    LoadImage(i, dir$ + d$(i) + #SLASH + GetGadgetItemText(i + 2, GetGadgetState(i + 2)))
  ElseIf GetGadgetState(i + 2) = 0
    CreateImage(i, 8, 8, 32, #PB_Image_Transparent)
  EndIf
  
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

; update all layers
Procedure UpdateLayers()
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
EndProcedure
; IDE Options = PureBasic 6.01 LTS (Windows - x64)
; CursorPosition = 140
; FirstLine = 127
; Folding = --
; EnableXP
; DPIAware
; UseIcon = Icons\Icon.ico
; Executable = 9-slice Vehicles Generator.exe