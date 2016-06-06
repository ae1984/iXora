/* vcblk076.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Список блокированных сумм на транзитных счетах с возможностью разблокирования, перевода на другой ARP,
             создания возвратного внешнего платежа, отмены транзакции по разблокировке
 * RUN
        главное меню
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        15-7
 * AUTHOR
        15.10.2003 nadejda
 * BASES
        BANK COMM
 * CHANGES
        14.11.2003 nadejda  - печать операц.ордера перенесена после создания joudoc
        25.11.2003 nadejda  - проставление статуса 6, если не нужен дополнительный контроль
        13/05/2004 madiar   - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        19.07.2004 saltanat - Реализована выборка блокированных сумм на дату.
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
        22.07.2005 saltanat - Внесла возможность просмотра заблокированных сумм для опер. департамента.
        13.01.2006 nataly   - добавила проверку на заполнение справочников zsgavail, zdcavail
        15/08/2006 u00600   - оптимизация
        28/07/2009 galina   - добавила формирование возвратного платежа при нажатии на кнопку "ВОЗВРАТ"
        15/03/2010 galina   - расширила поле счета до 21 символа
        16/03/2010 galina   - явно указала ширину фрейма f1
        18.05.2012 aigul    - блокировка суммы - тз962
        30.05.2012 aigul    - добавила блокировку суммы с ЦО ТЗ 1369, увеличила число строк назначения платежа
        13.06.2012 damir    - добавил keyord.i, printvouord, передавать в trxgen (jou0036,jou0033) КОд из sub-cod.ccod = "eknp".
*/

{mainhead.i}
{vc.i}
{comm-txb.i}
{lgps.i new}
{keyord.i}

def var v-dt as date.
def var s-vcourbank as char.
def var v-proftcn as char.
def var v-proftname as char.
DEFINE VARIABLE method-return AS LOGICAL.
def var i AS INTEGER.
def var v-msgerr as char.
def var v-teklgr as char.
def var v-acc as char.
def new shared var s-jh like jh.jh.
def var v-delim as char init "|".
define variable rcode   as integer.
define variable rdes    as character.
def var v-ans as logical.
def var v-control as logical.
def var v-str as char.
def var v-knp as char.
def var v-cgeo as char.
def var dvjh like jh.jh.
def var v-docnum as char.
def var v-accname as char.
def var v-knpname as char.
def var v-days as integer init 180.
def new shared var s-remtrz like remtrz.remtrz.
def new shared var v-option as char.
define new shared variable s-newrec as logical.
def var v-gavail as char.
def var v-cavail as char.
def var v-gavail1 as char.
def var v-cavail1 as char.
def var v-detail1 as char.
def var v-detail2 as char.
def var v-detail3 as char.
def var v-detail4 as char.
def var v-detail5 as char.
def var v-detail6 as char.

def new shared temp-table t-block like vcblock.


def var v-sts like jh.sts.

def var v-lookdep as char init '103'.


form
   skip(1)
   v-dt label ' На дату: ' format '99/99/9999' skip(1)
   with centered side-label row 5 title "УКАЖИТЕ ДАТУ" frame f-dt.

v-dt = g-today.

update v-dt with frame f-dt.

s-vcourbank = comm-txb().

find sysc where sysc.sysc = "vc-agr" no-lock no-error.
if avail sysc then v-teklgr = sysc.chval.
else do:
  message skip " Не найдена настройка ""VC-AGR"" : список групп текущих счетов !" skip(1)
    view-as alert-box title " ОШИБКА ! ".
  return.
end.

/* найти контрольное количество дней просрочки */
find vcparams where vcparams.parcode = "dayerror" no-lock no-error.
if avail vcparams then v-days = vcparams.valinte.


find ofc where ofc.ofc = g-ofc no-lock no-error.
v-proftcn = ofc.titcd.
find codfr where codfr.codfr = "sproftcn" and codfr.code = v-proftcn no-lock no-error.
if avail codfr then v-proftname = caps(codfr.name[1]).
               else v-proftname = "НЕИЗВЕСТНЫЙ ДЕПАРТАМЕНТ".

/* найти контролера для данного офицера */
v-control = (lookup("manager", ofc.tit) = 0).
if v-control then do:
  /* если сам не контролер, поищем живого контролера по списку */
  v-str = ofc.tit.
  v-control = no.
  do i = 1 to NUM-ENTRIES(v-str):
    find ofc where ofc.ofc = entry(i, v-str) no-lock no-error.
    if avail ofc and lookup("manager", ofc.tit) > 0 then do:
      v-control = yes.
      leave.
    end.
  end.
