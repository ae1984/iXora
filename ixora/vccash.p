/* vccash.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Контроль кассовых операций Юр. лиц.
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
 * BASES
        BANK COMM
 * CHANGES
        16.07.2004 saltanat - Контроль кассовых операций.
        23.08.2004 saltanat - убрала проверку по сумме.
        23.09.2004 saltanat - добавила нахождение записи в cursts по номеру транз. с exclusive-lock.
        28/11/2011 Luiza    - добавила контроль для проводок с 100500 ЭК
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

def var v-num like remtrz.remtrz.
def var v-clname like cif.cif.
def var v-rnn like cif.jss.
def var v-ref like remtrz.ref.
def var v-who like ofc.ofc.
def var v-dracc like remtrz.sacc.
def var v-drcrc like crc.crc.
def var v-dramt like remtrz.payment.
def var v-cracc like remtrz.sacc.
def var v-crcrc like crc.crc.
def var v-cramt like remtrz.payment.
def var ans as log format "да/нет".
def var v-oldsts like cursts.sts.
def var naloper as char init "jbb_jou,jcc_jou,jgg_jou".
def var db_sum as deci format "zzz,zzz,zzz,zzz.99" .
def var cr_sum as deci format "zzz,zzz,zzz,zzz.99" .

{global.i}
{vccash.f}
{comm-txb.i}
{get-kod.i}   /* get-kod.i для проверки Юр/Физ Лицевости */

v-num = ''.

def temp-table t-ln
  field dtreg like joudoc.whn
  field dnum  like joudoc.docnum
  field trnum like joudoc.jh
  index main dnum.

/* Заполнение временной таблицы */
for each jl where (jl.gl= 100100 or jl.gl = 100200)
              and jl.jdt = g-today
              and jl.crc <> 1
              and jl.sts = 5
              no-lock.

    find first jh where jh.jh = jl.jh no-lock no-error.

    find first joudoc where joudoc.docnum = jh.ref no-lock no-error.
    if avail joudoc then do:

    /* Получение дебетовой суммы в долларах */
    find first crc where crc.crc = joudoc.drcur no-lock no-error.
    if avail crc then do:

    if crc.crc <> 2 then do:
        db_sum = joudoc.dramt * crc.rate[1].
        find first crc where crc.crc = 2 no-lock no-error.
        db_sum = db_sum / crc.rate[1].
    end.
    else db_sum = joudoc.dramt.

end.

/* Получение кредитовой суммы в долларах */
find first crc where crc.crc = joudoc.crcur no-lock no-error.
if avail crc then do:
if crc.crc <> 2 then do:
cr_sum = joudoc.cramt * crc.rate[1].
find first crc where crc.crc = 2 no-lock no-error.
cr_sum = cr_sum / crc.rate[1].
end.
else cr_sum = joudoc.cramt.

end.

/* Проверка по сумме */

/*if (db_sum >= 50000 or cr_sum >= 50000 ) then do:*/
/*  Проверка на юр.лицо  */

find aaa where aaa.aaa = joudoc.cracc no-lock no-error. /* проверим кредит */
if not available aaa then
find aaa where aaa.aaa = joudoc.dracc no-lock no-error. /* проверим дебет */
if available aaa then
if substr(get-kod(aaa.aaa, ''), 1, 1) = '2' then do:

find first cursts where cursts.acc = string(joudoc.docnum) and cursts.sub = "jou".
if avail cursts then do:

if cursts.valaks <> "val" then do:

    create t-ln.
    t-ln.dtreg = joudoc.whn.
    t-ln.dnum = joudoc.docnum.
    t-ln.trnum = joudoc.jh.

end. end. end. end. end.

define frame fr skip(1)
       v-num label " Документ "
       skip(1) with side-labels.

on help of v-num in frame fr do:
  find first t-ln no-error.
  if not avail t-ln then do:
    message skip " Справочник номеров документов пуст! " skip(1) view-as alert-box button ok title "".
    return.
  end.
  {itemlist.i
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-ln.dtreg label 'Дата рег.'
                    t-ln.dnum label 'Номер документа'
                    t-ln.trnum label 'Номер транзакции'
                   "
       &chkey = "dnum"
       &chtype = "string"
       &index  = "main"
       &end = "if keyfunction(lastkey) eq 'end-error' then return."
  }
  v-num = t-ln.dnum.
  displ v-num with frame fr.
