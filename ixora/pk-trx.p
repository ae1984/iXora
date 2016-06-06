/* pk-trx.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Генерация проводки по данным из pkanketa со счета клиента на счет организации
        также - печать приходного ордера и плат.поручения. Сумма проводки:pkanketa.summq
 * RUN
      
 * CALLER
        pkcifnew.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
       
 * AUTHOR
        09.02.2003 sasco
 * CHANGES
        09.09.03 nadejda - проверка на статус 35 (отштампована ли первая проводка)
        28.01.04 sasco   - проверка на существование партнера (если нет - то только комиссия)
        03.02.04 sasco   - снятие 5% суммы вознаграждения с клиента, если есть такой партнер для снятия
        08.12.2004 saltanat - берутся тарифы со статусом "r" - рабочий.
        16/05/2005 madiyar - счет ГК для комиссий теперь определяется не по "tarif2", а по "tarfnd"
        25/01/2006 madiyar - в шаблоне lon0058 еще одна линия для комиссии ABN
        24/04/2007 madiyar - веб-анкеты
        11/10/2007 madiyar - все ордера попадают в один документ
        14.01.08   marinav - добавлена печать Платежного поручения
        18/02/2008 madiyar - последняя проводка при выдаче через РКЦ - условие по записи в справочнике
        13/03/2008 madiyar - исправил опечатку
        04.06.2008 madiyar - валютный контроль 
        05/02/2008 madiyar - если не нужно брать комиссию - просто меняем статус и выходим
*/

{global.i}
{pk.i}

{pk-sysc.i}
{get-kod.i}
{pkcifnew.i}


def var v-aaa like aaa.aaa.
def var i   as int.
def var v-clnkod as char init "19".
def var kbe as char init "14".
def var v-knp as char init "720".
def var knpcom as char init "890".
def var v-sum as decimal.
def var v-bal as decimal.
def var v-sumout as decimal.
define variable comsum  as decimal. /* сумма комиссии  */
define variable perevodsum  as decimal. /* сумма переводимая партнеру  */
define variable vparam  as character.
define variable vdel    as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.
def new shared var s-jh like jh.jh.
def new shared var s-remtrz like remtrz.remtrz.

define variable sum5 as decimal. /* сумма 5 % вознаграждения */
define variable sum%% as decimal. /* процент вознаграждения */
define variable v-sumabn as decimal. /* комиссия ABN при выдаче кредита картой */
define variable v-glabn as integer. /* счет ГК для комиссии ABN */

def var v-file as char no-undo.

procedure fmsg-w.
    def input parameter p-bank as char no-undo.
    def input parameter p-credtype as char no-undo.
    def input parameter p-ln as integer no-undo.
    def input parameter p-msg as char no-undo.
    find first pkanketh where pkanketh.bank = p-bank and pkanketh.credtype = p-credtype and pkanketh.ln = p-ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
    pkanketh.value1 = p-msg.
    find current pkanketh no-lock.
end procedure.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.

def var v-inet as logi init no.
if pkanketa.id_org = "inet" then v-inet = yes.

/* проверка статуса - был ли контроль первой проводки */
if pkanketa.sts = "35" then do:
  find jh where jh.jh = pkanketa.trx1 no-lock no-error.
  if avail jh and jh.sts = 6 then do:
    find current pkanketa exclusive-lock.
    pkanketa.sts = "40".
    find current pkanketa no-lock.
  end.
  else
    if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pk-trx - Требуется утверждение перевода средств старшим менеджером!").
    else message skip " Требуется утверждение перевода средств старшим менеджером!" skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
end.

/* проверим статус - а надо ли нам это вообще?!
   проводить или не проводить?!
   вот в чем вопрос ! ! ! */
if pkanketa.sts <> "40" then return.

/* Если не нужно брать комиссию - просто меняем статус и выходим */
if pkanketa.sumcom = 0 then do:
    find current pkanketa exclusive-lock.
    pkanketa.sts = "50".
    find current pkanketa no-lock.
    return.
end.

if pkanketa.crc = 1 then v-aaa = pkanketa.aaa.
else v-aaa = pkanketa.aaaval.

find first aaa where aaa.aaa = v-aaa no-lock no-error.
if not avail aaa or (avail aaa and aaa.sta = "c") then do:
   if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pk-trx - Счет" + v-aaa + "не существует или закрыт!").
   else message skip " Счет" v-aaa "не существует или закрыт!" skip(1) view-as alert-box button ok title " ОШИБКА ! ".
   return.
end.

/* суммой транзакции считаем ВСЮ сумму на счете - счет-то новый открыт, там нет ничего лишнего! */
find first aaa where aaa.aaa = v-aaa no-lock no-error.
v-sum = aaa.cr[1] - aaa.dr[1].
v-bal = v-sum - pkanketa.sumcom.
v-sumout = v-bal.