end.

DEFINE QUERY q1 FOR vcblock, crc.

def browse b1
  query q1 no-lock
  display
      vcblock.arp label "ТРНЗ.СЧЕТ" format "x(21)"
      vcblock.remname format "x(30)" label "ПОЛУЧАТЕЛЬ"
      vcblock.rdt label "ДАТА БЛК" format "99/99/99"
      vcblock.amt format "zzz,zzz,zz9.99" label "БЛОКИРОВ.СУММА"
      crc.code label "ВАЛ"
      (g-today - vcblock.rdt) format "zz9" label "ДНИ"
  with 9 down separators single
       title " ТРАНЗИТНЫЕ СЧЕТА ВАЛЮТ.КОНТРОЛЯ : " + trim(substr(v-proftname, 1, 45)) no-labels.

DEFINE BUTTON bsend  LABEL "ЗАЧИСЛИТЬ КЛИЕНТУ".
DEFINE BUTTON barp  LABEL "ЗАЧИСЛИТЬ НА ARP-КАРТ.".
DEFINE BUTTON breturn  LABEL "ВОЗВРАТ".
DEFINE BUTTON bstorno  LABEL "ОТМЕНИТЬ РАЗБЛОК.".

def frame f1
    b1
    skip
    space(2)
    bsend
    space(1)
    barp
    space(1)
    breturn
    space(1)
    bstorno
    with row 3 centered width 92.

def frame f2
  vcblock.remtrz no-label
  "->"
  vcblock.remdetails format "x(63)" no-label
  with row 22 centered width 80.


/* в нижней строке выводим детали платежа */
ON VALUE-CHANGED OF b1 in frame f1 DO:
  if num-results("q1") > 0 then
    DISPLAY vcblock.remtrz vcblock.remdetails WITH FRAME f2.
  else
    hide frame f2 no-pause.
END.


/* функция проверки введенного номера клиентского счета в validate */
function chk-acc returns logical (p-value as char).
  if p-value = "" then do:
    v-msgerr = " Укажите счет клиента для зачисления средств!".
    return false.
  end.

  find aaa where aaa.aaa = p-value no-lock no-error.
  if not avail aaa then do:
    v-msgerr = " Счет не найден!".
    return false.
  end.

  if aaa.sta = "C" then do:
    v-msgerr = " Указанный счет закрыт!".
    return false.
  end.

  if lookup (aaa.lgr, v-teklgr) = 0 then do:
    v-msgerr = " Указанный счет не является текущим счетом!".
    return false.
  end.

  if aaa.crc <> vcblock.crc then do:
    find crc where crc.crc = aaa.crc no-lock no-error.
    v-msgerr = " Валюта указанного счета (" + crc.code + ") не совпадает с валютой платежа!".
    return false.
  end.

  return true.
end function.


/* функция проверки введенного номера ARP-счета в validate */
function chk-arp returns logical (p-value as char).
  if p-value = "" then do:
    v-msgerr = " Укажите номер ARP-карточки для зачисления средств!".
    return false.
  end.

  find arp where arp.arp = p-value no-lock no-error.
  if not avail arp then do:
    v-msgerr = " ARP-карточка не найдена!".
    return false.
  end.

  if arp.crc <> vcblock.crc then do:
    find crc where crc.crc = arp.crc no-lock no-error.
    v-msgerr = " Валюта указанной ARP-карточки (" + crc.code + ") не совпадает с валютой платежа!".
    return false.
  end.

  return true.
end function.



