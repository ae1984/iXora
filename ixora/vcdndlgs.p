/* vcdndlgs.p
 * MODULE
        Валютный контроль/Клиенты и контракты
 * DESCRIPTION
        Данные долгов по контракту
 * RUN
        Через меню "Долги"
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Меню "Долги"
 * AUTHOR
        21/06/04 saltanat
 * CHANGES
        01.07.2004 saltanat - для контрактов типа =5, обязательным является наличие паспорта сделки
        25.04.2008 galina - удалена проверка наличия ПС для контрактов типа 5
        28.12.2010 aigul - передала вкладку для вычисления залогов
        27.01.2011 aigul - экспорт тип 26 и импорт тип 27 NO
                           экспорт тип 27 и импорт тип 26 YES
*/

{vc.i}


{mainhead.i VCCONTRS}

def shared var s-contract like vccontrs.contract.
def shared var s-vcdoctypes as char.
def shared var s-dnvid as char.
def var v-contrnum as char.

find vccontrs where vccontrs.contract = s-contract no-lock no-error.

if vccontrs.cttype <> "1" then DO:
    message "Залог можно создать только для документов 1-го типа!" VIEW-AS ALERT-BOX.
    RETURN.
end.

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

{vc-dolgs.i
  &option = "vcdolgs"
  &head = " vcdolgs"
  &headkey = "dolgs"
  &frame = "vcdndlg"
  &start = " "
  &no-add = " if vccontrs.sts begins 'c' then do: run noupd. next outer. end. "
  &no-update = " if vccontrs.sts begins 'c' then do: run noupd. next outer. end. "
  &no-del = " if vccontrs.sts begins 'c' then do: run noupd. next outer. end. "
  &predisplay = /*"if avail vcdolgs then do:
                   run deftypename.
                 end. "*/
                 " if avail vcdolgs then do: run defcrckod. run deftypename. run defpartner. run defprocent. end.
     else do: v-crckod = ''. v-dntypename = ''. v-partner = ''. end. "
  &display = " vcdolgs.dntype v-dntypename vcdolgs.rdt vcdolgs.rwho vcdolgs.cdt vcdolgs.cwho
               vcdolgs.pdt vcdolgs.pwho vcdolgs.dnnum /*vcdolgs.dnvn vcdolgs.dnpg vcdolgs.dopsv*/
               vcdolgs.dndate vcdolgs.pdt vcdolgs.pwho vcdolgs.payret vcdolgs.sumpercent
               vcdolgs.info[2] vcdolgs.pcrc vcdolgs.sum
               vcdolgs.cursdoc-con vcdolgs.sum / vcdolgs.cursdoc-con @ v-sumdoccon vcdolgs.info[4]
               vcdolgs.knp vcdolgs.origin vcdolgs.kod14 vcdolgs.info[1]"
  &postdisplay = " "
  &preupdate = " run deftypename. "
  &update = "  do transaction on endkey undo, return:
                 run pro-upd.
              end.
            "
  &postupdate = " run vcctsumm. if vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1' then
     run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
     displ v-sumost1 v-suminv v-sumkon v-sumexc v-sumgtd v-sumplat v-sumakt v-sumost v-sumexc% v-term v-sumzalog with frame vcctsumm."
  &precreate = " "
  &postcreate = " run ppostcr. "
  &predelete = " "
  &delete = " delete  vcdolgs. "
  &postdelete = " run vcctsumm. if vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1' then
      run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
      displ v-sumost1 v-suminv v-sumkon v-sumexc v-sumgtd v-sumplat v-sumakt v-sumost v-sumexc% v-term v-sumzalog with frame vcctsumm. "
  &no-pog = " if vccontrs.sts begins 'c' then do: run noupd. next outer. end. "
  &prepog = " "
  &pog = " run pogashenie. "
  &postpog = " "
  }
procedure deftypename.
  find codfr where codfr.codfr = "vcdoc" and codfr.code = vcdolgs.dntype no-lock no-error.
  if avail codfr then v-dntypename = codfr.name[2]. else v-dntypename = "".
end procedure.
procedure defpaid.
  def var i as integer.
  if vcdolgs.info[1] <> '' then do:
    repeat i = 1 to num-entries(vcdolgs.info[1], ';'):
      find b-vcdolgs where (b-vcdolgs.dntype = '26' or b-vcdolgs.dntype = '27') and
         b-vcdolgs.dnnum = entry(i, vcdolgs.info[1], ';') exclusive-lock no-error.
      if avail b-vcdolgs then b-vcdolgs.info[5] = 'paid'.
    end.
  end.
end procedure.

procedure defcrckod.
  find ncrc where ncrc.crc = vcdolgs.pcrc no-lock no-error.
  if avail ncrc then v-crckod = ncrc.code. else v-crckod = ''.
