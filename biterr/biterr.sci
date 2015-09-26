//Author: Navin Anwani
//Status: Working

//Category B: biterr
//About function:
//Name  : biterr

//***************
////Few comments:
//1. The function accepts minimum 2 input argument and maximum 4.

//2. The option for providing word length K as an optional input argument as in MATLAB has been added.

//3. Functionality to select row-wise or column-wise or overall bit error has been added as in MATLAB.

//4. Also the argument #3 and #4 can be swapped without any trouble

function [number, ratio, varargout] = biterr(X, Y, varargin)
//  X, Y : Matrices of Boolean, integer or float/real datatype, such that at least one of the dimension of the two is identical and when the datatype is real then all the elemnts be integer valued.

//All the elements of inputs X and Y should fit in 32 bit unsigned integer representation

//Optional input arguments: 

////CFLAG => {'row-wise', column-wise', 'overall'}: -specifying how to report the results.

//// Specification of word length K has also been added.

//Output arguments:
////  number : Total number of bits which are in error

////  ratio : Ratio of the nummber of bits in error to the total number of element in the larger of the matrices X and Y.

////  varargout = individual: nummber of error in individual elements


    maxRHS = 4      //the maximum number of input arguments
    minRHS = 2      //the minimum number of input arguments

//Initialization of outputs; useful only when an error is to be reported
    number = []
    ratio = []
    individual = []
    varargout = list(individual)
    
//Initially assume scope of comparison and K have not been defined
    scopeDefined = 0        
    KDefined = 0

//Verifying correct number of input and output arguments
    [lhs, rhs] = argn(0)
    if rhs < minRHS then
        disp("Error: Insufficient number of input arguments.")
        return
    elseif rhs > maxRHS then 
        disp("Error: Too many input arguments.")
        return
    end

//Verify correct format of input argument #3 and #4
    if (rhs > 2) then      //if the varargin is not empty
        if ((varargin(1) == 'row-wise') | (varargin(1) == 'column-wise') | (varargin(1) == 'overall')) then
            reportScope = varargin(1)
            scopeDefined = 1
            if rhs==4 then      //if there are 4 input arguments
                K = varargin(2)         //if varargin(1) is one of row-wise/column-wise/overall then varargin(2) should be word length K
                if ((K ~= floor(K)) | (K > 32)) then        //if given word length is not an integer or it is grater than 32 then report error
                    disp("Error: Improper input at argument #4")
                    return
                else
                    KDefined = 1
                end
            end
        else
            K = varargin(1)         //if varargin(1) is NONE of row-wise/column-wise/overall then varargin(2) should be word length K
            if ((K ~= floor(K)) | (K > 32)) then        //if given word length is not an integer or it is grater than 32 then report error
                disp("Error: Improper input at argument #3")
                return
            else
                KDefined = 1
            end
            if rhs==4 then      //if there are 4 input arguments and 3rd is K then 4th is reportScope
                if ((varargin(2) == 'row-wise') | (varargin(2) == 'column-wise') | (varargin(2) == 'overall')) then
                    reportScope = varargin(2)
                    scopeDefined = 1
                else
                    disp("Error: Improper input at argument #4.")
                    return
                end
            end
        end
    end
    

//Verification of whether the input matrices have correct datatype
    typeX = type(X)
    typeY = type(Y)
    
    if typeX ~= typeY then      //if the two matrices are of different datatype then report error
        disp("Error: both matrices must be of same datatype")
        return
    end
    if ((typeX == 5) | (typeX == 6)) then      //If the inputs are sparse matrices then convert them to full matrices
        X = full(X)
        Y = full(Y)
    end

//Refresh the type after converting to full if the input was sparse
    typeX = type(X)
    typeY = type(Y)

    if typeX == 1 then      //if the input matrices are of float type 
        floorX = floor(X)          //element-wise round down
        if (~(isequal(X, floorX))) then     //if all the elments of X are not integer valued then report an error
            disp("Error: The input matrices must have integer valued elements.")
            return
        end
        floorY = floor(Y)          //element-wise round down
        if (~(isequal(Y, floorY))) then     //if all the elments of X are not integer valued then report an error
            disp("Error: The input matices must have integer valued elements.")
            return
        end
        X = uint32(X)       //if the input matrices are integer valued but with float datatype then
        Y = uint32(Y)       //convert them to unsigned 32 bit int
    end

//refresh the type after conversion
    typeX = type(X)
    typeY = type(Y)

    if ((typeX ~= 4) & (typeX ~= 8)) then      //continue only if the input datatype is either 4 viz Boolean or 8 viz integer now since float has alrady been converted above.
        disp("Error: The inputs should either be matrices of Boolean or integer datatype")
        return
    end

//Dynamically determine the word length which is large enough to accomodate any of the elements of both input matrices
    if typeX==8 then        //if input is integer
        maxX = max(X)
        maxY = max(Y)
        maximum = max(maxX,maxY)        //Determination of maximum of all elements
        wordLen = floor(log2(double(maximum))) + 1    //The minimum number of bits required to represent the largest element in unsigned int format upto 32 bits.
        
        if KDefined then
            if K < wordLen      //report error if provided K is less than min. number of bits required to represent maximum
                disp('Error: The given input matrices in arguments #1 and #2 have elements too large to fit into given word length')
                return
            end
        else
            K=wordLen
        end
    else        //if input is boolean
        if KDefined then
            if K ~= 1      //report error if provided K is greater than 1 if input is boolean
                disp('Error: For Boolean input word length must be 1')
                return
            end
        else
            K=1
        end
    end
    
