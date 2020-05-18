import re
import sys


#Return a list containing every occurrence of "ai":
def calReg(instruction,oneTwoThreeOp,instructionFunction,errorFlag):
    
    regField = list("000000000")
    Reg = re.findall("[R-r][0-7]", instruction)
    #print(Reg)
    isImmediate = not(len(Reg) == len(oneTwoThreeOp)+1 or instructionFunction == "010100")
    #if the instruction is one operand but isn't NOP
    isOneInstruction = (instructionFunction != "000000" and instructionFunction[1:3] == "00")
    #if the instruction is LDD/STD
    isEA = (instructionFunction == "1101011" or instructionFunction == "1101110")
    regCount = len(Reg)
    if(instructionFunction == "0010100"):
        regCount += 1
        Reg.append(Reg[0])
    #print(instructionFunction)
    #if it is swap
    print(Reg)
    for i in range(regCount):
        print(Reg[i])
        print(len(Reg[i]))
        if(len(Reg[i]) > 2):
            errorFlag = True
        elif(Reg[i][1] == "0"):
            regField[3*i:3*(i+1)] = "000"
        elif(Reg[i][1] == "1"):
            regField[3*i:3*(i+1)] = "001"
        elif(Reg[i][1] == "2"):
            regField[3*i:3*(i+1)] = "010"
        elif(Reg[i][1] == "3"):
            regField[3*i:3*(i+1)] = "011"
        elif(Reg[i][1] == "4"):
            regField[3*i:3*(i+1)] = "100"
        elif(Reg[i][1] == "5"):
            regField[3*i:3*(i+1)] = "101"
        elif(Reg[i][1] == "6"):
            regField[3*i:3*(i+1)] = "110"
        elif(Reg[i][1] == "7"):
            regField[3*i:3*(i+1)] = "111"
        else:
            errorFlag = True
            return "","","",errorFlag

    #if it is one instruction but not NOP
    if(isOneInstruction):
        regField[6:9] = regField[0:3]
        #if the instruction is out
        if(instructionFunction == "0000011"):
            regField[6:9] = "000"
        #if the instruction is in
        elif(instructionFunction == "0001101"):
            regField[0:3] = "000" 
        #regField[0:3] = "000"

    #if the instruction is shl,shr
    if(instructionFunction == "1011100" or instructionFunction == "1011101"):
        regField[6:9] = regField[0:3]
    #check if the instruction is memory
    if(instructionFunction[1:3] == "10"):
        regField[6:9] = regField[0:3]
        regField[0:3] = "000"
        
    #if the instruction is swap
    if(instructionFunction == "0010100"):
        regField[6:9] = regField[3:6]
    if(instructionFunction == "1011110"):
        regField[6:9] = regField[3:6]

    immediateValue = ""
    EAValue = ""
    #print(regCount)
    #print(isImmediate)
    if(isEA):
        #look for the hexadecimal immediate value
        lastComma = int(oneTwoThreeOp[len(oneTwoThreeOp)-1])
        # Code to convert hex to binary 
        EAValueHex = instruction[lastComma+1:]
        #print(immediateValueHex)
        try:
            EAValue = "{0:020b}".format(int(EAValueHex, 16))
        except:
            errorFlag = True
        #print(immediateValue)
    elif(isImmediate):
        #in case of iadd
        if(instructionFunction == "011110"):
            regField[6:9] = regField[3:6]
            regField[3:6] = "000"
        #look for the hexadecimal immediate value
        lastComma = int(oneTwoThreeOp[len(oneTwoThreeOp)-1])
        # Code to convert hex to binary 
        immediateValueHex = instruction[lastComma+1:]
        #print(immediateValueHex)
       
        try:
            immediateValue = "{0:016b}".format(int(immediateValueHex, 16))
        except:
            errorFlag = True
        #print(immediateValue)
        
    
    
    #print("one is "+instruction[1:3])

    regField = "".join(regField)
    return regField,immediateValue,EAValue,errorFlag

