/* rptkas2.p
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

/*rptkas.p*/

{global.i}
def temp-table wt
    field sim as char
    field acc as char format 'x(9)'
    field crc like crc.crc
    field dam like jl.dam
    field cam like jl.cam
    field rem like jl.rem[1]
    index wt is primary crc sim.

def temp-table wt1
    field sim as char
    field dam like jl.dam
    field cam like jl.cam
    index wt is unique sim.

def buffer bjl for jl.

def var v-rptfrom as date /*initial 01/01/00*/ .
def var v-rptto as date /*initial   01/10/00*/ .
def stream s-err .

/*{image1.i rpt.img}*/

v-rptfrom = g-today - 1.
v-rptto  = g-today.
                 
update v-rptfrom label "Дата с " v-rptto label " по "
with row 9 side-labels no-box centered.

output stream s-err to kasplan.err.

{image1.i rpt.img}
{image2.i}

{report1.i 66}
vtitle= "".
{report2.i 97
"'КАССОВЫЙ ОТЧЕТ (СИМВОЛЫ КАСПЛАНА)'   skip
   fill('=',97) format 'x(97)' skip "}
  
put "Дата " v-rptfrom " - " v-rptto skip.
put "СИМВОЛ             НАИМЕНОВАНИЕ/СЧЕТ/ТРАНЗКАКЦИЯ ".
put fill(' ',35) format 'x(35)' "ДЕБЕТ                 КРЕДИТ"  skip.

for each jl where jl.jdt ge v-rptfrom and jl.jdt le v-rptto no-lock :
    find first jlsach where jlsach.jh eq jl.jh and jlsach.ln eq jl.ln no-lock
    no-error.
    if not available jlsach then do:
        if jl.gl eq 100100 then do:
            find wt where wt.crc eq jl.crc and wt.sim eq jl.trx no-error.
            if not available wt then do:
                create wt.
                wt.sim = jl.trx.  
                wt.crc = jl.crc.
            end.
            wt.dam = wt.dam + jl.dam.
            wt.cam = wt.cam + jl.cam.
            
            put stream s-err unformatted 
            jl.jh format ">>>>>>>9" " " jl.ln " " jl.crc " " jl.dam " " jl.cam 
            " " jl.trx skip.
            
        end.
    end.  
      
    for each jlsach where jlsach.jh eq jl.jh and jlsach.ln eq jl.ln no-lock :
            create wt.
            find first bjl where bjl.jh = jlsach.jh and bjl.acc <> "" no-lock no-error.
            if available bjl then wt.acc = bjl.acc. else wt.acc = string(jlsach.jh).
            wt.sim = string(jlsach.sim).  
            wt.crc = jl.crc. 
        if jl.dc eq "D" then   wt.dam = jlsach.amt.
        else wt.cam = jlsach.amt. wt.rem = jl.rem[1].
    end.

end.  /*jl*/

for each wt no-lock break by wt.crc  by wt.sim:
    find last crchis where crchis.crc eq wt.crc and crchis.rdt le v-rptto
    no-lock no-error.
  
    ACCUMULATE wt.dam (total by  wt.sim by wt.crc).
    ACCUMULATE wt.cam (total by  wt.sim by wt.crc).

    if first-of(wt.crc) then do:
        put  skip(1) crchis.des skip(2).
    end.
    put skip wt.sim " " fill(" ",41)   wt.acc
     wt.dam format ">>>,>>>,>>>,>>>,>>9.99-" at 50 
     wt.cam format ">>>,>>>,>>>,>>>,>>9.99-"  at 75 wt.rem.

    if last-of(wt.sim) then do:
     find cashpl where cashpl.sim eq integer(wt.sim) no-lock no-error.
     put skip wt.sim " ".
     if available cashpl then put cashpl.des format "x(40)" " ".
     else put fill(" ",41).
     put   ACCUMulate total  by (wt.sim) wt.dam  format ">>>,>>>,>>>,>>>,>>9.99-"  at 50
     ACCUMulate total  by (wt.sim) wt.cam format ">>>,>>>,>>>,>>>,>>9.99-" at 75 skip .
    end.
end.

output stream s-err close.
{report3.i}
{image3.i}


 
                
            