end procedure.

procedure defpartner.
  find vcpartners where vcpartners.partner = vcdolgs.info[4] no-lock no-error.
  if avail vcpartners then v-partner = vcpartners.name.
                      else v-partner = "".
  v-locatben = (avail vcpartners and vcpartners.country = "KZ").
end.

procedure pogashenie.
  vcdolgs.pdt = g-today.
  vcdolgs.pwho = g-ofc.
end procedure.



procedure ppostcr.
  vcdolgs.contract = s-contract.
  vcdolgs.dndate = g-today.
  /*vcdolgs.dnvn = g-today.
  vcdolgs.dnpg = g-today.*/
  vcdolgs.dntype = "26".
  if (vccontrs.expimp = 'i' and  vcdolgs.dntype = '26') or (vccontrs.expimp = 'e' and  vcdolgs.dntype = '27') then vcdolgs.payret = yes.
  if (vccontrs.expimp = 'e' and  vcdolgs.dntype = '26') or (vccontrs.expimp = 'i' and  vcdolgs.dntype = '27') then vcdolgs.payret = no.
  find ncrc where ncrc.code = entry(1, vccontrs.ctvalpl) no-lock no-error.
  if avail ncrc then vcdolgs.pcrc = ncrc.crc.
end.

procedure noupd.
  bell.
  message skip " Контракт закрыт !" skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
end procedure.

procedure pro-upd.
    update vcdolgs.dntype with frame vcdndlg.
    run deftypename. displ v-dntypename with frame vcdndlg.
    if (vccontrs.expimp = 'i' and  vcdolgs.dntype = '26') or (vccontrs.expimp = 'e' and  vcdolgs.dntype = '27') then vcdolgs.payret = yes.
    if (vccontrs.expimp = 'e' and  vcdolgs.dntype = '26') or (vccontrs.expimp = 'i' and  vcdolgs.dntype = '27') then vcdolgs.payret = no.
        DISPL vcdolgs.payret with frame vcdndlg.
     update vcdolgs.dnnum with frame vcdndlg.
     update vcdolgs.dndate with frame vcdndlg.
     if vcdolgs.dndate entered then do:
       run crosscurs(vcdolgs.pcrc, vccontrs.ncrc, vcdolgs.dndate, output vcdolgs.cursdoc-con).
       displ vcdolgs.cursdoc-con vcdolgs.sum / vcdolgs.cursdoc-con @ v-sumdoccon
       with frame vcdndlg.
     end.
     update vcdolgs.pdt vcdolgs.pwho = g-ofc with frame vcdndlg.
     if vcdolgs.pdt entered then do:
       run crosscurs(vcdolgs.pcrc, vccontrs.ncrc, vcdolgs.dndate, output vcdolgs.cursdoc-con).
       displ vcdolgs.cursdoc-con vcdolgs.sum / vcdolgs.cursdoc-con @ v-sumdoccon
       with frame vcdndlg.
     end.
     update vcdolgs.sumpercent
        with frame vcdndlg.
     if vccontrs.cttype = '6' then do:
       update vcdolgs.info[2] with frame vcdndlg.
       if vcdolgs.info[2] entered then run defprocent.
       display v-procent with frame vcdndlg.
     end.
     update vcdolgs.pcrc with frame vcdndlg.
     if vcdolgs.pcrc entered then do:
        run defcrckod.
        run crosscurs(vcdolgs.pcrc, vccontrs.ncrc, vcdolgs.dndate, output vcdolgs.cursdoc-con).
        displ v-crckod vcdolgs.cursdoc-con vcdolgs.sum / vcdolgs.cursdoc-con @ v-sumdoccon
        with frame vcdndlg.
     end.
     update vcdolgs.sum with frame vcdndlg.
     if vcdolgs.sum entered then displ vcdolgs.sum / vcdolgs.cursdoc-con @ v-sumdoccon with frame vcdndlg.
     update vcdolgs.cursdoc-con with frame vcdndlg.
     if vcdolgs.cursdoc-con entered then
       displ vcdolgs.sum / vcdolgs.cursdoc-con @ v-sumdoccon with frame vcdndlg.
     if index('p', s-dnvid) > 0 then do:
       update vcdolgs.info[4] with frame vcdndlg.
       run defpartner. displ v-partner v-locatben with frame vcdndlg.
     end.
     update vcdolgs.knp
            vcdolgs.origin vcdolgs.kod14 when index('p', s-dnvid) > 0 or vcdolgs.dntype = '26' or vcdolgs.dntype = '27'
            vcdolgs.info[1] /*vcdolgs.udt = g-today vcdolgs.uwho = g-ofc*/
     with frame vcdndlg.
end procedure.