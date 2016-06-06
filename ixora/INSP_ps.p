/* INSP_ps.p
 * MODULE
        Обработка РПРО
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Пункт меню
 * AUTHOR
        08/12/2009 galina
 * BASES
        BANK COMM
 * CHANGES
       05/02/2010 galina - убрала параметр РНН и БИК в процедуре MT998h
       12/05/2011 evseev - поиск,  блокирование и наложение арестров через txb
       08/06/2011 evseev - переход на ИИН/БИН
       09/09/2011 evseev - исправил проблему подтягивания города из cmp
       13/12/2011 evseev - изменение в подтягивание города из cmp.
       15/12/2011 evseev - изменение в подтягивание города из cmp.
       05.10.2012 evseev - ТЗ-797
       13.03.2013 evseev - tz-1759

*/

{chbin.i}

def var s-aaa like aaa.aaa no-undo.
def shared var g-today as date.
def shared var g-ofc as char.
def var v-dep like ofchis.depart no-undo.
define var op_kod as char format "x(1)" no-undo.

def buffer b-insin for insin.
def buffer b-ofc for ofc.

def var v-maillist as char no-undo.
def var v-mailmessage as char.
def var v-mailmessage2 as char.
def var v-mailmessage3 as char.
def var v-aaaerr as char.
def var v-aaacls as char.
def var i as integer no-undo.
def var s-ourbank as char no-undo.

def var v-bic as char no-undo.

def var v-bank as char no-undo.
def var v-isfindaaa as logical no-undo.
def var v-sta like aaa.sta no-undo.
def var vbin as char no-undo.
def var v-cifname as char no-undo.
def var v-lgr as char no-undo.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   run savelog( "insps", "INSP_ps: There is no record OURBNK in bank.sysc file!").
   return.
end.
s-ourbank = trim(sysc.chval).

/*find sysc where sysc.sysc = "CLECOD" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   run savelog( "insps", "INSP_ps: There is no record OURBNK in bank.sysc file!").
   return.
end.
v-bic = sysc.chval.*/


run inssts.

v-mailmessage = ''.
v-mailmessage2 = ''.
v-mailmessage3 = ''.

for each insin where insin.bank eq s-ourbank and insin.mnu eq "accept" and insin.stat = 1 no-lock:
    v-aaaerr = ''.
    v-aaacls = ''.
    iik:
    do i = 1 to num-entries(insin.iik):
       run findaaa(entry(i,insin.iik),insin.bank1, output v-bank, output v-isfindaaa, output v-sta, output vbin, output v-cifname, output v-lgr).

       if not v-isfindaaa then do:
          if v-aaaerr <> '' then v-aaaerr = v-aaaerr + ','.
          v-aaaerr = v-aaaerr + entry(i,insin.iik).
          next iik.
       end.
       if (v-sta = "C") or (v-sta = "E") then do:
          if v-aaacls <> '' then v-aaacls = v-aaacls + ','.
          v-aaacls = v-aaacls + entry(i,insin.iik).
          run MT998h(entry(i,insin.iik)).
          next iik.
       end.

       if insin.stat eq 1 then do:
           find first b-ofc where b-ofc.ofc = g-ofc no-lock.
           run creaasofins(insin.ref, entry(i,insin.iik), v-bank, b-ofc.regno).


           if lookup (v-lgr , "138,139,140,143,144,145") > 0 then do:
               run mail("DPC@fortebank.com", "METROCOMBANK <abpk@fortebank.com>", "Прием РПРО ",
                   insin.filename + " Расп.=" + string(insin.numr) + " БИН=" + insin.clbin + " счет=" + entry(i,insin.iik)
                   , "1", "", "").
           end.
           if insin.type = 'AC' then do:
              if v-mailmessage <> '' then v-mailmessage = v-mailmessage + "\n\n".
              if v-bin then v-mailmessage = v-mailmessage + insin.filename + " Расп.=" + string(insin.numr) + " БИН=" + insin.clbin + " счет=" + entry(i,insin.iik).
              else v-mailmessage = v-mailmessage + insin.filename + " Расп.=" + string(insin.numr) + " РНН=" + insin.clrnn + " счет=" + entry(i,insin.iik).
           end.
           if insin.type = 'ACP' then do:
              if v-mailmessage2 <> '' then v-mailmessage2 = v-mailmessage2 + "\n\n".
              if v-bin then v-mailmessage2 = v-mailmessage2 + insin.filename + " Расп.=" + string(insin.numr) + " БИН=" + insin.clbin + " счет=" + entry(i,insin.iik).
              else v-mailmessage2 = v-mailmessage2 + insin.filename + " Расп.=" + string(insin.numr) + " РНН=" + insin.clrnn + " счет=" + entry(i,insin.iik).
           end.
           if insin.type = 'ASD' then do:
              if v-mailmessage3 <> '' then v-mailmessage3 = v-mailmessage3 + "\n\n".
              if v-bin then v-mailmessage3 = v-mailmessage3 + insin.filename + " Расп.=" + string(insin.numr) + " БИН=" + insin.clbin + " счет=" + entry(i,insin.iik).
              else v-mailmessage3 = v-mailmessage3 + insin.filename + " Расп.=" + string(insin.numr) + " РНН=" + insin.clrnn + " счет=" + entry(i,insin.iik).
           end.
       end.
    end. /*do i*/
    do transaction:
    find first b-insin where b-insin.ref = insin.ref exclusive-lock no-error.
    if avail b-insin then do:
      assign b-insin.clsaaa = v-aaacls
             b-insin.erraaa = v-aaaerr.
      find current b-insin no-lock.
    end.
    end.