/* для запроса номера клиентского счета */
def frame f-acc
  skip(1)
  v-acc label "   Текущий счет клиента" format "x(21)"
    help " Счет клиента для зачисления блокированных средств"
    validate (chk-acc (v-acc), v-msgerr)
  v-accname no-label format "x(40)" colon 35 " " skip
  v-knp label " Код назначения платежа" format "xxx"
    help " F2 - список кодов назначения платежа"
    validate (v-knp <> "" and can-find (codfr where codfr.codfr = "spnpl" and codfr.code = v-knp no-lock), " КНП не найден!")
  v-knpname no-label format "x(40)" colon 35 " " skip(1)
  v-gavail label " Справочник наличия записи" format "xxx"
    help " F2 - список наличия записи"
    validate (v-gavail <> "" and can-find (codfr where codfr.codfr = "zsgavail" and codfr.code = v-gavail no-lock), " Код наличия записи не найден!")
  v-cavail label " Справочник наличия документов" format "xxx"
    help " F2 - список наличия документов"
    validate (v-cavail <> "" and can-find (codfr where codfr.codfr = "zdcavail" and codfr.code = v-cavail no-lock), " Код наличия док-тов не найден!")
  v-detail1 label "Назначение платежа" format "x(35)" skip
  v-detail2 label "" format "x(35)" skip
  v-detail3 label "" format "x(35)" skip
  v-detail4 label "" format "x(35)" skip
  v-detail5 label "" format "x(35)" skip
  v-detail6 label "" format "x(35)" skip
  with centered overlay row 10 side-labels title " СЧЕТ ПОЛУЧАТЕЛЯ ".



/* для запроса номера ARP-счета */
def frame f-arp
  skip(1)
  v-acc label "           ARP-карточка" format "x(21)"
    help " ARP-карточка для зачисления блокированных средств"
    validate (chk-arp (v-acc), v-msgerr)
  v-accname no-label format "x(40)" colon 35 " " skip
  v-knp label " Код назначения платежа" format "xxx"
    help " F2 - список кодов назначения платежа"
    validate (v-knp <> "" and can-find (codfr where codfr.codfr = "spnpl" and codfr.code = v-knp no-lock), " КНП не найден!")
  v-knpname no-label format "x(40)" colon 35 " " skip(1)
  v-gavail label " Справочник наличия записи" format "xxx"
    help " F2 - список наличия записи"
    validate (v-gavail <> "" and can-find (codfr where codfr.codfr = "zsgavail" and codfr.code = v-gavail no-lock), " Код наличия записи не найден!")
  v-cavail label " Справочник наличия документов" format "xxx"
    help " F2 - список наличия документов"
    validate (v-cavail <> "" and can-find (codfr where codfr.codfr = "zdcavail" and codfr.code = v-cavail no-lock), " Код наличия док-тов не найден!")
  v-detail1 label "Назначение платежа" format "x(35)" skip
  v-detail2 label "" format "x(35)" skip
  v-detail3 label "" format "x(35)" skip
  v-detail4 label "" format "x(35)" skip
  v-detail5 label "" format "x(35)" skip
  v-detail6 label "" format "x(35)" skip
  with centered overlay row 10 side-labels title " СЧЕТ ПОЛУЧАТЕЛЯ ".



on help of v-gavail in frame f-acc do:
   run h-codfr ('zsgavail', output v-gavail1).
   v-gavail = v-gavail1.
   displ v-gavail with frame f-acc.
 end.

on help of v-cavail in frame f-acc do:
   run h-codfr ('zdcavail', output v-cavail1).
   v-cavail = v-cavail1.
   displ v-cavail with frame f-acc.
 end.

on help of v-gavail in frame f-arp do:
   run h-codfr ('zsgavail', output v-gavail1).
   v-gavail = v-gavail1.
   displ v-gavail with frame f-arp.
end.

on help of v-cavail in frame f-arp do:
   run h-codfr ('zdcavail', output v-cavail1).
   v-cavail = v-cavail1.
   displ v-cavail with frame f-arp.
 end.


