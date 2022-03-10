Terminate iCue v1.1
=======================================
A hack for 2021 Lenovo Legion laptops to maintain iCue RGB profiles between reboots

What it solves
---------------------------------------
On Legion 7 laptops, iCue will reset the built-in lighting manager when it exits.

This results in your custom RGB profile being replaced by a "rainbow" swirl during reboots.

https://forums.lenovo.com/t5/Gaming-Laptops/Stop-the-RIDICULOUS-Spiral-Rainbow-Keyboard-backlight-effect-Let-us-turn-it-off/m-p/4552233?page=12

https://www.reddit.com/r/Lenovo/comments/oqsvdu/disable_spinning_rainbow_keyboard/

https://www.reddit.com/r/LenovoLegion/comments/ncuh0k/icue_v_411274_no_more_rainbow_swirl_at_boot/

https://forums.lenovo.com/t5/Gaming-Laptops/Legion-7i-Rainbow-Spiral/m-p/5073453

By force terminating the iCue process, your custom RGB profile persists between reboots:

https://www.reddit.com/r/LenovoLegion/comments/p5b8e2/possible_solution_to_removing_the_rainbow_swirl/

Why this workaround works
---------------------------------------
There is a plugin in iCue which allows iCue to control the Laptop's RGB. When the plugin exits, it is resetting the lighting effects back to defaults on some sort of "close" or "exit" event. (you can test this by disabling plugins under iCue settings). This would occur whenever the iCue app is cleanly exited, such as via the system tray icon or shutdown. By abruptly terminating the iCue process, this prevents the plugin to perform it's "close" routine, resulting in any user-defined lighting effects not being removed.

How Terminate iCue works
---------------------------------------
- At startup, terminate-icue.bat is launched.
- The bat file periodically checks if iCue is running.
- If detected, the iCue process and it's child processes are terminated with `taskkill /f /t /im icue.exe`. 
- If iCue is not detected after one minute, we assume iCue is not being run at startup and the .bat file exits.

Setup
---------------------------------------
- Download a release from https://github.com/ldstein/terminate-icue/releases and unzip to your drive.
- Double click "setup.bat".
- When asked "Do you want to allow this app to make changes to your device", click "Yes".
- Select option 1 to run Terminate iCue at login.
- Optionally, select 2 to terminate the iCue Plugin host. 
- Wait for setup to complete.
- Optional: Select option 4 to disable Corsair background services to improve battery life.
- Select option 6 to exit.

Removal
---------------------------------------
- Double click "setup.bat"
- Click "Yes" when prompted "Do you want to allow this app to make changes to your device"
- Select option 3 to stop running Terminate iCue at login.
- Optional: Select option 5 to re-enable Corsair background services.
- Select option 6 to exit

FAQ
------------------------

**Why does setup require admin privileges?**

Admin rights are required to add and remove tasks to Windows Task Scheduler and manage Windows background services.

**Why not just copy terminate-icue.bat to the startup folder?**

You can, but this will cause the command prompt to briefly flash up at login. Running the .bat file as a task resolves this behaviour.

TROUBLESHOOTING
------------------------

**It isn\'t working**

Check you have downloaded a release from https://github.com/ldstein/terminate-icue/releases. If you downloaded a Zip of the repo, the bat file will not work due to Unix-style line breaks.

CREDITS
------------------------
rickje139 for his work which lead to Terminate iCue:
https://www.reddit.com/r/LenovoLegion/comments/p5b8e2/comment/hyqis0u
https://www.reddit.com/r/GamingLaptops/comments/n40jxx/i_have_found_a_way_to_disable_the_rgb_on_startup/

felipe31soares for identifying working out how to terminate newer versions of iCue:
https://www.reddit.com/r/LenovoLegion/comments/p5b8e2/comment/hswdixw

goodsignal for identifying unplugging the AC adaptor reset the RGB:
https://www.reddit.com/r/LenovoLegion/comments/p5b8e2/comment/htrrou1

HISTORY
------------------------
v1.1
- Ported to Powershell
- Smarter calculation of delay before terminating
- Add option to terminate iCue plugin host
- Fixed bug where task was not run when on battery

v1.0
- Initial release