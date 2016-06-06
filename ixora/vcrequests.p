/* vcrequests.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Редактирование запросов по ПС, переведенных из другого банка
 * RUN
        верхнее меню сведений о контракте
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        19.01.2011 aigul - на основе vcdndocs
 * BASES
        BANK COMM
 * CHANGES
        24.02.2011 aigul - увеличила поля Уб и должности
        21.12.2012 damir - Изменений не было. Перекомпиляция.
*/
{vc.i}
{mainhead.i VCCONTRS}
def shared var s-contract like vccontrs.contract.
def shared var s-vcdoctypes as char.
def shared var s-dnvid as char.
def new shared var s-request as char.
def var v-contrnum as char.
find vccontrs where vccontrs.contract = s-contract no-lock no-error.
if (vccontrs.cttype = "1") and not can-find(vcps where vcps.contract = s-contract and vcps.dntype = "01" no-lock) then do:
  bell.
  message skip " Контракт требует ввода паспорта сделки ! " skip(1) view-as alert-box buttons ok
    title " Предупреждение ".
  return.
end.

if vccontrs.expimp = "i" then
  v-contrnum = "импорт, ".
else
  v-contrnum = "экспорт, ".
v-contrnum = v-contrnum + trim(vccontrs.ctnum) + " от " + string(vccontrs.ctdate, "99/99/9999").

{vc-request.i
  &option = "vcdocs"
  &head = " vcdocs"
  &headkey = "docs "
  &frame = "vcrequest"
  &no-add = " if (vccontrs.sts begins 'c') then do: run noupd. next outer. end. "
  &no-update = " if (vccontrs.sts begins 'c') then do: run noupd. next outer. end. "
  &no-del = " if (vccontrs.sts begins 'c') then do: run noupd. next outer. end. "
  &predisplay = " if avail vcdocs and vcdocs.info[3] <> '' then do:
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
                  s-request = vcdocs.info[2].
                  run deftypename."
  &display = " vcdocs.dntype v-dntypename vcdocs.dnnum vcdocs.dndate v-ub v-ub1 v-ub2 vcdocs.info[2] v-to v-to2 v-to1 v-from v-from2 v-from1
               vcdocs.info[5] "
  &preupdate = " run deftypename. "
  &update = " /*do transaction on endkey undo, return:
                 run pro-upd.
              end.*/
              update vcdocs.dntype with frame vcrequest.
              run deftypename.
              displ v-dntypename when (index('z', s-dnvid) > 0)
              with frame vcrequest.
              update vcdocs.dnnum vcdocs.dndate v-ub v-ub1 v-ub2 v-to v-to2 v-to1 v-from v-from2 v-from1  vcdocs.info[5] with frame vcrequest.
              vcdocs.info[1] = v-ub + v-ub1 + v-ub2.
              vcdocs.info[3] = v-to + v-to2 + '|' + v-to1.
              vcdocs.info[4] = v-from + v-from2 + '|' + v-from1.
              vcdocs.uwho = g-ofc.
              vcdocs.udt = g-today.
            "
  &postupdate = " run vcctsumm. if vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1' then
                  run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
                  displ v-sumost1 v-suminv v-sumkon v-sumexc v-sumgtd v-sumplat v-sumakt v-sumost v-sumexc% v-term v-sumzalog with frame vcctsumm."
  &postcreate = " run postcrt. "
  &delete = " delete vcdocs. "
  &postdelete = " run vcctsumm.
                  if vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1' then
                  run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
                  displ v-sumost1 v-suminv v-sumkon v-sumexc v-sumgtd v-sumplat v-sumakt v-sumost v-sumexc% v-term v-sumzalog with frame vcctsumm."
}

procedure deftypename.
  find codfr where codfr.codfr = "vcdoc" and codfr.code = vcdocs.dntype no-lock no-error.
  if avail codfr then v-dntypename = codfr.name[2]. else v-dntypename = "".
end procedure.


procedure noupd.
  bell.
  message skip " Данное действие невозможно! Контракт закрыт либо у Вас нет прав на выполнение данной процедуры." skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
end procedure.
/*
procedure pro-upd.
    update vcdocs.dntype with frame vcrequest.
    run deftypename.
    displ v-dntypename when (index('z', s-dnvid) > 0)
        with frame vcrequest.
    update vcdocs.dnnum vcdocs.dndate vcdocs.info[1] v-to v-to1 v-from v-from1  vcdocs.info[5] with frame vcrequest.
    vcdocs.info[3] = v-to + "|" + v-to1.
    vcdocs.info[4] = v-from + "|" + v-from1.
    vcdocs.uwho = g-ofc.
    vcdocs.udt = g-today.
end procedure.
*/
procedure postcrt.
    vcdocs.contract = s-contract.
    assign vcdocs.contract = s-contract
    vcdocs.dntype = '28'
    vcdocs.dnnum = ''
    vcdocs.dndate = g-today
    vcdocs.info[2] = string(next-value(vcrequest))
    v-ub  = ''
    v-ub1 = ''
    v-ub2 = ''
    v-to = ''
    v-to2 = ''
    v-to1 = ''
    v-from = ''
    v-from2 = ''
    v-from1 = ''.
end.