/* кнопка ЗАЧИСЛИТЬ КЛИЕНТУ */
ON CHOOSE OF bsend IN FRAME f1 do:

  if lookup(v-proftcn,v-lookdep) > 0 then return.

  DO i = b1:NUM-SELECTED-ROWS TO 1 by -1 transaction on error undo, retry:
    method-return = b1:FETCH-SELECTED-ROW(i).
    GET CURRENT q1 NO-LOCK.
    find current vcblock no-lock.


    /* счет получателя попытаемся найти в платеже */
    v-acc = "".
    find remtrz where remtrz.remtrz = vcblock.remtrz no-lock no-error.
    if not avail remtrz then
    find remtrz where substr(remtrz.sqn,7,10) = vcblock.remtrz no-lock no-error.
    v-str = remtrz.racc.
    v-detail1 = remtrz.det[1].
    v-detail2 = remtrz.det[2].
    v-detail3 = remtrz.det[3].
    v-detail4 = substr(remtrz.det[4],1,35).
    v-detail5 = substr(remtrz.det[4],36,35).
    v-detail6 = substr(remtrz.det[4],71,35).

    if v-str = "" then v-str = remtrz.ba.
    v-str = trim (v-str).
    if index (v-str, "/") > 0 then do:
      if index (v-str, "/") = 1 or index (v-str, "/") = length(v-str) then v-str = replace (v-str, "/", "").
    end.

    if v-str <> "" and can-find (aaa where aaa.aaa = v-str and aaa.crc = vcblock.crc no-lock) then   v-acc = v-str.

    /* Dt резидентство по геокоду ARP */
    find arp where arp.arp = vcblock.arp no-lock no-error.
    if length(trim(arp.geo)) >= 3 then v-str = substr (trim(arp.geo), 3, 1).
    else do:
      message skip " Не найдены сведения о резидентстве для ARP-карточки :" skip
                     arp.arp arp.des "!" skip(1) view-as alert-box title " ОШИБКА ! ".
      return.
    end.
    if lookup (v-str, "1,2") = 0 then v-str = "2".

    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.ccod = "eknp" no-lock no-error.
    if avail sub-cod then v-str = substr(sub-cod.rcode,1,1).

    /* КНП попробуем взять из платежа */
    find sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = vcblock.remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod and num-entries (sub-cod.rcode) >= 3 then v-knp = entry(3, sub-cod.rcode).

      /* Наличие записи попробуем взять из платежа */
    find sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = vcblock.remtrz and sub-cod.d-cod = "zsgavail" no-lock no-error.
    if avail sub-cod  then v-gavail = sub-cod.ccode.

    /* Наличие док-тов попробуем взять из платежа */
    find sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = vcblock.remtrz and sub-cod.d-cod = "zdcavail" no-lock no-error.
    if avail sub-cod  then v-cavail = sub-cod.ccode.

    update v-acc with frame f-acc.
    find aaa where aaa.aaa = v-acc no-lock no-error.
    find cif where cif.cif = aaa.cif no-lock no-error.
    v-accname = trim(trim(cif.prefix) + " " + trim(cif.sname)).
    displ v-accname with frame f-acc.

    update v-knp with frame f-acc.
    find codfr where codfr.codfr = "spnpl" and codfr.code = v-knp no-lock no-error.
    v-knpname = codfr.name[1] + codfr.name[2] + codfr.name[3] + codfr.name[4].
    displ v-knpname with frame f-acc.

    update v-gavail v-cavail v-detail1 v-detail2 v-detail3 v-detail4 v-detail5 v-detail6 with frame f-acc.

    find remtrz where remtrz.remtrz = vcblock.remtrz exclusive-lock no-error.
    if not avail remtrz then
    find remtrz where substr(remtrz.sqn,7,10) = vcblock.remtrz exclusive-lock no-error.
    remtrz.det[1] = v-detail1.
    remtrz.det[2] = v-detail2.
    remtrz.det[3] = v-detail3.
    remtrz.det[4] = v-detail4 + v-detail5 + v-detail6.

    find current vcblock exclusive-lock.
    vcblock.remdetails = v-detail1 + v-detail2 + v-detail3 + v-detail4 + v-detail5 + v-detail6.
     /*меняем значение*/
    find sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = vcblock.remtrz and sub-cod.d-cod = "zsgavail"  exclusive-lock no-error.
    if avail sub-cod  then sub-cod.ccode = v-gavail .

    find sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = vcblock.remtrz and sub-cod.d-cod = "zdcavail" no-error.
    if avail sub-cod  then sub-cod.ccode = v-cavail.


    /* параметры для шаблона */
    v-str = "" + v-delim +
            string(vcblock.amt) + v-delim +
            string(vcblock.crc) + v-delim +
            vcblock.arp + v-delim +
            v-acc + v-delim +
            "Валютный контроль. Зачисление средств " + vcblock.remtrz + " " +
            vcblock.remdetails /*+ " (" + vcblock.remname + ")"*/ + v-delim +
             v-str + v-delim +                                                        /* резидентство по дебету */
             v-knp.

    v-ans = no.
    message " Провести транзакцию на счет клиента ? " update v-ans.

    s-jh = 0.

    if v-ans then DO TRANSACTION on error undo, retry :
      /* будем делать проводку! */

      run trxgen("JOU0033", v-delim, v-str, "cif", "",
                   output rcode, output rdes, input-output s-jh).
      if rcode ne 0 then do:
          message rdes.
          pause.
          undo, return.
      end.

      /* если есть контролер для данного офицера - поставить статус 5, если нет - статус 6 */
      run trxsts (s-jh, if v-control then 5 else 6, output rcode, output rdes).
      if rcode <> 0 then do:
          message rdes.
          pause.
          undo, return.
      end.

      /* если есть контролер для данного офицера - наложить специнструкцию до контроля */
      if v-control then do:
        run jou42-aasnew (vcblock.arp, v-acc, vcblock.amt, s-jh).
      end.
    end.

    if s-jh <> 0 then do:
      /* только если была транзакция - пишем данные в таблицу, создаем jou-документ и удаляем строки списка */

      GET CURRENT q1 EXCLUSIVE-LOCK.

      find current vcblock exclusive-lock.
      assign vcblock.sts = "C"
             vcblock.acc = v-acc
             vcblock.jh2 = s-jh
             vcblock.deldt = g-today
             vcblock.delwho = g-ofc
             vcblock.cif = aaa.cif.
             vcblock.remdetails = v-detail1 + v-detail2 + v-detail3 + v-detail4 + v-detail5 + v-detail6.
      find current vcblock no-lock.

      run vcjoudoc (s-jh, "2", output v-docnum).

      find current vcblock exclusive-lock.
      vcblock.retremtrz = v-docnum.
      find current vcblock no-lock.

      /* 1 экземпляр ордера */
      if v-noord = no then run vou_bank(2).
      else run printvouord(2).

      /* перерисуем список */
      run reopen (yes).

    end.
  END.
