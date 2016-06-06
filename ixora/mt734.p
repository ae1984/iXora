/* mt734.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        MT734
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        25/02/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
        04/08/2011 id00810 - {cr-swthead.i} формирование заголовка сообщения
        13/09/2011 id00810 - обработка ошибки копирования в SWIFT
        10/02/2012 id00810 - определение каталога swift через функцию get-path
        20/04/2012 id00810 - перекомпиляция в связи с изменением cr-swthead.i
        24/04/2012 evseev - изменения в .i
*/

{global.i}
def shared var s-lc like LC.LC.
def shared var s-number like lcevent.number.
def shared var s-event like lcevent.event.

def var v-bank   as char no-undo.
def var s-value1 as char no-undo.
def var v-file0  as char no-undo init 'MT734'.
def var v-result as char no-undo.
def var k        as int  no-undo.
def var i        as int  no-undo.
def var v-swt    as char no-undo.
def stream out.

{cr-swthead.i}

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   message " There is no record OURBNK in bank.sysc file!" view-as alert-box error.
   return error.
end.
v-bank = trim(sysc.chval).

v-swt = get-path('swtpath').

find first lceventh where lceventh.bank = v-bank and lceventh.lc = s-lc and  lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = "SendTRN734" and lceventh.value1 <> '' no-lock no-error.
if avail lceventh and trim(lceventh.value1) <> '' then s-value1 = replace(lceventh.value1,"/", "_") + "_" + s-event + string(s-number,'999').

output stream out to value(v-file0).

find first lceventh where lceventh.bank = v-bank and lceventh.lc = s-lc and  lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = "InstTo734" no-lock no-error.
if avail lceventh and trim(lceventh.value1) <> '' then put stream out unformatted cr-swthead ('734',trim(lceventh.value1)).

put stream out unformatted '\{4:' skip.
put stream out unformatted ':20:'.
find first lceventh where lceventh.bank = v-bank and lceventh.lc = s-lc and  lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = "SendTRN734" no-lock no-error.
if avail lceventh and trim(lceventh.value1) <> '' then put stream out unformatted caps(lceventh.value1) skip.

put stream out unformatted ':21:'.
find first lceventh where lceventh.bank = v-bank and lceventh.lc = s-lc and  lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = "PrBnkRef734" no-lock no-error.
if avail lceventh and trim(lceventh.value1) <> '' then put stream out unformatted caps(lceventh.value1) skip.

 put stream out unformatted ":32A:".
 find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'DtUtil734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
 if avail LCeventh then put stream out unformatted datestr(LCeventh.value1) .
 find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'CurUtil734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
 if avail LCeventh then do:
     find first crc where crc.crc = int(LCeventh.value1) no-lock no-error.
     if avail crc then put stream out unformatted crc.code.
 end.
 find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'AmtUtil734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
 if avail LCeventh then put stream out unformatted trim(replace(string(deci(LCeventh.value1),'>>>>>>>>9.99'),'.',',')) skip.

  find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'ChCl734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
  if avail LCeventh and trim(LCeventh.value1) <> '' then do:
      put stream out unformatted ':73:'.
      k = length(LCeventh.value1).
      i = 1.
      repeat:
          put stream out unformatted caps(trim(substr(LCeventh.value1,i,35))) SKIP.
          k = k - 35.
          if k <= 0 then leave.
          i = i + 35.
      end.
  end.

  find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'TotAmtClO734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
  if avail LCeventh and trim(LCeventh.value1) <> '' then do:
     put stream out unformatted ':33' + trim(LCeventh.value1) + ':'.
     if trim(LCeventh.value1) = 'A' then do:
        find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'DtTtAmtCl734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
        if avail LCeventh then put stream out unformatted datestr(LCeventh.value1) .
     end.
     find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'CurTtAmtCl734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
     if avail LCeventh then do:
        find first crc where crc.crc = int(LCeventh.value1) no-lock no-error.
        if avail crc then put stream out unformatted crc.code.
     end.
     find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'TtAmtCl734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
     if avail LCeventh then put stream out unformatted trim(replace(string(deci(LCeventh.value1),'>>>>>>>>9.99'),'.',',')) skip.

  end.

  find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'AccWBnkA734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
  if avail LCeventh and trim(LCeventh.value1) <> '' then do:
     put stream out unformatted ':57a:' skip.
     put stream out unformatted '/' + LCeventh.value1 skip.
     find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'AccWBnkB734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
     if avail LCeventh then put stream out unformatted LCeventh.value1 skip.
  end.

  find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'S2RInf734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
  if avail LCeventh and trim(LCeventh.value1) <> '' then do:
      put stream out unformatted ':72:'.
      k = length(LCeventh.value1).
      i = 1.
      repeat:
          put stream out unformatted caps(trim(substr(LCeventh.value1,i,35))) SKIP.
          k = k - 35.
          if k <= 0 then leave.
          i = i + 35.
      end.
  end.

 put stream out unformatted ':77J:' skip.
 find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'Disc734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
  if avail LCeventh and trim(LCeventh.value1) <> '' then do:
      k = length(LCeventh.value1).
      i = 1.
      repeat:
          put stream out unformatted caps(trim(substr(LCeventh.value1,i,35))) SKIP.
          k = k - 35.
          if k <= 0 then leave.
          i = i + 35.
      end.
  end.

put stream out unformatted ':77B:'.
find first LCeventh where lceventh.bank = v-bank and LCeventh.lc = s-lc and LCeventh.kritcode = 'DisOfDoc734' and LCeventh.event = s-event and LCeventh.number = s-number no-lock no-error.
if avail LCeventh then put stream out unformatted '/' + LCeventh.value1 + '/' skip.

put stream out unformatted "-}".
output stream out close.

unix silent value("un-win1 " + v-file0 + " " + s-value1).

unix silent cptwin value(s-value1) notepad.

v-result = ''.
input through value ("scp -i $HOME/.ssh/id_swift -o PasswordAuthentication=no " + s-value1 + " " + v-swt + ";echo $?").
repeat:
    import unformatted v-result.
end.
if v-result <> "0" then do:
    message skip "Произошла ошибка при копировании файла " s-value1 " в SWIFT Alliance." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".
    unix silent rm -f value (s-value1).
    unix silent rm -f value (v-file0).
    return error.
end.

v-result = ''.
input through  value("cp " + s-value1 + " /data/export/mt734;echo $?").
repeat:
    import unformatted v-result.
end.
if v-result <> "0" then
message "Произошла ошибка при копировании файла" s-value1 " в архив /data/export/mt734." skip(1) "Код ошибки " v-result view-as alert-box buttons ok title " ОШИБКА ! ".

unix silent rm -f value (s-value1).
unix silent rm -f value (v-file0).
