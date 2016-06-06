/* acc_gen.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Генерация 20-ти значного счета
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
        15/04/2009 galina
 * BASES
        BANK
 * CHANGES
       17/04/2009 galina - подправила функцию modulo_97
       08/02/2010 galina - переместила функци в chkaa20.i
       10/02/2010 galina - перекомпиляция
*/

{global.i}

{chkaaa20.i}
def input parameter p-gl like gl.gl.
def input parameter p-crc as integer.
def input parameter p-cif as char.
def input parameter p-arpsek as char.
def input parameter p-viewacc as logi.
def output parameter p-acc as char.
def var v-secek as char.


def var v-acc as char.



find first crc where crc.crc = p-crc no-lock no-error.
if not avail crc then do:
  message "Неверный код валюты " + string(p-crc) view-as alert-box title "Внимание".
  return.
end.

find first gl where gl.gl = p-gl no-lock no-error.
if not avail gl then do:
  message "Неверный счет главной книги" + string(p-gl) view-as alert-box .
  return.
end.


case gl.subled:
  when "CIF" or when "LON" then do:
    find first cif where cif = p-cif no-lock no-error.
    if not avail cif then do:
       message "Неверный код клиента " + string(p-cif) view-as alert-box title "Внимание".
       return.
    end.
    find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = p-cif and sub-cod.d-cod = "secek" no-lock no-error.
    if not avail sub-cod or sub-cod.ccode = "msc" then do:
       message "Неверное значение сектора экономики клиента - msc. Нельзя открыть счет" view-as alert-box title "Внимание".
       return.
    end.
    if sub-cod.ccode = "9" then do:
      if cif.type = 'B' and cif.cgr = 403 then v-secek = "0".
      else v-secek = "9".
    end.
    else v-secek = sub-cod.ccode.
  end.
  when "ARP" then do:
    v-secek = p-arpsek.
  end.
  when "DFB" then do:
    v-secek = "4".
  end.

end. /*case*/


find nmbr where nmbr.code = "iban-" + gl.subled no-lock no-error.
if not avail nmbr then do:
   message "Нет параметра iban-" + gl.subled + " в nmbr" view-as alert-box title "Внимание".
   return.
end.
do transaction:
  find current nmbr exclusive-lock.
  if nmbr.nmbr = 9999 then do:
     nmbr.nmbr = 1.

     nmbr.prefix = entry(index(v-leter,nmbr.prefix) + 1,v-leter).
  end.
  else nmbr.nmbr = nmbr.nmbr + 1.
  find current nmbr no-lock.
end.



if p-crc < 10 then do:
 v-acc = "470" + string(p-crc) + v-secek + substr(string(p-gl),1,4) + get_figure(nmbr.prefix) + string(nmbr.nmbr,'9999') + nmbr.sufix + get_figure("KZ") + "00".
 p-acc = "KZ" + string(98 - modulo_97(decimal(v-acc)),'99') + "470" + string(p-crc) + v-secek + substr(string(p-gl),1,4) + nmbr.prefix + string(nmbr.nmbr,'9999') + nmbr.sufix.
end.
else do:
 v-acc = "4700" + v-secek + substr(string(p-gl),1,4) + get_figure(nmbr.prefix) + string(nmbr.nmbr,'9999') + nmbr.sufix + get_figure("KZ") + "00".
 p-acc = "KZ" + string(98 - modulo_97(decimal(v-acc)),'99') + "4700" + v-secek + substr(string(p-gl),1,4) + nmbr.prefix + string(nmbr.nmbr,'9999') + nmbr.sufix.
end.



/*раскомитить после перехода на 20-ти значные счета*/

if gl.subled eq "ARP" then do transaction :
   create arp.
   arp.arp = p-acc no-error.
   if error-status:error then undo,leave.
end.

/*if gl.subled eq "DFB" then do transaction :
   create dfb.
   dfb.dfb = p-acc no-error.
   if error-status:error then undo,leave.
end.*/

if gl.subled eq "CIF" then do transaction :
  create aaa.
  aaa.aaa = p-acc no-error.
  if error-status:error  then do:
        message "Такой счет уже существует" view-as alert-box.
        undo,leave.
  end.
end.

if gl.subled eq "lon" then do transaction :
   create lon.
   lon.lon = p-acc no-error.
   if error-status:error then undo,leave.
end.
if p-viewacc = true then display p-acc format "x(20)" label "Новый счет "  with frame a overlay side-label row 10  centered.


