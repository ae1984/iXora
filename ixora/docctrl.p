/* docctrl.p
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
        last change - 20.11.2001 by sasco - control for all docs with sts = "bac"
        12.04.2004 nadejda - контроль документов универсального журнала (ujo)
        09.08.2004 dpuchkov - добавил отображение курсов валют при контроле
        11.07.2005 dpuchkov - добавил формирование корешка
        02.02.10 marinav - расширение поля счета до 20 знаков
        03/07/2010 galina - выводим дату паспорта
        08/07/2010 madiyar - исправил ошибку
        03.12.2010 evseev - запрет контроля своих же созданных платежей
        29.06.2011 Luiza - Добавила вывод наименования для арп счетов, переменные v-desdracc и v-descracc
        26/09/2011 Luiza   - добавила переменную v-transf для поля joudoc.transf номер перевода
        11/10/2011 Luiza - Добавила вывод суммы комиссии v-comamt
        31/10/2011 Luiza - добавила формат format "x(12)" для переменной v-transf.
        14/12/2011 evseev - изменение в docctrl.f
        07.02.2012 lyubov - если статус был "cas", тогда мы не меняем его на "con", а оставляем
        15/03/2012 Luiza  - добавила проверку не контролировать в данном пункте меню внутренние переводы
        19/03/2012 Luiza  - расширила поле "Уд/Личн " до 35 символов
        26.03.2012 damir  - добавил keysign.i, сохранение документов для отображения подписей в ордерах.
        11.04.2012 damir  - добавил signdocum.p...
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        10.05.2012 damir    - перекомпиляция.
        14/05/2012 Luiza - добавила F2
        28/07/2012 Luiza - добавила available joudop при заполнении поля wrk.inf
        04.09.2012 evseev - иин/бин
        09/11/2012 Luiza  - контроль документов unistrim до транзакции
        10.01.2013 Lyubov - продублировала проверку статуса документа перед вызовом chgsts,т.к. была возможность отконтролировать дважды
        19.07.2013 damir - Внедрено Т.З. № 1931.
*/

{keysign.i}

def var v-num like remtrz.remtrz label "Документ".
def var v-sub like substs.sub label "Признак".
def var v-ref like remtrz.ref.
def var v-who like ofc.ofc.
def var v-dracc like aaa.aaa.
def var v-drcrc like crc.crc.
def var v-desdracc as char format "x(30)".
def var v-descracc as char format "x(30)".

def var v-dramt like remtrz.payment.

def var v-cracc like aaa.aaa.
def var v-crcrc like crc.crc.
def var v-cramt like remtrz.payment.
def var v-det like remtr.detpay.
def var ans as log format "да/нет".
def var v-oldsts like cursts.sts.


def var v-brate like joudoc.brate.
def var v-srate like joudoc.srate.
def var v-obmen as logical init false.

def var v-jss  as char format "x(30)" .
def var v-pass as char format "x(35)".
def var v-fio  as char format "x(50)".
def var v-transf as char format "x(12)".
def var v-comamt as decim.

