# customlog
very customizable roblox logs with presets and extendable functionality for script developers<br>

 ✔ **Supports Custom Logs (Creating New Methods)**<br>
 ✔ **Supports Roblox/Luau (Scripts And Executor)**<br>
 ✔ **Comes With Presets (Shown Below)**<br>

## preview
![image](https://github.com/user-attachments/assets/7c742397-c8cc-46c4-9d0e-fddc5bf77431)

## usage
```lua
local make = loadstring(game:HttpGet("https://github.com/transmutational/customlog/blob/main/src.lua?raw=true"))()

local endorsed = make("rbxasset://textures/StudioToolbox/EndorsedBadge.png", Color3.fromRGB(249, 209, 115))
endorsed("This asset was verified and published by Roblox.")

folder("Saved config! 5.16 KiB written to workspace (or anything else but).")
check("Successfully loaded <insert generic script hub name here> in 532 ms!")
roblox("Admin BitDancer joined the game.")
badge("Obtained the \"I Can't Sleep\" badge!")
star("Fly me to the moon, let me play among the stars~")
```

see [customlog/src.lua](./src.lua) implementation for more examples on creating presets