def checkOnAdditiveText(instructionFunction,instruction):
    errorFlag = False
    numOfReg = len(re.findall("[R-r][0-7]", instruction))
    print("num of reg = "+str(numOfReg))
    numOfCommas = len(re.findall(",", instruction))
    print(numOfCommas)
    if(instructionFunction == "0000000" and len(instruction.split()) != 1):
        errorFlag = True
    elif(instructionFunction == "0000100"): # not instruction
        if((len(instruction.split()) != 2 or numOfReg != 1)):
            errorFlag = True
        else:
            reg1 = instruction.split()[1]
            print("reg1 = "+reg1)
            if(len(reg1) > 2):
                errorFlag = True
    elif(instructionFunction == "0001001"): # inc instruction
        #print(len(instruction.split()))
        if((len(instruction.split()) != 2 or numOfReg != 1)):
            errorFlag = True
        else:
            reg1 = instruction.split()[1]
            print("reg1 = "+reg1)
            if(len(reg1) > 2):
                errorFlag = True
    elif(instructionFunction == "0001000"): # dec instruction
        if((len(instruction.split()) != 2 or numOfReg != 1)):
            errorFlag = True
        else:
            reg1 = instruction.split()[1]
            print("reg1 = "+reg1)
            if(len(reg1) > 2):
                errorFlag = True
    elif(instructionFunction == "0000011"): # out instruction
        if((len(instruction.split()) != 2 or numOfReg != 1)):
            errorFlag = True
        else:
            reg1 = instruction.split()[1]
            print("reg1 = "+reg1)
            if(len(reg1) > 2):
                errorFlag = True
    elif(instructionFunction == "0001101"): # in instruction
        if((len(instruction.split()) != 2 or numOfReg != 1)):
            errorFlag = True
        else:
            reg1 = instruction.split()[1]
            print("reg1 = "+reg1)
            if(len(reg1) > 2):
                errorFlag = True

    elif(instructionFunction == "0010000" or instructionFunction == "0010001" or instructionFunction == "0010010"
         or instructionFunction == "0010011"): # add,sub,and,or instructions
        if((numOfCommas != 2 or numOfReg != 3)):
            errorFlag = True
        else:
            lastRegIndex = instruction.rfind(re.findall("[R-r][0-7]",instruction)[2])
            print("last reg = "+str(lastRegIndex))
            checkComment = instruction[lastRegIndex+2:].split()
            if(len(checkComment) > 0):
                if(checkComment[0] != "#"):
                    errorFlag = True
            
            if(instructionFunction == "0010011"):
                instruction = instruction[2:]
            else:
                instruction = instruction[3:]
            reg1 = instruction.split(",")[0].split()[0]
            reg2 = instruction.split(",")[1].split()[0]
            reg3 = instruction.split(",")[2].split()[0]
            print("reg1 = "+reg1)
            print("reg2 = "+reg2)
            print("reg3 = "+reg3)
            if(len(reg1) > 2 or len(reg2) > 2 or len(reg3) > 2):
                errorFlag = True
   
    elif(instructionFunction == "0010100"): # swap instruction
        if((numOfCommas != 1 or numOfReg != 2)):
            errorFlag = True
        else:
            lastRegIndex = instruction.rfind(re.findall("[R-r][0-7]",instruction)[1])
            print("last reg = "+str(lastRegIndex))
            checkComment = instruction[lastRegIndex+2:].split()
            if(len(checkComment) > 0):
                if(checkComment[0] != "#"):
                    errorFlag = True
            
            instruction = instruction[4:]
            reg1 = instruction.split(",")[0].split()[0]
            reg2 = instruction.split(",")[1].split()[0]
            print("reg1 = "+reg1)
            print("reg2 = "+reg2)
            if(len(reg1) > 2 or len(reg2) > 2):
                errorFlag = True

    elif(instructionFunction == "1011110"): # iadd instruction
        if((numOfCommas != 2 or numOfReg != 2)):
            errorFlag = True
        else:
            lastElements = instruction[4:].split(",")[2].split()
            print(lastElements)
            if(len(lastElements) > 1):
                if(lastElements[1][0] != "#"):
                    errorFlag = True
        
        instruction = instruction[4:]
        reg1 = instruction.split(",")[0].split()[0]
        reg2 = instruction.split(",")[1].split()[0]
        print("reg1 = "+reg1)
        print("reg2 = "+reg2)
        if(len(reg1) > 2 or len(reg2) > 2):
            errorFlag = True

                    
    elif(instructionFunction == "1011100" or instructionFunction == "1011101"): # shl,shr instructions
        if((numOfCommas != 1 or numOfReg != 1)):
            errorFlag = True
        else:
            lastElements = instruction[3:].split(",")[1].split()
            print(lastElements)
            if(len(lastElements) > 1):
                errorFlag = True
        
        instruction = instruction[3:]
        reg1 = instruction.split(",")[0].split()[0]
        print("reg1 = "+reg1)
        if(len(reg1) > 2):
            errorFlag = True

    elif(instructionFunction == "0100001"): # pop instruction
        if((len(instruction.split()) != 2 or numOfReg != 1)):
            errorFlag = True
        else:
            reg1 = instruction.split()[1]
            print("reg1 = "+reg1)
            if(len(reg1) > 2):
                errorFlag = True
    elif(instructionFunction == "0100100"): # push instruction
        if((len(instruction.split()) != 2 or numOfReg != 1)):
            errorFlag = True
        else:
            reg1 = instruction.split()[1]
            print("reg1 = "+reg1)
            if(len(reg1) > 2):
                errorFlag = True

    elif(instructionFunction == "1101001" or instructionFunction == "1101011" or instructionFunction == "1101110"): # ldm,ldd,std instructions
        if((numOfCommas != 1 or numOfReg != 1)):
            errorFlag = True
        else:
            lastElements = instruction[3:].split(",")[1].split()
            print(lastElements)
            if(len(lastElements) > 1):
                errorFlag = True
        
        instruction = instruction[3:]
        reg1 = instruction.split(",")[0].split()[0]
        print("reg1 = "+reg1)
        if(len(reg1) > 2):
            errorFlag = True

    elif(instructionFunction == "0110000"): # jz instruction
        if((len(instruction.split()) != 2 or numOfReg != 1)):
            errorFlag = True
        else:
            reg1 = instruction.split()[1]
            print("reg1 = "+reg1)
            if(len(reg1) > 2):
                errorFlag = True
    elif(instructionFunction == "0110001"): # jmp instruction
        if((len(instruction.split()) != 2 or numOfReg != 1)):
            errorFlag = True
        else:
            reg1 = instruction.split()[1]
            print("reg1 = "+reg1)
            if(len(reg1) > 2):
                errorFlag = True
    elif(instructionFunction == "0110010"): # call instruction
        if((len(instruction.split()) != 2 or numOfReg != 1)):
            errorFlag = True
        else:
            reg1 = instruction.split()[1]
            print("reg1 = "+reg1)
            if(len(reg1) > 2):
                errorFlag = True
    elif(instructionFunction == "0111100"  and len(instruction.split()) != 1): # ret instruction
        errorFlag = True
    elif(instructionFunction == "0111101"  and len(instruction.split()) != 1): # rti instruction
        errorFlag = True
    
    return errorFlag
    

