/* vcrequesthis.p
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
        21.01.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
        09.03.2011 aigul - расширила поля

*/
{vc.i}

def shared var s-vcdoctypes as char.
def shared var s-dnvid as char.
def shared var s-contract like vccontrs.contract.
def var v-contrnum as char.

{vc-vhis.i
 &head = "vcdocs"
 &headkey = "docs"
 &headhis = "vcdocshis"
 &start = " "
 &frame = "vcrequest"
 &predisplay = "
      find vccontrs where vccontrs.contract = s-contract no-lock no-error.
      if avail vcdocs and vcdocs.info[3] <> '' then do:
                    /*v-to = entry(1,vcdocs.info[3], '|').
                    v-to1 = entry(2,vcdocs.info[3], '|').
                    v-from = entry(1,vcdocs.info[4], '|').
                    v-from1 = entry(2,vcdocs.info[4], '|').*/
                    v-ub = substr(vcdocs.info[1],1,31).
                    v-ub1 = substr(vcdocs.info[1],32,31).
                    v-ub2 = substr(vcdocs.info[1],63,31).
                    v-to = substr(entry(1,vcdocs.info[3], '|'),1,31).
                    v-to2 = substr(entry(1,vcdocs.info[3], '|'),32,62).
                    v-to1 = entry(2,vcdocs.info[3], '|').
                    v-from = substr(entry(1,vcdocs.info[4], '|'),1,31).
                    v-from2 = substr(entry(1,vcdocs.info[4], '|'),32,62).
                    v-from1 = entry(2,vcdocs.info[4], '|').
                  end.
                  else do:
                    v-dntypename = ''.
                  end.
      if vccontrs.expimp = 'i' then v-contrnum = 'импорт, '.
      else v-contrnum = 'экспорт, '.
      v-contrnum = v-contrnum + trim(vccontrs.ctnum) + ' от ' + string(vccontrs.ctdate, '99/99/9999').
      "
 &header = "ДОКУМЕНТА"
 &displcif = "true"
 &display = "
     vcdocs.dntype v-dntypename vcdocs.dnnum vcdocs.dndate v-ub v-ub2 v-ub1 v-to v-to2 v-to1 v-from v-from2 v-from1 vcdocs.info[5] "
}