end.

update v-num with frame fr.

find first t-ln where t-ln.dnum = v-num no-error.
if avail t-ln then do:

    find first joudoc where joudoc.docnum = v-num no-lock no-error.

    find aaa where aaa.aaa = joudoc.dracc no-lock no-error.
    if not avail aaa then
    find aaa where aaa.aaa = joudoc.cracc no-lock no-error.

    if not avail aaa then do:
       message "Для данного документа не найден счет !!!". pause.
       return.
    end.

    find cif where cif.cif = aaa.cif no-lock no-error.

    v-clname = cif.cif.
    v-rnn = cif.jss.
    v-ref = joudoc.docnum.
    v-who = joudoc.who.
    if joudoc.dramt = 0 then
    v-dramt = joudoc.comamt.
    else
    v-dramt = joudoc.dramt.

    v-dracc = joudoc.dracc.
    v-drcrc = joudoc.drcur.
    v-cracc = joudoc.cracc.
    v-crcrc = joudoc.crcur.
    v-cramt = joudoc.cramt.

display
v-clname v-rnn
v-ref v-who v-dracc  v-cracc
v-dramt  v-cramt v-drcrc v-crcrc with frame con.

Message "Контролировать ? " update ans.

if ans then do:
   /*find current cursts exclusive-lock.*/
   find first cursts where cursts.acc = v-num and cursts.sub = "jou" exclusive-lock.
   cursts.valaks = "val".
   find current cursts no-lock.
   Message " Документ отконтролирован! ".
   pause.
end.
end.
else do:
    /* Luiza  --------------------------------------------------*/
    def var v_prrr as int.
    v_prrr = 0.
    find first joudoc where joudoc.docnum = v-num no-lock no-error.
    if available joudoc then do:
        find first arp where arp.arp = joudoc.cracc no-lock no-error.
        if avail arp and arp.gl = 100500 and arp.crc <> 1 then v_prrr = 1.
        else do:
            find first arp where arp.arp = joudoc.dracc  no-lock no-error.
            if avail arp and arp.gl = 100500 and arp.crc <> 1 then v_prrr = 1.
            else do:
                find first arp where arp.arp = joudoc.comacc no-lock no-error.
                if avail arp and arp.gl = 100500 and arp.crc <> 1 then v_prrr = 1.
            end.
        end.
        if v_prrr = 1 then do:
            find aaa where aaa.aaa = joudoc.dracc no-lock no-error.
            if not avail aaa then
            find aaa where aaa.aaa = joudoc.cracc no-lock no-error.

            if not avail aaa then do:
               message "Для данного документа не найден счет !!!". pause.
               return.
            end.

            find cif where cif.cif = aaa.cif no-lock no-error.

            v-clname = cif.cif.
            v-rnn = cif.jss.
            v-ref = joudoc.docnum.
            v-who = joudoc.who.
            if joudoc.dramt = 0 then v-dramt = joudoc.comamt.
            else v-dramt = joudoc.dramt.

            v-dracc = joudoc.dracc.
            v-drcrc = joudoc.drcur.
            v-cracc = joudoc.cracc.
            v-crcrc = joudoc.crcur.
            v-cramt = joudoc.cramt.

            display
            v-clname v-rnn
            v-ref v-who v-dracc  v-cracc
            v-dramt  v-cramt v-drcrc v-crcrc with frame con.

            Message "Контролировать ? " update ans.

            if ans then do:
               /*find current cursts exclusive-lock.*/
               find first cursts where cursts.acc = v-num and cursts.sub = "jou" exclusive-lock.
               cursts.valaks = "val".
               find current cursts no-lock.
               Message " Документ отконтролирован! ".
               pause.
               return.
            end.
        end. /* end if v_prrr = 1 */
        else do:
           Message " Документ не подлежит контролю! ".
           pause.
           return.
        end.
    end. /* end if available joudoc*/
    /*-----------------------------------------------------------------*/
Message " Вы задали неправильный номер документа! ".
pause.
end.