end.

/* кнопка ЗАЧИСЛИТЬ НА ARP-КАРТ. */
ON CHOOSE OF barp IN FRAME f1 do:

  if lookup(v-proftcn,v-lookdep) > 0 then return.

  DO i = b1:NUM-SELECTED-ROWS TO 1 by -1 transaction on error undo, retry:
    method-return = b1:FETCH-SELECTED-ROW(i).
    GET CURRENT q1 NO-LOCK.
    find current vcblock no-lock.


    /* счет получателя попытаемся найти в платеже */
    v-acc = "".
    find remtrz where remtrz.remtrz = vcblock.remtrz no-lock no-error.
    if not avail remtrz then
    find remtrz where substr(remtrz.sqn,7,10) = vcblock.remtrz no-lock no-error.
    v-str = remtrz.racc.
    v-detail1 = remtrz.det[1].
    v-detail2 = remtrz.det[2].
    v-detail3 = remtrz.det[3].
    v-detail4 = substr(remtrz.det[4],1,35).
    v-detail5 = substr(remtrz.det[4],36,35).
    v-detail6 = substr(remtrz.det[4],71,35).

    if v-str = "" then v-str = remtrz.ba.
    v-str = trim (v-str).
    if index (v-str, "/") > 0 then do:
      if index (v-str, "/") = 1 or index (v-str, "/") = length(v-str) then v-str = replace (v-str, "/", "").
    end.

    if v-str <> "" and can-find (arp where arp.arp = v-str and arp.crc = vcblock.crc no-lock) then
      v-acc = v-str.

    /* Dt резидентство по геокоду ARP */
    find arp where arp.arp = vcblock.arp no-lock no-error.
    if length(trim(arp.geo)) >= 3 then v-str = substr (trim(arp.geo), 3, 1).
    else do:
      message skip " Не найдены сведения о резидентстве для ARP-карточки :" skip
              arp.arp arp.des "!" skip(1)
        view-as alert-box title " ОШИБКА ! ".
      return.
    end.
    if lookup (v-str, "1,2") = 0 then v-str = "2".

    /* КНП попробуем взять из платежа */
    find sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = vcblock.remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod and num-entries (sub-cod.rcode) >= 3 then v-knp = entry(3, sub-cod.rcode).


    /* Наличие записи попробуем взять из платежа */
    find sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = vcblock.remtrz and sub-cod.d-cod = "zsgavail" no-lock no-error.
    if avail sub-cod  then v-gavail = sub-cod.ccode.

    /* Наличие док-тов попробуем взять из платежа */
    find sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = vcblock.remtrz and sub-cod.d-cod = "zdcavail" no-lock no-error.
    if avail sub-cod  then v-cavail = sub-cod.ccode.


    update v-acc with frame f-arp.
    find arp where arp.arp = v-acc no-lock no-error.
    v-accname = arp.des.
    displ v-accname with frame f-arp.


    update v-knp with frame f-arp.
    find codfr where codfr.codfr = "spnpl" and codfr.code = v-knp no-lock no-error.
    v-knpname = codfr.name[1] + codfr.name[2] + codfr.name[3] + codfr.name[4].
    displ v-knpname with frame f-arp.

    update v-gavail v-cavail v-detail1 v-detail2 v-detail3 v-detail4 v-detail5 v-detail6 with frame f-arp.

    find remtrz where remtrz.remtrz = vcblock.remtrz exclusive-lock no-error.
    if not avail remtrz then
    find remtrz where substr(remtrz.sqn,7,10) = vcblock.remtrz exclusive-lock no-error.
    remtrz.det[1] = v-detail1.
    remtrz.det[2] = v-detail2.
    remtrz.det[3] = v-detail3.
    remtrz.det[4] = v-detail4 + v-detail5 + v-detail6.


    find current vcblock exclusive-lock.
    vcblock.remdetails = v-detail1 + v-detail2 + v-detail3 + v-detail4 + v-detail5 + v-detail6.
     /*меняем значение*/
    find sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = vcblock.remtrz and sub-cod.d-cod = "zsgavail"  exclusive-lock no-error.
    if avail sub-cod  then sub-cod.ccode = v-gavail .
    find sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = vcblock.remtrz and sub-cod.d-cod = "zdcavail"  no-error.
    if avail sub-cod  then sub-cod.ccode = v-cavail.



    /* Kt резидентство по геокоду указанного ARP */
    if length(trim(arp.geo)) >= 3 then v-cgeo = substr (trim(arp.geo), 3, 1).
    else do:
      message skip " Не найдены сведения о резидентстве для ARP-карточки :" skip
              arp.arp arp.des "!" skip(1)
        view-as alert-box title " ОШИБКА ! ".
      return.
    end.
    if lookup (v-cgeo, "1,2") = 0 then v-cgeo = "2".

    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.ccod = "eknp" no-lock no-error.
    if avail sub-cod then v-str = substr(sub-cod.rcode,1,1).

    /* параметры для шаблона */
    v-str = "" + v-delim +
            string(vcblock.amt) + v-delim +
            string(vcblock.crc) + v-delim +
            vcblock.arp + v-delim +
            v-acc + v-delim +
            "Валютный контроль. Перевод средств " + vcblock.remtrz + " " +
            vcblock.remdetails /*+ " (" + vcblock.remname + ")"*/ + v-delim +
             v-str + v-delim +                                                        /* резидентство по дебету */
             v-cgeo + v-delim +                                                       /* резидентство по кредиту */
             v-knp.

    v-ans = no.
    message " Провести транзакцию на ARP-карточку ? " update v-ans.

    s-jh = 0.

    if v-ans then DO TRANSACTION on error undo, retry :
      /* будем делать проводку! */

      run trxgen("JOU0036", v-delim, v-str, "arp", "",
                   output rcode, output rdes, input-output s-jh).
      if rcode ne 0 then do:
          message rdes.
          pause.
          undo, return.
      end.

      /* если есть контролер для данного офицера - поставить статус 5, если нет - статус 6 */
      run trxsts (s-jh, if v-control then 5 else 6, output rcode, output rdes).
      if rcode <> 0 then do:
          message rdes.
          pause.
          undo, return.
      end.
    end.

    if s-jh <> 0 then do:
      /* только если была транзакция - пишем данные в таблицу, создаем jou-документ и удаляем строки списка */
      GET CURRENT q1 EXCLUSIVE-LOCK.
      find current vcblock exclusive-lock.
      assign vcblock.sts = "C"
             vcblock.acc = v-acc
             vcblock.jh2 = s-jh
             vcblock.deldt = g-today
             vcblock.delwho = g-ofc
             vcblock.cif = arp.cif.
             vcblock.remdetails = v-detail1 + v-detail2 + v-detail3 + v-detail4 + v-detail5 + v-detail6.
      find current vcblock no-lock.

      run vcjoudoc (s-jh, "4", output v-docnum).

      find current vcblock exclusive-lock.
      vcblock.retremtrz = v-docnum.
      find current vcblock no-lock.
      /* 1 экземпляр ордера */

      if v-noord = no then run vou_bank(2).
      else run printvouord(2).

      /* перерисуем список */
      run reopen (yes).

    end.
  END.
