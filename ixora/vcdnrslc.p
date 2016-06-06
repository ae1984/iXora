/* vcdnrslc.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Просмотра и редактирования рег.свид-ва/лицензии
 * RUN
        верхнее меню сведений о контракте
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        15-1
 * AUTHOR
        18.10.2002 nadejda
 * CHANGES
        29.09.2003 nadejda  - добавлены поля валюты, курса и признака состояния лицензии
        01.07.2004 saltanat - для контрактов типа =5, обязательным является наличие паспорта сделки
        21.09.2004 saltanat - для добавления,редактирования и удаления вставила проверку на то,что акцептующее лицо не может
                              выполнять эти процедуры.
        17.04.2008 galina - для редактирования и удаления удалена проверка на то,что акцептующее лицо не может
                              выполнять эти процедуры.
        28.04.2008 galina - удалена проверка наличия ПС для контрактов типа 5
        11.03.2011 damir - перекомпиляция в связи с добавлением нового поля opertyp
        */


{vc.i}


{mainhead.i VCCONTRS}

def shared var s-contract like vccontrs.contract.
def new shared var s-dnvid as char init "d".
def new shared var s-vcdoctypes as char.
def var v-contrnum as char.


find vccontrs where vccontrs.contract = s-contract no-lock no-error.

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

s-vcdoctypes = "".
for each codfr where codfr.codfr = "vcdoc" and index(s-dnvid, codfr.name[5]) > 0 no-lock:
  s-vcdoctypes = s-vcdoctypes + codfr.code + ",".
end.


{vc-alldoc.i
&option = "vcrslc"
&head = " vcrslc"
&headkey = "rslc "
&frame = "vcdnrslc"
&no-add = " if (vccontrs.sts begins 'c') /*or (chkrights('vcrslcac'))*/ then do: run noupd. next outer. end. "
&no-update = " if (vccontrs.sts begins 'c') /*or (frame-value <> 'Акцепт' and chkrights('vcrslcac'))*/ then do: run noupd. next outer. end. "
&no-del = " if (vccontrs.sts begins 'c') /*or (chkrights('vcrslcac'))*/ then do: run noupd. next outer. end. "
&predisplay = " if avail vcrslc then do: run deftype. if vcrslc.dntype = '22' then run defsts. run defncrc. end.
                else do: v-dntypename = ''. v-stsname = ''. v-nbcrckod = ''. end. "
&display = " vcrslc.dntype v-dntypename
             vcrslc.dnnum vcrslc.dndate
             vcrslc.lastdate vcrslc.ncrc v-nbcrckod vcrslc.sum vcrslc.cursdoc-con vcrslc.sum / vcrslc.cursdoc-con @ v-sumdoccon
             vcrslc.rdt vcrslc.rwho vcrslc.cdt vcrslc.cwho vcrslc.info[1] when vcrslc.dntype = '22'
             v-stsname when vcrslc.dntype = '22' "
&postdisplay = " "
&preupdate = " run deftype. if vcrslc.dntype = '22' then run defsts. run defncrc. "
&update = " update vcrslc.dntype with frame vcdnrslc.
            if vcrslc.dntype entered then run deftype.
            displ v-dntypename with frame vcdnrslc.
            update vcrslc.dnnum with frame vcdnrslc.
            update vcrslc.dndate with frame vcdnrslc.
            if vcrslc.dndate entered then do:
              run crosscurs(vcrslc.ncrc, vccontrs.ncrc, vcrslc.dndate, output vcrslc.cursdoc-con).
              displ vcrslc.cursdoc-con vcrslc.sum / vcrslc.cursdoc-con @ v-sumdoccon with frame vcdnrslc.
            end.
            update vcrslc.lastdate vcrslc.ncrc with frame vcdnrslc.
            if vcrslc.ncrc entered then do:
              run defncrc. run crosscurs(vcrslc.ncrc, vccontrs.ncrc, vcrslc.dndate, output vcrslc.cursdoc-con).
              displ v-nbcrckod vcrslc.cursdoc-con vcrslc.sum / vcrslc.cursdoc-con @ v-sumdoccon with frame vcdnrslc.
            end.

            update vcrslc.sum with frame vcdnrslc.
            if vcrslc.sum entered then
              displ vcrslc.sum / vcrslc.cursdoc-con @ v-sumdoccon with frame vcdnrslc.

            update vcrslc.cursdoc-con with frame vcdnrslc.
            if vcrslc.cursdoc-con entered then
              displ vcrslc.sum / vcrslc.cursdoc-con @ v-sumdoccon with frame vcdnrslc.

            if vcrslc.dntype = '22' then do:
              update vcrslc.info[1] with frame vcdnrslc.
              if vcrslc.info[1] entered then do:
                vcrslc.info[1] = caps(vcrslc.info[1]). run defsts.
                if vcrslc.info[1] = 'Z' then vcrslc.info[2] = string(g-today, '99/99/9999'). else vcrslc.info[2] = ''.
                displ vcrslc.info[1] v-stsname with frame vcdnrslc.
              end.
            end. "

&postupdate = " "
&prefind = " "
&postfind = " "
&precreate = " "
&postcreate = " vcrslc.contract = s-contract.
                vcrslc.dndate = g-today. vcrslc.lastdate = vccontrs.lastdate.
                vcrslc.ncrc = vccontrs.ncrc. vcrslc.cursdoc-con = 1.
                if vcrslc.dntype = '22' then do: vcrslc.info[1] = 'R'. run defsts. end. "
&predelete = " "
&delete = " delete vcrslc. "
&postdelete = " "
}

procedure deftype.
  find codfr where codfr.codfr = 'vcdoc' and codfr.code = vcrslc.dntype no-lock no-error.
  if avail codfr then v-dntypename = codfr.name[2]. else v-dntypename = ''.
end.

procedure noupd.
  bell.
  message skip " Данное действие невозможно! Контракт закрыт либо у Вас нет прав на выполнение данной процедуры." skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
end procedure.

procedure defsts.
  find bookcod where bookcod.bookcod = "vclic" and bookcod.code = vcrslc.info[1] no-lock no-error.
  v-stsname = bookcod.name.
end.

procedure defncrc.
  find ncrc where ncrc.crc = vcrslc.ncrc no-lock no-error.
  if avail ncrc then v-nbcrckod = ncrc.code.
  else v-nbcrckod = ''.
end.
