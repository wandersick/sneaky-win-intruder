
Instructions for Sneaky Win Intruder (Swi) Type 1

Last update: 11/9/2008, revision 0.9a

Purpose: 

To get into a password-protected Windows using the sethc.exe trick, thru the administrative command prompt shown at logon to create a new temp account and refresh the screen. after having finished working with the PC, restore the modifications e.g. temp user account UAC setting, last logon user history, user profile, etc.

---------------------------------------

Before running, make sure all required executables exist (see 'Required exe...' section)

If you're clueless, please run in this order:

  [Part 1] -- Swap sethc.exe

With an external Windows source (i.e. not currently logged on) or under Windows PE, run "Swi.bat", enter "Search" or "S" to locate target Windows

Note: For Vista or later, in the middle of the way it may ask you to disable UAC if it detected UAC is on, please enter "y" to turn it off. It will be enabled during restoration later.

  [Part 2] -- Create temporary user

Boot to target Windows, at logon screen, hit SHIFT 5 times, enter "adduser" (if it does not work, try "adduser1") in the Command Prompt that's just popped up. It may ask you to refresh screen, enter "y" if you don't see an updated Welcome screen. enter 'n' if you use a logon box.

  [Part 3] -- Delete account, remove traces

After working with the PC, to restore the changes and remove the traces, open a Command Prompt (cmd.exe), enter "clean". Do not open Command Prompt by hitting SHIFT 5 times or else restoration may fail.

Your part is done. The last part of removal is ALMOST complete. So far, temp account deleted, sethc.exe restored, last logon user (only if AutoAdminLogon is off) erased.

The rest will carry on in the background at the next logon of the user (not you). If the user is not administrator it will fail as it uses RunOnce.

By then, UAC will be re-enabled (only if it was initially on), user profile folder and the rest of files that was left over will be deleted.

Even if it fails, the traces that it left are not noticeable by a normal user. If you want you can remove manually the files in "clean_next_boot.bat".

---------------------------------------

Required executables for download

Before running, please ensure some of the following executables must be present either in system path (e.g. Windows\system32 folder) or in Swi folder.

attrib - XP/2003 built-in*
cacls - XP/2003 built-in*
sc - XP/2003 built-in*
reg - XP/2003 built-in*
taskkill - XP Pro/2003 built-in* (alternatively, use wkill and pskill)
  ALT: pskill - http://technet.microsoft.com/en-us/sysinternals/bb896683.aspx
  ALT: wkill - http://alter.org.ua/en/
takeown - Server 2003 built-in (alternatively, use subinacl)
  ALT: subinacl - http://www.microsoft.com/downloads/details.aspx?FamilyID=E8BA3E56-D8FE-4A91-93CF-ED6985E3927B&displaylang=en
startx -  http://www.naughter.com/startx.html
srvany - Windows 2003 Resource Kit - http://www.microsoft.com/Downloads/details.aspx?FamilyID=9d467a69-57ff-4ae7-96ee-b18c4790cffd&displaylang=en

*Note while Vista and 7 also have these, they cannot run on older OS. So better use XP version.

---------------------------------------

Known bugs:

- After applying SWI on Windows 7, the Command Prompt shown by hitting SHIFT 5 times cannot show some messages properly, however script runs fine.
- In Windows 7, sometimes after restoration user profile is not fully deleted, leaving only empty Music, Pictures, Documents folder. But other leftovers are deleted.
- Fails if "Sticky Keys" is disabled, in that case, use Swi type 2 instead (which is not yet finished at this moment).

So far it has been confirmed working offline on Windows XP, 2003, Vista, 7, both Chinese and English, using Windows PE 1.x (NoName XPE, Hiren's BootCD), PE2.0 (VistaPE), PE3.0 (C7PE), XP, 7 as base system.

---------------------------------------

For details, refer to the blog post at https://wandersick.blogspot.com/2009/09/windows-sneaky-win-intruder.html (available in English translation)

Please report any bugs to wandersick@gmail.com, or reply to the blog post
