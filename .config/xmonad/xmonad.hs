-- Import stattements
import XMonad
import System.Environment  -- Used to create xmonad environment variables. It will be helpful for prompts
import System.IO (hClose, hPutStr, hPutStrLn) -- Used for xmobar and namedkeymappings
import System.Exit (exitSuccess)  -- Used to quit from xmonad

import qualified Data.Map as M -- to work with list in workspaces
import Data.Maybe (fromJust)  -- Used in workspaces
import Data.Char (isSpace, toUpper) -- Used in namedkeymappings

import XMonad.Util.SpawnOnce  -- Used to launch autostart applications
import XMonad.Util.Run (spawnPipe)  -- Used to launch xmobar

  -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..)) -- Used for xmobar
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks,ToggleStruts(..))

import qualified XMonad.StackSet as W  -- Used to calculate the count of the windows

  -- Keys
import XMonad.Util.EZConfig (additionalKeysP, mkNamedKeymap)
import XMonad.Util.NamedActions
  -- Actions
import XMonad.Actions.CopyWindow (kill1) -- Used in basic xmonad keybinding to handle windows and workspaces
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen) -- Used in basic xmonad keybinding to handle windows and workspaces
import XMonad.Actions.WithAll (sinkAll, killAll) -- Used in basic xmonad keybinding to handle windows and workspaces
import XMonad.Actions.Promote -- Used in basic xmonad keybinding to handle windows and workspaces
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown) -- Used in basic xmonad keybinding to handle windows and workspaces
   -- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Actions.MouseResize
    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
  -- Layout utilities
-- import XMonad.Layout.LayoutModifier
-- import XMonad.Layout.Spacing
-- import XMonad.Layout.SubLayouts
-- import XMonad.Layout.Renamed
-- import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
-- import XMonad.Layout.WindowNavigation
-- import XMonad.Layout.NoBorders
-- import XMonad.Layout.Simplest
-- -- Layouts
-- import XMonad.Layout.Accordion
-- import XMonad.Layout.SimplestFloat
-- import XMonad.Layout.ResizableTile
-- import XMonad.Layout.Tabbed
import Data.Monoid -- For layout hook
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
----------------------------------------------------------------------------------------------------


myTerminal :: String
myTerminal  = "alacritty"

myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth :: Dimension
myBorderWidth   = 2

myBrowser :: String
myBrowser = "brave"

myCustomBrowser :: String
myCustomBrowser = "google-chrome-stable"

myModMask :: KeyMask
myModMask = mod4Mask

myEditor :: String
myEditor = myTerminal ++ " -e nvim"

myWindowsCount :: X (Maybe String)
myWindowsCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset
----------------------------------------------------------------------------------------------------
-- myWorkspaces = [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]
myWorkspaces =
         "<fn=1> \xebca </fn>" :
         "<fn=1> \xfa9e </fn>" :
         "<fn=1> \xe7a3 </fn>" :
         "<fn=1> \xf001 </fn>" :
         "<fn=1> \xf03d </fn>" :
         "<fn=1> \xf823 </fn>" :
         []
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices
----------------------------------------------------------------------------------------------------
--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ limitWindows 5
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 8
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ Full
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ simplestFloat
tallAccordion  = renamed [Replace "tallAccordion"]
           $ Accordion
wideAccordion  = renamed [Replace "wideAccordion"]
           $ Mirror Accordion

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = "#46d9ff"
                 , inactiveColor       = "#202328"
                 , activeBorderColor   = "#46d9ff"
                 , inactiveBorderColor = "#282c34"
                 , activeTextColor     = "#282c34"
                 , inactiveTextColor   = "#dfdfdf"
                 }
-- The layout hook
myLayoutHook = avoidStruts
               $ mouseResize
               $ windowArrange
               $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout = withBorder myBorderWidth tall
                                           ||| noBorders monocle
                                           ||| floats
                                           ||| tallAccordion
                                           ||| wideAccordion
----------------------------------------------------------------------------------------------------
myStartupHook :: X ()
myStartupHook = do
  spawnOnce "bash ~/.scripts/myCustomWallpapers.sh"
  -- spawnOnce "nitrogen --restore &"
  spawnOnce "picom -b"
  spawnOnce "mocp -S"
  -- spawn "killall conky"
  -- spawn ("sleep 2 && conky -c /home/testing/.config/conky/dt.conkyrc")
