Config {
	position = TopSize C 100 30,
	alpha = 200,
	border = NoBorder,
	-- bgColor = "#282c34",
	fgColor      = "#ff6c6b",
	font = "xft:Hack Nerd Font:weight=bold:size=9:hinting=true:antialias=true",
	additionalFonts=["xft:Hack Nerd Font:weight=bold:size=14:hinting=true:antialias=true"]
	commands = [
		Run UnsafeStdinReader,
		Run Com "bash" ["/home/testing/.scripts/date.sh"] "date" 10,
		Run Com "echo" ["<fn=2> \xf011 </fn>"] "power" 3600, -- Power icon
		Run Com "echo" ["<fn=2> \xf001 </fn>"] "music" 3600, --  music icon
		-- Run Date "%a %b %d %Y - (%H:%M)" "date" 10,
		Run Memory ["-t", "<fn=2>\xf233 </fn><used>M (<usedratio>%)"] 20,
		Run Com "bash" ["/home/testing/.scripts/pac.sh"] "pacupdate" 10 ,
		Run Com "bash" ["/home/testing/.scripts/volume.sh"] "volume" 10 ,
		Run Com "echo" ["<fn=2> \xf0f3 </fn>"] "bell" 3600 , -- Bell icon
		Run Com "echo" ["<fn=2> \xeab0 </fn>"] "cal" 3600, -- Calendar icon
		Run Com "echo" ["<fn=1> \xfa80 </fn>"] "volumeMute" 3600, -- volume Mute
		Run Com "echo" ["<fn=1> \xfc5b </fn>"] "volumeIncrease" 3600, -- volume Increase
		Run Com "echo" ["<fn=1> \xfc5c </fn>"] "volumeDecrease" 3600 -- volume Decrease
		],
	sepChar = "%",
	alignSep = "}{",
--	iconRoot = "/home/testing/.config/xmobar/haskell.xpm",
	template = "<icon=/home/testing/.config/xmobar/haskell.xpm/>  %UnsafeStdinReader%}{ <box type=Bottom width=2 mb=2 color=#ecbe7b><fc=#ecbe7b><action=`alacritty -e htop`>%memory%</action></fc></box> <fc=#000000>|</fc>  <box type=Bottom width=2 mb=2 color=#51afef><action=`alacritty -e sudo pacman -Syyu`><fc=#51afef>%pacupdate%</fc> </action></box> <fc=#000000>|</fc> <box type=Bottom width=2 mb=2 color=#ff6c6b><fc=#ff6c6b><action=`pamixer -i 5`>%volumeIncrease%</action><action=`pamixer -d 5`>%volumeDecrease%</action><action=`pamixer -t`>%volumeMute%</action>%volume%</fc></box> <fc=#000000>|</fc> <box type=Bottom widht=2 mb=2 color=#c678dd><fc=#c678dd>%date%</fc></box> <fc=#000000>|</fc> <box type=Bottom width =2 mb=2 color=#d67c76><action=`alacritty -e mocp`><fc=#d67c76>%music%</fc></action></box> <fc=#000000>|</fc> <box type=Bottom width=2 mb=2 color=#e3091b><action=`bash /home/testing/.scripts/power.sh`><fc=#e3091b>%power%</fc></action></box>"
	}