def readLineByLine(textBody):
    instructionLines = []
    errorString = ""
    lineStr = ""
    for i in textBody:
        #print("hello assembler2 "+str(ord(i)))
        if(ord(i) != 10):
            lineStr += i
        else:
            #print(lineStr)
            instructionLines.append(lineStr)
            lineStr = ""
    instructionLines.append(lineStr)
    #print(lineStr)

    for inst in instructionLines:
        print(inst)


    outputFile = open("instructionMemory.mem", "w")
    outputFile.write('// memory data file (do not edit the following line - required for mem load use)\n')
    outputFile.write('// instance=/ram/ram\n')
    outputFile.write('// format=mti addressradix=h dataradix=s version=1.0 wordsperline=4\n')
    outputFile2 = open("dataMemory.mem", "w")
    outputFile2.write('// memory data file (do not edit the following line - required for mem load use)\n')
    outputFile2.write('// instance=/ram/ram\n')
    outputFile2.write('// format=mti addressradix=h dataradix=s version=1.0 wordsperline=4\n')
    instructionMemory = []
    dataMemory = []
    instructionPointer = 0
    instructionPointerDiff = 0
    PCValue = 0
    InterruptAddress = 0
    dataPointer = 0
    lineNumber = 0
    errorFlag = False
    for i in range(0,2048):
        instructionMemory.append("0000000000000000")
    
    for i in range(0,1024):
        dataMemory.append("00000000000000000000000000000000")
    for instruction in instructionLines:
        
        #first we need to load the reset and interrupt instructions
        #if it contains inline comment
        if(instruction.find("#") != -1):
            instruction = instruction[:instruction.find("#")]
        #to ignore the white lines
        if(instruction != ""):
            print("current instruction is "+instruction)
            if(instructionPointer <= 3):
                #this is a comment not instruction or not ORG 
                if(instruction[0:1] != "#"):
                    #if(instruction.find(".ORG") == 0):
                    #print(instruction)
                    #at first we read the ORG keyword to indicate the next instruction pointer
                    if(instructionPointer % 2 == 0):
                        orgValue = int(re.findall('\-*[0-9]+',instruction)[0])
                    else:
                        if(instructionPointer == 1): 
                            PCValue = re.findall('\-*[0-9]+',instruction)[0]
                            #PCValue changed to hex
                            PCValue = int(PCValue,16)
                        if(instructionPointer == 3):
                            InterruptAddress = re.findall('\-*[0-9]+',instruction)[0]
                            #InterruptAddress changed to hex
                            InterruptAddress = int(InterruptAddress,16)
                        #PCValue should be appended to the RAM
                        instructionPointerDiff = PCValue - instructionPointer
                        if(instructionPointer == 3):
                            PCValue = (f'{int(PCValue):032b}')
                            InterruptAddress = (f'{int(InterruptAddress):032b}')
                            print(PCValue[:16])
                            instructionMemory.append(PCValue[:16])
                            print(PCValue[16:])
                            instructionMemory.append(PCValue[16:])
                            print(InterruptAddress[:16])
                            instructionMemory.append(InterruptAddress[:16])
                            print(InterruptAddress[16:])
                            instructionMemory.append(InterruptAddress[16:])
                            for _ in range(instructionPointerDiff-1):
                                print(f'{int(0):016b}')
                                instructionMemory.append(f'{int(0):016b}')
                    instructionPointer += 1
                    print(instructionPointer)
                else:
                    pass
                    #print("comment not inst")

            elif(not(".data" in instruction.lower()) and dataPointer == 0):
                if(instructionPointer != 4):    
                    if(instruction[0:1] != "#"):
                        oneTwoThreeOp = []
                        for i, ltr in enumerate(instruction): 
                            if ltr == ',':
                                oneTwoThreeOp.append(i)

                        instructionFunction = ""
                        
                        #instruction operation text
                        instructionOperation = re.findall("[a-zA-Z]*",instruction)[0]
                        if("nop" == instructionOperation.lower()):
                            instructionFunction = "0000000"
                        elif("not" == instructionOperation.lower()):
                            instructionFunction = "0000100"
                        elif("inc" == instructionOperation.lower()):
                            instructionFunction = "0001001"
                        elif("dec" == instructionOperation.lower()):
                            instructionFunction = "0001000"
                        elif("out" == instructionOperation.lower()):
                            instructionFunction = "0000011"
                        elif("in" == instructionOperation.lower()):
                            instructionFunction = "0001101"
                        elif("add" == instructionOperation.lower() and not("iadd" == instructionOperation.lower())):
                            instructionFunction = "0010000"
                        elif("sub" == instructionOperation.lower()):
                            instructionFunction = "0010001"
                        elif("and" == instructionOperation.lower()):
                            instructionFunction = "0010010"
                        elif("or" == instructionOperation.lower()):
                            instructionFunction = "0010011"
                        elif("swap" == instructionOperation.lower()):
                            instructionFunction = "0010100"
                        elif("iadd" == instructionOperation.lower()):
                            instructionFunction = "1011110"
                        elif("shl" == instructionOperation.lower()):
                            instructionFunction = "1011100"
                        elif("shr" == instructionOperation.lower()):
                            instructionFunction = "1011101"
                        elif("pop" == instructionOperation.lower()):
                            instructionFunction = "0100001"
                        elif("push" == instructionOperation.lower()):
                            instructionFunction = "0100100"
                        elif("ldm" == instructionOperation.lower()):
                            instructionFunction = "1101001"
                        elif("ldd" == instructionOperation.lower()):
                            instructionFunction = "1101011"
                        elif("std" == instructionOperation.lower()):
                            instructionFunction = "1101110"
                        elif("jz" == instructionOperation.lower()):
                            instructionFunction = "0110000"
                        elif("jmp" == instructionOperation.lower()):
                            instructionFunction = "0110001"
                        elif("call" == instructionOperation.lower()):
                            instructionFunction = "0110010"
                        elif("ret" == instructionOperation.lower()):
                            instructionFunction = "0111100"
                        elif("rti" == instructionOperation.lower()):
                            instructionFunction = "0111101"
                        else:
                            print("error !! , improper instruction operation in line "+str(lineNumber+1))
                            errorString = "error !! , improper instruction in line "+str(lineNumber+1)
                            errorFlag = True
                        
                        errorFlag = checkOnAdditiveText(instructionFunction,instruction)
                        if(errorFlag):
                            print("error !! , non meaningful text in line "+str(lineNumber+1))
                            errorString = "error !! , non meaningful text in line "+str(lineNumber+1)

                        improperSymbols = re.findall('[@!~$%^&*()\-+/.]',instruction)
                        #print(improperSymbols)    
                        if(len(improperSymbols) > 0):
                            print("error !! , improper symbols in line "+str(lineNumber+1))
                            errorString = "error !! , improper symbols in line "+str(lineNumber+1)
                            errorFlag = True
                        
                        
                        if(errorFlag):
                            break
                        instructionFunction = "".join(instructionFunction)
                        regField = ""
                        immediateValue = ""
                        EAValue = ""
                        #print(instructionFunction)
                        #three operands case
                        #if(len(oneTwoThreeOp) >= 0 or instructionFunction == "011100" or instructionFunction == "011101"):
                        #check if the instruction isn't NOP/RTI/RET
                        noRegInstructions = (instructionFunction == "0000000" or instructionFunction == "0111100" or instructionFunction == "0111101")
                        if(not(noRegInstructions)):
                            regField,immediateValue,EAValue,errorFlag = calReg(instruction,oneTwoThreeOp,instructionFunction,errorFlag)
                        else:
                            regField = "000000000"
                        
                        #check if there is no error from the register numbers range
                        if(errorFlag):
                            print("error !! , plz enter registers number ranged from 0 to 7 in line "+str(lineNumber+1))
                            errorString = "error !! , plz enter registers number ranged from 0 to 7 in line "+str(lineNumber+1)
                            break
                        
                    # print(instructionFunction)
                        #print(instructionFunction+regField)
                        if(EAValue != ""):
                            regField = list(regField)
                            regField[2:6] =  list(EAValue[:4]) 
                            regField = "".join(regField)
                        print(instructionFunction+regField)
                        instructionMemory.append(instructionFunction+regField)   
                        if(EAValue != ""):
                            EAValue = "".join(list(EAValue[4:]))
                            print(EAValue)
                            instructionMemory.append(EAValue)
                        
                        if(immediateValue != ""):
                            print(immediateValue)
                            instructionMemory.append(immediateValue)
                            
                        #case of the operation is one operand
                        instructionPointer += 1
                    else:
                        pass
                        #print("not inst may be comment or sth else")
                else:
                    if(instruction[0:1] == "."):
                        instructionPointer += 1
            else:

                print("data pointer = "+str(dataPointer))
                if(dataPointer == 0):
                    pass
                    #print("data")
                
                #print(immediateValueHex)
                if(dataPointer > 0):
                    variableValue = "{0:032b}".format(int(instruction, 16))
                    #print(variableValue[:16])
                    dataMemory.append(variableValue)
                    print("HEREEEEEEEEEEEE")
                    #print(variableValue[16:])
                    #dataMemory.append(variableValue[16:])
                dataPointer += 1
                
            #print("inst pointer = "+str(instructionPointer))
        lineNumber += 1

    if(not(errorFlag)):
        for i in range(0,2048):
            if(i % 4 == 0):
                outputFile.write(hex(i)[2:]+': ')    
            if(i < len(instructionMemory)):
                outputFile.write(instructionMemory[i]+' ')
            else:
                outputFile.write("0000000000000000"+' ')
            if((i+1) % 4 == 0):
                outputFile.write('\n')

        print(dataMemory)
        for i in range(0,1024):
            if(i % 4 == 0):
                outputFile2.write(hex(i)[2:]+': ')
            if(i < len(dataMemory)):
                outputFile2.write(dataMemory[i]+' ')
            else:
                outputFile2.write("00000000000000000000000000000000"+' ')
            if((i+1) % 4 == 0):
                outputFile2.write('\n')
        
    return errorFlag,errorString    
