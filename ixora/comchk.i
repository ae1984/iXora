/* comchk.i
 * MODULE
        Платежная система
 * DESCRIPTION
        Функция проверки введенной суммы комиссии внешнего платежа
        Заодно проверяется соответствие кода комиссии статусу клиента (ФЛ/ЮЛ) и валюте платежа
 * RUN
        
 * CALLER
        3-svch.p, LON_ps.p, psroup.p, psroup-2.p, rotlxzi.p, rotlxzp.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-3-1, 5-2-8 ...
 * AUTHOR
        24.09.2003 nadejda
 * CHANGES
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/

def var v-komissmin as decimal.
def var v-komissmax as decimal.
def var v-msgerr as char.


function chkkomcod returns logical (p-value as integer).
  def var v-msgs as char extent 4 init
  [" Комиссия с данным кодом не найдена в тарификаторе!",
   " Комиссия с данным кодом не активна!",
   " Код комиссии не соответствует валюте платежа!",
   " Код комиссии не соответствует статусу клиента (ФЛ/ЮЛ)!"
  ].
  def var v-kodoffice as integer.
  def var v-clnsts as char init "".


  /* вообще проверяем тарифы только для валютных платежей */
  if remtrz.fcrc = 1 then return true.

  /* если не задан код комиссии - ничего не проверяем */
  if p-value = 0 then return true.

  find first tarif2 where tarif2.str5 = string(p-value) 
                      and tarif2.stat = 'r' no-lock no-error.
  if not avail tarif2 then do:
    v-msgerr = v-msgs[1].
    return false.
  end.

  if tarif2.pakalp begins "N/A" then do:
    v-msgerr = v-msgs[2].
    return false.
  end.


  find first cmp no-lock no-error.
  v-kodoffice = cmp.code.


  /* проверим, чтобы комиссия за счет отправителя соответствовала  */
  find aaa where aaa.aaa = remtrz.sacc no-lock no-error.
  if avail aaa then do:
    v-clnsts = "0".
    find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "clnsts" and sub-cod.acc = aaa.cif no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> "msc" then v-clnsts = sub-cod.ccode.
  end.
  else do:
    find lon where lon.lon = remtrz.sacc no-lock no-error.
    if avail lon then do:
      v-clnsts = "0".
      find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "clnsts" and sub-cod.acc = lon.cif no-lock no-error.
      if avail sub-cod and sub-cod.ccode <> "msc" then v-clnsts = sub-cod.ccode.
    end.
  end.

  /* платежи в RUR - общие тарифы */
  if remtrz.fcrc = 4 and (lookup(string(p-value), "205,219") > 0) then do:
    v-msgerr = v-msgs[3].
    return false.
  end.
  if remtrz.fcrc <> 4 and (lookup(string(p-value), "217,218") > 0) then do:
    v-msgerr = v-msgs[3].
    return false.
  end.

  /* проверка на ФЛ/ЮЛ */
  if v-clnsts <> "" then do:
    if (v-clnsts = "0" and lookup(string(p-value), "208,212,209,217") > 0) or 
       (v-clnsts = "1" and lookup(string(p-value), "204,205,218,219") > 0) then do:
      v-msgerr = v-msgs[4].
      return false.
    end.
  end.

  /* для Астаны есть отдельные тарифы */
  if v-kodoffice = 1 then do:
    /* в EUR */
    if remtrz.fcrc = 11 and (lookup(string(p-value), "205,217,218") > 0) then do:
      v-msgerr = v-msgs[3].
      return false.
    end.
    if remtrz.fcrc <> 11 and p-value = 219 then do:
      v-msgerr = v-msgs[3].
      return false.
    end.
  end.

  /* для филиалов есть отдельные тарифы */ 
  if v-kodoffice = 1 or v-kodoffice = 2 then do:
    /* тариф RUR */
    if remtrz.fcrc <> 4 and p-value = 217 then do:
      v-msgerr = v-msgs[3].
      return false.
    end.
  end.

  return true.
end.


function chkkomiss returns logical (p-value as decimal).
  def var v-msgs as char init " Сумма комиссии выходит за пределы установленного тарифа!".

  /* вообще проверяем тарифы только для валютных платежей */
  if remtrz.fcrc = 1 then return true.

  /* если не задан код комиссии - ничего не проверяем */
  if remtrz.svccgr = 0 then return true.


  /* заодно проверим, чтобы комиссия за счет отправителя соответствовала  */
  if not chkkomcod (remtrz.svccgr) then do:
    return false.
  end.

  /* проверка сумм */
  if (p-value < v-komissmin) or (v-komissmax > 0 and p-value > v-komissmax) then do:
    v-msgerr = v-msgs.
    return false.
  end.

  return true.
end.

