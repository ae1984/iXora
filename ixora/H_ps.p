/* H_ps.p
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
        18.12.2005 tsoy     - добавил время создания платежа.

*/


{Hvars_ps.i "NEW" }

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

{global.i }
{lgps.i }
{rmz.f}
v-text = "" .


  /*
    m_pid = "H10".
    u_pid = "HOME".
  */


find sysc where sysc.sysc = "clcen" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет CLGEN записи в sysc файле ! ".
 run lgps.
 return .
end.
clecod = sysc.chval.
find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
if not avail sysc then
  do:
       v-text  =  " Нет LBNSTR записи в sysc файле ! ".
       run lgps .
       return.
 end.
 lbnstr = sysc.chval .


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет OURBNK записи в sysc файле ! ".
 run lgps.
 return .
end.
ourbank = sysc.chval.

if clecod ne ourbank then brnch = yes.

find first bankl where bankl.bank = ourbank no-lock .

find sysc where sysc.sysc = "PS_ERR" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет PS_ERR записи в sysc файле ! ".
 run lgps.
 return .
end.
 v-err = sysc.chval.

if v-cif = "sharm0" then
input through value("lget 10E 10B 11B; echo $? ") .          /*  !!!!!!!!!!!!!!
*/  else
input through value("lget -i H_PS -q RCVD1 10B 10E 11B; echo $?
") . /*  !!!!!!!!!!!!!! */

num = "".
repeat:
  import num  .
  leave .
end.

if  num[1]  = "0"
 then do:
 /*
  v-text = " QUEUE is EMPTY ... " .
  run lgps.
 */
  return .
 end.

exitcod = "".
repeat:
  import exitcod  .
end.

   fou = false .
   do i = 1 to length(num[1]) .
      if substr(num[1],i,1) > "9" or substr(num[1],i,1) <  "0"
       then do: fou = true . leave . end .
   end.

  if not fou then
  do i = 2 to 100 .
   if num[i] ne ""  then
   do: fou = true . leave . end .
  end.


if  ( exitcod ne "0" ) or fou
 then do:
  do i = 1 to 100 .
   if num[i] ne "" then
   v-text = v-text + " " + num[i]  .
  end.
  v-text = " Ошибка транспортной системы ! (LGET) " + v-text .
  run lgps.
  return .
 end.


input close .

/*        Defaulting         */

v-pri = "n".
v-chg = "BEN".

input through value("larc -F s -s " + string(num[1] ) ) .

import unformatted v-field[1].
m-typ = substr(v-field[1],34,3).
v-info3 = m-typ + "^" .
repeat :
v-field = "".
import unformatted v-field[1] .

if not ( v-field[1] begins ":") and not ( blok4 or blokA ) then next .
 blok4 = true .
 if v-field[1] matches "*\{A:*" then do: blokA = true . rep = "0" . end .
 if v-field[1] begins ":" then do: rep = "0" . irep = 0 . end .
 i = 0 .
 v-string = "".
 repeat:
  i = i + 1 . if i > 50 then leave .
  if v-field[i] = "" then next .
  v-string = v-string + v-field[i] + " " .
 end.

 if v-string begins ":20:" then v-ref = substr(v-string,5) .
  else
 if v-string begins ":3d:" then
  v-date = date(int(substr(v-string,7,2)), int(substr(v-string,9,2)),
  int( substr(string(year(today)),1,2) +
  substr(v-string,5,2))) .
 else
 if v-string begins ":3c:" then do:
   tmp = (substr(v-string,5)) .
   if tmp = "lvl" then tmp = "ls" .
   find first crc where crc.code = tmp no-lock no-error .
   if not avail crc then  v-crc = 0 .
   else v-crc = crc.crc .
  end .
 else
 if v-string begins ":3a:" then do:
   tmp = (substr(v-string,5)) .
   overlay (tmp,index(tmp,",")) = "." .
   v-amt = decimal(tmp).
 end.
 else
 if v-string begins ":50:" or rep = "50" then do:
   if rep = "0" then do: rep = "50" .
          v-ord  = (substr(v-string,5)) .
    end .
    else
    v-ord  = substr(v-ord,1,length(v-ord) - 1) + " " + v-string .
 end.
 else
 if v-string begins ":5a:" then v-acc = substr(v-string,5) .
 else
 if v-string begins ":6a:" or rep = "6a" then do:
   if rep = "0" then do: rep = "6a" .
       v-intmed  = (substr(v-string,5)) .
    end .
    else
    v-intmed  = substr(v-intmed,1,length(v-intmed) - 1) + " " + v-string .
 end.
 else
 if v-string begins ":6b:" then v-intmedact = substr(v-string,5) .
 else
 if v-string begins ":6c:" then v-intmedact = v-intmedact +
  " " + substr(v-string,5) .
 else
 if v-string begins ":6d:" then v-intmedact = v-intmedact +
  " " + substr(v-string,5) .
 else
 if v-string begins ":6e:" then v-intmedact = v-intmedact +
  " " + substr(v-string,5) .
 else
 if v-string begins ":6f:" then v-intmedact = v-intmedact +
  " " + substr(v-string,5) .
 else
 if v-string begins ":7a:" or rep = "7a" then do:
   if rep = "0" then do: rep = "7a" .
       v-bb  = (substr(v-string,5)) .
    end .
    else
    v-bb  = substr(v-bb,1,length(v-bb) - 1) + " " + v-string .
 end.
 else
 if v-string begins ":7b:" then v-bb  = v-bb + " " + substr(v-string,5) .
 else
 if v-string begins ":7c:" then v-bb  = v-bb + " " + substr(v-string,5) .
 else
 if v-string begins ":7d:" then v-bb  = v-bb + " " + substr(v-string,5) .
 else
 if v-string begins ":7e:" then v-bb  = v-bb + " " + substr(v-string,5) .
 else
 if v-string begins ":7f:" then v-bb  = v-bb + " " + substr(v-string,5) .
 else
 if v-string begins ":9a:" or rep = "9a" then do:
   if rep = "0" then do: rep = "9a" .
          v-ben  = (substr(v-string,5)) .
    end .
    else
     v-ben = substr(v-ben,1,length(v-ben) - 1) + " " + v-string .
    end.
 else
 if v-string begins ":9b:" then v-ba = substr(v-string,5) .
 else
 if v-string begins ":70:" or rep = "70" then do:
   if rep = "0" then do: rep = "70" .
          v-det  = (substr(v-string,5)) .
    end .
    else
    v-det = substr(v-det,1,length(v-det) - 1) + " " + v-string .
 end.
 else
 if v-string begins ":70A:" or rep = "70A" then do:
   if rep = "0" then do: rep = "70A" .
         v-det  = (substr(v-string,5)) .
    end .
    else
    v-det = substr(v-det,1,length(v-det) - 1) + " " + v-string .
 end.
 else
 if v-string begins ":71A:" then v-chg = substr(v-string,6) .
  else
 if v-string begins ":f5:" then
  dep-date = date(int(substr(v-string,7,2)), int(substr(v-string,9,2)),
  int( substr(string(year(today)),1,2) +  substr(v-string,5,2))) .
 else
 if v-string begins ":f0:" then
  do:
  v-cif = substr(v-string,13,6) .  tradr = substr(v-string,5) .
  end.
 else
  if v-string begins ":PC:" and v-cif = "sharm0" then
   v-cif = substr(v-string,5,6) .
 else
 if v-string begins ":f3:" then v-pri = substr(v-string,5,1) .
 else
 if v-string begins ":5c:" then v-bank = substr(v-string,5) .
 else
 if v-string begins ":72:" or rep = "72" then do:
   if rep = "0" then do: rep = "72" .
          v-info  = (substr(v-string,5)) .
    end .
    else
    v-info  = substr(v-info,1,length(v-info) - 1) + " " + v-string .
 end.
 else
 if v-string begins ":3F:" then do :
   substr(v-info,1,8) = substr(v-string,5) + " days".
   v-info3 = v-info3 + substr(v-string,2) + "^" .
 end .
 else
 if v-string begins ":9C:" then do :
  if m-typ = "10B" then do :
   v-bic = substr(v-string,5) .
  end .
  else do :
   substr(v-ben,1,35) = substr(v-string,5) .
   v-info3 = v-info3 + substr(v-string,2) + "^" .
  end .
 end .
 else
 if v-string begins ":9D:" then do :
  if m-typ = "10B" then do :
   v-bsubc = substr(v-string,5) .
  end .
  else do :
   substr(v-ben,61,35) = substr(v-string,5) .
   v-info3 = v-info3 + substr(v-string,2) + "^" .
  end .
 end .
 else
 if v-string begins ":9E:" then do :
  if m-typ = "10B" then do :
   v-bc = substr(v-string,5) .
  end .
  else do :
   substr(v-ben,121,35) = substr(v-string,5) .
   v-info3 = v-info3 + substr(v-string,2) + "^" .
  end .
 end .
 else
 if v-string begins ":9F:" then do :
   v-info3 = v-info3 + substr(v-string,2) + "^" .
 end .
 else
 if v-string begins ":5D:" then do :
  v-osubc = substr(v-string,5) .
 end .
 else
 if v-string begins ":5E:" then do :
  v-oc = substr(v-string,5) .
 end .
 else
 if v-string begins ":73:" then do :
  v-pk = substr(v-string,5) .
 end .
end.
input close .
if m-typ = "10B" then do :
 if v-bic <> "" then
  v-info = substr(v-info,1,length(v-info) - 1) + " /COD/" + v-bic .
 if v-bc <> "" then
  v-ben = substr(v-ben,1,length(v-ben) - 1) + " /ID/" + v-bc .
 if v-oc <> "" then
  v-ord = substr(v-ord,1,length(v-ord) - 1) + " /ID/" + v-oc .
 if v-pk = "TAX" then
  v-info = "/TAX/" + v-info .
end .

if m-typ = "11B" then do :
 run H11b_ps .
end .
else
if m-typ = "10B" or m-typ = "10E" then do:
 find remtrz where remtrz.sbank = ourbank  and
     remtrz.sqn   = v-cif + "." + string(dep-date,"99/99/9999") + "."
     + trim(v-ref) no-lock no-error .
 if avail remtrz then do:
   v-reterr = 1 .

   v-text = "Дубликат ! SQN = " + string(num[1]) + " from " +
   string(num[1]) + v-cif + "." + string(dep-date,"99/99/9999")  + "." + v-ref +
   "  уже зарегистрирован в базе филиала  " .
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
   v-text =  "Ошибка ! SQN  = " + string(num[1]) + " от " +
   string(num[1]) + v-cif + "." + string(dep-date,"99/99/9999")  + "." + v-ref +
      "  валюта счета : " +
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

if v-reterr eq 0 and v-bank = ourbank then do:
  find first aaa where aaa.aaa = v-ba no-lock no-error .

  if not avail aaa then do:
    v-text = "  Ошибка ! SQN = " + string(num[1]) + " от " +
     string(num[1]) + v-cif + "." + string(dep-date,"99/99/9999")
     + "." + v-ref + " -> " + v-ba +
     " не найден счет ! " .
    v-reterr = 2 .
  end .
  else
  if aaa.crc ne v-crc  then do:
   v-text = " Ошибка ! SQN = " + string(num[1]) + " от " +
    string(num[1]) +
   v-cif + "." + string(dep-date,"99/99/9999")  + "." + v-ref + " -> " + v-ba +
      " валюта счета: " +
      string(v-crc) + " " + string(aaa.crc) +
      " не равна валюте платежа !" .
      v-reterr = 3.  /* v-crc ne aaa.crc  */  .
  end.
end .


if v-reterr eq 0 and m-typ = "10b" then do:
 if v-bank eq "" then  do:
     v-text = "Ошибка ! SQN = " + string(num[1]) + " от " +
       string(num[1]) +
      v-cif + "." + string(dep-date,"99/99/9999")  + "." + v-ref +
      "  Нет кода банка получателя  ! " .
      v-reterr = 4 .  /* v-crc ne aaa.crc  */  .
 end.
 else
 do:

/*  known RECEIVER  */

  find first bankl where bankl.bank = v-bank no-lock no-error.
  if not avail bankl then do:
   v-text = " Ошибка ! SQN = " + string(num[1]) + " от " +
       string(num[1]) +
      v-cif + "." + string(dep-date,"99/99/9999")  + "." + v-ref +
      " Не найден код банка " + v-bank + " ! " .
      v-reterr = 5 .  /*  */  .
  end.
 end .

end . /* if '10b'  */


if v-reterr gt 0 then

 do :
  run lgps.
  if dep-date = ? then  do:
   v-text = " Ошибка транспортной системы ! (LARC) SQN = " + string(num[1]) .
   run lgps.
  return .
  end.
  run ps-rej  ( input
  string(num[1]) + v-cif + "." + string(dep-date,"99/99/9999")
  + "." + v-ref,
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
      v-text = " Ошибка транспортной системы ! (LGET DONE) " +
      v-cif + "." + string(dep-date,"99/99/9999")  + "." + v-ref +
       " SQN = " + string(num[1])  .
      run lgps.
     end.

 return .
end.



do on error undo  :
     create remtrz .
     remtrz.rtim = time.

     run n-remtrz.                     /* !!!!!!!!!!!!!!!! */
     remtrz.t_sqn = num[1] .
     remtrz.rdt = today .
     remtrz.remtrz = s-remtrz .
     remtrz.valdt1 = v-date .
     remtrz.saddr = tradr .
     if m-typ = "10B" and v-osubc <> "" then
      remtrz.sacc = substr(v-acc,1,length(v-acc) - 1) + "/" + v-osubc .
     else
      remtrz.sacc = v-acc  .
     remtrz.tcrc = v-crc .
     remtrz.payment = v-amt .
     remtrz.dracc = v-acc  .
     find first aaa where aaa.aaa = v-acc no-lock no-error .
     remtrz.drgl = aaa.gl .
     remtrz.fcrc = v-crc .
     remtrz.amt = v-amt .
     remtrz.jh1   = ?  . remtrz.jh2 = ? .
     remtrz.ord = v-ord .
     if remtrz.ord = ? then do:
       run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "H_ps.p 509", "1", "", "").
     end.
     remtrz.bb[1]  = "/" + substr(v-bb,1,35) .
     remtrz.bb[2]  = substr(v-bb,36,35) .
     remtrz.bb[3]  = substr(v-bb,71,70) .

     remtrz.intmed = v-intmed  .
     remtrz.intmedact  = v-intmedact  .

     remtrz.actins[1]  = "/" + substr(v-bb,1,35) .
     remtrz.actins[2]  = substr(v-bb,36,35) .
     remtrz.actins[3]  = substr(v-bb,71,35) .
     remtrz.actins[4]  = substr(v-bb,106,35) .

     remtrz.bn[1] = substr(v-ben,1,60) .
     remtrz.bn[2] = substr(v-ben,61,60) .
     remtrz.bn[3] = substr(v-ben,121,60) .
     remtrz.rcvinfo[1] = substr(v-info,1,35) .
     remtrz.rcvinfo[2] = substr(v-info,36,35) .
     remtrz.rcvinfo[3] = substr(v-info,71,35) .
     remtrz.rcvinfo[4] = substr(v-info,106,35) .
     remtrz.rcvinfo[5] = substr(v-info,141,35) .
     remtrz.rcvinfo[6] = substr(v-info,176,35) .

     if m-typ = "10B" and v-bsubc <> "" then
      remtrz.ba = substr(v-ba,1,length(v-ba) - 1) + "/" + v-bsubc .
     else
      remtrz.ba = v-ba .
     if not remtrz.ba begins  "/" then remtrz.ba = "/" + remtrz.ba .
     remtrz.bi = v-chg .

     remtrz.margb = 0.
     remtrz.margs = 0.

     remtrz.svca   = 0.
     remtrz.svcaaa = "".
     remtrz.svcmarg = 0.
     remtrz.svcp = 0.
     remtrz.svcrc = 0.
     remtrz.svccgl = 0.
     remtrz.svcgl = 0.
     find first crchs where crchs.crc = remtrz.fcrc no-lock .

     if m-typ = "10B" and v-crc = 1 then do:
      remtrz.svcrc = remtrz.fcrc.
      remtrz.svcaaa = remtrz.dracc.
      remtrz.svcgl = remtrz.drgl.
      find bankl where bankl.bank = v-bank no-lock no-error.
      if avail bankl then do:
       if bankl.nu = "u"
        then remtrz.svccgr = 501 .
        else do:
         if v-pri = "n" then
             remtrz.svccgr = 502 .
         else if (v-pri = "u" or v-pri = "e") then
             remtrz.svccgr = 503 .
        end.
      end.
     end.   /* m-typ = '10B'   */
     else
     if  ( m-typ eq "10E" and v-crc = 1 ) or crchs.hs = "h" then do:
      remtrz.svcrc = remtrz.fcrc.
      remtrz.svcaaa = remtrz.dracc.
      remtrz.svcgl = remtrz.drgl.
      find bankl where bankl.bank = v-bank no-lock no-error.
      if avail bankl then do:
       if bankl.nu = "u"
        then remtrz.svccgr = 501 .
       else do:
        if v-chg = "OUR" then
        do:
         if v-pri = "n" then
          remtrz.svccgr = 504 .
         if v-pri = "u" then
          remtrz.svccgr = 512 .
         if v-pri = "e" then
          remtrz.svccgr = 513 .
        end.
        if v-chg = "BEN" then
        do:
         if v-pri = "n" then
          remtrz.svccgr = 504 .
         if v-pri = "u" then
          remtrz.svccgr = 509 .
         if v-pri = "e" then
          remtrz.svccgr = 510 .
        end.
       end. /*  else do  */
      end.  /* avail bankl  */
     end .  /* crc.hs = 'h'  */
     else
     if   m-typ ne "10B" and  crchs.hs = "s" then do:
      remtrz.svcrc = remtrz.fcrc.
      remtrz.svcaaa = remtrz.dracc.
      remtrz.svcgl = remtrz.drgl.
      remtrz.svccgr = 524 .
     end.
     if remtrz.sacc = '2560000011' then remtrz.svccgr = 232.
     find first aaa where aaa.aaa = remtrz.sacc no-lock no-error .

     if avail aaa and aaa.cif = "G13644" and remtrz.fcrc = 1 then do:
          remtrz.svcrc = 0.
          remtrz.svcaaa = "".
          remtrz.svcgl = 0.
          remtrz.svccgr = 0 .
     end.
     if avail aaa and aaa.cif = "G01255" then do:
               remtrz.svcrc = remtrz.fcrc .
               remtrz.svcaaa = remtrz.dracc.
               remtrz.svcgl = remtrz.drgl.
               remtrz.svccgr = 234 .
     end.
     if avail aaa and aaa.cif = "G13597" then do:
         remtrz.svcrc = 0.
         remtrz.svcaaa = "".
         remtrz.svcgl = 0.
         remtrz.svccgr = 0 .
     end.

     if remtrz.svccgr ne 0
      then run comiss .

     remtrz.cracc = "".
     remtrz.crgl = 0.
     remtrz.sbank = ourbank.
     remtrz.scbank = ourbank.
     find bankl where bankl.bank = remtrz.sbank no-lock no-error.
     if available bankl then do:
                       remtrz.ordins[1] = bankl.name.
                       remtrz.ordins[2] = bankl.addr[1].
                       remtrz.ordins[3] = bankl.addr[2].
                       remtrz.ordins[4] = bankl.addr[3].
                    end.

     remtrz.sqn   = v-cif + "." + string(dep-date,"99/99/9999") + "." +
     trim(v-ref) .
     remtrz.rcbank = "".
     remtrz.rbank = v-bank.
     if l-chng then
     do:
      v-text = remtrz.remtrz + " " + old-bank + " изменен на -> " + ourbank.
      run lgps.
     end.
     acode = "".
     remtrz.racc = v-ba .
     remtrz.outcode = 3 .


     if v-bank eq "" and not brnch then  do:
        v-text = remtrz.remtrz +
        " Внимание ! Нет кода банка-получателя ! " .
        run lgps.
     end.
    else
    do:
     if brnch and v-bank = "" then  v-bank = clecod.

       /*  known RECEIVER  */

     find first bankl where bankl.bank = v-bank no-lock no-error.

     if not avail bankl then do:
       v-text = remtrz.remtrz + " Внимание ! Нет кода банка " +
       v-bank + "  ! " .
       run lgps .
       v-reterr = v-reterr + 8.  /*  */  .
     end.
     else if bankl.bank ne ourbank  then
     do  :
      find first crc where crc.crc = remtrz.tcrc.  bcode = crc.code .
      find first bankt where bankt.cbank = bankl.cbank and
        bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .

      if not avail bankt then do:
        v-text = remtrz.remtrz + " HOME " +
        " Внимание ! не найден корр.счет для " + bankl.cbank +
        " Валюта = " + bcode  .
        run lgps .
      end.
      else do :        /* not error */
       if remtrz.valdt1 >= g-today then
       remtrz.valdt2 = remtrz.valdt1 + bankt.vdate .
       else
       remtrz.valdt2 = g-today + bankt.vdate .
       if remtrz.valdt2 = g-today and bankt.vtime < time
       then remtrz.valdt2 = remtrz.valdt2 + 1 .

       repeat:
        find hol where hol.hol eq remtrz.valdt2 no-lock  no-error.
        if not available hol and weekday(remtrz.valdt2) ge v-weekbeg
          and  weekday(remtrz.valdt2) le v-weekend then leave.
        else remtrz.valdt2  = remtrz.valdt2 + 1.
       end.

       find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
       remtrz.rcbank = t-bankl.bank .    /* ??????????? */
       if t-bankl.nu = "u" then
       do:
        receiver = "u".
        remtrz.rsub = "cif".
       end.
       else do:
        receiver = "n" .
        remtrz.ba = "/" +  v-ba .
       end .
       remtrz.rcbank = t-bankl.bank .
       remtrz.raddr = t-bankl.crbank.
       remtrz.cracc = bankt.acc.
       if bankt.subl = "dfb" then do:
        find first dfb where dfb.dfb = bankt.acc no-lock no-error .
        if not avail dfb  then do:
         v-text = remtrz.remtrz + " Внимание ! Не найден корр.счет " +
         bankt.acc  + " для " + v-bank + " !" .
         run lgps .
         v-reterr = v-reterr + 125.  /*  */  .
        end.
        else do:
         remtrz.crgl = dfb.gl.
         find tgl where tgl.gl = remtrz.crgl no-lock.
        end.
       end.

       if bankt.subl = "cif" then do:
        find first aaa where aaa.aaa = bankt.acc no-lock no-error .
        if not avail aaa  then do:
          v-text = remtrz.remtrz + " Внимание ! Не найден LORO счет " +
          bankt.acc  + " для " + v-bank + " ! " .
          run lgps .
          v-reterr = v-reterr + 126.  /*  */  .
        end.
        else do:
           remtrz.crgl = aaa.gl.
           find tgl where tgl.gl = remtrz.crgl no-lock.
        end.
       end.
      end .  /* not error */
      find first bankl where bankl.bank = v-bank no-lock no-error.
    end.     /* rbank isn't our bank  */

    else do :
      remtrz.rsub = "cif".
      remtrz.raddr = "".
      remtrz.valdt2 = remtrz.valdt1 .
      if remtrz.rsub ne "" then do:
       c-acc = remtrz.racc .
       if rsub = "cif" then do:
         find first aaa where aaa.aaa = c-acc
         and aaa.crc eq remtrz.tcrc no-lock no-error .
         if avail aaa then do:
          if aaa.sta eq "C" then do:
           v-text = remtrz.remtrz + " Закрытый счет : " + c-acc.
        for each aas where aas.aaa = c-acc and aas.sic = "KM" no-lock .
        v-text = remtrz.remtrz + " Счет  " + c-acc +
                     " переведен в " + aas.payee .
           end .
           run lgps .
           v-reterr = v-reterr + 8.
           /* aaa for rbank.racc  wasn't found */  .
          end.
          else do :
           find tgl where tgl.gl = aaa.gl no-lock.
           remtrz.cracc = remtrz.racc .
           remtrz.crgl = tgl.gl.
          end .
         end.
         else
         do:

         v-text = remtrz.remtrz + " Не найден счет " +
            c-acc  + " или валюта счета не = валюте платежа " .
          run lgps .
          v-reterr = v-reterr + 32.  /* aaa for rbank.racc  wasn't found */  .
         end.
       end.         /* cif */
       else
       do:
          v-text = remtrz.remtrz + " RSUB не CIF:   " + rsub + " " +
           c-acc   .
          run lgps .
          v-reterr = v-reterr + 64 .  /* */ .
       end.
      end.        /*  rsub ne "" */
      else
      do:
          v-text = remtrz.remtrz + " RSUB пуст " +
           c-acc  .
          run lgps .
          v-reterr = v-reterr + 128 .  /* */ .
      end.
    end .        /* end rbank = ourbank */
end .

     find first aaa where aaa.aaa = remtrz.dracc no-lock no-error .
     find first xaaa where xaaa.aaa = remtrz.cracc no-lock no-error .
     if avail aaa and avail xaaa then do:
      if xaaa.cif = aaa.cif and aaa.cif ne "" then do:
           remtrz.svcrc = 0.
           remtrz.svcaaa = "".
           remtrz.svcgl = 0.
           remtrz.svccgr = 0 .
           remtrz.svca = 0 .
           remtrz.svccgl = 0 .
      end.
     end.


                remtrz.ref =
                (substring(trim(v-cif),1,6) +
                fill(" " , 6 - length(substring(trim(v-cif),1,6))))
                +  "HOME" +
                (substring(trim(v-ref),1,12) +
                fill(" " , 12 - length(substring(trim(v-ref),1,12))))
                +
                (substring(trim(ourbank),1,12) +
                fill(" " , 12 - length(substring(trim(ourbank),1,12))))
                +
                (substring(trim(v-acc),1,10) +
                fill(" " , 10 - length(substring(trim(v-acc),1,10))))

                + string(day(dep-date),"99")
                + string(month(dep-date),"99")
                + substr(string(year(dep-date),"9999"),3,2) .
                                                  /*
                + substring(v-rcvinfo[1],11,5) .
                                                    */

        if m-typ = "10B" and remtrz.fcrc = 1
          and remtrz.crgl ne 0 and remtrz.cracc ne "0"
            then remtrz.chg = 0. else remtrz.chg = 7 .


 /* ptype determination  */
if remtrz.rbank = ourbank then remtrz.rcbank = ourbank.

if remtrz.rcbank = "" then remtrz.rcbank = remtrz.rbank .
if remtrz.scbank = "" then remtrz.scbank = remtrz.sbank .

find first bankl where bankl.bank = remtrz.scbank  no-lock no-error .
if avail bankl then
  if bankl.nu = "u" then sender = "u". else sender = "n" .
find first bankl where bankl.bank = remtrz.rcbank no-lock no-error .
if avail bankl then
  if bankl.nu = "u" then receiver  = "u". else receiver  = "n" .
  if remtrz.scbank = ourbank then sender = "o" .
  if remtrz.rcbank = ourbank then receiver  = "o" .
find first ptyp where ptyp.sender = sender and ptyp.receiver = receiver
     no-lock no-error .
if avail ptyp then remtrz.ptype = ptyp.ptype.
else remtrz.ptype = "N".

/*
if remtrz.ptype = "M" and remtrz.rbank ne ourbank
*/
if remtrz.ptype = "4" then do :
   v-det = trim(remtrz.ba) + " " + v-det.
   remtrz.det[1] = substr(v-det,1,35) .
   remtrz.det[2] = substr(v-det,36,35) .
   remtrz.det[3] = substr(v-det,71,35) .
   remtrz.det[4] = substr(v-det,106,35) .
end.
else do :
   remtrz.det[1] = substr(v-det,1,35) .
   remtrz.det[2] = substr(v-det,36,35) .
   remtrz.det[3] = substr(v-det,71,35) .
   remtrz.det[4] = substr(v-det,106,35) .
end.

remtrz.rwho = g-ofc .
remtrz.source = m_pid .

 if receiver ne "o" and v-bank ne "" then do:
  {nbal+r.i}       /*  nbal   */
 end.

 create que.
 que.remtrz = remtrz.remtrz.
 que.pid = m_pid.
 remtrz.remtrz = que.remtrz .
 que.ptype = remtrz.ptype.
 if v-reterr = 0 then  do:
   que.rcod = "0" .
   if remtrz.cracc = lbnstr then que.rcod = "3" .
  end.
 else
 do:
  que.rcod = "1".
  que.pvar = string(v-reterr).
 end.

 if remtrz.ptype = "M" and ( remtrz.cracc eq "" or remtrz.crgl = 0 )
  then que.rcod = "2" .
 que.con = "F".
 que.dp = today.
 que.tp = time.
 if v-pri = "E" then
  que.pri = 9999 .
  else
 if v-pri = "U" then
  que.pri = 19999 .
  else
  que.pri = 29999 .
  ok = true  .


 v-text = "Автоматическая регистрация платежа " + remtrz.remtrz +
  " <- SQN = " + string(num[1]) +
 " <- " + v-cif  + " " + remtrz.sqn + " тип=" + remtrz.ptype +
  " код завершения = " + que.rcod +  " -> " + remtrz.rbank .
 run lgps.

end.
end .

if ok then
 do:
 input through
   value( "lget -q RCVD1 --done " + string(num[1]) + " ; echo $? " ) .
  exitcod = "".
  repeat:
   import exitcod .
  end.
 input close .
   if  exitcod ne "0"  then do:
    v-text =" Ошибка транспортной системы ( LGET DONE ) для "  + remtrz.remtrz +
       " SQN = " + string(num[1])  .
     run lgps.
   end.
 pause 0 .
end .

