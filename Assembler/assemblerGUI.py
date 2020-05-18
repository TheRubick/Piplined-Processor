from tkinter import *
from assembler3 import *
def printText():
     
    test = textBody.get("1.0", "end-1c") 
    print(test)
    errorFlag,errorString = readLineByLine(test)
    
   
    if(not(errorFlag)):
        consoleWindow.configure(text="compiled successfully with zero errors",fg="green")
    else:
        consoleWindow.configure(text=errorString,fg="red")
def openDialogBox():
    from tkinter import filedialog
   
    root.fileName = filedialog.askopenfilename(filetypes=(("File instruction", ".txt"), ("All files","*.*")))

    print(root.fileName)
    root.title("Instruction file = "+root.fileName)
    text1 = open(root.fileName).read()
    print(text1)
    textBody.delete("1.0",END)
    textBody.insert(END,text1)
        
root = Tk()
root.title('assembler')
topFrame = Frame(root)
topFrame.pack(side=TOP)
b = Button(topFrame,text="open text file",command=openDialogBox,font="Arial")
b.pack(side=LEFT)
b2 = Button(topFrame,text="generate memory file",command=printText,font="Arial")
b2.pack(side=RIGHT)
sb = Scrollbar(root)
sb.pack(side=RIGHT,fill=Y)
textBody = Text(root,font="Arial",yscrollcommand=sb.set)
textBody.pack(fill=BOTH)

consoleWindow = Label(root,text="machine instructions would be generated in instructionMemory.mem and dataMemory.mem in the same directory/folder",fg="black",font="Arial")
consoleWindow.pack(side=LEFT)
root.mainloop()