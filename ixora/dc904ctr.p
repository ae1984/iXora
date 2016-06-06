/* dc904ctr.p
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
 * BASES
        BANK COMM
 * CHANGES
        13.07.2005 dpuchkov добавил переменные v-jss v-pass v-fio
        02.02.2007 u00121 v-num при выводе в лог весь большими буквами теперь, иначе не оттображалась в истории
        02.02.10 marinav - расширение поля счета до 20 знаков
        29.06.2011 Luiza - Добавила вывод наименования для арп счетов, переменные v-desdracc и v-descracc
        26/09/2011 Luiza - добавила переменную v-transf для поля joudoc.transf номер перевода
        11/10/2011 Luiza - Добавила вывод суммы комиссии v-comamt
        26.03.2012 damir - добавил keysign.i, сохранение документов для отображения подписей в ордерах.
        11.04.2012 damir - добавил signdocum.p.
        10.05.2012 damir - перекомпиляция.

*/

/*
   Файл на основе docctrl.p
   16.01.2002 by sasco - control for all docs (RMZ, JOU)
   with ARP account from table ARPCON  :: DEBET OPERATIONS ONLY !!!

   21.08.2002 BY SASCO - write REMTRZ history

*/

{lgps.i "new"}
{keysign.i}

def var v-num as char format 'x(12)' label "Документ".
def var v-sub like substs.sub label "Признак".
def var v-ref like remtrz.ref.
def var v-transf as char init "".
def var v-comamt as decim.
def var v-who like ofc.ofc.
def var v-dracc like aaa.aaa.
def var v-drcrc like crc.crc.
def var v-dramt like remtrz.payment.
def var v-cracc like aaa.aaa.
def var v-crcrc like crc.crc.
def var v-cramt like remtrz.payment.
def var v-det like remtr.detpay.
def var ans as log format "да/нет" init no.
def var v-brate like joudoc.brate.
def var v-srate like joudoc.srate.

def var v-jss  as char format "x(30)" .
def var v-pass as char format "x(30)".
def var v-fio  as char format "x(50)".
def var v-desdracc as char format "x(30)".
def var v-descracc as char format "x(30)".


{global.i}
{docctrl.f}

update v-num v-sub validate(can-find(trxsub where trxsub.subled = v-sub) ,
 "Неверный признак") with frame req side-label row 3 centered.

if v-sub = "rmz" then do:
    find remtrz where remtrz.remtrz = v-num no-lock no-error.
    if not avail remtrz then do :
       message "Документа в системе нет". pause.
       return.
    end.

    v-ref = substr(remtrz.sqn,19).
    v-who = remtrz.rwho.
    v-dracc = remtrz.sacc.
    if v-dracc = "" then
    v-dracc = remtrz.dracc.
    v-drcrc = remtrz.fcrc.
    v-dramt = remtrz.amt.
    v-cracc = remtrz.racc.
    v-crcrc = remtrz.tcrc.
    v-cramt = remtrz.payment.
    v-det[1] = remtrz.detpay[1].
    v-det[2] = remtrz.detpay[2].
    v-det[3] = remtrz.detpay[3].
    v-det[4] = remtrz.detpay[4].

end.

if v-sub = "jou" then do:
    find joudoc where joudoc.docnum = v-num no-lock no-error.
    if not avail joudoc then do :
       message "Документа в системе нет". pause.
       return.
    end.

    v-ref = joudoc.docnum.
    v-transf = joudoc.transf.
    v-comamt = joudoc.comamt.
    v-who = joudoc.who.
    v-dracc = joudoc.dracc.
    v-drcrc = joudoc.drcur.
    v-dramt = joudoc.dramt.
    v-cracc = joudoc.cracc.
    v-crcrc = joudoc.crcur.
    v-cramt = joudoc.cramt.
    v-det[1] = joudoc.rem[1].
    v-det[2] = joudoc.rem[2].
    v-det[3] = ''.
    v-det[4] = ''.
end.

/* Luiza -------------------------------------------------------*/
    if v-dracc <> "" then do:
        find first arp where arp.arp = v-dracc no-lock no-error.
        if available arp then v-desdracc = arp.des.
    end.
    if v-cracc <> "" then do:
        find first arp where arp.arp = v-cracc no-lock no-error.
        if available arp then v-descracc = arp.des.
    end.
/*------------------------------------------------------------------*/

/* найдем настройку счета для контроля */
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
find arpcon where arpcon.arp = v-dracc and
                  arpcon.txb = sysc.chval and
                  arpcon.sub = v-sub
                  exclusive-lock no-error.
if avail arpcon then do:

         /* найдем в истории, был ли уже контроль (то есть sts = arpcon.new-sts) */
         find substs where substs.sub = v-sub and substs.acc = v-dracc and
                           substs.sts = arpcon.new-sts no-lock no-error.
         find cursts where cursts.acc = v-num and cursts.sub = v-sub
                           use-index subacc no-lock no-error.

         if avail substs
         then do :
                  display cursts with side-label.
                  message "Документ не подлежит контролю " view-as alert-box.
                  return.
         end.

         /* проверим, находится ли платеж на очереди для контроля */
         if not avail cursts or (avail cursts and cursts.sts ne arpcon.new-sts)
         then do :
                  display cursts with side-label.
                  message "Документ не подлежит контролю " view-as alert-box.
                  return.
         end.

display v-ref v-transf v-comamt v-who v-dracc v-desdracc v-cracc v-descracc v-dramt  v-cramt v-drcrc  v-crcrc  v-det[1]  v-det[2]  v-det[3]  v-det[4] with frame con.

Message "Контролировать ? " update ans.

if ans then do:
    run chgsts(input v-sub, v-num, arpcon.old-sts). pause 10.
    /* ИСТОРИЯ ДЛЯ РЭМТЭЭРЗЭТ :) */
    if v-sub = "rmz" then do:
        v-text = CAPS(v-num) + " Пройден контроль по счету " + trim(string(v-dracc)) + ", сумма " + trim(string(v-dramt)).
        run lgps.
    end.
    if v-transsign = yes then run signdocum(input v-sub,input v-num).
end.

end.
