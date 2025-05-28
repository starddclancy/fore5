for(i 1 length(x)/2 cons(nth(length(x)-1) x))




;1


procedure( onlyPositive(a)
    let((item b)
        b = '()
        foreach(item a
        if(item>0 then
           b = append1(b item)
            )
        )
    )
)

;2
procedure( justTheTip(x y)
    let((a b z)
        b = list(car(x))
        if(y>0 && y<length(x) then
            for(z 1 y-1
                    x = cdr(x)
                    a = car(x)
                    b = append1(b a)
                    ) 
        else
            b = "error")
    b)
)

procedure( myReverse(x)
    let((a i)
        a = '()
        for(i 0 length(x)-1
            a = cons(nth(i x) a)
        )
    a)
)

procedure( listCompound(x y)
    let(()
                b = '()
                foreach(i x
                        foreach(j y
                            append1(b i))   
                )
        ))

