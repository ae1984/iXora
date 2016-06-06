/* lnrkcin.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Раскидка платежей из промежуточной таблицы lnrkc по текущим счетам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        27/12/2007 madiyar
 * BASES
        BANK COMM
 * CHANGES
        28/12/2007 madiyar - сделал более подробный вывод
        09/01/2008 madiyar - исправил проблему проставления поля dtimp по прогруженным платежам
        25/04/2012 evseev  - rebranding. разбранчевка с учетом банк-мко.
*/

{global.i}

def var v-bn as integer no-undo.
def var v-arp as char no-undo.

v-arp = "003076667".

find first cmp no-lock no-error.
if not avail cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

/*if cmp.name matches "*ForteBank*" then v-bn = 2. /* BANK */
else v-bn = 1. /* MKO */*/

if bank.cmp.name matches ("*МКО*") then v-bn = 1.
else v-bn = 2.

define temp-table t_error no-undo
  field bank as char
  field cif as char
  field amt as deci
  field jh as integer
  field whn as date
  field msg as char
  index idx is primary bank cif.

def buffer b-lnrkc for lnrkc.

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

procedure save_err.
    def input parameter v-bank as char no-undo.
    def input parameter v-cif as char no-undo.
    def input parameter v-amt as deci no-undo.
    def input parameter v-jh as integer no-undo.
    def input parameter v-whn as date no-undo.
    def input parameter v-msg as char no-undo.
    create t_error.
    assign t_error.bank = v-bank
           t_error.cif = v-cif
           t_error.amt = v-amt
           t_error.jh = v-jh
           t_error.whn = v-whn
           t_error.msg = v-msg.
end procedure.

def var v-lon as char no-undo.
def var v-aaa as char no-undo.
def var v-bal as deci no-undo.
def var v-msg as char no-undo.

def new shared var s-jh like jh.jh.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.
def var v-allsum as deci no-undo.

find first lnrkc where lnrkc.bank = s-ourbank and lnrkc.bn = v-bn and lnrkc.whn <= g-today and lnrkc.dtimp = ? no-lock no-error.
if not avail lnrkc then do:
  message "Нет платежей для прогрузки" view-as alert-box information.
  return.
end.

def var v-ja as logi no-undo init no.
message "Произвести прогрузку платежей?" view-as alert-box question buttons yes-no update v-ja.
if not v-ja then return.

def stream rep.
output stream rep to res.csv.
put stream rep unformatted "bank;cif;transaction#;amount;date" skip.

v-allsum = 0.

for each lnrkc where lnrkc.bank = s-ourbank and lnrkc.bn = v-bn and lnrkc.whn <= g-today and lnrkc.dtimp = ? no-lock:

    find first cif where cif.cif = lnrkc.cif no-lock no-error.
    if not avail cif then do:
        run save_err(s-ourbank,lnrkc.cif,lnrkc.amt,lnrkc.jh,lnrkc.whn,'Не найдена клиентская запись').
        next.
    end.

    v-lon = ''. v-msg = ''.
    for each lon where lon.cif = lnrkc.cif no-lock:
        run lonbalcrc('lon',lon.lon,g-today,"1,7,2,9,16",yes,lon.crc,output v-bal).
        if v-bal > 0 then do:
            if v-lon <> '' then do:
                v-msg = 'У клиента более одного действующего кредита'.
                leave.
            end.
            else v-lon = lon.lon.
        end.
    end.
    if v-lon = '' then v-msg = 'У клиента нет действующих кредитов'.
    else do:
        find first lon where lon.lon = v-lon no-lock no-error.
        if avail lon then v-aaa = lon.aaa.
        find first aaa where aaa.aaa = v-aaa no-lock no-error.
        if (not avail aaa) or (aaa.sta = 'c') or (aaa.sta = 'e') then v-msg = 'Текущий счет не существует или закрыт'.
    end.

    if v-msg <> '' then do:
        run save_err(s-ourbank,lnrkc.cif,lnrkc.amt,lnrkc.jh,lnrkc.whn,v-msg).
        next.
    end.

    v-param = "" + vdel +
              string(lnrkc.amt) + vdel +
              "1" + vdel + /* валюта */
              v-arp + vdel +
              v-aaa + vdel +
              "Оплата кредита " + v-lon + vdel +
              "1" + vdel + /* резидент */
              /* "9" + vdel + -- сектор экономики - домашнее хоз-во -- */
              if lon.gl = 141120 then "421" else "423". /* код назначения платежа */

    s-jh = 0.
    run trxgen ('jou0033', vdel, v-param, "cif", v-aaa, output rcode, output rdes, input-output s-jh).

    if rcode ne 0 then do:
        run save_err(s-ourbank,lnrkc.cif,lnrkc.amt,lnrkc.jh,lnrkc.whn,'Транзакция: ' + rdes).
        message rdes.
        pause 1000.
        next.
    end.

    find first b-lnrkc where b-lnrkc.bank = lnrkc.bank and b-lnrkc.jh = lnrkc.jh exclusive-lock.
    b-lnrkc.dtimp = g-today.
    find current b-lnrkc no-lock.

    put stream rep unformatted
        s-ourbank ';'
        lnrkc.cif ';'
        lnrkc.jh ';'
        replace(trim(string(lnrkc.amt,">>>>>>>>9.99")),'.',',') ';'
        string(lnrkc.whn,"99/99/9999") skip.

    v-allsum = v-allsum + lnrkc.amt.

end. /* for each lnrkc */

put stream rep unformatted
    s-ourbank ';'
    'ВСЕГО;'
    ';'
    replace(trim(string(v-allsum,">>>>>>>>9.99")),'.',',') ';' skip.

output stream rep close.
unix silent cptwin res.csv excel.

find first t_error no-lock no-error.
if avail t_error then do:
    output stream rep to err.csv.

    put stream rep unformatted "bank;cif;transaction#;amount;date;error_message" skip.

    for each t_error no-lock:
        put stream rep unformatted
            t_error.bank ';'
            t_error.cif ';'
            t_error.jh ';'
            replace(trim(string(t_error.amt,">>>>>>>>9.99")),'.',',') ';'
            string(t_error.whn,"99/99/9999") ';'
            t_error.msg skip.
    end.

    output stream rep close.
    unix silent cptwin err.csv excel.
end.



