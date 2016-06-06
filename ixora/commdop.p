/* commdop.p
 * MODULE
        Платежная система
 * DESCRIPTION
        I-шка предназначена для снятия дополнительной комиссии
 * RUN
        isrmgnt.p
 * CALLER
        isrmgnt.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-3-1
 * AUTHOR
        10.08.2005 saltanat 
 * CHANGES
*/
{global.i}

def input parameter rmz like remtrz.remtrz.
def input parameter kod as char.
def output parameter v-sumkom as decimal.
def output parameter v-gl as char.

def var v-summin as deci.
def var v-summax as deci.
def var v-uslug as char format "x(4)".
def var pakal like tarif2.pakalp.
def var kods like remtrz.svccgl .
def var tv-cif like aaa.cif .
def var lbnstr as cha . 
def var v-aaa like aaa.aaa init ''.

find first sysc where sysc.sysc = "LBNSTR" no-lock no-error . 
if avail sysc then lbnstr = sysc.chval . 

  find first remtrz where remtrz.remtrz = rmz exclusive-lock .
   v-sumkom = 0 .
   do on error undo,retry :
   v-uslug = kod.
   if kod ne '0' then do:
    find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = kod
                        and tarif2.stat = 'r' no-lock no-error .
    if not avail tarif2 then undo,retry .
    
    v-gl = string(tarif2.kont).
    if not (remtrz.dracc = lbnstr or remtrz.info[2] = lbnstr) then do:
       if string(remtrz.drgl) begins '1411' or
          string(remtrz.drgl) begins '1414' or
          string(remtrz.drgl) begins '1417' then do.
           find first lon where lon.lon = remtrz.dracc no-lock no-error.
           if  avail lon then tv-cif = lon.cif .
           else tv-cif = "" .
       end .
       else do.   
           find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
           if  avail aaa then do: tv-cif = aaa.cif . v-aaa = aaa.aaa. end.
           else tv-cif = "" .
       end . 
    end.
    else do:
        if string(remtrz.crgl) begins '1411' or
           string(remtrz.crgl) begins '1414' or
           string(remtrz.crgl) begins '1417' then do.
            find first lon where lon.lon = remtrz.dracc no-lock no-error.
            if  avail lon then tv-cif = lon.cif .
            else tv-cif = "" .
         end .
         else do.
           find first aaa where aaa.aaa = remtrz.cracc no-lock no-error.
           if  avail aaa then do: tv-cif = aaa.cif . v-aaa = aaa.aaa. end.
           else tv-cif = "" .
         end.
    end.     
    run perev2 (input v-aaa,
                input v-uslug, 
                input remtrz.payment, 
                input remtrz.tcrc,
                input remtrz.svcrc, 
                input tv-cif, 
                OUTPUT v-sumkom, 
                OUTPUT kods , 
                OUTPUT pakal, 
                output v-summin, 
                output v-summax).
    end.
   end.
