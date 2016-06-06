/* tdainfo1.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Просмотр состояния счета TDA
 * RUN
        вызов из списка счетов по типу TDA
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        10-7-3, 1-1, 1-2
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        20.05.2004 nadejda - добавлен просмотр признака исключения по % ставке
                             добавлен параметр номера счета в вызов tdagetrate
        10.01.2005 dpuchkov - добавил параметр K (информация о пролонгации)
        25.02.2005 dpuchkov - теперь отображается ставка из ааа.rate
        11.04.2006 dpuchkov - добавил отображение информации для новой звезды
        25/09/2008 galina - перекомпеляция в связи с изменениями tdainfo.f
        29/09/2008 galina - перекомпеляция в связи с изменениями tdainfo.f
        29/12/2010 evseev - заремил v-paynow в форме, т.к. расчитывается неверно.
        25.04.2011 ruslan - добавил P - % за каждый день
*/


def input parameter in-aaa as char.

def shared var g-today as date.


{tdainfo.f}

vaaa = in-aaa.


view frame tda0.
view frame tda1.
view frame tda2.

find aaa where aaa.aaa = vaaa no-lock no-error.
if not available aaa then do:
   message "Счет " vaaa " не существует." view-as alert-box title "".
   undo, return.
end.
find lgr where lgr.lgr = aaa.lgr no-lock.
if lgr.led <> "TDA" then do:
   message "Счет не является счетом срочного депозита типа TDA."
     view-as alert-box title "".
   undo, return.
end.
/*if aaa.sta = "C" or aaa.sta = "E" then do:
   message "Закрытый счет." view-as alert-box title "".
   undo, return.
end.
*/
find cif where cif.cif = aaa.cif no-lock.
find crc where crc.crc = aaa.crc no-lock.

if aaa.cr[1] > 0 then vopnamt = aaa.opnamt.
else vopnamt = 0.
find aas where aas.aaa = aaa.aaa and aas.ln = 7777777 no-lock no-error.
if available aas then currentbase = aas.chkamt.
else currentbase = 0.
capitalized = aaa.stmgbal.
adddepos = currentbase - vopnamt - capitalized.
if adddepos < 0 then adddepos = 0.

if lgr.feensf <> 2 and lgr.feensf <> 5 then do:
  intavail = aaa.cr[1] - aaa.dr[1] - currentbase.
  intpaid = aaa.dr[2] - intavail - capitalized.

  if intpaid < 0 then do:
     intpaid = aaa.dr[1].
  end.

end.

else do: /* для депозитов типа резервный */
 intavail = aaa.cr[1] - aaa.dr[1] - aaa.hbal.
 intpaid = aaa.dr[1] .
end.
vterm = aaa.expdt - g-today /*+ 1*/.
/*if vterm < 0 then vterm = 0.*/
vday  = aaa.expdt - aaa.regdt.
if g-today < aaa.expdt /*+ 1*/ then
v-paynow = aaa.cr[1] - aaa.dr[1] + aaa.cr[2] - aaa.dr[2] - aaa.accrued.
else
v-paynow = aaa.cr[1] - aaa.dr[1] + aaa.cr[2] - aaa.dr[2].

if aaa.payfre = 1 then v-excl = "!".
/*
if aaa.sta = "M" then do:

   find sysc where sysc = "bsrate" no-lock no-error.
   if available sysc then intrat = sysc.deval.
   else intrat = 0.
end.
else run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, aaa.nextint, currentbase, output intrat).
*/
   intrat = aaa.rate.

if g-today < aaa.expdt /*+ 1*/ then do:
   v-pay = aaa.cr[1] - aaa.dr[1] + aaa.cr[2] - aaa.dr[2].
   if lgr.intcal <> "S" and lgr.intcal <> "N" then
   v-pay = v-pay + aaa.m10 + (aaa.expdt - g-today /*+ 1*/) * currentbase * intrat / aaa.base / 100.
   else if lgr.intcal = "S" and aaa.lstmdt = g-today and aaa.cr[2] = 0 then
   v-pay = v-pay + (aaa.expdt - aaa.lstmdt /*+ 1*/) * currentbase * intrat / aaa.base / 100.
end.
else
   v-pay = v-paynow.

display vaaa caps(aaa.cif) @ aaa.cif trim(trim(cif.prefix) + " " + trim(cif.name)) @ cif.name
        crc.code aaa.sta aaa.pri lgr.lgr lgr.des aaa.lstmdt aaa.expdt
        /*aaa.cla*/ vday vterm /*v-paynow*/ v-pay with frame tda0.
display vopnamt adddepos capitalized currentbase with frame tda1.
display intrat v-excl aaa.accrued intpaid intavail with frame tda2.

hotkeys:
repeat:

find last lgr where lgr.lgr = aaa.lgr no-lock no-error.
if avail lgr then do:
 if lgr.feensf = 5 then
    message "T - проводки, H - история % ставки, I - таблица %, E - см.исключ-е, P - % за каждый день                   K - пролонгация, F4 - выход".
 else
    message "T - проводки, H - история % ставки, I - таблица %, E - см.исключ-е, P - % за каждый день, F4 - выход".
end.
else
    message "T - проводки, H - история % ставки, I - таблица %, E - см.исключ-е, P - % за каждый день, F4 - выход".

   readkey.
   if keyfunction(lastkey) = 'T' then do:
      if available aaa then run tdajlhist(aaa.aaa).
      readkey pause 0.
   end.
   if keyfunction(lastkey) = 'H' then do:
      find lgr where lgr.lgr = aaa.lgr no-lock.

      if available aaa and (lgr.feensf <> 3 and lgr.feensf <> 5 and lgr.feensf <> 9) then run tdaaabhist(aaa.aaa).
      if available aaa and (lgr.feensf = 3  or lgr.feensf = 5 or lgr.feensf = 9) then run histrez(aaa.aaa).

      readkey pause 0.
   end.
   if keyfunction(lastkey) = 'I' then do:
      if available aaa then run tdainthist(aaa.pri).
      readkey pause 0.
   end.
   if keyfunction(lastkey) = 'E' then do:
      if available aaa then run tdaexhist (aaa.aaa).
      readkey pause 0.
   end.
   if keyfunction(lastkey) = 'P' then do:
      if available aaa then run p_show (aaa.aaa).
      readkey pause 0.
   end.
   if keyfunction(lastkey) = 'K' then do:
       find sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = aaa.aaa and sub-cod.d-cod = 'prlng' no-lock no-error.
       if avail sub-cod and (sub-cod.ccod = 'yes' or sub-cod.ccod = 'done') then do:
          message skip " Депозит" aaa.aaa "пролонгируется автоматически! " skip(1) view-as alert-box title "".
       end.
       else
          message skip " Депозит" aaa.aaa "не пролонгируется! " skip(1) view-as alert-box title "".

       readkey pause 0.
   end.

   else if keyfunction(lastkey) = 'end-error' then do:
      leave hotkeys.
   end.
end.

