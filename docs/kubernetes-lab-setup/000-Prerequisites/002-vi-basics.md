# VI editor basics

VI is a terminal editor tool, there are many other editors but is available on both Alpine and Ubuntu . And most importantly I am used to VI. 

If you are a beginner, there are some basic commands you will need to know. 



| Action              | command                                               | notes                                                        |
| ------------------- | ----------------------------------------------------- | ------------------------------------------------------------ |
| Create/ Edit file   | vi filename.txt                                       | run this from the same folder the file is located. If its in a different folder, use the relevant path to the file |
| insert mode         | `i`                                                   | When you open a file with VI, you cannot edit the file. To edit enter `i` to insert in command mode. You now can type to make changes. |
| save and exit       | `esc` :x                                              | Once edits are complete, press `esc` to enter the command mode. The `:x` to save and exit |
| exit without saving | `esc`  `:q!`                                          | To not save the file, press `esc` to enter the command mode. The `:q!` to exit |
| Copy selection      | left mouse click to copy , right mouse click to paste | Left click and drag selection, right click to paste          |

There are many more that you can use, but with these basics you should be able to perform the tasks required in this Lab setup guide.