/* doccn.p
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
        21.09.04 dpuchkov
 * BASES
        BANK COMM
 * CHANGES
        13.07.2005 dpuchkov добавил переменные v-jss v-pass v-fio
        02.02.10 marinav - расширение поля счета до 20 знаков
        29.06.2011 Luiza - Добавила вывод наименования для арп счетов, переменные v-desdracc и v-descracc
        26/09/2011 Luiza   - добавила переменную v-transf для поля joudoc.transf номер перевода
        11/10/2011 Luiza - Добавила вывод суммы комиссии v-comamt
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".

*/


def var v-num like remtrz.remtrz label "Документ".
def var v-sub like substs.sub label "Признак".
def var v-ref like remtrz.ref.
def var v-transf as char init "".
def var v-comamt as decim.
def var v-who like ofc.ofc.
def var v-dracc like aaa.aaa.
def var v-drcrc like crc.crc.
def var v-dramt like remtrz.payment.
def var v-desdracc as char format "x(30)".
def var v-descracc as char format "x(30)".

def var v-cracc like aaa.aaa.
def var v-crcrc like crc.crc.
def var v-cramt like remtrz.payment.
def var v-det like remtr.detpay.
def var ans as log format "да/нет".
def var v-oldsts like cursts.sts.

def var v-brate as char.
def var v-srate as char.
def var v-obmen as logical init false.

def var v-jss  as char format "x(30)" .
def var v-pass as char format "x(30)".
def var v-fio  as char format "x(50)".


{global.i}
{docctrl.f}

form v-ref label "НомерДок" space(10) v-who label "Исполнил" skip
v-dracc label "СчетД" space(3)  v-cracc label "СчетК" skip
v-dramt label "СуммаД"  v-cramt label "СуммаК" skip
v-drcrc label "ВалД" space(22)
v-crcrc label "ВалК" skip
v-brate label "КОд" space(22)
v-srate label "КБе" skip
v-det[1] label "ДеталиПл" skip
v-det[2] label "ДеталиПл" skip
v-det[3] label "ДеталиПл" skip
v-det[4] label "ДеталиПл"
  with frame con  side-label row 9  centered  .


update v-num v-sub validate(can-find(trxsub where trxsub.subled = v-sub) ,
 "Неверный признак") with frame req side-label row 3 centered.

find cursts where cursts.acc = v-num and cursts.sub = v-sub no-lock no-error.
/*
if not avail cursts or (avail cursts and (cursts.sts ne "apr" and
   cursts.sts ne "new" and cursts.sts ne "bac" and cursts.sts ne "bap"))
*/

if v-sub <> "rmz"
   then do:
/*      display cursts. */
      message "Документ не подлежит контролю ". pause.
      return.
end.

v-oldsts = cursts.sts.

if v-sub = "rmz" then do:
    find remtrz where remtrz.remtrz = v-num no-lock no-error.
    if not avail remtrz then do:
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

  find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
  if avail sub-cod then do:

     if substr(sub-cod.rcode, 4, 1) = "2" then
     do:
       find last rmzkbe where rmzkbe.remtrz = remtrz.remtrz exclusive-lock no-error.
       if not avail rmzkbe then do:
         create rmzkbe.
         rmzkbe.sta = False.
         rmzkbe.remtrz = remtrz.remtrz.
       end.
     end.
  end.


    find last rmzkbe where rmzkbe.remtrz = v-num exclusive-lock no-error.
    if avail rmzkbe then do:

      if rmzkbe.sta = True then do:
        find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
        if avail sub-cod then do:
          v-brate =  substr(sub-cod.rcode, 1, 2).
          v-srate = substr(sub-cod.rcode, 4, 2).

        end.

        display v-ref v-who v-dracc v-desdracc v-cracc v-descracc
                 v-dramt  v-cramt v-drcrc v-crcrc
                 v-det[1]  v-det[2]  v-det[3]  v-det[4] v-brate v-srate with frame con.


       message "Документ уже проконтролирован". pause.
       return.
      end.
      else do:
        find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
        if avail sub-cod then do:
          v-brate =  substr(sub-cod.rcode, 1, 2).
          v-srate = substr(sub-cod.rcode, 4, 2).
        end.

         display v-ref v-who v-dracc v-desdracc v-cracc v-descracc
                 v-dramt  v-cramt v-drcrc v-crcrc
                 v-det[1]  v-det[2]  v-det[3]  v-det[4] v-brate v-srate with frame con.
         Message "Контролировать ? " update ans.
         if ans then
         do:
            rmzkbe.sta = True.

              find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
              if avail sub-cod then do:
                if remtrz.fcrc = 1 and remtrz.payment < 3000000  and substr(sub-cod.rcode, 4, 1) = "2" then
                do:
/*                  run chgsts(input "rmz", remtrz.remtrz, "con").
                  if v-oldsts = "bac" then run chgsts(input v-sub, v-num, "cas").
                  if v-oldsts = "new" then run chgsts(input v-sub, v-num, "kbn").
*/
                end.
              end.

         end.
      end.
    end.

end.










