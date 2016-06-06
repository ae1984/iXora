/* docctrlcas.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        контроль расходных кассовых операций физ лиц более 5000 долл 2-4-1-10
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
        05/04/10 marinav
 * BASES
        BANK COMM
 * CHANGES
        03.12.2010 evseev - запрет контроля своих же созданных платежей
        26.03.2012 damir  - добавил keysign.i, сохранение документов для отображения подписей в ордерах.
        11.04.2012 damir  - добавил signdocum.p.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        10.05.2012 damir  - перекомпиляция.
        14/05/2012 Luiza - добавила F2
        04.09.2012 evseev - ИИН/БИН
*/

{keysign.i}

def var v-num like remtrz.remtrz label "Документ".
def var v-sub like substs.sub label "Признак".
def var v-ref like remtrz.ref.
def var v-who like ofc.ofc.
def var v-dracc like aaa.aaa.
def var v-drcrc like crc.crc.
def var v-dramt like remtrz.payment.
def var v-cracc like aaa.aaa.
def var v-crcrc like crc.crc.
def var v-cramt like remtrz.payment.
def var v-det like remtr.detpay.
def var ans as log format "да/нет".
def var v-oldsts like cursts.sts.
def var v-jss  as char format "x(30)" .
def var v-pass as char format "x(30)".
def var v-fio  as char format "x(50)".

{global.i}

form v-ref label "НомерДок" space(10) v-who label "Исполнил" skip
v-dracc label "СчетД" space(3)  v-cracc label "СчетК" skip
v-dramt label "СуммаД"  v-cramt label "СуммаК" skip
v-drcrc label "ВалД" space(22)
v-crcrc label "ВалК" skip
v-det[1] label "ДеталиПл" skip
v-det[2] label "ДеталиПл" skip
v-det[3] label "ДеталиПл" skip
v-det[4] label "ДеталиПл" skip
v-jss    label "ИИН/БИН " skip
v-pass   label "Уд/Личн " skip
v-fio    label "Ф.И.О   "
 with frame con  side-label row 9  centered  .

/* Luiza ---------------------------------------------------------*/
function getcrc returns char(cc as int).
    find first crc where crc.crc = cc no-lock no-error.
    if avail crc then return crc.code.
    else return "".
end.

define temp-table wrk no-undo
    field doc as char
    field jh as int
    field sub as char
    field inf as char
    field sum as decim
    field crc as char
    field id as char
    index ind is primary  doc.

define temp-table temp_ofc like ofc.
define variable v-stslist as char.

form v-num v-sub with frame req side-label row 3 centered.
DEFINE QUERY q-rez FOR wrk /* temp_ofc*/ .
DEFINE BROWSE b-rez QUERY q-rez
       DISPLAY wrk.doc label '№ документа' format "x(10)"
               wrk.jh  label 'Транзак' format "zzzzzzzzzz"
               wrk.inf label 'Наименование/ФИО' format 'x(30)'
               wrk.sum label 'Сумма' format 'zzzzzzzzzzzz9.99'
               wrk.crc label 'Валюта' format 'x(3)'
               wrk.id  label 'id исполнителя'
       WITH  10 DOWN.
DEFINE FRAME f-rez b-rez  WITH overlay 3 COLUMN SIDE-LABELS row 7 width 100 NO-BOX.

on end-error of b-rez in frame f-rez do:
    hide frame f-rez.
end.

def var ofc_contr as char no-undo init " ".

on help of v-num in frame req do:
    for each temp_ofc.
        delete temp_ofc.
    end.
    for each wrk.
        delete wrk.
    end.

    for each trxdel_control_ofc no-lock.
        if lookup(g-ofc,trxdel_control_ofc.control_ofc) > 0 then do:
            ofc_contr = ofc_contr + "," +  trim(trxdel_control_ofc.dep).
        end.
    end.

    for each ofc no-lock.
     if lookup(trim(ofc.titcd),ofc_contr) > 0 then do:
        create temp_ofc.
        temp_ofc.ofc = trim(ofc.ofc).
        temp_ofc.titcd = trim(ofc.titcd).
        temp_ofc.name = trim(ofc.name).
      end.
    end.
    for each cursts where cursts.sub = "jou" and cursts.rdt = today and cursts.sts = "bad" no-lock,
        each temp_ofc where cursts.who = temp_ofc.ofc.
        find first joudoc where joudoc.docnum = cursts.acc and joudoc.whn  = g-today no-lock no-error.
        if available joudoc then do:
            create wrk.
            wrk.doc = joudoc.docnum.
            wrk.jh = joudoc.jh.
            wrk.sub = "jou".
            wrk.inf = joudoc.benname.
            if joudoc.dramt <> 0 then wrk.sum = joudoc.dramt. else wrk.sum = joudoc.cramt.
            if joudoc.dramt <> 0 then wrk.crc = getcrc(joudoc.drcur). else wrk.crc = getcrc(joudoc.crcur).
            wrk.id = joudoc.who.
        end.
    end.
    find first wrk where no-error.
    if not available wrk then message "Нет документов для контроля!".
    else do:
        OPEN QUERY  q-rez FOR EACH wrk no-lock /*, each temp_ofc where wrk.id = temp_ofc.ofc*/ .
        ENABLE ALL WITH FRAME f-rez.
        wait-for return of frame f-rez
        FOCUS b-rez IN FRAME f-rez.
        v-num = wrk.doc.
        v-sub = wrk.sub.
        hide frame f-rez.
        displ v-num v-sub with frame req.
    end.
end.
/*------------------------------------------------------------------*/

update v-num v-sub validate(can-find(trxsub where trxsub.subled = v-sub) , "Неверный признак") with frame req side-label row 3 centered.

find cursts where cursts.acc = v-num and cursts.sub = v-sub no-lock no-error.
if not avail cursts or (avail cursts and cursts.sts ne "bad")
   then do :
      display cursts.
      message "Документ не подлежит контролю в этом пункте!". pause.
      return.
end.

v-oldsts = cursts.sts.

if v-sub = "jou" then do:
    find joudoc where joudoc.docnum = v-num no-lock no-error.
    if not avail joudoc then do :
       message "Документа в системе нет". pause.
       return.
    end.

    v-ref = joudoc.num.
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
    v-det[1] = substr(remark[1],1,35).
    v-det[2] = substr(remark[1],36).
    v-det[3] = substr(remark[2],1,35).
    v-det[4] = substr(remark[2],36).
    v-jss = joudoc.perkod.
    v-pass = joudoc.passp.
    v-fio = joudoc.info.
end.

  display v-ref v-who v-dracc  v-cracc
  v-dramt  v-cramt v-drcrc v-crcrc
  v-det[1]  v-det[2]  v-det[3]  v-det[4] v-jss v-pass v-fio  with frame con.

Message "Контролировать ? " update ans.
/*evseev 03.12.2010*/
if v-who = g-ofc then do:
   message g-ofc " не может контролировать свои платежи". pause.
   return.
end.
/*evseev 03.12.2010*/

if ans then do:
    run chgsts(input v-sub, v-num, "cas").
    if v-transsign = yes then run signdocum(input v-sub,input v-num).
end.