end.


/* кнопка ВОЗВРАТ */
ON CHOOSE OF breturn IN FRAME f1 do:
  if lookup(v-proftcn,v-lookdep) > 0 then return.

  DO i = b1:NUM-SELECTED-ROWS TO 1 by -1 transaction on error undo, retry:
    method-return = b1:FETCH-SELECTED-ROW(i).
    GET CURRENT q1 NO-LOCK.
    find current vcblock no-lock.
    run vcretcall(vcblock.remtrz,vcblock.bank).

    if s-remtrz <> "" then do:
      /* только если был создан платеж - пишем данные в таблицу и удаляем строки списка */
      GET CURRENT q1 EXCLUSIVE-LOCK.

      find current vcblock exclusive-lock.
      assign vcblock.sts = "R"
             vcblock.retremtrz = s-remtrz
             vcblock.deldt = g-today
             vcblock.delwho = g-ofc.
      find current vcblock no-lock.

      /* перерисуем список */
      run reopen (yes).

    end.
    else run reopen (no).
  END.
end.


/* кнопка ОТМЕНА РАЗБЛОКИРОВКИ */
ON CHOOSE OF bstorno IN FRAME f1 do:

  if lookup(v-proftcn,v-lookdep) > 0 then return.

  /* выбрать среди разблокированных сумм нужную, удалить/сторнировать проводку, снять специнструкцию если есть, проставить признак блокировки */

  /* собрать все ранее разблокированные суммы */
  for each t-block: delete t-block. end.
  for each vcblock where vcblock.bank = s-vcourbank and vcblock.jh2 <> 0 and vcblock.sts <> "B" and vcblock.depart = v-proftcn no-lock:
    create t-block.
    buffer-copy vcblock to t-block.
    if vcblock.cif = "" then do:
      find arp where arp.arp = vcblock.acc no-lock no-error.
      if avail arp then t-block.remname = arp.des.
    end.
    else do:
      find cif where cif.cif = vcblock.cif no-lock no-error.
      if avail cif then t-block.remname = trim(trim(cif.sname) + " " + trim(cif.prefix)).
    end.
  end.

  /* выбрать проводку для блокировки по новой */
  s-remtrz = "".
  run vcchblock (output s-remtrz).

  if s-remtrz <> "" then do:
    find vcblock where vcblock.bank = s-vcourbank and vcblock.remtrz = s-remtrz no-lock no-error.
    s-jh = vcblock.jh2.

    if vcblock.jh2 <> 0 then do:
      find first jl where jl.jh = vcblock.jh2 no-lock no-error.
      if avail jl then do:
        find crc where crc.crc = vcblock.crc no-lock no-error.
        find t-block where vcblock.bank = s-vcourbank and t-block.remtrz = s-remtrz no-lock no-error.
        v-str = trim(substr(t-block.remname, 1, 30)).
        if length(v-str) < 30 then v-str = v-str + fill (" ", 30 - length(v-str)).

        v-ans = no.
        message skip " Удалить транзакцию по разблокировке валютных средств ?"
                skip(1) "               N :" trim(string(vcblock.jh2, ">>>>>>>9")) + fill (" ", 30 - length(trim(string(vcblock.jh2, ">>>>>>>9"))))
                skip    "            дата :" string(jl.jdt, "99/99/9999")  + fill (" ", 20)
                skip    "           сумма :" trim(string(vcblock.amt, ">>>,>>>,>>>,>>9.99")) + " " + crc.code + fill (" ", 26 - length(trim(string(vcblock.amt, ">>>,>>>,>>>,>>9.99"))))
                skip    " счет получателя :" trim(vcblock.acc) + fill (" ", 30 - length(trim(vcblock.acc)))
                skip    "      получатель :" v-str
                skip(1) view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-ans.

        if v-ans then do:
          find jh where jh.jh = vcblock.jh2 no-lock no-error.

          /* если это проводка на счет клиента, то там была специнструкция и штамповка */
          find first jl where jl.jh = vcblock.jh2 and jl.sub = "cif" and jl.dc = "c" no-lock no-error.
          if avail jl then do:
            if jh.sts = 6 then do:
              v-ans = no.
              message skip " Транзакция уже утверждена старшим менеджером !"
                      skip " Подтверждаете удаление транзакции ?"
                      skip(1) view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-ans.
            end.
            else
              run jou-aasdel (vcblock.acc, vcblock.amt, vcblock.jh2).
          end.

          if v-ans then do:
            if jh.post then do transaction on error undo, retry:
              /* не сегодняшняя, сторнировать придется */
              dvjh = ? .
              run trxstor(s-jh, 6, output dvjh, output rcode, output rdes).
              if rcode <> 0 then do:
                message rdes.
                pause.
                undo, return .
              end.

              s-jh = 0.
            end.
            else do transaction on error undo, retry:
              v-sts = jh.sts.

              run trxsts (s-jh, 0, output rcode, output rdes).
              if rcode <> 0 then do:
                message rdes.
                pause.
                undo, return .
              end.

              run trxdel (s-jh, true, output rcode, output rdes).
              if rcode <> 0 then do:
                message rdes.
                pause.
                if rcode = 50 then do:
                                   run trxsts (s-jh, v-sts, output rcode, output rdes).
                                   return.
                              end.
                else undo, return .
              end.

              /* а ведь мы jou-документ создавали, наверно! */
              if vcblock.retremtrz <> "" and vcblock.retremtrz begins "jou" then do:
                find first joudoc where joudoc.docnum = vcblock.retremtrz and joudoc.jh = s-jh exclusive-lock no-error.
                if avail joudoc then do transaction on error undo, retry:
                  joudoc.jh = ?.
                  find current joudoc no-lock.
                end.
              end.
              s-jh = 0.
            end.
          end.
        end.
      end.
      else
        s-jh = 0.
    end.

    if s-jh = 0 then do:
      find current vcblock exclusive-lock.
      assign vcblock.sts = "B"
             vcblock.jh2 = 0
             vcblock.acc = ""
             vcblock.cif = "".
      find current vcblock no-lock.

      /* перерисуем список */
      run reopen (yes).

    end.
  end.
