/* vcjoublk.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Вызывается для вида проводки ARP -> СЧЕТ  в журнале операций
        ставит признак снятия средств для сумм на ARP-счетах КРЕДИТОРОВ Валютного Контроля
 * RUN

 * CALLER
        jou_main.p
 * SCRIPT

 * INHERIT

 * MENU
        2-1
 * AUTHOR
        12.11.2003 nadejda  - вынесен в отдельную программу из jou42-aasnew.p
 * BASES
        BANK COMM
 * CHANGES
        13.10.2003 nadejda  - проставление номера второй проводки в списке блокированных сумм
        16.10.2003 nadejda  - при выборе платежа в списке блокированных сумм единственная найденная считается верной, выбор из списка дается в случае, когда найдено несколько одинаковых сумм
        24.11.2003 nadejda  - если не найден счет клиента - вместо cif ставим "" (сделано для проводок ARP -> КАССА)
        23.11.2011 aigul    - добавила логи
        18.05.2012 aigul    - блокировка суммы - тз962
        05.06.2012 damir    - искать документ в remtrz по полю remtrz.sqn.
*/


{global.i}
{vc.i}


def input parameter v-dracc as char.
def input parameter s-aaa as char.
def input parameter s-amt as decimal.
def input parameter s-jh  like jh.jh.
def output parameter p-block as logical initial no.
def output parameter p-rmz as char.


p-rmz = "".
find arp where arp.arp = v-dracc no-lock no-error.
if not avail arp then return.

/* если это не счет валютного контроля - не надо ничего делать, выход */
def var v-arpblkgl as char init "286060".

find sysc where sysc.sysc = "ARPBGL" no-lock no-error.
if avail sysc then v-arpblkgl = sysc.chval.

if lookup(string(arp.gl), v-arpblkgl) = 0 then return.




def new shared var s-remtrz like remtrz.remtrz.

def new shared temp-table t-rmz
    field remtrz like remtrz.remtrz
    field rdt as date
    field crc as char
    field amt as decimal
    field name as char
    field acc as char
    index remtrz is primary unique name rdt remtrz.


{comm-txb.i}
def var v-ourbank as char.
v-ourbank = comm-txb().

def frame f-remtrz
  skip(1)
  s-remtrz label " РЕФЕРЕНС ВХОДЯЩЕГО ПЛАТЕЖА "
      help " Укажите референс платежа, сумма которого была заблокирована на транзитном счете "
      validate (s-remtrz = "" or s-remtrz = " " or
                can-find(remtrz where remtrz.remtrz = s-remtrz and lookup(remtrz.ptype, "3,7") > 0
                         and remtrz.tcrc = arp.crc and remtrz.amt = s-amt no-lock),
                " Не найден входящий платеж или валюта/сумма не соответствуют проводке!")
  "   " skip(1)
  with side-labels row 6 overlay centered title " ВАЛЮТНЫЙ КОНТРОЛЬ - УКАЖИТЕ РАЗБЛОКИРУЕМЫЙ ПЛАТЕЖ ".

def var v-kol as integer init 0.


for each vcblock where vcblock.bank = v-ourbank and vcblock.arp = v-dracc and vcblock.sts = "B" and vcblock.amt = s-amt
no-lock use-index sts:
    accumulate vcblock.remtrz (count).
end.
v-kol = accum count vcblock.remtrz.

if v-kol = 0 then do:
    /* не найден входящий платеж - запросить REMTRZ */
    update s-remtrz with frame f-remtrz.
    if s-remtrz <> "" then v-kol = 1.
    if s-remtrz = "" then do:
        p-block = yes.
        p-rmz = "".
    end.
end.

if v-kol = 1 then do:
    /* найден один платеж - считаем его верным */
    find vcblock where vcblock.bank = v-ourbank and vcblock.arp = v-dracc and vcblock.sts = "B" and vcblock.amt = s-amt
    no-lock use-index sts no-error.
    if avail vcblock then  s-remtrz = vcblock.remtrz.
end.

if v-kol > 1 then do:
    /* найдено несколько платежей на эту сумму - выбрать верный */
    for each vcblock where vcblock.bank = v-ourbank and vcblock.arp = v-dracc and vcblock.sts = "B" and vcblock.amt = s-amt
    no-lock use-index sts:
        find crc where crc.crc = vcblock.crc no-lock no-error.

        create t-rmz.
        assign
        t-rmz.remtrz = vcblock.remtrz.
        find remtrz where remtrz.remtrz = vcblock.remtrz or trim(substr(trim(remtrz.sqn),7,10)) = trim(vcblock.remtrz) no-lock no-error.
        if avail remtrz then do:
            assign
            t-rmz.rdt = remtrz.rdt
            t-rmz.acc = remtrz.racc.
        end.
        assign
        t-rmz.amt = vcblock.amt
        t-rmz.crc = crc.code
        t-rmz.name = vcblock.remname.
    end.

    run ch-rmz.
end.

if s-remtrz <> "" then do:
  find remtrz where remtrz.remtrz = s-remtrz or trim(substr(trim(remtrz.sqn),7,10)) = s-remtrz no-lock no-error.

  find first vcblock where vcblock.bank = v-ourbank and vcblock.remtrz = s-remtrz exclusive-lock no-error.
  if not avail vcblock then do:
    find sub-cod where sub-cod.sub = "arp" and sub-cod.acc = v-dracc and sub-cod.d-cod = "sproftcn" no-lock no-error.
    run savelog("vcjoublk", "id: " + g-ofc + ", date: " + string(g-today) + ",bank: " + v-ourbank + ",rmz: " + remtrz.remtrz).
    create vcblock.
    assign vcblock.bank = v-ourbank
           vcblock.remtrz = remtrz.remtrz
           vcblock.remracc = remtrz.racc
           vcblock.remname = remtrz.bn[1]
           vcblock.remdetails = trim(remtrz.detpay[1] + remtrz.detpay[2] + remtrz.detpay[3] + remtrz.detpay[4])
           vcblock.amt = remtrz.amt
           vcblock.crc = remtrz.tcrc
           vcblock.arp = v-dracc
           vcblock.depart = if avail sub-cod and sub-cod.ccode <> "msc" then sub-cod.ccode else "506"
           vcblock.jh1 = remtrz.jh2
           vcblock.rdt = g-today
           vcblock.rwho = g-ofc
           vcblock.retremtrz = "".
  end.

  find aaa where aaa.aaa = s-aaa no-lock no-error.

  assign vcblock.acc = s-aaa
         vcblock.jh2 = s-jh
         vcblock.sts = "C"
         vcblock.deldt = g-today
         vcblock.delwho = g-ofc
         vcblock.cif = if avail aaa then aaa.cif else "".
  release vcblock.
  run savelog("vcjoublk", "id: " + g-ofc + ", date: " + string(g-today) + ",bank: " + v-ourbank + ",rmz: " + remtrz.remtrz).
  p-rmz = s-remtrz.
  p-block = no.
end.
