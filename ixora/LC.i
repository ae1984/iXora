/* LC.i
 * MODULE
        Trade Finance
 * DESCRIPTION
        Общие таблицы, переменные
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
        09/09/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        25/11/2010 galina - добавила b-LCotherD
        10/02/2011 id00810 - перенесла сюда таблицу t-LCpay и буфер b-LCpay
        29/12/2011 id00810 - дополнила функцию getVisual
*/



def {1} shared var s-ourbank as char no-undo.


find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def temp-table t-LCmain no-undo like LCh
    field showOrder as integer
    field dataName as char
    field dataSpr as char
    field dataValueVis as char
    index idx_sort showOrder.

def  temp-table t-LCShip no-undo like LCh
    field showOrder as integer
    field dataName as char
    field dataSpr as char
    field dataValueVis as char
    index idx_sort showOrder.

def temp-table t-LCotherD no-undo like LCh
    field showOrder as integer
    field dataName as char
    field dataSpr as char
    field dataValueVis as char
    index idx_sort showOrder.

def buffer b-LCotherD for t-LCotherD.

def temp-table t-LCpay no-undo like LCpayh
    field showOrder as integer
    field dataName as char
    field dataSpr as char
    field dataValueVis as char
    index idx_sort showOrder.

def buffer b-LCpay for t-LCpay.

function getVisual returns char (input p-dataCode as char, input p-value as char).
    def var res as char no-undo.
    res = p-value.
    find first LCkrit where LCkrit.dataCode = p-dataCode no-lock no-error.
    if avail LCkrit then do:
        if trim(LCkrit.dataSpr) <> '' then do:
            find first codfr where codfr.codfr = LCkrit.dataSpr and codfr.code = p-value no-lock no-error.
            if avail codfr then res = p-value + ' - ' + codfr.name[1].
        end.
        else do:
            if LCkrit.dataType = 'd' and p-value <> '' then res = string(date(p-value),"99/99/9999") no-error.
            if LCkrit.dataType = 'r' and p-value <> '' then res = trim(string(deci(p-value),"zzz,zzz,zzz,zz9.99")) no-error.
            if LCkrit.dataType = 'i' and p-value <> '' then res = trim(string(int(p-value),"zzz,zzz,zzz,zz9")) no-error.
            else res = p-value.
        end.
    end.
    return res.
end function.




