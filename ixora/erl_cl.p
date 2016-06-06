  /* erc_cl.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Расчет эфф. проц. ставки - розничный кредиты
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-1-10-5
 * AUTHOR
        14.05.2013 Lyubov
 * BASES
 		BANK
 * CHANGES
*/
def var v-credlim   as deci.
def var v-credper   as inte.
def var v-fsv       as deci.
def var v-odpr      as deci.
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
v-odpr      label 'Размер погашения ОД            ' format '>>9'            '%' skip
v-issdt     label 'Дата выдачи                    ' format '99/99/9999'         skip
v-frstdt    label 'Дата первого погашения         ' format '99/99/9999'         skip
v-rcom      label 'Комиссия за рассмотрение       ' format '>>>,>>>,>>9.99' skip
v-ocom      label 'Комиссия за организацию        ' format '>>>,>>>,>>9.99' skip
v-pcom      label 'Комиссия за предоставление     ' format '>>>,>>>,>>9.99' skip
v-scom      label 'Комиссия за снятие наличных    ' format '>>>,>>>,>>9.99' skip
v-srvcom    label 'Комиссия за обслуживание счета ' format '>>>,>>>,>>9.99' skip
v-eps       label 'Эффективная ставка             ' format '>>9.9'         '% годовых' skip(1)
with side-labels centered row 3 title ' Рассчет эффективной процентной ставки '  width 100 frame feps.

displ v-credlim v-credper v-fsv v-odpr v-issdt v-frstdt v-eps with frame feps.
update v-credlim v-credper v-fsv v-odpr v-issdt v-frstdt v-rcom v-ocom v-pcom v-scom v-srvcom with frame feps.
run erl_cl1(v-credlim,v-credper,v-fsv,v-odpr,v-issdt,v-frstdt,v-frstdt,v-frstdt,v-rcom + v-ocom + v-scom + v-pcom + v-srvcom,output v-eps).
v-eps = round(v-eps * 100,1).
displ v-eps with frame feps.

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