//Author: Navin Anwani
//Status: Working

//Category A: qpskdemod
//About function:
//Name  :qpskdemod
//It expects a complex vector Y as input and gives a binary column vector x with length twice that of Y.
//The function assumes gray coded qpsk constellation of the symbols at the input.
//The output is obtained by mapping qpsk symbols back to bit pairs and then performing decoding the bit pair assuming it was gray coded.

function x = qpskdemod(Y,phaseShift)
//  Y : QPSK modulated input of length r.
//  phaseShift : it is the amount of phase shift in the input apart from qpsk modulation
//  x : it is a column vector of decoded bits from input QPSK symbols stream. It's length is 2r.
    
//Initialize the outut in case of an error
    x = []
    
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
    
// Verification of size of the input
    [r,c] = size(Y)

    if r == 1 then          //if Y is row vector
        Y = Y'          //Converting the row vecctor to colummn vector
        [r,c] = size(Y)     //Refresh the size of vector x
    elseif c ~= 1 then        //if Y is neither a column nor a row vector
        disp("Error: The input must be a column or a row vector")
        return
    end
//if Y is a column vector or has been made one from a row vector than continue demod.

//Reversal of given phase shift and adding a phase shift of pi/4 for ease of decoding.
    Yhat = Y*exp(%i*(%pi/4 - phaseShift))

//Determination of the quadrant in which the symbol lies by determining the sign of real and imaginary part
    isReNeg = zeros(r,1)
    isImNeg = zeros(r,1)
    isReNeg(real(Yhat) < 0) = 1    //set if real part of corresponding element in Yhat is negative
    isImNeg(imag(Yhat) < 0) = 1    //set if imaginary part of corresponding element in Yhat is negative
    
//Consider following analysis of relation of variables isReNeg and is ImNeg with the desired demodulated bit pair
//  quadrant    isImNeg  isReNeg    demodulated bit pair
//      1           0       0           00
//      2           0       1           01
//      3           1       1           11
//      4           1       0           10
//Thus isImNeg is same as the MSB of the desired demodulated bit pair and isReNeg is same as the LSB of the desired demodulated bit pair 

//Genaration of demodulated data using above analysis
    x = zeros(2*r,1)
    x(1:2:2*r-1) = isReNeg  //moving isReNeg in LSB position of bit pairs
    x(2:2:2*r) = isImNeg  //moving isImNeg in MSB position of bit pairs
endfunction

////        Test cases
////1.
//  x = [0 0 1 0 0 1 1 1]'
//  Y = qpskmod(x, 0)       //The expected output is Y = [1  i  -i -1]'
//  xHat = qpskdemod(Y, 0)      //the expected output is same as x

////2.
//  x = [0 0 1 0 0 1 1 1]'
//  Y = qpskmod(x, %pi/4)       //The expected output is Y = 0.707*[(1+j)  (-1+j)  (1-j)  (-1-j)]'
//  xHat = qpskdemod(Y, %pi/4)      //the expected output is same as x

////3.
//  x = [0 0 1 0 0 1 1 1]'
//  Y = qpskmod(x, %pi/4)       //The expected output is Y = 0.707*[(1+j)  (-1+j)  (1-j)  (-1-j)]'
//  Y = Y'
//  xHat = qpskdemod(Y, %pi/4)      //the expected output is same as x
