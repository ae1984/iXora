/* crmzusrg.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

{mainhead.i}
{lgps.i }
def var k1 as  int.
def var k2  as int.
def var nbank as inte.
def var veids as  log . 
def var nk as inte.
def shared var ddat as date.
def new shared var s-datt as date.
def var vvans as logi initial false format "да/нет".
def new shared var s-num like clrdoc.pr.
def new shared var s-remtrz like remtrz.remtrz.
def shared var vnum like clrdoc.pr init 1.
def  var v_num like clrdoc.pr  init  1.
def new shared var vsum as deci.
def new shared var nsum as deci format "zzz,zzz,zzz,zzz.99".
def var otv as log init false.
def var msgg1 as char initial
"Enter-выбрать;1-печать сводного док.;F4-выход".

def new shared temp-table oree
    field npk as inte format "zz9"
    field cwho as char format "x(8)"
    field quo as inte format "zzz9"
    field kopa as deci format "zzz,zzz,zzz,zzz.99".
def new shared temp-table roree
    field remtrz as char format "x(10)"
    field cwho as char format "x(8)"
    field racc as char format "x(10)"
    field amt as deci index iroree amt.

def var lbnstr as char.    
def var n-ofc as char format "x(30)".

    
ddat = g-today.
clear frame ans.

find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
if not avail sysc then
do:
   v-text  =  " Нет LBNSTR записи в sysc файле ! ".
   run lgps .
   return.
end.
lbnstr = trim(sysc.chval) .


nk = 0.
for each clrdog where clrdog.rdt = ddat and clrdog.pr = vnum no-lock :
  find first remtrz where remtrz.remtrz = clrdog.rem no-lock no-error.
  if avail remtrz then do :
    create roree.
    roree.remtrz = remtrz.remtrz.
    roree.cwho = remtrz.cwho.
    roree.racc = clrdog.tacc.
    roree.amt = remtrz.payment.
    find first oree where oree.cwho = remtrz.cwho no-lock no-error.
    if not avail oree then do :
       create oree.
       nk = nk + 1.
       oree.cwho = remtrz.cwho.
       oree.npk = nk.
    end.
    oree.kopa = oree.kopa + clrdog.amt.
    oree.quo = oree.quo + 1.
    vsum = vsum + clrdog.amt.
    nsum = nsum + 1.
  end.
end.


{jabre.i
&start = " "
&head = "oree"
&headkey = "npk"
&where = "true"
&formname = "uclrdoc"
&framename = "uclrdoc"
&frameparm = "new"
&addcon = "false"
&deletecon = "false"
&prechoose = "message msgg1."
&display = "
oree.npk oree.cwho oree.quo oree.kopa"
&highlight = "oree.npk oree.cwho oree.quo oree.kopa"
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
             run uclrrmz1(oree.cwho).
             pause 0.
             display oree.npk oree.cwho oree.quo oree.kopa 
                     with frame uclrdoc.
             pause 0.        
            end.

            else if keyfunction(lastkey) = '1' then do:
               output to rpt.img.
               put space(10) 
               ' Сводная ведомость платежных документов по контролерам' skip
                 space(30) 'за ' g-today skip(1)
                 '    Контролер' space(26) '     Кол-во       Сумма  ' skip.
              for each oree.
                 find first ofc where ofc.ofc = oree.cwho no-lock no-error.
                 if avail ofc then n-ofc = trim(ofc.name).
                 else n-ofc = ''.
                 put oree.cwho space(2) n-ofc space(4) oree.quo 
                     space(2) oree.kopa skip.
              end.
              put skip(2).
              output close.
              unix silent prit rpt.img.
              pause 0.
            end.
            "
&end = "hide frame uclrdoc. hide frame ans. hide frame dat. hide frame kopp.
hide message. "
}

