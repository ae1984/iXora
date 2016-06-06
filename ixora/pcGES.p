  /* pcGES.p
 * MODULE
        Кредитный лимит по ПК и доп.услуги
 * DESCRIPTION
        Расчет эффективной процентной ставки
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-2-1
 * AUTHOR
        14.05.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
        11.09.2013 Lyubov - ТЗ 2066, добавила в выборку из pccstaff0 поиск по CIF
*/


def shared var v-aaa      as char no-undo.
def shared var v-bank     as char no-undo.
def shared var s-credtype as char init '4' no-undo.
def shared var v-cifcod   as char no-undo.

def var v-credlim   as deci.
def var v-credper   as inte.
def var v-fsv       as deci.
def var v-issdt     as date.
def var v-frstdt    as date.
def var v-rcom      as deci.
def var v-ocom      as deci.
def var v-pcom      as deci.
def var v-scom      as deci.
def var v-srvcom    as deci.
def var v-eps       as deci.
def var hol         as logi init false.
def var dt          as date.
def var v-weekbeg   as inte init 2.
def var v-weekend   as inte init 6.

form
skip(1)
v-credlim   label 'Сумма кредитного лимита        ' format '>>>,>>>,>>9.99' 'тенге' skip
v-credper   label 'Срок кредитования              ' format '>>9'            'мес.' skip
v-fsv       label 'Ставка вознаграждения          ' format '>>9.99'         '% годовых' skip
v-issdt     label 'Дата выдачи                    ' format '99/99/9999'         skip
v-frstdt    label 'Дата первого погашения         ' format '99/99/9999'         skip
v-rcom      label 'Комиссия за рассмотрение       ' format '>>>,>>>,>>9.99' skip
v-ocom      label 'Комиссия за организацию        ' format '>>>,>>>,>>9.99' skip
v-pcom      label 'Комиссия за предоставление     ' format '>>>,>>>,>>9.99' skip
v-scom      label 'Комиссия за снятие наличных    ' format '>>>,>>>,>>9.99' skip
v-srvcom    label 'Комиссия за обслуживание счета ' format '>>>,>>>,>>9.99' skip
v-eps       label 'Эффективная ставка             ' format '>>9.9'         '% годовых' skip(1)
with side-labels centered row 3 title ' Рассчет эффективной процентной ставки '  width 100 frame feps.

find first pccards where pccards.bank = v-bank and pccards.aaa = v-aaa and pccards.cif = v-cifcod and sts <> 'Closed' no-lock no-error.
if not avail pccards then do:
    message 'Карточка не выпущена! Невозможно рассчитать ГЭСВ.' view-as alert-box.
    return.
end.

find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = '4' and pkanketa.aaa = v-aaa  no-lock no-error.

if pkanketa.rateq > 0 then do:
    message 'ГЭСВ уже расчитана!' view-as alert-box.
    return.
end.

if can-do('100,120',pkanketa.sts) or pkanketa.rateq <> 0 then do:
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'credlim' no-lock no-error.
    if avail pkanketh then do:
        v-credlim = pkanketa.summa.
        run DayCount(pkanketh.rdt, pccards.expdt, output v-credper).
    end.
    v-fsv = 24.
    v-issdt = pkanketh.rdt.
    v-eps = pkanketa.rateq.
.
    /*определяем последний рабочий день месяца даты выдачи*/
    dt = date(month(pkanketh.rdt) + 1,1, year(pkanketh.rdt)) - 1.
    v-frstdt = dt.
    do while hol = false:
        if v-frstdt >= today - weekday(today) + 1 and v-frstdt <= today + 7 - weekday(today) then do:
          find sysc where sysc.sysc = "WKEND" no-lock no-error.
          if available sysc then v-weekend = sysc.inval.
          find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
          if available sysc then v-weekbeg = sysc.inval.
        end.
        if weekday(v-frstdt) >= v-weekbeg and weekday(v-frstdt) <= v-weekend then hol = true.
        else do:
            hol = false.
            v-frstdt = v-frstdt - 1.
        end.
    end.
    displ v-credlim v-credper v-fsv v-issdt v-frstdt v-eps with frame feps.
    update v-rcom v-ocom v-pcom v-scom v-srvcom with frame feps.
    run erl_cl1(v-credlim,v-credper,v-fsv,10,v-issdt,v-frstdt,v-frstdt,v-frstdt,v-rcom + v-ocom + v-scom + v-pcom + v-srvcom,output v-eps).
    v-eps = round(v-eps * 100,1).
    displ v-eps with frame feps.
    find current pkanketa exclusive-lock no-error.
        assign
        pkanketa.summa     = v-credlim
        pkanketa.srok      = v-credper
        pkanketa.rateq     = round(v-eps,1).
        pkanketa.sts       = '60'.
    find current pkanketa no-lock no-error.
end.

else if pkanketa.sts = '110' then do:
    message 'Просим рассмотреть заявку в Нестандартном процессе!' view-as alert-box.
    return.
end.

Procedure DayCount. /* возвращает количество месяцев за период */
def input parameter a_start  as date .
def input parameter a_expire as date .
def output parameter iimonth as integer .
def var e_refdate as date no-undo.
def var months as inte initial 0 no-undo.
def var e_date as date no-undo.
iimonth = 0.
e_refdate = a_start.
if a_start = a_expire then do: return. end.
do e_date = a_start to a_expire :
   if day(e_date) = day(e_refdate) and e_date <> a_start then do:
      iimonth = iimonth + 1.
   end.
end.
End procedure.