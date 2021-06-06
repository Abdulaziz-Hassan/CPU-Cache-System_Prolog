convertBinToDec(X,D) :-
	convertBinToDec(X,0,0,D).

convertBinToDec(0,_,Accumulator,Accumulator).


convertBinToDec(X,Counter,Accumulator,Result):-
	X > 0,
	X1 is X // 10,
	1 is X mod 10,
	Accumulator1 is Accumulator + 2**Counter,
	Counter1 is Counter + 1,
	convertBinToDec(X1,Counter1,Accumulator1,Result).

convertBinToDec(X,Counter,Accumulator,Result):-
	X > 0,
	X1 is X // 10,
	0 is X mod 10,
	Counter1 is Counter + 1,
	convertBinToDec(X1,Counter1,Accumulator,Result).

replaceIthItem(Const,List,Index,Result):- 
	replaceIthItem(Const,List,0,Index,Result).


replaceIthItem(Const,[H|T],Counter,Index,[H|T2]):-
	Counter \= Index,
	Counter1 is Counter + 1,
	replaceIthItem(Const,T,Counter1,Index,T2).

replaceIthItem(Const,[H|T],Counter,Counter,[Const|T]).

splitEvery(X,List,Result):-
	splitEvery(X,[],[],List,Result).


splitEvery(_,Sublist,List,[],NewList):-
	append(List,[Sublist],NewList).

splitEvery(X,Sublist,List,Original,Result):-
	Original \= [],
	length(Sublist,L),
	L = X,
	append(List,[Sublist],NewList),
	splitEvery(X,[],NewList,Original,Result).

splitEvery(X,Sublist,List,[H|T],Result):-
	length(Sublist,L),
	L \= X,
	append(Sublist,[H],NewList),
	splitEvery(X,NewList,List,T,Result).

logBase2(X,0):- 
	X =< 1.

logBase2(X,N):- 
	X > 1,
	X1 is X / 2,
	logBase2(X1,N1),
	N is 1 + N1.

getNumBits(_,directMap,Cache,BitsNum):-
	length(Cache,CacheL),
	logBase2(CacheL,BitsNum).

getNumBits(_,fullyAssoc,[_|_],0).

getNumBits(NumOfSets,setAssoc,[_|_],BitsNum):-
	logBase2(NumOfSets,BitsNum).

fillZeros(R,0,R).

fillZeros(String,N,R) :-
	N > 0,
	string_concat('0', String, String2),
	N1 is N - 1,
	fillZeros(String2,N1,R).

%flag 

		 %DirectMapping

getTag(String,Res,Index) :-
	atom_number(String,N),
	Res is N // 10**Index.	

getDataFromCache(StringAddress,Cache,Data,HopsNum,directMap,BitsNum) :-
	getTag(StringAddress,Tag,BitsNum),
	getDataFromCacheHelper(Tag,Cache,Data,HopsNum,directMap,BitsNum).

getDataFromCacheHelper(Tag,[item(tag(StringTag),data(MemData),ValidBit,Order)|_],MemData,Order,directMap,_) :-
	atom_number(StringTag,Res),
	Tag == Res,
	ValidBit = 1.

getDataFromCacheHelper(Tag,[item(tag(StringTag),data(MemData),ValidBit,Order)|T],Data,HopsNum,directMap,_) :-
	atom_number(StringTag,Res),
	Tag == Res,
	ValidBit \= 1,
	getDataFromCacheHelper(Tag,T,Data,HopsNum,directMap,_).

getDataFromCacheHelper(Tag,[item(tag(StringTag),data(MemData),ValidBit,Order)|T],Data,HopsNum,directMap,_) :-
	atom_number(StringTag,Res),
	Tag \= Res,
	getDataFromCacheHelper(Tag,T,Data,HopsNum,directMap,_).	

convertAddress(Bin,BitsNum,Tag,Idx,directMap) :-
	Tag is Bin // 10**BitsNum,
	Idx is Bin mod 10**BitsNum.
	
getPriorityByIndex([H|T],Index):- 
	getPriorityByIndex(T,H,0,0,Index).


getPriorityByIndex([],_,_,Acc,Acc).


getPriorityByIndex([item(_,_,ValidBit1,Order1)|T],item(_,_,ValidBit2,Order2),Counter,Acc,Index):-
	ValidBit1 = 0,
	ValidBit2 = 1,
	Counter1 is Counter + 1,
	getPriorityByIndex(T,item(_,_,ValidBit1,Order1),Counter1,Counter1,Index).
	

getPriorityByIndex([item(_,_,ValidBit1,Order1)|T],item(_,_,ValidBit2,Order2),Counter,Acc,Index):-
	ValidBit1 = 1,
	ValidBit2 = 0,
	Counter1 is Counter + 1,
	getPriorityByIndex(T,item(_,_,ValidBit2,Order2),Counter1,Acc,Index).	
				
				
				
