/* clrrmzp1.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

def shared var g-today as date.
def var vree as char extent 100.
def var iree as inte.
def var iree0 as inte.
def var nree as inte.
def var vkop as deci.
def var ckop as inte.
def var dkop as inte.
def var v-mudate as char format "x(20)".
{men-l.f}
def shared temp-table ree
    field npk as inte format "zz9"
    field bank as char format "x(9)"
    field bbic like bankl.bic
    field quo as inte format "zzzzz9"
    field kopa as deci format "zzz,zzz,zzz,zzz.99".
find sysc where sysc.sysc = "CLECOD" no-lock.

 v-mudate = string(year(g-today),'9999.g ')
          + string(day(g-today),'99') + '.'
          + men-l[month(g-today)].

for each ree:
   iree = iree + 1.
   vkop = vkop + ree.kopa.
   dkop = dkop + ree.quo.
   ckop = ckop + integer(ree.bank).
end.
   nree = iree / 2.
   iree = 0.
   iree = iree + 1.
   vree[iree] = fill(" ",27) + "Клирингов.расчеты".
   iree = iree + 1.
   vree[iree] = fill(" ",27) + "Сопров.документ ".
   iree = iree + 1.
   vree[iree] = fill(" ",25) + "Дата   " + v-mudate.
   iree = iree + 2.
   vree[iree] = fill(" ",10) + "Кредитное учреждение     :".
   iree = iree + 1.
   vree[iree] = fill(" ",10) + "Банк  Komercbanka Рег. Nr. 000302472  ".
   iree = iree + 1.
   vree[iree] = fill(" ",10) + "no 1991.г. 6. сентября ".
   iree = iree + 1.
   vree[iree] = fill(" ",10) + "Код учреждения     :           Код валюты  :".
   iree = iree + 1.
   vree[iree] = fill(" ",19) + substring(sysc.chval,7,3) 
              + "                        LVL". 

   iree = iree + 1.
   vree[iree] = "   " + "-----------------------------------" + "   " +
                "-----------------------------------".
   iree = iree + 1.
   vree[iree] = "   " + "|NPK |Кому |Док.  |     Сумма     |" + "   " +
                "|NPK |Кому |Док.  |     Сумма     |".
   iree = iree + 1.
   vree[iree] = "   " + "|    |     |кол-во|               |" + "   " +
                "|    |     |кол-во|               |".
   iree = iree + 1.
   vree[iree] = "   " + "-----------------------------------" + "   " +
                "-----------------------------------".
   iree0 = iree.
for each ree:
    iree = iree + 1.
    if iree - iree0 <= nree then do:
      vree[iree] = "   " + "|" + string(ree.npk,"zz9") + " | " + ree.bank + " | "
                 + string(ree.quo,"zzz9")
                 + " |" + string(ree.kopa,"zzz,zzz,zzz.99") + " |".
      if iree - iree0 = nree then do:
         iree = iree + 1.
         vree[iree] = "   " + "-----------------------------------".
      end.
    end.
    else do:
      vree[iree - nree - 1] = vree[iree - nree - 1] + "   " + "|"
                        + string(ree.npk,"zz9") + " | "
                        + ree.bank + " | "
                        + string(ree.quo,"zzz9") + " |"
                        + string(ree.kopa,"zzz,zzz,zzz.99") + " |".
    end.
end.
    nree = nree + 1.
    iree = iree + 1.
    if vree[iree - nree] <> "" then
       vree[iree - nree] = vree[iree - nree] + "   "
                           + "-----------------------------------".
    else vree[iree - nree] = fill(" ",41)
                           + "-----------------------------------".
    iree = iree + 1.
    if vree[iree - nree] <> "" then
       vree[iree - nree] = vree[iree - nree] + "   "
                           + "|Итог|" + string(ckop,"zzzz9") + "|"
                           + string(dkop,"zzzz9") +  " |"
                           + string(vkop,"zzz,zzz,zzz.99") + " |".
    else vree[iree - nree] = fill(" ",41)
                           + "|Итог|" + string(ckop,"zzzz9") + "|"
                           + string(dkop,"zzzz9") +  " |"
                           + string(vkop,"zzz,zzz,zzz.99") + " |".
    iree = iree + 1.
    if vree[iree - nree] <> "" then
       vree[iree - nree] = vree[iree - nree] + "   "
                           + "-----------------------------------".
    else vree[iree - nree] = fill(" ",41)
                           + "-----------------------------------".
    iree = iree - nree.
    iree = iree + 2.
    vree[iree] = fill(" ",3) + "Кр.учреждение" + fill(" ",25)
                              + "Проверено Нац.Банком     ".
    iree = iree + 2.
    vree[iree] = fill(" ",3) + "М.П." + fill(" ",46) + "_____________".
    iree = iree + 1.
    vree[iree] = fill(" ",54) + "  ( дата )  ".
    iree = iree + 1.
    vree[iree] = fill(" ",3) + "Подпись :" + fill(" ",29)
                              + "Подпись :".
nree = iree.
output to rpt.img.
do iree = 1 to nree:
   put vree[iree] format "x(80)" skip.
end.
output close.
   unix silent prit value("rpt.img"). 