//Process based on the relative size of matrices
    [rX cX] = size(X)
    [rY cY] = size(Y)
    
    if ((rX == rY) & (cX == cY)) then           //if X and Y have identical size
        Xhat = X
        Yhat = Y
        //Determining the scope of comparison
        if ~(scopeDefined) then            //if the varargin is empty then default reportScope
            reportScope = 'overall'         //by default report overall comparison for identical sized Matrices
        end

    elseif ((rX ~= rY) & (cX == cY)) then       //if the number of rows is different but number of columns is same
        if rX == 1 then          //if X is a row vector
            Xhat = repmat(X,rY,1)
            Yhat = Y
        elseif rY == 1 then          //if Y is a row vector
            Yhat = repmat(Y,rX,1)
            Xhat = X
        else                    //if neither X nor Y is a row vector report error
            disp("Error: If the number of rows of two input matrices is different then at least one of them must be a row vector")
            return
        end

//Determining the scope of comparison
        if ~(scopeDefined) then            //if the varargin is empty then default reportScope
            reportScope = 'row-wise'         //by default report row-wise comparison for such input            
        elseif reportScope == 'column-wise' then
            disp("Error: A column-wise comparison is not possible when sizes of two inputs are not same and one of the inputs is a row vector")
            return
        end
        
    elseif ((cX ~= cY) & (rX == rY)) then       //if the number of columns is different but number of rows is same
        if cX == 1          //if X is a column vector
            Xhat = repmat(X,1,cY)
            Yhat = Y
        elseif cY == 1 then          //if Y is a column vector
            Yhat = repmat(Y,1,cX)
            Xhat = X
        else            //if neither X nor Y is a column vector report error
            disp("Error: If the number of columns of two input matrices is different then at least one of them must be a column vector")
            return
        end

//Determining the scope of comparison
        if ~(scopeDefined) then            //if the varargin is empty then default reportScope
            reportScope = 'column-wise'         //by default report column-wise comparison for such input            
        elseif reportScope == 'row-wise' then
            disp("Error: A row-wise comparison is not possible when sizes of two inputs are not same and one of the inputs is a row vector")
            return
        end

    else        //if none of the dimensions of X and Y is same then report an error
        disp("Error: None of the dimensions of two input matrices is matching")
        return
    end
    
    if typeX == 4 then      //if the type of input is boolean
        Diff = Xhat <> Yhat     //Calculate difference indicator function between the two matrices
        individual = Diff       // error in Individual element is same as bit-wise xor
    else                    //if the type of input is integer
        if inttype(Xhat) ~= 14
            Xhat = uint32(Xhat)     //convert the variables to unsigned integers if they are not already
        end
        if inttype(Yhat) ~= 14
            Yhat = uint32(Yhat)
        end
        
        Diff = bitxor(Xhat, Yhat)       //difference between the two inputs (error)
        
        [rDiff cDiff] = size(Diff)
        individual = zeros(rDiff,cDiff)     //number of bit errors in each individual element
        
        for b=1:K       //loop over the word length
            individual = individual + bitget(Diff,b)        //accumulate errors in individual for every element separately
        end
    end

    varargout = list(individual)        //Assign individual number of bit error to the 3rd output argument
    if reportScope == 'overall' then
        number = sum(individual)        //the total number of bit errors
        numElements = rDiff*cDiff
    elseif reportScope == 'row-wise' then
        number = sum(individual,2)        //the total number of bit errors
        numElements = cDiff
    elseif reportScope == 'column-wise' then
        number = sum(individual,1)        //the total number of bit errors
        numElements = rDiff
    end
    numBits = numElements*K
    ratio = double(number)/double(numBits)      //the ratio of number of bit errors to the number of bits
endfunction

////        Test cases

//  d = [1 2 3 4]'

////1.
//  X = d
//  Y = d
//  [number, rate] = biterr(X,Y)
//  
////2.
//  Y(2) = 1
//  [number, rate] = biterr(X,Y)
//  
////3.
//  [number, rate, indiv] = biterr(X,Y)

////4.: It by default gives column-wise comparison
//  X = repmat(d,1,3)
//  Y = d
//  Y(2) = 1
//  [errNum, rate, indiv] = biterr(X,Y)

////5.: Asking for overall comparison
//  [errNum, rate, indiv] = biterr(X,Y,'overall')

////6.:It by default gives row-wise comparison
//  X = repmat(d',3,1)
//  Y = d'
//  Y(2) = 1
//  [errNum, rate, indiv] = biterr(X,Y)

////7.:It by default gives overall comparison
//  X = repmat(d',3,1)
//  Y = X
//  Y(2,2) = 1
//  [errNum, rate, indiv] = biterr(X,Y)

////8.:Asking for row-wise comparison
//  X = repmat(d',3,1)
//  Y = X
//  Y(2,2) = 1
//  [errNum, rate, indiv] = biterr(X,Y,'row-wise')

////9.:Specifyig the word length K
//  X = repmat(d',3,1)
//  Y = X
//  Y(2,2) = 1
//  [errNum, rate, indiv] = biterr(X,Y,5)

////10.:Specifyig all 4 input arguments
//  X = repmat(d',3,1)
//  Y = X
//  Y(2,2) = 1
//  [errNum, rate, indiv] = biterr(X,Y,5,'row-wise')

////11.
//  [errNum, rate, indiv] = biterr(X,Y,'row-wise',5)

