/* H11b_ps.p
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

{Hvars_ps.i }
{global.i }
{lgps.i }

def var kn as int .

 kn = 1 .
 repeat while entry(kn,v-info3,"^") <> "" .
  if entry(kn,v-info3,"^") begins "3F:" then do :
   kn = integer(substring(entry(kn,v-info3,"^"),4)) .
   if kn > 8 or kn < 1 or v-date + kn < today then do :
    v-reterr = 1 .
    v-text = "Ошибка ! SQN = " + string(num[1]) + " от " +
    string(num[1]) + v-cif + "." + string(dep-date,"99/99/9999")  + "." + v-ref
    + " некорректный срок действия . " .
   end .
   leave .
  end .
  kn = kn + 1 . 
 end .

 if not v-bank begins "RKB" then do :
  v-text = "Ошибка !!! LASKA SQN = " + string(num[1]) + " от " +
    string(num[1]) + v-cif + "." + string(dep-date,"99/99/9999")  + "." + v-ref
    + " ошибочный банк-получатель " .
  v-reterr = 1 .
  run lgps .
 end .

 find remtrz where remtrz.sbank = ourbank  and
     remtrz.sqn = v-cif + "." + string(dep-date,"99/99/9999") + "."
     + trim(v-ref) + ".1" no-lock no-error .
 if avail remtrz then do:
   v-reterr = 1 .
   v-text = "Дубликат ! SQN = " + string(num[1]) + " from " +
   string(num[1]) + v-cif + "." + string(dep-date,"99/99/9999")  
   + "." + v-ref + " уже зарегистрирован ." .
 end .

if v-reterr eq 0 then do:

find first aaa where aaa.aaa = v-acc no-lock no-error .
if avail aaa then find cif of aaa no-lock no-error .

if not avail cif or not avail aaa or ( v-cif ne cif.cif ) then do:
    v-text = " Ошибка ! SQN = " + string(num[1]) + " от " +
      string(num[1]) +
     v-cif + "." + string(dep-date,"99/99/9999")  + "." + v-ref + " " + v-acc +
    "  код клиента не найден или счет не является счетом клиента или
            более 1 счета клиента ! " .
    v-reterr = 2 .
  end .
  else
  if aaa.crc ne v-crc  then do:
   v-text = "Ошибка ! SQN = " + string(num[1]) + " от " +
   string(num[1]) + v-cif + "." + string(dep-date,"99/99/9999")  + "." + v-ref +
    "  валюта счета :  " +
      string(v-crc) + " " + string(aaa.crc)   +
      " не равна валюте платежа ! " .
      v-reterr = 3.  /* v-crc ne aaa.crc  */  .
  end.
end .

find sysc where sysc.sysc = "othbnk" no-lock no-error .
if avail sysc and sysc.chval ne "" and v-bank ne "" then do:
  if lookup(trim(v-bank),sysc.chval,",") ne 0 then 
   do:
    old-bank = v-bank .
    l-chng = true . 
    v-bank = ourbank.
  end.
  else 
  l-chng = false  .
 end.
 
/*if v-reterr eq 0 and v-bank = ourbank then do:
  find first aaa where aaa.aaa = v-ba no-lock no-error .

  if not avail aaa then do:
    v-text = " Ошибка ! SQN = " + string(num[1]) + " от " +
     string(num[1]) + v-cif + "." + string(dep-date,"99/99/9999")
     + "." + v-ref + " -> " + v-ba +
     " - счет не найден ! " .
    v-reterr = 2 .
  end .
  else
  if aaa.crc ne v-crc  then do:
   v-text = "Ошибка ! SQN = " + string(num[1]) + " от " +
    string(num[1]) +
   v-cif + "." + string(dep-date,"99/99/9999")  + "." + v-ref + " -> " + v-ba +
      "  валюта счета : " +
      string(v-crc) + " " + string(aaa.crc)   +
      " не равна валюте платежа ! " .
      v-reterr = 3.  /* v-crc ne aaa.crc  */  .
  end.
end .*/     /*------because no second account-------*/

if v-reterr gt 0 then

 do :
  run lgps.
  if dep-date = ? then  do:
   v-text = " Ошибка транспортной системы ! (LARC) SQN = " + string(num[1]) .   run lgps.
  return .
  end.
  run ps-rej  ( input
  string(num[1]) + v-cif + "." + string(dep-date,"99/99/9999") + "." + v-ref,
  input string(num[1]), input  tradr , output v-ret ) .
  if v-ret = "1" then return .

 if v-cif = "sharm0" then
  input through
    value( "lget --done " + string(num[1]) + " ; echo $? " ) .
  else
  input through
   value( "lget -q RCVD1 --done " + string(num[1]) + " ; echo $? " ) .

   exitcod = "".
   repeat:
    import exitcod .
   end.
   input close .

    if  exitcod ne "0"  then do:
      v-text = " Ошибка транспортной системы ( LGET DONE ) для " +  
      v-cif + "." + string(dep-date,"99/99/9999")  + "." + v-ref +
       " SQN = " + string(num[1])  .
      run lgps.
     end.

 return .
end.

do on error undo :
 trzerr = false .
  find first sysc where sysc.sysc = "SNIPGL" no-lock
      no-error.
  if not avail sysc then do :
   v-text = "Нет записи SNIPGL в sysc файле ! " .       
   trzerr = true .
   run lgps .
   snpacc = "" .
   snpgl = 0 .
   snpgl2 = 0 .
  end .
  else do :
   snpacc = entry(2,sysc.chval) . 
   find first arp where arp.arp = snpacc no-lock no-error .
   if snpacc <> "" and not avail arp then do :
    v-text = " Ошибка . Не найден " + remtrz.cracc  .       
    trzerr = true .
    run lgps .
   end .
   else if snpacc <> "" and arp.crc <> v-crc then do :
    v-text = "Ошибка ! Валюта " + remtrz.cracc + " " + string(arp.crc)
      + " не соответствует валюте " + remtrz.dracc + string(remtrz.tcrc) .
    trzerr = true .
    run lgps .
   end .
   snpgl = integer(entry(1,sysc.chval)) .
   find first gl where gl.gl = snpgl no-lock no-error .
   if not avail gl then do :
    v-text = "Не найден счет  Г/К "  + string(snpgl) .       
    trzerr = true .
    run lgps .
   end .
  end .
 run H11btrz_ps(1).
 run H11btrz_ps(2).
 if trzerr then do:
  que1.rcod = "2".
  que2.rcod = "2".
 end .
 if not trz2 begins "single" then do :
  find remtrz where remtrz.remtrz = trz2 exclusive-lock .
  remtrz.ref = trz1 + " SNIP tax for cash  " + trz2 .
  v-text = "Автоматическая регистрация платежа " + remtrz.remtrz +
   " <- SQN = " + string(num[1]) +
   " <- " + v-cif  + " " + remtrz.sqn + " тип =" + remtrz.ptype +
   " код завершения = " + que2.rcod +  " -> " + remtrz.rbank .
  run lgps.
 end .
 find remtrz where remtrz.remtrz = trz1 exclusive-lock .
 remtrz.ref = trz2 + " SNIP payment       " + trz1 .
 v-text = "Автоматическая регистрация платежа  " + remtrz.remtrz +
  " <- SQN = " + string(num[1]) +
 " <- " + v-cif  + " " + remtrz.sqn + " тип=" + remtrz.ptype +
  " retcode = " + que1.rcod +  " -> " + remtrz.rbank .
 run lgps.
 ok = true .
end .