v-clnkod = get-kodkbe (v-aaa, "").
if v-clnkod = ? then do:
   if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pk-trx - Не могу определить код КБЕ для счета " + v-aaa).
   else message skip " Не могу определить код КБЕ для счета " v-aaa skip(1) view-as alert-box button ok title " ОШИБКА ! ".
   return.
end.

v-knp = string(get-pksysc-int ("knp")).

/* внутренний перевод */
v-sumabn = 0.
if pkanketa.rescha[3] <> '' then do:
    find first tarif2 where tarif2.str5 = "039" and tarif2.stat = 'r' no-lock no-error.
    if avail tarif2 then assign v-sumabn = tarif2.ost v-glabn = tarif2.kont.
    else assign v-sumabn = 350 v-glabn = 460717.
end.

if v-sum < pkanketa.sumcom + v-sumabn then do:
    if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pk-trx - Сумма на счете меньше необходимой!").
    else message skip "pk-trx - Сумма на счете меньше необходимой!" skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    return.
end.

knpcom = string(get-pksysc-int ("knpcom")).

find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "tarfnd" no-lock no-error.
if not avail pksysc then do:
    if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pk-trx - Не настроена переменная tarfnd в pksysc!").
    else message skip "pk-trx - Не настроена переменная tarfnd в pksysc!"  skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    return.
end.

find first tarif2 where tarif2.num  = string(pksysc.inval) and
                        tarif2.kod  = trim(pksysc.chval) and
                        tarif2.stat = 'r' no-lock no-error.
if not avail tarif2 or (avail tarif2 and not (can-find (gl where gl.gl = tarif2.kont no-lock))) then do:
    if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pk-trx - Не могу найти счет Г/К для снятия комиссии!").
    else message skip "pk-trx -  Не могу найти счет Г/К для снятия комиссии!"  skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    return.
end.

vparam = string (pkanketa.sumcom) + vdel +
         string (v-aaa) + vdel +
         string(tarif2.kont) /*'442900'*/ + vdel +
         pkanketa.rnn + " " + pkanketa.name + vdel +
         "Комиссия за выдачу кредита " + vdel +
         knpcom + vdel +
         string(v-sumabn) + vdel +
         string(v-glabn) + vdel +
         pkanketa.rnn + " " + pkanketa.name + vdel +
         "Комиссия ABN - выдача кредита картой".

run trxgen ("LON0058", vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).

if rcode <> 0 then do: message rcode rdes. pause 100. return. end.

/* статус после проводки со страховкой */
find current pkanketa exclusive-lock.
if s-jh <> 0 then pkanketa.sts = "50".
pkanketa.trx2 = s-jh.
find current pkanketa no-lock.

if s-jh <> 0 then do:
    if v-inet then do:
        run vou_bank(0).
        v-file = "/var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/oporderp.htm".
        unix silent value("echo '<pre>' >> " + v-file + ";cat vou.img >> " + v-file + ";echo '</pre>' >> " + v-file).
        unix silent value("chmod 666 " + v-file).
    end.
    else
    do i = 1 to get-pksysc-int ("kolord"):
        run vou_bank(2).
    end.
end.

/********** Проводка на счет РКЦ-1 begin************************/
find first sysc where sysc.sysc = "rkcout" no-lock no-error.
if avail sysc and sysc.loval then do:
    s-jh = 0.
    vparam = string (pkanketa.ln) + vdel +
             string (pkanketa.summa - pkanketa.sumcom) + vdel + string(pkanketa.crc) + vdel +
             string (pkanketa.aaa) + vdel +
             '000904512'  + vdel +
             pkanketa.rnn + " " + pkanketa.name + "  Перевод собственных средств " + vdel +
             v-knp .
    
    run trxgen ("JOU0028", vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).
    
    if rcode <> 0 then do: message rcode rdes. pause 100. return. end.
    
    find current pkanketa exclusive-lock.
    pkanketa.sumout = pkanketa.summa - pkanketa.sumcom. 
    find current pkanketa no-lock.
    
    if s-jh <> 0 then do:
        if v-inet then do:
            run vou_bank(0).
            v-file = "/var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/oporderp.htm".
            unix silent value("echo '<pre>' >> " + v-file + ";cat vou.img >> " + v-file + ";echo '</pre>' >> " + v-file).
            unix silent value("chmod 666 " + v-file).
        end.
        else do:
            do i = 1 to get-pksysc-int ("kolord"):
                run vou_bank(2).
            end.
            do i = 1 to get-pksysc-int ("kolkvt"):
                run pk-kvit.
            end.
        end.
    end.
    
    find first comm.txb where comm.txb.bank = "rkc00" no-lock no-error.
    if avail comm.txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + comm.txb.path + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run rkccif(pkanketa.cif).
        if connected ("txb") then disconnect "txb".
    end.
    
end.

/********** Проводка на счет РКЦ-1 end  ************************/

