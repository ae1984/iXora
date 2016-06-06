/* vcdngtds.p
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
        01.07.2004 saltanat - для контрактов типа =5, обязательным является наличие паспорта сделки
        21.09.2004 saltanat - для добавления,редактирования и удаления вставила проверку на то,что акцептующее лицо не может
                              выполнять эти процедуры.
        17.01.2005 saltanat - Предусмотрела исключение для редактирования и т.д.
        28.04.2008 galina - удалена проверка наличия ПС для контрактов типа 5
        13.05.2008 galina - добавлен вывод полей "СУММА ЗАЙМ.%" и "СРОК ДВИЖ.КАП."
        06.06.2008 galina - добавления поля остаток непереведенных средств
        10.07.2008 galina - для редактирования и удаления удалена проверка на то,что акцептующее лицо не может
                              выполнять эти процедуры.
        14.08.2009 galina - перекомпиляция в связи с изменением vc-summf.i
        26.08.2009 galina - в процедуру check_term не передаем дату
        11.03.2011 damir - перекомпиляция в связи с добавлением нового поля opertyp
*/

/* vcdngtd.p Валютный контроль
   Редактирование ГТД

   18.10.2002 nadejda создан
*/

{vc.i}


{mainhead.i VCCONTRS}

def shared var s-contract like vccontrs.contract.
def shared var s-vcdoctypes as char.
def shared var s-dnvid as char.
def var v-contrnum as char.
/*def var v-exc as char init ''.*/

find vccontrs where vccontrs.contract = s-contract no-lock no-error.

/*find sysc where sysc.sysc = "vkexc" no-lock no-error.
if avail sysc then v-exc = sysc.chval.
else v-exc = "". */

if ((vccontrs.cttype = "1") /*or (vccontrs.cttype = "5")*/) and
     not can-find(vcps where vcps.contract = s-contract and vcps.dntype = "01" no-lock) then do:
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

{vc-alldoc.i
  &option = "vcdocs"
  &head = " vcdocs"
  &headkey = "docs "
  &frame = "vcdngtd"
  &start = " "
  &no-add = " if (vccontrs.sts begins 'c') /*or (chkrights('vcdocsac') and lookup(g-ofc,v-exc) = 0)*/ then do: run noupd. next outer. end. "
  &no-update = " if (vccontrs.sts begins 'c') /*or (frame-value <> 'Акцепт' and chkrights('vcdocsac') and lookup(g-ofc,v-exc) = 0)*/ then do: run noupd. next outer. end. "
  &no-del = " if (vccontrs.sts begins 'c') /*or (chkrights('vcdocsac') and lookup(g-ofc,v-exc) = 0)*/ then do: run noupd. next outer. end. "
  &predisplay = " if avail vcdocs then do:
                   run defcrckod. run deftypename.
                 end. else do: v-crckod = ''. v-dntypename = ''. end. "
  &display = " vcdocs.dntype v-dntypename vcdocs.dnnum vcdocs.dndate vcdocs.payret vcdocs.pcrc
               v-crckod vcdocs.sum vcdocs.cursdoc-con vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon
               vcdocs.origin vcdocs.info[1] vcdocs.rdt vcdocs.rwho vcdocs.cdt vcdocs.cwho "
  &postdisplay = " "
  &preupdate = " run defcrckod. run deftypename. "
  &update = " update vcdocs.dntype with frame vcdngtd. run deftypename.
             displ v-dntypename with frame vcdngtd.

             update vcdocs.dnnum with frame vcdngtd.
             update vcdocs.dndate with frame vcdngtd.
             if vcdocs.dndate entered then do:
               run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
               displ vcdocs.cursdoc-con vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon
                  with frame vcdngtd.
             end.

             update vcdocs.payret with frame vcdngtd.
             update vcdocs.pcrc with frame vcdngtd.
             if vcdocs.pcrc entered then do:
               run defcrckod.
               run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
               displ v-crckod vcdocs.cursdoc-con vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon
                 with frame vcdngtd.
             end.

             update vcdocs.sum with frame vcdngtd.
             if vcdocs.sum entered then
               displ vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon with frame vcdngtd.
             update vcdocs.cursdoc-con /*when vcdocs.cursdoc-con = 0*/ with frame vcdngtd.
             if vcdocs.cursdoc-con entered then
               displ vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon with frame vcdngtd.

             update vcdocs.origin vcdocs.info[1] with frame vcdngtd. "
  &postupdate = " run vcctsumm.
                  if vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1' then
                    run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
                  displ v-sumost1 v-suminv v-sumkon v-sumexc v-sumgtd v-sumplat v-sumakt v-sumost  v-sumexc% v-term with frame vcctsumm.
                  if vcdocs.info[1] entered then run defpaid. "
  &precreate = " "
  &postcreate = " run ppostcr. "
  &predelete = " "
  &delete = " delete vcdocs. "
  &postdelete = " run vcctsumm.
                  if vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1' then
                     run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
                  displ v-sumost1 v-suminv v-sumkon v-sumexc v-sumgtd v-sumplat v-sumakt v-sumost  v-sumexc% v-term with frame vcctsumm. "
  }


procedure defpaid.
  def var i as integer.
  if vcdocs.info[1] <> '' then do:
    repeat i = 1 to num-entries(vcdocs.info[1], ';'):
      find b-vcdocs where (b-vcdocs.dntype = '12' or b-vcdocs.dntype = '15') and
         b-vcdocs.dnnum = entry(i, vcdocs.info[1], ';') exclusive-lock no-error.
      if avail b-vcdocs then b-vcdocs.info[5] = 'paid'.
    end.
  end.
end procedure.

procedure defcrckod.
  find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
  if avail ncrc then v-crckod = ncrc.code. else v-crckod = ''.
end procedure.

procedure deftypename.
  find codfr where codfr.codfr = "vcdoc" and codfr.code = vcdocs.dntype no-lock no-error.
  if avail codfr then v-dntypename = codfr.name[2]. else v-dntypename = "".
end procedure.

procedure ppostcr.
  vcdocs.contract = s-contract.
  vcdocs.dndate = g-today.
  vcdocs.dntype = entry(1, s-vcdoctypes).
  vcdocs.dnnum = vccontrs.custom + "/".
  find ncrc where ncrc.code = entry(1, vccontrs.ctvalpl) no-lock no-error.
  vcdocs.pcrc = ncrc.crc.
  run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
end.

procedure noupd.
  bell.
  message skip " Данное действие невозможно! Контракт закрыт либо у Вас нет прав на выполнение данной процедуры." skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
end procedure.


