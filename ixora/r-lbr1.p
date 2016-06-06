/* r-lbr1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

def var datBeg as date.
def var datEnd as date.
def var datCount as date.
def var rtFact as dec.     /* фактическая % ставка */
def var rtLibor as dec.    /* двойная % ставка по LIBOR*/
def var sumFact as dec.    /* фактически начисленная сумма по депозиту*/
def var sumLibor as dec.   /* начисленная сумма по депозиту по LIBOR*/
def var sumDiff as dec.    /* сумма разницы*/
def var sumPrib as dec.    /* сумма возн. за счет прибыли */
def var sumVych as dec.    /* сумма возн. на вычет*/
def var totFact as dec.    /* общая сумма фактически начисл.*/
def var totLibor as dec.   /* общая сумма начисл. по LIBOR x 2*/
def var totDiff as dec.    /* общая сумма за счет прибыли*/
def var totPrib as dec.
def var totVych as dec.
def var totAcc as int format ">>>>9".
def var tempAcc as int format ">>>>9".
def var totSum as dec format "->>>,>>>,>>9.99".
def var tempSum as dec format "->>>,>>>,>>9.99".
def stream m-out.
def buffer c_aab for aab.

def shared var g-today as date.
def shared variable g-batch  as log initial false.

def temp-table tgr
field tgr as char format "x(3)"
field tacc like aaa.aaa
field tbal like aab.bal
field tfact as dec
field tlibor as dec
field tdiff as dec
field tprib as dec
field tvych as dec
field trtlb as dec.

def buffer c_tgr for tgr.

datEnd = g-today.
datCount = g-today.

display datCount label "с" datEnd label "по" 
    with row 8 centered side-labels frame opt title "Введите:".

update datCount datEnd with frame opt.
if datCount > datEnd then do:
    message "Дата конца периода не может быть больше даты начала!".
    quit.
end.
datBeg = datCount.
display '   Ждите...   '  with row 5 frame ww centered .
hide frame opt.

do while datCount <= datEnd:
    for each aaa where (aaa.gl = 221520 or aaa.gl = 221720) and 
     aaa.crc = 2 and 
     (aaa.expdt >= today or aaa.expdt <= today) no-lock break by aaa.lgr:
        find last aab where aab.aaa = aaa.aaa and aab.fdt <= datCount                    no-error.
        if available aab then do:
            if aab.bal <> 0 then do:
            if aaa.expdt >= datCount then do:
                rtFact = aaa.rate.
            end.
            else if aaa.expdt < datCount then do:
                rtFact = 2.
            end.
            find first c_aab where c_aab.aaa = aaa.aaa.
            find last taxrate where taxrate.taxrate = "lbr" and taxrate.regdt <=             c_aab.fdt no-lock no-error.
            if available taxrate then do:
                rtLibor = taxrate.val[12] * 2.
            end.
            else do:
                rtLibor = 6.3 * 2.
            end.
            sumFact = aab.bal / 100 * rtFact / aaa.base.
            sumLibor = aab.bal / 100 * rtLibor / aaa.base.
            if sumLibor < sumFact then do:
                sumPrib = sumFact - sumLibor.
            end.
            else do:
                sumPrib = 0.
            end.
            if sumLibor < sumFact then do:
                sumVych = sumLibor.
            end.
            else do:
                sumVych = sumFact.
            end.
            
            /*put datCount " " aab.aaa aab.bal aaa.expdt rtFact sumFact skip.*/
            
            create tgr.
            tgr.tgr =  aaa.lgr.
            tgr.tbal = aab.bal.
            tgr.tacc = aab.aaa.
            tgr.tfact = sumFact.
            tgr.tlibor = sumLibor.
            tgr.tprib = sumPrib.
            tgr.tvych = sumVych.
            tgr.trtlb = rtLibor.
            end.
        end.
    end.
    datCount = datCount + 1. 
end.

hide all.

def button btnSort label "Отчет, отсортированный по ставкам LIBOR".
def button btnFull label "Отчет по всем депозитам".
def var prz as int init 1.

def frame frmMain skip(1) btnSort btnFull with centered title "Выбор" row 5.

on choose of btnSort, btnFull do:
    if self:label = "Отчет, отсортированный по ставкам LIBOR" then prz = 1.
    else if self:label = "Отчет по всем депозитам" then prz = 2.
end.
        
enable all with frame frmMain.
wait-for choose of btnSort, btnFull.
hide frame frmMain.

output stream m-out to rpt.img.
{functions-def.i}
if prz = 2 then do:

put stream m-out skip
FirstLine( 1, 1 ) format 'x(58)' skip(1)
'                             ДЕПОЗИТЫ ФИЗИЧЕСКИХ ЛИЦ'  skip
'                                 (221520, 221720)' skip
'                          ЗА ПЕРИОД ' datBeg " - " datEnd skip(1)
FirstLine( 2, 1 ) format 'x(58)' skip.

put stream m-out " " skip.
put stream m-out fill("=", 75) format "x(75)" skip.
put stream m-out "ГРП СЧЕТ      СУММА НА НАЧАЛО  НАЧИСЛ.%   2-LIBOR ЗА СЧ.ПР.  НА ВЫЧЕТ LBR" skip.
put stream m-out fill("=", 75) format "x(75)" skip.