end.



/* первичное открытие списка */
run reopen (no).

ENABLE all WITH centered FRAME f1.

b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").

APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.



/************************************************************************************/

procedure reopen.
  def input parameter p-close as logical.

  if p-close then close query q1.

  open query q1 for each vcblock where vcblock.bank = s-vcourbank and vcblock.rdt <= v-dt and vcblock.sts = "b"
                                   and if lookup(v-proftcn,v-lookdep) > 0 then true else vcblock.depart = v-proftcn
                                   no-lock, each crc where crc.crc = vcblock.crc no-lock.

  if p-close then apply "VALUE-CHANGED" to BROWSE b1.
end.


/* нужно создать jou-документ, иначе контролер не сможет отштамповать в 2-13 ! */
procedure vcjoudoc.
  def input parameter p-jh like jh.jh.
  def input parameter p-crtype as char.
  def output parameter p-docnum as char.

  def var v-num as integer.

  find first jh where jh.jh = s-jh no-lock no-error.
  if not avail jh then return.

  find nmbr where nmbr.code = "JOU" no-lock no-error.

  v-num = next-value (journal).

  do transaction on error undo, retry:
    create joudoc.
    assign joudoc.docnum = "jou" + string (v-num, "999999") + nmbr.prefix
           joudoc.whn    = g-today
           joudoc.who    = g-ofc
           joudoc.tim    = time
           joudoc.drcur  = vcblock.crc
           joudoc.crcur  = vcblock.crc
           joudoc.jh     = p-jh
           joudoc.bas_amt = "D"
           joudoc.dracc  = vcblock.arp
           joudoc.dramt  = vcblock.amt
           joudoc.dracctype = "4"
           joudoc.cracc  = vcblock.acc
           joudoc.cramt  = vcblock.amt
           joudoc.cracctype = p-crtype.

    find first jl where jl.jh = p-jh no-lock no-error.
    joudoc.remark[1] = substring(jl.rem[1] + jl.rem[2], 1, 70).
    joudoc.remark[2] = vcblock.remdetails.

    find current jh exclusive-lock.
    assign jh.ref = joudoc.docnum
           jh.party = joudoc.docnum
           jh.sub = "jou".
    find current jh no-lock.

    run chgsts("jou", joudoc.docnum, "rdy").
  end.
  find current joudoc no-lock.

  p-docnum = joudoc.docnum.
end.