getPriorityByIndex([item(_,_,ValidBit1,Order1)|T],item(_,_,ValidBit2,Order2),Counter,Acc,Index):-
	ValidBit1 = ValidBit2,
	Counter1 is Counter + 1,
	Order1 < Order2,
	getPriorityByIndex(T,item(_,_,ValidBit1,Order2),Counter1,Acc,Index).			
			
					
getPriorityByIndex([item(_,_,ValidBit1,Order1)|T],item(_,_,ValidBit2,Order2),Counter,Acc,Index):-
	ValidBit1 = ValidBit2,
	Counter1 is Counter + 1,
	Order1 > Order2,
	getPriorityByIndex(T,item(_,_,ValidBit1,Order1),Counter1,Counter1,Index).					
					
	
getIthItem(L,I,Z):- getIthItem(L,I,0,Z).

getIthItem([H|_],I,I,H).

getIthItem([H|T],I,Counter,Z):-
	Counter \= I,
	Counter1 is Counter +1,
	getIthItem(T,I,Counter1,Z).
			
			
replaceInCache(Tag,Idx,Mem,OldCache,NewCache,ItemData,directMap,BitsNum):- 	
	atom_number(Tagf,Tag),
	atom_number(Idxf,Idx),
	atom_length(Idxf,IndexLength),
	NewIndexLength is BitsNum - IndexLength,
	fillZeros(Idxf,NewIndexLength,NewIdxf),
	string_concat(Tagf,NewIdxf,Addressf),
	atom_number(Addressf,Addressk),
	convertBinToDec(Addressk,N),
	getIthItem(Mem,N,ItemData),
	atom_number(TagString,Tag),
	OldCache = [item(tag(TagString2),_,_,_)|_],
	atom_length(TagString,X),
	atom_length(TagString2,Y),
	Z is Y - X,		
	fillZeros(TagString,Z,NewTag),
	convertBinToDec(Idx,Index),
	NewItem = item(tag(NewTag),data(ItemData),1,0),
	replaceIthItem(NewItem,OldCache,Index,NewCache).
		

getData(StringAddress,OldCache,Mem,NewCache,Data,HopsNum,Type,BitsNum,hit):-
	getDataFromCache(StringAddress,OldCache,Data,HopsNum,Type,BitsNum),
	NewCache = OldCache.

getData(StringAddress,OldCache,Mem,NewCache,Data,HopsNum,Type,BitsNum,miss):-
	\+getDataFromCache(StringAddress,OldCache,Data,HopsNum,Type,BitsNum),
	atom_number(StringAddress,Address),
	convertAddress(Address,BitsNum,Tag,Idx,Type),
	replaceInCache(Tag,Idx,Mem,OldCache,NewCache,Data,Type,BitsNum).
		
runProgram([],OldCache,_,OldCache,[],[],Type,_).

runProgram([Address|AdressList],OldCache,Mem,FinalCache,[Data|OutputDataList],[Status|StatusList],Type,NumOfSets):-
	getNumBits(NumOfSets,Type,OldCache,BitsNum),
	getData(Address,OldCache,Mem,NewCache,Data,HopsNum,Type,BitsNum,Status),
	runProgram(AdressList,NewCache,Mem,FinalCache,OutputDataList,StatusList,
		Type,NumOfSets).

%endFlag
			%FullyAssociative

getDataFromCache(StringAddress,Cache,Data,HopsNum,fullyAssoc,0):-
	getDataFromCache(StringAddress,Cache,Data,HopsNum,0,fullyAssoc,0).
						
getDataFromCache(Tag,[item(tag(Tag),data(Data),1,_)|T],Data,Counter,Counter,fullyAssoc,0).

getDataFromCache(StringAddress,[item(tag(Tag),_,_,_)|T],Data,HopsNum,Counter,fullyAssoc,0):-
	StringAddress \= Tag,
	Counter1 is Counter + 1,
	getDataFromCache(StringAddress,T,Data,HopsNum,Counter1,fullyAssoc,0).
		
convertAddress(Bin,_,Tag,_,fullyAssoc):-
	atom_number(Temp,Bin),
	atom_number(Temp,Tag).


replaceInCache(Tag,Idx,Mem,OldCache,NewCache,ItemData,fullyAssoc,BitsNum):- 	
	convertBinToDec(Tag,N),
	getIthItem(Mem,N,ItemData),
	atom_number(TagString,Tag),
	OldCache = [item(tag(TagString2),_,_,_)|_],
	atom_length(TagString,X),
	atom_length(TagString2,Y),
	Z is Y - X,		
	fillZeros(TagString,Z,NewTag),
	getPriorityByIndex(OldCache,Index),
	NewItem = item(tag(NewTag),data(ItemData),1,0),
	replaceIthItem(NewItem,OldCache,Index,NewCache).	
		   