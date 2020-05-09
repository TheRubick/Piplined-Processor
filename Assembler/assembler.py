import re
import sys
#Return a list containing every occurrence of "ai":
def calReg(instruction,oneTwoThreeOp,instructionFunction,errorFlag):
    
    regField = list("000000000")
    Reg = re.findall("[R-r][0-9]", instruction)
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
    for i in range(regCount):
        if(Reg[i][1] == "0"):
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
            regField[0:3] = "000"
        #if the instruction is in
        elif(instructionFunction == "0001101"):
            regField[6:9] = "000" 
        #regField[0:3] = "000"

    #if the instruction is shl,shr
    if(instructionFunction == "1011100" or instructionFunction == "1011101"):
        regField[6:9] = regField[0:3]
    #check if the instruction is memory
    if(instructionFunction[1:3] == "10"):
        regField[6:9] = regField[0:3]
        regField[0:3] = "000"
        
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
        EAValue = "{0:020b}".format(int(EAValueHex, 16))
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
        immediateValue = "{0:016b}".format(int(immediateValueHex, 16))
        #print(immediateValue)
        
    
    
    #print("one is "+instruction[1:3])

    regField = "".join(regField)
    return regField,immediateValue,EAValue,errorFlag


inputFile = open(sys.argv[1], "r")
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
orgValue = 0
isOrgAddress = False
PCValue = 0
InterruptAddress = 0
dataPointer = 0
lineNumber = 0
errorFlag = False
for instruction in inputFile:
    #first we need to load the reset and interrupt instructions
    #to ignore the white lines
    if(len(instruction) != 1):
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
                        print("error !! , improper instruction in line "+str(lineNumber+1))
                        errorFlag = True
                            
                    
                    improperSymbols = re.findall('[@!~$%^&*()\-+/.]',instruction)
                    #print(improperSymbols)    
                    if(len(improperSymbols) > 0):
                        print("error !! , improper symbols in line "+str(lineNumber+1))
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
            if(dataPointer == 0):
                pass
                #print("data")
       
            #print(immediateValueHex)
            if(dataPointer > 0):
                variableValue = "{0:032b}".format(int(instruction, 16))
                #print(variableValue[:16])
                dataMemory.append(variableValue)
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

    for i in range(0,1024):
        if(i % 4 == 0):
            outputFile2.write(hex(i)[2:]+': ')
        if(i < len(dataMemory)):
            outputFile2.write(dataMemory[i]+' ')
        else:
            outputFile2.write("00000000000000000000000000000000"+' ')
        if((i+1) % 4 == 0):
            outputFile2.write('\n')