for each tgr break by tgr.tgr by tgr.tacc: 
    accumulate tgr.tfact (total by tgr.tacc).
    accumulate tgr.tfact (count by tgr.tacc).
    accumulate tgr.tlibor (total by tgr.tacc).
    accumulate tgr.tprib (total by tgr.tacc).
    accumulate tgr.tvych (total by tgr.tacc).
    
    accumulate tgr.tfact (total by tgr.tgr).
    accumulate tgr.tlibor (total by tgr.tgr).
    accumulate tgr.tprib (total by tgr.tgr).
    accumulate tgr.tvych (total by tgr.tgr).
    accumulate tgr.tacc (count by tgr.tgr).
    
    if last-of(tgr.tacc) then do:
        find first c_tgr where c_tgr.tacc = tgr.tacc.
        tempSum = tempSum + c_tgr.tbal.
        totSum = totSum + c_tgr.tbal.
        totAcc = totAcc + 1.
        totFact = totFact + accum total by tgr.tacc tgr.tfact.
        totLibor = totLibor + accum total by tgr.tacc tgr.tlibor.
        totPrib = totPrib + accum total by tgr.tacc tgr.tprib.
        totVych = totVych + accum total by tgr.tacc tgr.tvych.
   /*     put stream m-out 
            tgr.tgr " "
            tgr.tacc
            c_tgr.tbal format "->>>,>>>,>>9.99"
            accum total by tgr.tacc tgr.tfact
            accum total by tgr.tacc tgr.tlibor
            accum total by tgr.tacc tgr.tprib
            accum total by tgr.tacc tgr.tvych " " 
            tgr.trtlb format ">9.99" skip. */
    end.
    if last-of(tgr.tgr) then do:
        put stream m-out " " skip.
        put stream m-out "ИТОГО ПО ГРУППЕ:" skip.
        put stream m-out
            tgr.tgr " "
            "          "
            tempSum
            accum total by tgr.tgr tgr.tfact
            accum total by tgr.tgr tgr.tlibor
            accum total by tgr.tgr tgr.tprib
            accum total by tgr.tgr tgr.tvych skip.
        put stream m-out fill("-", 75) format "x(75)" skip.    
        tempSum = 0.
    end.
end.

put stream m-out "ВСЕГО:   " totAcc " " 
                             totSum 
                             totFact 
                             totLibor 
                             totPrib 
                             totVych skip.
  
end.
else if prz = 1 then do:

put stream m-out skip
FirstLine( 1, 1 ) format 'x(75)' skip(1)
'                        ДЕПОЗИТЫ ФИЗИЧЕСКИХ ЛИЦ,'  skip
'                    ОТСОРТИРОВАННЫЕ ПО СТАВКАМ LIBOR' skip
'                     ЗА ПЕРИОД ' datBeg " - " datEnd skip(1)
FirstLine( 2, 1 ) format 'x(75)' skip.

put stream m-out " " skip.
put stream m-out fill("=", 75) format "x(75)" skip.
put stream m-out 
"СТ. LIBOR      СУММА НА  КОЛ-  НАЧИСЛ.% НАЧИСЛ.%   ЗА СЧЕТ  НА ВЫЧЕТ" skip
"               НАЧАЛО    ВО    ФАКТИЧ.  2-LIBOR    ПРИБЫЛИ" skip.
put stream m-out fill("=", 75) format "x(75)" skip.

put stream m-out
" LGR  LBR        ACC    BAL       FACT      LIBIR      DIFF     PRIB      VYCH     " skip.
for each tgr break by tgr.trtlb by tgr.tacc:

 put stream m-out  skip 
 tgr.tgr ' ' tgr.trtlb  ' '  tgr.tacc ' ' tgr.tbal ' '
                     tgr.tfact  ' '  tgr.tlibor ' ' tgr.tdiff  ' '
                                               tgr.tprib ' ' tgr.tvych ' ' .
    accumulate tgr.tfact (total by tgr.trtlb by tgr.tacc).
    accumulate tgr.tlibor (total by tgr.trtlb by tgr.tacc).
    accumulate tgr.tprib (total by tgr.trtlb by tgr.tacc).
    accumulate tgr.tvych (total by tgr.trtlb by tgr.tacc).
    totFact = totFact + tgr.tfact.
    totLibor = totLibor + tgr.tlibor.
    totPrib = totPrib + tgr.tprib.
    totVych = totVych + tgr.tvych.
    if last-of(tgr.tacc) then do:
        find first c_tgr where c_tgr.tacc = tgr.tacc.
        tempAcc = tempAcc + 1.
        totAcc = totAcc + 1.
        tempSum = tempSum + c_tgr.tbal.
        totSum = totSum + c_tgr.tbal.
    if last-of(tgr.trtlb) then do:
        put stream m-out skip "Total " tgr.trtlb format "->>>9.99"
            tempSum
            tempAcc
            accum total by tgr.trtlb tgr.tfact
            accum total by tgr.trtlb tgr.tlibor
            accum total by tgr.trtlb tgr.tprib
            accum total by tgr.trtlb tgr.tvych skip.
        tempAcc = 0.
        tempSum = 0.
    end.
    end.    
end.
put stream m-out fill("-", 75) format "x(75)" skip.
put stream m-out 
"ИТОГО   " totSum totAcc totFact totLibor totPrib totVych skip.

end.

put stream m-out fill("=", 75) format "x(75)" skip.

output stream m-out close. 
if not g-batch then do:
   pause 0 before-hide.
   run menu-prt('rpt.img').
   pause before-hide.
end.
                                    
{functions-end.i}