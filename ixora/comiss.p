/* comiss.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/

/* comiss.p
   комиссия при проведении внешних платежей
   изменения от 13.03.2001
   - учет ссудных счетов для поиска льгот по комиссии
*/   
def shared var s-remtrz like remtrz.remtrz .
def var v-sumkom like remtrz.svca.
def var v-uslug as char format "x(10)".
def var pakal like tarif2.pakalp.
def var kods like remtrz.svccgl .
def var tv-cif like aaa.cif .
def var lbnstr as cha . 
def var v-aaa as char.
find first sysc where sysc.sysc = "LBNSTR" no-lock no-error . 
if avail sysc then lbnstr = sysc.chval . 

  find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock .
   v-sumkom = remtrz.svca .
   do on error undo,retry :
   v-uslug = string(remtrz.svccgr).
   if remtrz.svccgr ne 0 then do:
    find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(remtrz.svccgr) 
                        and tarif2.stat = 'r' no-lock no-error .
    if not avail tarif2 then undo,retry .
    
    if not (remtrz.dracc = lbnstr or remtrz.info[2] = lbnstr) then do:
       if string(remtrz.drgl) begins '1411' or
          string(remtrz.drgl) begins '1414' or
          string(remtrz.drgl) begins '1417' then do.
           find first lon where lon.lon = remtrz.dracc no-lock no-error.
           if  avail lon then  tv-cif = lon.cif . 
           else tv-cif = "" .
           v-aaa = ''.
       end .
       else do.   
           find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
           if  avail aaa then do: tv-cif = aaa.cif . v-aaa = aaa.aaa. end.
           else do: tv-cif = "" . v-aaa = ''. end.
       end . 
    end.
    else do:
        if string(remtrz.crgl) begins '1411' or
           string(remtrz.crgl) begins '1414' or
           string(remtrz.crgl) begins '1417' then do.
            find first lon where lon.lon = remtrz.dracc no-lock no-error.
            if  avail lon then tv-cif = lon.cif .
            else tv-cif = "" .
            v-aaa = ''.
         end .
         else do.
           find first aaa where aaa.aaa = remtrz.cracc no-lock no-error.
           if  avail aaa then do: tv-cif = aaa.cif . v-aaa = aaa.aaa. end.
           else do: tv-cif = "" . v-aaa = ''. end.
         end.
    end.     
    run perev (input v-aaa, input v-uslug, input remtrz.payment, input remtrz.tcrc,
     input remtrz.svcrc, input tv-cif, OUTPUT v-sumkom, OUTPUT kods , OUTPUT
     pakal).
     remtrz.svccgl = kods .
     remtrz.svca = v-sumkom .
/*
     display remtrz.svccgl pakal with frame remtrz .
*/
    end.
   end.
