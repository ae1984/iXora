/* functext.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Функции, используемые в выписках по счетам клиентов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK
 * CHANGES
        23.05.2012 damir.
        24.05.2012 damir - корректировка.
        17.09.2012 damir - добавил функции Razd,RazdSpace. Т.З. № 1379.
        25.09.2012 damir - внедрено Т.З. № 1522.
*/
def temp-table wrk_1
    field i as inte
    field txt as char
    index idx is primary i ascending.

def temp-table wrk_2
    field i as inte
    field txt as char
    index idxn is primary i ascending.

def buffer b-wrk_2 for wrk_2.

function remconv returns char(input p-jh as char,input p-rem as char).
    def var v-rem as char.
    find first dealing_doc where dealing_doc.jh = inte(p-jh) no-lock no-error.
    if avail dealing_doc then do:
        if p-rem <> "" then v-rem = p-rem + " курс " + string(dealing_doc.rate).
        else v-rem = p-rem.
    end.
    else v-rem = p-rem.
    return v-rem.
end function.

function Razd returns char(input rem as char,input numb as inte).
    def var v-mod as inte.
    def var v-mas as inte.
    def var k as inte.
    def var RetVal as char.

    v-mod = 0. v-mod = length(trim(rem)) modulo numb.

    v-mas = 0. v-mas = inte(length(trim(rem)) / numb).
    if v-mod > 0 then v-mas = v-mas + 1.

    RetVal = "". k = 1.
    do i = 1 to v-mas:
        if RetVal <> "" then RetVal = RetVal + "<br>" + trim(substr(trim(rem),k,numb)).
        else RetVal = trim(substr(trim(rem),k,numb)).
        k = k + numb.
    end.
    return RetVal.
end function.

function RazdSpace returns char(input rem as char,input num as inte).
    def var v-txt as char.
    def var v-lasnum as inte.
    def var v-chk as logi.
    def var RetValue as char.
    v-chk = false. RetValue = "". v-txt = "". v-lasnum = 0. empty temp-table wrk_1. empty temp-table wrk_2.
    repeat i = 1 to num-entries(trim(rem)," "):
        if length(entry(i,trim(rem)," ")) > 0 then do:
            create wrk_1.
            wrk_1.i = i.
            wrk_1.txt = trim(entry(i,trim(rem)," ")).
        end.
    end.
    find last wrk_1 use-index i no-lock no-error.
    if avail wrk_1 then v-lasnum = wrk_1.i.

    i = 0.
    for each wrk_1 no-lock use-index i:
        v-txt = v-txt + " " + wrk_1.txt.
        if length(trim(v-txt)) > num then do:
            if wrk_1.i <> v-lasnum then do:
                if r-index(trim(v-txt)," ") > 0 then do:
                    if length(trim(substr(trim(v-txt),1,r-index(trim(v-txt)," ")))) > num then do:
                        create wrk_2.
                        i = i + 1.
                        wrk_2.i = i.
                        wrk_2.txt = Razd(trim(substr(trim(v-txt),1,r-index(trim(v-txt)," "))),num).
                    end.
                    else do:
                        create wrk_2.
                        i = i + 1.
                        wrk_2.i = i.
                        wrk_2.txt = trim(substr(trim(v-txt),1,r-index(trim(v-txt)," "))).
                    end.
                    v-txt = trim(substr(trim(v-txt),r-index(trim(v-txt)," "),length(trim(v-txt)))).
                end.
                v-chk = true.
            end.
            else do:
                if num-entries(trim(v-txt)," ") > 1 then do:
                    create wrk_2.
                    i = i + 1.
                    wrk_2.i = i.
                    wrk_2.txt = trim(substr(trim(v-txt),1,r-index(trim(v-txt)," "))).

                    if length(trim(substr(trim(v-txt),r-index(trim(v-txt)," "),length(trim(v-txt))))) > 24 then do:
                        create wrk_2.
                        i = i + 1.
                        wrk_2.i = i.
                        wrk_2.txt = Razd(trim(substr(trim(v-txt),r-index(trim(v-txt)," "),length(trim(v-txt)))),24).
                    end.
                    else do:
                        create wrk_2.
                        i = i + 1.
                        wrk_2.i = i.
                        wrk_2.txt = trim(substr(trim(v-txt),r-index(trim(v-txt)," "),length(trim(v-txt)))).
                    end.

                    v-chk = true.
                end.
                else do:
                    create wrk_2.
                    i = i + 1.
                    wrk_2.i = i.
                    wrk_2.txt = Razd(trim(v-txt),24).
                end.
            end.
        end.
        else do:
            if v-chk = true and wrk_1.i = v-lasnum then do:
                create wrk_2.
                i = i + 1.
                wrk_2.i = i.
                wrk_2.txt = trim(substr(trim(v-txt),1,num)).
            end.
        end.
    end.
    if v-chk = false then do:
        i = 0.
        create wrk_2.
        i = i + 1.
        wrk_2.i = i.
        wrk_2.txt = trim(v-txt).
    end.

    i = 0.
    for each wrk_2 no-lock:
        if RetValue <> "" then RetValue = RetValue + "<br>" + trim(wrk_2.txt).
        else RetValue = trim(wrk_2.txt).
        i = i + 1.
    end.
    if i = 1 then find last b-wrk_2 no-lock no-error.
    if avail b-wrk_2 then RetValue = trim(b-wrk_2.txt).

    return RetValue.
end function.

function ReplMarks returns char(input rem as char).
    def var RetVal as char.
    RetVal = "".
    RetVal = trim(rem).
    RetVal = replace(RetVal,",",",&nbsp;").
    RetVal = replace(RetVal,"'","'&nbsp;").
    RetVal = replace(RetVal,".",".&nbsp;").
    RetVal = replace(RetVal,",",",&nbsp;").
    RetVal = replace(RetVal,"(","(&nbsp;").
    RetVal = replace(RetVal,")",")&nbsp;").
    RetVal = replace(RetVal,"-","-&nbsp;").
    RetVal = replace(RetVal,"!","!&nbsp;").
    return RetVal.
end function.