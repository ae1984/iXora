/* trxbal.p
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
        26/11/03 nataly добавлена обработка subledger SCU
        07/03/04 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        01/09/04 sasco русифицировал ошибки
        26/07/2011 madiyar - исключил из проверки на нехватку средств уровни корректировок провизий по кредитам и счет 358000 (прибыли-убытки)
        10/10/2011 madiyar - исключил из проверки на нехватку средств уровень дисконта (42)
        29/12/2011 madiyar - исключил из проверки на нехватку средств уровень амортизации дисконта (31)
*/

def output parameter rcode as inte init 0.
def output parameter rdes as char.
def shared temp-table tmpl like trxtmpl.
def var vamt as deci.
def var errlist as char extent 30.
def var wcamold as deci .
def var wdamold as deci .
def var w-void as deci .
def temp-table wbal
    field gl as inte
    field sub as char
    field acc as char
    field crc as inte
    field lev as inte
    field avl as deci
    field dam as deci
    field cam as deci.
def var vdam as deci.
def var vcam as deci.

errlist[28] = "Нехватка средств.".

for each tmpl where tmpl.drsub <> "" and tmpl.dracc <> ""
                         break by tmpl.drsub by tmpl.dracc:
/*      display tmpl.crc .  pause .   */
   find first wbal where wbal.sub = tmpl.drsub
                        and wbal.acc = tmpl.dracc
                        and wbal.lev = tmpl.dev
                        and wbal.crc = tmpl.crc no-error.
      if not available wbal then do:
        create wbal.
        wbal.gl = tmpl.drgl.
        wbal.sub = tmpl.drsub.
        wbal.acc = tmpl.dracc.
        wbal.lev = tmpl.dev.
        wbal.crc = tmpl.crc.
        run trxsubbal(wbal.sub,wbal.acc,wbal.lev,wbal.crc
                     ,output wbal.dam, output wbal.cam, output wbal.avl).
      end.
end.
for each tmpl where tmpl.crsub <> "" and tmpl.cracc <> ""
                         break by tmpl.crsub by tmpl.cracc:
      find first wbal where wbal.sub = tmpl.crsub
                        and wbal.acc = tmpl.cracc
                        and wbal.lev = tmpl.cev
                        and wbal.crc = tmpl.crc no-error.
      if not available wbal then do:
        create wbal.
        wbal.gl = tmpl.crgl.
        wbal.sub = tmpl.crsub.
        wbal.acc = tmpl.cracc.
        wbal.lev = tmpl.cev.
        wbal.crc = tmpl.crc .
                run trxsubbal(wbal.sub,wbal.acc,wbal.lev,wbal.crc
                     ,output wbal.dam, output wbal.cam, output wbal.avl).
      end.
end.


for each tmpl:
/* Debet turnovers after transaction */
if tmpl.drsub <> "" and tmpl.dracc <> "" then do:
     find first wbal where wbal.sub = tmpl.drsub
                       and wbal.acc = tmpl.dracc
                       and wbal.lev = tmpl.dev
                       and wbal.crc = tmpl.crc .
     wbal.dam = wbal.dam + tmpl.amt.
end. /*DR*/
/*Credit turnovers after transaction */
if tmpl.crsub <> "" and tmpl.cracc <> "" then do:
     find first wbal where wbal.sub = tmpl.crsub
                       and wbal.acc = tmpl.cracc
                       and wbal.lev = tmpl.cev
                       and wbal.crc = tmpl.crc.
     wbal.cam = wbal.cam + tmpl.amt.
 end. /*CR*/
end. /*for each tmpl*/

for each wbal:
 run trxsubbal(wbal.sub,wbal.acc,wbal.lev,wbal.crc
          ,output wdamold, output wcamold, output w-void).

/*  display wbal . pause .   */
  if wbal.sub = "dfb" and wbal.lev = 1 then next.
  if wbal.sub = "lon" and ((wbal.lev = 31) or (wbal.lev = 38) or (wbal.lev = 39) or (wbal.lev = 40) or (wbal.lev = 42)) then next.
  if wbal.gl = 358000 then next.
  find gl where gl.gl = wbal.gl no-lock.
  find first sub-cod where sub-cod.sub = "gld" and
   sub-cod.acc = string(gl.gl) and sub-cod.d-cod = "gldic" and
   sub-cod.ccode = "01" no-lock no-error .
   if  ((gl.type = "L" or gl.type = "R" or gl.type = "O" )
      and not avail sub-cod )
      or (( gl.type = "A" or gl.type = "E") and avail sub-cod)
     then do:
          if wbal.sub = "cif" and wbal.lev = 1 then do:
           if wbal.cam  >= wbal.dam  then next.
           else do:
            if
       /*     wbal.avl + wbal.cam - wbal.dam < 0   */
             wbal.avl + wbal.cam - wbal.dam < 0
            then do:
             rcode = 28.
             rdes = errlist[rcode] + ": " + "Субсчет-" + wbal.sub
                  + ": " + "Уровень-" + string(wbal.lev,"99")
                  + ": " + "Счет-" + wbal.acc.
             return.
            end.
           end.
          end.
          else do:
         if  wbal.cam < wbal.dam then do:
           if wbal.cam - wcamold < wbal.dam - wdamold then do:
            rcode = 28.
            rdes = errlist[rcode] + ": " + "Субсчет-" + wbal.sub
                 + ": " + "Уровень-" + string(wbal.lev,"99")
                 + ": " + "Счет-" + wbal.acc.
             return.
            end.
           end.
          end.
     end.
     if ((gl.type = "A" or gl.type = "E") and not avail sub-cod )
     or  ((gl.type = "L" or gl.type = "R" or gl.type = "O" )
           and avail sub-cod )
     then do:
        if wbal.dam <  wbal.cam then do:
         if wbal.cam - wcamold > wbal.dam - wdamold then do:
           rcode = 28.
           rdes = errlist[rcode] + ": " + "Субсчет-" + wbal.sub
                + ": " + "Уровень-" + string(wbal.lev,"99")
                + ": " + "Счет-" + wbal.acc.
           return.
          end.
        end .
     end.
end.