end.

def var v-city as char.
if v-mailmessage <> '' then do:
    v-maillist = ''.
    find first sysc where sysc.sysc = "inkmail" no-lock no-error.
    if avail sysc and trim(sysc.chval) <> '' then do:
        do i = 1 to num-entries(sysc.chval):
            if trim(entry(i,sysc.chval)) <> '' then do:
                if v-maillist <> '' then v-maillist = v-maillist + ','.
                v-maillist = v-maillist + trim(entry(i,sysc.chval)) + "@fortebank.com".
            end.
        end. /* do i = 1 */
        if v-maillist <> '' then do:
            find first cmp no-lock no-error.
            if avail cmp then do:
               v-city = "".
               if entry(2,cmp.addr[1]) matches "*г.*" then v-city = entry(2,cmp.addr[1]).
                  else if entry(3,cmp.addr[1]) matches "*г.*" then v-city = entry(3,cmp.addr[1]).
               v-mailmessage = v-city + "\n\n" + v-mailmessage.
               run mail(v-maillist, "METROCOMBANK <abpk@fortebank.com>", "Прием распоряжений о приост. расх. опер. налогопл. " + v-city, v-mailmessage, "1", "", "").
            end.
        end.
    end.
end.

if v-mailmessage2 <> '' then do:
    v-maillist = ''.
    find first sysc where sysc.sysc = "inkmail" no-lock no-error.
    if avail sysc and trim(sysc.chval) <> '' then do:
        do i = 1 to num-entries(sysc.chval):
            if trim(entry(i,sysc.chval)) <> '' then do:
                if v-maillist <> '' then v-maillist = v-maillist + ','.
                v-maillist = v-maillist + trim(entry(i,sysc.chval)) + "@fortebank.com".
            end.
        end. /* do i = 1 */
        if v-maillist <> '' then do:
            find first cmp no-lock no-error.
            if avail cmp then do:
               v-city = "".
               if entry(2,cmp.addr[1]) matches "*г.*" then v-city = entry(2,cmp.addr[1]).
                  else if entry(3,cmp.addr[1]) matches "*г.*" then v-city = entry(3,cmp.addr[1]).

               v-mailmessage2 = v-city + "\n\n" + v-mailmessage2.
               run mail(v-maillist, "METROCOMBANK <abpk@fortebank.com>", "Прием распоряжений о приост. расх. опер. ОПВ " + v-city, v-mailmessage2, "1", "", "").
            end.
        end.
    end.
end.

if v-mailmessage3 <> '' then do:
    v-maillist = ''.
    find first sysc where sysc.sysc = "inkmail" no-lock no-error.
    if avail sysc and trim(sysc.chval) <> '' then do:
        do i = 1 to num-entries(sysc.chval):
            if trim(entry(i,sysc.chval)) <> '' then do:
                if v-maillist <> '' then v-maillist = v-maillist + ','.
                v-maillist = v-maillist + trim(entry(i,sysc.chval)) + "@fortebank.com".
            end.
        end. /* do i = 1 */
        if v-maillist <> '' then do:
            find first cmp no-lock no-error.
            if avail cmp then do:
               v-city = "".
               if entry(2,cmp.addr[1]) matches "*г.*" then v-city = entry(2,cmp.addr[1]).
                  else if entry(3,cmp.addr[1]) matches "*г.*" then v-city = entry(3,cmp.addr[1]).

               v-mailmessage3 = v-city + "\n\n" + v-mailmessage3.
               run mail(v-maillist, "METROCOMBANK <abpk@fortebank.com>", "Прием распоряжений о приост. расх. опер. СО " + v-city, v-mailmessage3, "1", "", "").
            end.
        end.
    end.
end.


/* Обработка принятых отзывов */
run insrecblk.