----------------------------------------------------------------------------------------------------
subtitle' ::  String -> ((KeyMask, KeySym), NamedAction)
subtitle' x = ((0,0), NamedAction $ map toUpper
                      $ sep ++ "\n-- " ++ x ++ " --\n" ++ sep)
  where
    sep = replicate (30 + length x) '-'

showKeybindings :: [((KeyMask, KeySym), NamedAction)] -> NamedAction
showKeybindings x = addName "Show Keybindings" $ io $ do
  h <- spawnPipe $ "yad --text-info --fontname=\"SauceCodePro Nerd Font Mono 12\" --fore=#0f0f0f back=#383834 --center --geometry=1200x800 --title \"XMonad keybindings\""
  --hPutStr h (unlines $ showKm x) -- showKM adds ">>" before subtitles
  hPutStr h (unlines $ showKmSimple x) -- showKmSimple doesn't add ">>" to subtitles
  hClose h
  return ()

-- Custom Keybindings
myKeys :: XConfig l0 -> [((KeyMask, KeySym), NamedAction)]
myKeys c =
  --(subtitle "Custom Keys":) $ mkNamedKeymap c $
  let subKeys str ks = subtitle' str : mkNamedKeymap c ks in
  subKeys "Xmonad Essentials"
  [
      ("M-C-r", addName ": Xmonad recompile" $ spawn "xmonad --recompile"),
      ("M-S-r", addName ": Xmonad restart"   $ spawn "xmonad --restart"),
      ("M-S-q", addName ": Quit Xmonad"      $ io exitSuccess),
      ("M-S-c", addName ": Kill focused window" $ kill1),
      ("M-S-a", addName ": Kill all windows" $ killAll),
      ("M-S-<Return>", addName ": Launch dmenu" $ spawn "dmenu_run -c -l 10")
  ]

  ^++^ subKeys "Switch to workspace"
  [ ("M-1", addName ": Switch to workspace 1"    $ (windows $ W.greedyView $ myWorkspaces !! 0))
  , ("M-2", addName ": Switch to workspace 2"    $ (windows $ W.greedyView $ myWorkspaces !! 1))
  , ("M-3", addName ": Switch to workspace 3"    $ (windows $ W.greedyView $ myWorkspaces !! 2))
  , ("M-4", addName ": Switch to workspace 4"    $ (windows $ W.greedyView $ myWorkspaces !! 3))
  , ("M-5", addName ": Switch to workspace 5"    $ (windows $ W.greedyView $ myWorkspaces !! 4))
  , ("M-6", addName ": Switch to workspace 6"    $ (windows $ W.greedyView $ myWorkspaces !! 5))
  , ("M-7", addName ": Switch to workspace 7"    $ (windows $ W.greedyView $ myWorkspaces !! 6))
  , ("M-8", addName ": Switch to workspace 8"    $ (windows $ W.greedyView $ myWorkspaces !! 7))
  , ("M-9", addName ": Switch to workspace 9"    $ (windows $ W.greedyView $ myWorkspaces !! 8))]

  ^++^ subKeys "Send window to workspace"
  [ ("M-S-1", addName ": Send to workspace 1"    $ (windows $ W.shift $ myWorkspaces !! 0))
  , ("M-S-2", addName ": Send to workspace 2"    $ (windows $ W.shift $ myWorkspaces !! 1))
  , ("M-S-3", addName ": Send to workspace 3"    $ (windows $ W.shift $ myWorkspaces !! 2))
  , ("M-S-4", addName ": Send to workspace 4"    $ (windows $ W.shift $ myWorkspaces !! 3))
  , ("M-S-5", addName ": Send to workspace 5"    $ (windows $ W.shift $ myWorkspaces !! 4))
  , ("M-S-6", addName ": Send to workspace 6"    $ (windows $ W.shift $ myWorkspaces !! 5))
  , ("M-S-7", addName ": Send to workspace 7"    $ (windows $ W.shift $ myWorkspaces !! 6))
  , ("M-S-8", addName ": Send to workspace 8"    $ (windows $ W.shift $ myWorkspaces !! 7))
  , ("M-S-9", addName ": Send to workspace 9"    $ (windows $ W.shift $ myWorkspaces !! 8))]

  ^++^ subKeys "Window navigation"
  [ ("M-j", addName ": Move focus to next window"                $ windows W.focusDown)
  , ("M-k", addName ": Move focus to prev window"                $ windows W.focusUp)
  , ("M-m", addName ": Move focus to master window"              $ windows W.focusMaster)
  , ("M-S-j", addName ": Swap focused window with next window"   $ windows W.swapDown)
  , ("M-S-k", addName ": Swap focused window with prev window"   $ windows W.swapUp)
  , ("M-S-m", addName ": Swap focused window with master window" $ windows W.swapMaster)
  , ("M-<Backspace>", addName ": Move focused window to master"  $ promote)
  , ("M-S-,", addName ": Rotate all windows except master"       $ rotSlavesDown)
  , ("M-S-.", addName ": Rotate all windows current stack"       $ rotAllDown)]

  ^++^ subKeys "Monitors"
  [ ("M-.", addName "Switch focus to next monitor" $ nextScreen)
  , ("M-,", addName "Switch focus to prev monitor" $ prevScreen)]

  -- Switch layouts
  ^++^ subKeys "Switch layouts"
  [ ("M-<Tab>", addName "Switch to next layout"   $ sendMessage NextLayout)
  , ("M-<Space>", addName "Toggle noborders/full" $ sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)]

  -- Window resizing
  ^++^ subKeys "Window resizing"
  [ ("M-h", addName "Shrink window"               $ sendMessage Shrink)
  , ("M-l", addName "Expand window"               $ sendMessage Expand)
  , ("M-M1-j", addName "Shrink window vertically" $ sendMessage MirrorShrink)
  , ("M-M1-k", addName "Expand window vertically" $ sendMessage MirrorExpand)]

  -- Floating windows
  ^++^ subKeys "Floating windows"
  [ ("M-f", addName "Toggle float layout"        $ sendMessage (T.Toggle "floats"))
  , ("M-t", addName "Sink a floating window"     $ withFocused $ windows . W.sink)
  , ("M-S-t", addName "Sink all floated windows" $ sinkAll)]

  -- Increase/decrease spacing (gaps)
  ^++^ subKeys "Window spacing (gaps)"
  [ ("C-M1-j", addName "Decrease window spacing" $ decWindowSpacing 4)
  , ("C-M1-k", addName "Increase window spacing" $ incWindowSpacing 4)
  , ("C-M1-h", addName "Decrease screen spacing" $ decScreenSpacing 4)
  , ("C-M1-l", addName "Increase screen spacing" $ incScreenSpacing 4)]

  -- Increase/decrease windows in the master pane or the stack
  ^++^ subKeys "Increase/decrease windows in master pane or the stack"
  [ ("M-S-<Up>", addName "Increase clients in master pane"   $ sendMessage (IncMasterN 1))
  , ("M-S-<Down>", addName "Decrease clients in master pane" $ sendMessage (IncMasterN (-1)))
  , ("M-=", addName "Increase max # of windows for layout"   $ increaseLimit)
  , ("M--", addName "Decrease max # of windows for layout"   $ decreaseLimit)]

  -- Sublayouts
  -- This is used to push windows to tabbed sublayouts, or pull them out of it.
  ^++^ subKeys "Sublayouts"
  [ ("M-C-h", addName "pullGroup L"           $ sendMessage $ pullGroup L)
  , ("M-C-l", addName "pullGroup R"           $ sendMessage $ pullGroup R)
  , ("M-C-k", addName "pullGroup U"           $ sendMessage $ pullGroup U)
  , ("M-C-j", addName "pullGroup D"           $ sendMessage $ pullGroup D)
  , ("M-C-m", addName "MergeAll"              $ withFocused (sendMessage . MergeAll))
  -- , ("M-C-u", addName "UnMerge"               $ withFocused (sendMessage . UnMerge))
  , ("M-C-/", addName "UnMergeAll"            $  withFocused (sendMessage . UnMergeAll))
  , ("M-C-.", addName "Switch focus next tab" $  onGroup W.focusUp')
  , ("M-C-,", addName "Switch focus prev tab" $  onGroup W.focusDown')]

  ^++^ subKeys "Favourite applications"
  [ ("M-<Return>", addName ": Launch terminal"                   $ spawn (myTerminal))
  , ("M-b"       , addName ": Launch browser"                    $ spawn (myBrowser))
  , ("M-e"       , addName ": Launch editor"                     $ spawn (myEditor))]

  ^++^ subKeys "Multimedia keys"
  [ ("<F3>"    , addName ": Increase 5% volume"                $ spawn ("pamixer -i 5"))
  , ("<F2>"    , addName ": Decrease 5% volume"                $ spawn ("pamixer -d 5"))
  , ("<F4>"    , addName ": Toggle mute/unmute volume"         $ spawn ("pamixer -t"))  ]

  ^++^ subKeys "Custom scripts"
  [ ("M-p c"   , addName ": Edit config files"                 $ spawn ("bash $HOME/.scripts/configfiles.sh"))
  , ("M-p s"   , addName ": Shutdown"                          $ spawn ("bash $HOME/.scripts/power.sh"))]


  -- Controls for mocp music player (SUPER-u followed by a key)
  ^++^ subKeys "Mocp music player"
  [ ("M-u p", addName "mocp play"                $ spawn "mocp --play")
  , ("M-u l", addName "mocp next"                $ spawn "mocp --next")
  , ("M-u h", addName "mocp prev"                $ spawn "mocp --previous")
  , ("M-u <Space>", addName "mocp toggle pause"  $ spawn "mocp --toggle-pause")]
----------------------------------------------------------------------------------------------------
myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
  -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
  -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
  -- I'm doing it this way because otherwise I would have to write out the full
  -- name of my workspaces and the names would be very long if using clickable workspaces.
  [ className =? "confirm"         --> doCenterFloat
  , className =? "file_progress"   --> doFloat
  , className =? "dialog"          --> doCenterFloat
  , className =? "download"        --> doCenterFloat
  , className =? "error"           --> doFloat
  -- , className =? "Gimp"            --> doFloat
  , className =? "notification"    --> doFloat
  , className =? "pinentry-gtk-2"  --> doFloat
  , className =? "splash"          --> doFloat
  , className =? "toolbar"         --> doFloat
  , className =? "Yad"             --> doCenterFloat
  , title =? "Oracle VM VirtualBox Manager"  --> doFloat
  , title =? "Mozilla Firefox"     --> doShift ( myWorkspaces !! 1 )
  -- , title =? "MOC"     --> doShift ( myWorkspaces !! 3)
  , className =? "Brave-browser"   --> doShift ( myWorkspaces !! 1 )
  , className =? "mpv"             --> doShift ( myWorkspaces !! 4 )
  , className =? "Gimp"            --> doShift ( myWorkspaces !! 5 )
  , className =? "VirtualBox Manager" --> doShift  ( myWorkspaces !! 4 )
  , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
  , isFullscreen -->  doFullFloat
  ]
----------------------------------------------------------------------------------------------------
main :: IO ()
main =  do
	xmproc <- spawnPipe "xmobar -d"
	xmonad $ addDescrKeys' ((mod4Mask, xK_F1), showKeybindings) myKeys $  docks $ def{
		      -- simple stuff
		terminal           = myTerminal,
		focusFollowsMouse  = myFocusFollowsMouse,
		clickJustFocuses   = myClickJustFocuses,
		borderWidth        = myBorderWidth,
		modMask            = myModMask,
		workspaces         = myWorkspaces,
		      -- hooks, layouts
		manageHook         = myManageHook <+> manageDocks,
		startupHook        = myStartupHook,
		layoutHook         = myLayoutHook,
		logHook            = dynamicLogWithPP $ xmobarPP
					{
						ppOutput = hPutStrLn xmproc
						, ppCurrent = xmobarColor "#c678dd" "" . wrap
							      ("<box type=Bottom width=2 mb=2 color=" ++ "#c678dd" ++ ">") "</box>"
						  -- Visible but not current workspace
						, ppVisible = xmobarColor "#c678dd" "" . clickable
						  -- Hidden workspace
						, ppHidden = xmobarColor "#51afef" "" . wrap
							     ("<box type=Top width=2 mt=2 color=" ++ "#51afef" ++ ">") "</box>" . clickable
						  -- Hidden workspaces (no windows)
						, ppHiddenNoWindows = xmobarColor "#51afef" ""  . clickable
						  -- Title of active window
						, ppTitle = xmobarColor "#dfdfdf" "" . shorten 20
						  -- Separator character
						, ppSep =  "<fc=" ++ "#5b6268" ++ "> <fn=1>|</fn> </fc>"
						  -- Urgent workspace
						, ppUrgent = xmobarColor "#ff6c6b" "" . wrap "!" "!"
						  -- Adding # of windows on current workspace to the bar
						, ppExtras  = [myWindowsCount]
						  -- order of things in xmobar
						, ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
					}
	}
