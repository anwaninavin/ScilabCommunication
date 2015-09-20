//Author: Navin Anwani
//Status: Working

//Category A: qpskmod
//About function:
//Name  :qpskmod
//It expects a binary vector x with even numbered length and provides a complex column vector Y at output with a length half that of the input.
//The function provides output with gray coded qpsk constellation.
//The output is obtained by first generating bit pairs from the input and then gray coding those bit pairs. Next the gray coded bit pair is mapped to constellation symbol based on the symbol table.

function Y = qpskmod(x,phaseShift)
//  x : it is a vector which is then converted to a binary column vector with 1s and 0s. It's length r should be even.
//  phaseShift : it is the amount of desired phase shift in the output
//  Y : QPSK modulated output of length r/2.
    
//Initialize the outut in case of an error
    Y = []

//Verifying correct number of input and output arguments
    [lhs, rhs] = argn(0)
    
    if (lhs < 1) then       //if the number of output arguments is less than 1
        disp("Error: Insufficient number of output arguments")
        return
    end
    if (rhs < 2) then       //if the number of input arguments is less than 2
        disp("Error: Insufficient number of input arguments")
        return
    end

// Verification of size and format of the input
    [r,c] = size(x)
    if c == 1 then          //if x is column vector
        if bitget(r,1) then        //error if input is not even sized vector (if LSB is 1)
            disp("Error: The input must have even number of bits for qpsk modulation")
            return
        end
    elseif r == 1 then        //if x is a row vector
        if bitget(c,1) then        //error if input is not even sized vector (if LSB is 1)
            disp("Error: The input must have even number of bits for qpsk modulation")
            return
        end
        x = x'          //Converting the row vecctor to colummn vector
        [r,c] = size(x)     //Refresh the size of vector x
        
    else                    //if the input is not a vector
        disp("Error: The input must be a column or a row vector")
        return
    end
    
//Converting input from Boolean to 1s and 0s
    x = bool2s(x)

//Generating symbol table as per given phase shift in radians which also accounts for gray coding i.e., if phase shift is zero then
//00 --> 1 + 0j
//01 --> 0 + 1j
//10 --> 0 - 1j
//11 --> -1 + 0j
    symTable = [1; %i*1; %i*-1; -1]    //symbol table also accounting for gray coding i.e.,
    phasor = exp(%i*phaseShift)     //factor for obtaining phase shift
    symTable = symTable*phasor;     //Applying phase shift

//Genaration of modulated data by first obtaining mapping from input to symbol table
    map = ones(r/2,1)                       //Initialization of vector providing mapping from input x to the symbols in symbol table.
    map = map + x(1:2:r-1) + 2*x(2:2:r)     //Generation of index of the symbol corresponding to the bit pair in the symbol table. The LSB in the bit pair is obtained from bit in the odd position and MSB is obtaiined from bit in the even position in x i.e., if x = [0 0 1 0 0 1 1 1] then corresponding bit pairs are: 00, 01, 10 and 11.
    Y=symTable(map)
endfunction

////        Test cases
////1.
//  x = [0 0 1 0 0 1 1 1]'
//  Y = qpskmod(x, 0)       //The expected output is Y = [1  j  -j  -1]'

////2.
//  x = [0 0 1 0 0 1 1 1]'
//  Y = qpskmod(x, %pi/4)       //The expected output is Y = 0.707*[(1+j)  (-1+j)  (1-j)  (-1-j)]'

////3.
//  x = [0 0 1 0 0 1 1 1]
//  Y = qpskmod(x, %pi/4)       //The expected output is Y = 0.707*[(1+j)  (-1+j)  (1-j)  (-1-j)]'
