/* MT998aaa20.p
 * MODULE
       Платежная система
 * DESCRIPTION
       Отправка уведомление об изменении банковского счета
 * RUN

 * CALLER
        MT998aaa20_400_out.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        16/04/2009 galina
 * BASES
        BANK TXB
 * CHANGES
        17/04/2009 galina - смотрим дату открытия депозита в поле dtpay
        17/03/2010 galina - добавила счета гарантии 397 и 396
        31/03/2010 galina - добавила группы счетов 160,161,247,248
        23/09/2011 evseev - переход на ИИН/БИН
*/


def output parameter p-mlist as char.

def shared temp-table t-acc
 field jame as char
 field bik as char
 field acc as char
 field acc9 as char
 field acctype as char
 field opertype as char
 field rnn as char
 field bin as char
 field dt as date.

def var v-opertype as char.
def var v-acctype as char.
def var v-dt as date.
def buffer b-aaa for txb.aaa.
/**/
p-mlist = "".
find first txb.sysc where txb.sysc.sysc = "inkmail" no-lock no-error.
p-mlist = txb.sysc.chval.


find first txb.sysc where txb.sysc.sysc = 'CLECOD' no-lock no-error.
 v-dt = ?.
 v-opertype = "".
 v-acctype = "".

empty temp-table t-acc.

find last txb.cls where txb.cls.del no-lock no-error.

for each txb.aaa where (txb.aaa.regdt = txb.cls.whn) or (txb.aaa.dtpay = txb.cls.whn) no-lock:
  if length(txb.aaa.aaa) < 20 then next.
  if lookup(txb.aaa.lgr,"437,478,479,480,481,482,483,484,485,486,487,488,489,237,151,152,153,154,155,156,157,158,171,172,173,174,204,202,208,222,232,242,101,111,194,195,397,396,160,161,247,248") = 0 then next.
  find first b-aaa where b-aaa.aaa20 = txb.aaa.aaa no-lock no-error.
  if not avail b-aaa then next.
  find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
  if not avail txb.cif then next.
  if txb.cif.type = "p" and txb.cif.geo <> '022' then next.
/*уведомление об изменении счета*/
  v-opertype = '3'.
  if txb.aaa.lgr begins "4" then v-acctype = '05'.
  else v-acctype = '20'.
  v-dt = b-aaa.regdt.
  create t-acc.
  assign t-acc.jame = txb.cif.jame
         t-acc.acc = txb.aaa.aaa
         t-acc.acc9 = b-aaa.aaa
         t-acc.bik = trim(txb.sysc.chval)
         t-acc.acctype = v-acctype
         t-acc.opertype = v-opertype
         t-acc.rnn = txb.cif.jss
         t-acc.bin = txb.cif.bin
         t-acc.dt = v-dt.
end.