{global.i}
{docctrl.f}

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
v-stslist = "new,bac,bap,baf,apr".

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
    for each cursts where  (cursts.sub = "jou" or cursts.sub = "ujo") and cursts.rdt = today and lookup(cursts.sts,v-stslist) > 0 no-lock,
        each temp_ofc where cursts.who = temp_ofc.ofc.
        if cursts.sub = "jou" then do:
            find first joudoc where joudoc.docnum = cursts.acc and joudoc.whn  = g-today no-lock no-error.
            if available joudoc then do:
                find first joudop where joudop.docnum = cursts.acc no-lock no-error.
                    if not available joudop or (joudop.type <> "CS3" and (((substring(trim(joudop.type),4,1) = "3" or substring(trim(joudop.type),4,1) = "4") and cursts.sts = "new" and
                        (substring(trim(joudop.type),1,3) = "TR1" or substring(trim(joudop.type),1,3) = "RT1"))
                        or (cursts.sts <> "new" and (substring(trim(joudop.type),1,3) <> "TR1" and substring(trim(joudop.type),1,3) <> "RT1")))) then do:
                    create wrk.
                    wrk.doc = joudoc.docnum.
                    wrk.jh = joudoc.jh.
                    wrk.sub = "jou".
                    if available joudop and (joudop.type = "CS2" or joudop.type = "EK2") then wrk.inf = joudoc.benname.
                    else wrk.inf = joudoc.info.
                    if joudoc.dramt <> 0 then wrk.sum = joudoc.dramt. else wrk.sum = joudoc.cramt.
                    if joudoc.dramt <> 0 then wrk.crc = getcrc(joudoc.drcur). else wrk.crc = getcrc(joudoc.crcur).
                    wrk.id = joudoc.who.
                end.
            end.
        end.
        /*if cursts.sub = "rmz" then do:
            find first remtrz where remtrz.remtrz = cursts.acc and remtrz.rdt = g-today no-lock no-error.
            if available remtrz then do:
                create wrk.
                wrk.doc = remtrz.remtrz.
                wrk.jh = remtrz.jh1.
                wrk.sub = "rmz".
                wrk.inf = remtrz.ord.
                wrk.sum = remtrz.amt.
                wrk.crc = getcrc(remtrz.fcrc).
                wrk.id = remtrz.rwho.
            end.

        end.*/
        if cursts.sub = "ujo" then do:
            find first ujo where ujo.docnum = cursts.acc no-lock no-error.
            if available ujo then do:
                for each jl where jl.jh = ujo.jh no-lock use-index jhln:
                    if jl.ln = 1 then do:
                        create wrk.
                        wrk.doc = ujo.docnum.
                        wrk.jh = ujo.jh.
                        wrk.sub = "ujo".
                        wrk.inf = ujo.info.
                        wrk.crc = getcrc(jl.crc).
                        wrk.id = ujo.who.
                    end.
                    if jl.dc = "D" and jl.dam <> 0 then wrk.sum = jl.dam.
                    if jl.dc = "C" and jl.cam <> 0 then wrk.sum = jl.cam.
                end.
            end.
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
v-desdracc = "".
v-descracc = "".
update v-num v-sub validate(can-find(trxsub where trxsub.subled = v-sub) ,
 "Неверный признак") with frame req side-label row 3 centered.


 find first joudop where joudop.docnum = v-num no-lock no-error.
 if available joudop and joudop.type = "CS3" then do:
      message "Внутренние переводы контролируются в п.м. 2.4.1.3 " view-as alert-box.
      return.
 end.

find cursts where cursts.acc = v-num and cursts.sub = v-sub no-lock no-error.
if not avail cursts or (avail cursts and (cursts.sts ne "apr" and
   cursts.sts ne "new" and cursts.sts ne "bac" and cursts.sts ne "bap" and cursts.sts ne "baf"))
   then do :
      display cursts.
      message "Документ не подлежит контролю ". pause.
      return.
end.

v-oldsts = cursts.sts.

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

    v-ref = joudoc.num.
    v-transf = joudoc.transf.
    v-comamt = joudoc.comamt.
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
    v-det[1] = substr(joudoc.remark[1],1,35).
    v-det[2] = substr(joudoc.remark[1],36).
    v-det[3] = substr(joudoc.remark[2],1,35).
    v-det[4] = substr(joudoc.remark[2],36).
/*    find last aaa where aaa.aaa = joudoc.cracc no-lock no-error.
    if avail aaa then do:
       find last cif where cif.cif = aaa.cif no-lock.
       if avail cif then do: */

          v-jss = joudoc.perkod.
          v-pass = joudoc.passp.
          if joudoc.passpdt ne ? then v-pass = v-pass + ', ' + string(joudoc.passpdt,'99/99/9999').
          v-fio = joudoc.info.

