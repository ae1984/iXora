/* accept_crd.p
 * MODULE
        Платежная система
 * DESCRIPTION
        авотматический акцепт платежа зарпалтно-карточного проекта
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        5-1
 * AUTHOR
        17/01/05 tsoy
 * CHANGES
        11.10.2012 Lyubov - перекомпиляция в связи с изменением в chk-rbal
*/
{global.i}
{lgps.i}
{chk-rbal.i}

def input parameter p-remtrz like remtrz.remtrz .
def input parameter p-doc    as integer.

def shared var crd_file as char .

def shared var s-remtrz like remtrz.remtrz .

def var str as char .

def var cnt as int.
def var cnti as int.

def var crc as char init "".

def var v-crccode as char.

def var v-hash as char.

def var endof as log.

def var v-tot-amt   as deci.
def var v-tot-amtbt as deci.

def var vbal     as decimal.
def var v-ok     as logical.

def var wascrc as logical init no. /* была ли последняя строка с валютой */
def var wasbt  as logical init no. /* была ли последняя строка с итогом  */
def var filehead as char extent 3.


def temp-table tmp
           field num      as integer              /* N                   */
           field card     as char                 /* N карт              */
           field fio      as char                 /* ФИО                 */
           field sum      like jl.dam             /* Сумма к зачисл      */
           field crc      as char                 /* валюта              */
           field crccode  as char                 /* валюта              */
           field trxdes   as char                 /* описание транзакции */
           field sts      as char                 /* код статус          */
           field stsname  as char.                /* название статус     */

find ib.doc where doc.id = p-doc no-lock no-error.
find remtrz where remtrz.remtrz =  p-remtrz no-lock no-error.

s-remtrz = p-remtrz.

if not avail  ib.doc then do:
       v-text = "Accept CRD:  Документ не найден " + string(p-doc).
       run lgps.
end.

if not avail remtrz then do:
       v-text = "Accept CRD: Платеж не найден " + p-remtrz.
       run lgps.
end.

/* Проверим остаток */
         vbal = chk-rbal(p-remtrz).
         if vbal = ? or vbal < 0 then do:
            v-text = "3-go CRD : Ошибка контроля остатка (" + string(vbal) + ") " + " Платеж: " +  remtrz.remtrz.
            run lgps.

            create bank.reject .
            bank.reject.t_sqn = remtrz.t_sqn .
            remtrz.t_sqn = "IBNK " + remtrz.t_sqn .
            bank.reject.ref = remtrz.t_sqn + remtrz.sqn .
            bank.reject.whn = today.
            bank.reject.who = g-ofc.
            bank.reject.tim = time.
            run IBrej_ps(7,0," Недостаточно средств на счете / Not Enought balance ", remtrz.remtrz) .

            find first que where que.remtrz = s-remtrz exclusive-lock no-error.

            run delnbal.

            if avail que then do:
               v-text = s-remtrz + " Отвержение отправлено успешно: " + reas.
               que.pid = "ARC".
            end.

            return.
         end.

/* Проверим hash код */

        input from value (crd_file).
        import unformatted str no-error.
        /* обработка строк файла */
        if num-entries( str, ";" ) > 2  then do:
            filehead[1] = trim(entry(1, str, ";")).
            {crd-csv.i}
        end. else do:
            {crd-txt.i}
        end.

        input close.

        for each tmp break by tmp.sts by tmp.num:
             v-hash = v-hash + substring(tmp.card, 9, 8 ) + string(tmp.sum).
        end.

     if encode(v-hash) <> ib.doc.codepar[4] then do:
        v-text = "3-go CRD : Ошибка контроля hash кода " + " Платеж: " +  remtrz.remtrz.
        run lgps.
        return.
     end.

     v-text = " IBH-CRD Переставлен на очередь 3А " + remtrz.remtrz .
     run lgps.

/*   Отправим по маршруту  */
     find que where que.remtrz = p-remtrz exclusive-lock no-error.
     que.rcod = "0" .
     que.pid = "3A".
     que.con = "F".
     que.dp = today.
     que.tp = time.

     v-text = " IBH-CRD Отправлен " + remtrz.remtrz + " по маршруту , rcod = " +
     que.rcod + " " + remtrz.sbank + " -> " + remtrz.rbank .
     run lgps.



     release que.












