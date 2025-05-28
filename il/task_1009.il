(procedure splice(x y) 
    (let (variableName)
        lst = '()
        (for i 0 length(x)-1
            append1(nth(i y) lst)
            append1(nth(i x) lst)
        )
    )
    
)

(procedure stringstogram(str)
    (let (variableName)
    
        strlst = parseString(str)
        numlst = '()
        result = '()
        (for i 0 length(strlst)-1
            numlst = append1(numlst strlen(nth(i strlst)))
        )

        noDup = removeDup(numlst)

        (foreach lensum noDup
            count = 0
            (foreach item numlst
                if lensum = item then 
                    count++
            )
            result = append1(result count)
        )
        splice(removeDup(numlst) result)
    )
)
/*        (for j 0 length(numlst)-1
            count = 0
            (foreach item numlst
                (if nth(j numlst) = item then
                    count++
                )   
            )
            result = append1(result count) 
        )
        

    )
)*/


(procedure removeDup(lst)
    (let (i j)
        newList = '()     
        (foreach i lst
            (for j 0 length(lst)-1
                if i == nth(j lst) then 
                    newList = rmIndexElem(lst j)
            ) 
        )
        newList
    )
)


(procedure rmIndexElem(lst x)
    (let (i newList)
        newList = '()
        (for i 0 length(lst)-1
            if i != index then
                newlist = append1(newlist nth(i lst))
        )
    )
)


procedure removeAtIndex(lst, index)
    newList = '()
    for i from 0 to length(lst)-1
        if i != index then
            newList = append1(newList, nth(i lst))
    return newList




(procedure removeDup(lst)
    (let (i element found)
        newList = '()     
        (foreach i lst
            found = false
            (foreach element newList
                (if found == false then
                    (if i == element then
                        found = true
                    )
                )
            )
            (if found == false then
                newList = append1(newList, i)
            )
        )
        newList
    )
)

