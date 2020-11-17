# Killer Artists
Final project for FINE 1003. Definitely not an Among Us clone with drawing mechanics shoehorned in.
## How to Upload Assets (or anything) to the Project (The Quick and Easy Way)
  * First, you're gonna need to make sure you've installed Git (you could also use Atom, but Git coincides with the HARDCORE WAY of making changes): https://git-scm.com/downloads
### You downloaded it? No issues? Great. Now follow these steps:
  1. Now, you could clone the repository from the command line, but just download the ZIP - it's easier.
  2. Open up the Git GUI app that should've came with the Git installation.
  3. Select the ```Open Existing Repository``` option and browse for the unzipped repository folder.
  4. Drag and drop (or remove) whatever files you want into the project directory (artstuff goes into the ```assets``` folder) and then click the ```Rescan``` button on the GUI app to detect said changes.
  5. You'll want to "stage" any changes that you want to commit, so you can either select a single change and then press either ```Ctrl-T``` or go to ```Commit -> Stage To Commit```. You can also unstage changes by either pressing ```Ctrl-U``` while they're selected or ```Commit -> Unstage From Commit```.
  6. Once you're pleased with your staged changes, type a commit message in the textbox describing the changes in the commit, then click on the ```Push``` button and voila! You've pushed a commit to the repository.
## The Hardcore Way
### More Dependencies
 * On top of Git, you'll also need the VC 2019 C++ Runtime Distributable: https://support.microsoft.com/en-gb/help/2977003/the-latest-supported-visual-c-downloads
### We're Going In (The Engine)
 1. Download the repository, either through ZIP download or cloning via Git or Atom.
 2. Launch the Godot executable located in ```bin/Godot_v3.2.3-stable_win64.exe```
 3. Import the project into Godot by locating the ```project.godot``` directory through Godot's ```Import``` feature.
 4. Open up the project, and start the Git plugin by clicking ```Project -> Version Control -> Set Up Version Control -> Initialize``` (You'll have to do this every time you start Godot).
 5. There will now be a ```Commit``` tab on Godot's righthand menu, where you can stage changes and push commits with messages.
### Okay, I pressed commit, but nothing happened. What gives?
 6. Navigate to the project directory with your command line. On Windows, you use the ```cd (insert directory name here)``` command to navigate in and out of folders.
 7. Once your command line is inside the project directory (where the .git file is located) type in ```git push```. Your commit made inside Godot will officially be pushed to the repository, and yer done.
