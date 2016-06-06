/* cifkated.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Функция проверки категории клиента на доступность выписок
 * RUN

 * CALLER
        st_if.i, st_if2.i, st_if3.i, st_clif.i, vip_dok.p, vip_lst.p, vip_str.p
 * SCRIPT

 * INHERIT

 * MENU
        2-4-x
 * AUTHOR
        10.09.2003 nadejda
 * CHANGES
        31.08.2012 damir - закомментировал лишнюю проверку.

*/

def var v-msgerr as char.

function chkcif returns logical (p-value as char).
  p-value = trim(p-value).
  if p-value = "" then do:
    v-msgerr = " Задайте код клиента!".
    return false.
  end.

  find cif where cif.cif = p-value no-lock no-error.
  if not avail cif then do:
    v-msgerr = " Клиент с таким кодом не найден!".
    return false.
  end.

  /*find codfr where codfr.codfr = "cifkat" and trim(codfr.code) = trim(cif.trw) no-lock no-error.
  if avail codfr and codfr.name[5] <> "" and codfr.name[5] <> "yes" then do:
    find sysc where sysc.sysc = "supusr" no-lock no-error.
    /* суперюзерам выписки разрешаем :-) */
    if not avail sysc or sysc.chval = "" or lookup (g-ofc, sysc.chval) = 0 then do:
      find sysc where sysc.sysc = "vipvyp" no-lock no-error.
      /* некоторым юзерам выписки разрешаем :-) */
      if not avail sysc or sysc.chval = "" or lookup (g-ofc, sysc.chval) = 0 then do:
        v-msgerr = " Нет доступных выписок по выбранному счету!".
        return false.
      end.
    end.
  end.*/

  return true.
end.