/*       end.
    end.     */
end.

if v-sub = "ujo" then do:
    /* пока только для выдачи по чекам */

    find ujo where ujo.docnum = v-num no-lock no-error.
    if not avail ujo then do :
       message "Документа в системе нет". pause.
       return.
    end.

    v-dracc = "".
    v-cracc = "".
    for each jl where jl.jh = ujo.jh no-lock use-index jhln:
      if jl.dc = "d" then do:
        v-dracc = jl.acc.
        if jl.acc = "" then v-dracc = string(jl.gl).
        v-dramt = jl.dam.
        v-drcrc = jl.crc.
      end.
      else do:
        v-cracc = jl.acc.
        if jl.acc = "" then v-cracc = string(jl.gl).
        v-cramt = jl.cam.
        v-crcrc = jl.crc.
      end.
      if v-dracc <> "" and v-cracc <> "" then leave.
    end.

    v-ref = string(ujo.chk).
    v-who = ujo.who.

    find first jl where jl.jh = ujo.jh no-lock use-index jhln no-error.
    v-det[1] = substr(jl.rem[1],1,35).
    v-det[2] = substr(jl.rem[1],36).
    v-det[3] = substr(jl.rem[2],1,35).
    v-det[4] = substr(jl.rem[2],36).


/*    find last aaa where aaa.aaa = v-cracc no-lock no-error.
    if avail aaa then do:
       find last cif where cif.cif = aaa.cif no-lock.
       if avail cif then do:
          v-jss = cif.jss.
          v-pass = cif.pss.
          v-fio = cif.name.
       end.
    end. */


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
if v-sub = "jou" then do:
 find joudoc where joudoc.docnum = v-num no-lock no-error.
 if avail joudoc then do:
   if joudoc.sts = "LGC" then
     v-obmen = True.
   v-brate = joudoc.brate.
   v-srate = joudoc.srate.
 end.
end.

if v-obmen = True then do:
  display v-ref v-transf v-comamt v-who v-dracc  v-cracc
  v-dramt  v-cramt v-drcrc v-crcrc
  v-det[1]  v-det[2]  v-det[3]  v-det[4] v-brate v-srate  with frame con1.
end.
else do:
  display v-ref v-transf v-comamt v-who v-dracc v-desdracc v-cracc v-descracc
  v-dramt  v-cramt v-drcrc v-crcrc
  v-det[1]  v-det[2]  v-det[3]  v-det[4] v-jss v-pass v-fio  with frame con.

end.


Message "Контролировать ? " update ans.

/*евсеев 03.12.2010*/
if v-who = g-ofc then do:
   message g-ofc " не может контролировать свои платежи". pause.
   return.
end.
/*конец 03.12.2010*/


if ans then do:
    find cursts where cursts.acc = v-num and cursts.sub = v-sub no-lock no-error.
    if not avail cursts or (avail cursts and (cursts.sts ne "apr" and
       cursts.sts ne "new" and cursts.sts ne "bac" and cursts.sts ne "bap" and cursts.sts ne "baf"))
       then do :
          display cursts.
          message "Документ не подлежит контролю ". pause.
          return.
    end.
    v-oldsts = cursts.sts.

    run chgsts(input v-sub, v-num, "con").
    if v-oldsts = "bac" or v-oldsts = "baf" or v-oldsts = "cas" then run chgsts(input v-sub, v-num, "cas").

    find cursts where cursts.acc = v-num and cursts.sub = v-sub no-lock no-error.
    if avail cursts and cursts.sts = "con" then do:
        for each pcpay where pcpay.ref begins v-num exclusive-lock:
            if pcpay.sts = 'salload' then pcpay.sts = "ready".
            release pcpay.
        end.
    end.

    if v-transsign = yes then run signdocum(input v-sub,input v-num).
end.


