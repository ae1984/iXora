/* incbytm.p
 * MODULE
        Инкассовые распоряжения
 * DESCRIPTION
        Документы, полученные за период
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        1.3.1.12.4
 * BASES
        BANK
 * AUTHOR
        13.09.2008 alex
 * CHANGES
        14/05/2009 madiyar - добавил отчеты по частичной оплате ИР
        08/12/2009 galina - добавила отчеты по РПРО и отзывам РПРО
        03.07.2013 yerganat - tz1889,  пункты меню формирования консолидированного отчета
*/

def var v-select as integer no-undo.
def var s-vcourbank as char no-undo.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.

s-vcourbank = trim(sysc.chval).
if s-vcourbank = "TXB00" then do:
    run sel3 (" МЕНЮ ", " 0. Отчет по полученным ИР | 1. Консолид. отчет по ИР | 2. Отчет по част. оплате ИР | 3. Консолид. отчет по част. оплате ИР | 4. Отчет по отзывам ИР | 5. Консолид. отчет по отзывам ИР | 6. Отчет по распо. о приост. РО| 7. Консолид.отчет по расп. о приост. РО | 8. Отчет по отзывам расп. о приост. РО | 9. Конс.отчет по отз. расп. о приост.РО | 10. ВЫХОД ", output v-select).
    if v-select = 1 then run inkrep(no).
    else
    if v-select = 2 then run inkrep(yes).
    else
    if v-select = 3 then run incpart(no).
    else
    if v-select = 4 then run incpart(yes).
    else
    if v-select = 5 then run recrep(no).
    else
    if v-select = 6 then run recrep(yes).
    else
    if v-select = 7 then run insrep(no).
    else
    if v-select = 8 then run insrep(yes).
    else
    if v-select = 9 then run insrecrep(no).
    else
    if v-select = 10 then run insrecrep(yes).
    else return.
end.
else do:
    run sel3 (" МЕНЮ ", " 0. Отчет по полученным ИР | 1. Отчет по част. оплате ИР | 2. Отчет по отзывам ИР | 3. Отчет по расп. о приост. РО | 4. Отчет по отзывам расп. о приост. РО | 3. ВЫХОД ", output v-select).
    if v-select = 1 then run inkrep(no).
    else
    if v-select = 2 then run incpart(no).
    else
    if v-select = 3 then run recrep(no).
    else
    if v-select = 4 then run insrep(no).
    else
    if v-select = 5 then run insrecrep(no).
    else return.
end.

