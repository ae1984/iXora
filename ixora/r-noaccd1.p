/* r-credbd.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Отчет по непринятым досье
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-4-9-3
 * AUTHOR
        05/02/2007 Natalya D.
 * BASES
        bank, txb
 * CHANGES
        20/04/2007 madiyar - добавил из новой библиотеки
        21/05/2007 madiyar - в поиске проводки lon.rdt вместо lon.opndt
        25/07/2007 madiyar - добавил поле t-temp.fil
        30/07/2007 madiyar - теперь в отчет попадают все не сданные досье, не только отвергнутые
*/

def input parameter p-dt as date.
def var v-firstdt as date no-undo.
v-firstdt = p-dt.
def var v-sts as char no-undo.

find first txb.cmp no-lock no-error.

def shared temp-table t-temp no-undo
         field name as char
         field paydt as date
         field ofc-n as char
         field ofc-l as char
         field spf as char
         field fil as char
         field sts as char
         index idx is primary fil spf ofc-l.

for each txb.lon where (txb.lon.grp = 90 or txb.lon.grp = 92) no-lock:
  find last txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon
                      and txb.sub-cod.d-cod = 'docbd' no-lock no-error.

  if not avail txb.sub-cod or txb.sub-cod.ccode = "msc" then v-sts = "new".
  else do:
    if txb.sub-cod.ccode <> '01' then v-sts = "rejected".
    else next.
  end.

  find first txb.lonres where txb.lonres.jdt >= txb.lon.rdt  
                  and txb.lonres.lon = txb.lon.lon and txb.lonres.dc = 'd' 
                  and lookup(txb.lonres.trx,'lon0001,lon0002,lon0003,lon0004,lon0005,lon0006,lon0052') > 0 
                  no-lock no-error.
  if not avail txb.lonres then next.

  find last txb.ofc where txb.ofc.ofc = txb.lonres.who no-lock no-error.
  find last txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
  find first txb.ppoint where txb.ppoint.depart = (txb.ofc.regno mod 1000) no-lock no-error.
  create t-temp.
  t-temp.sts = v-sts.
  if avail txb.cmp then t-temp.fil = entry(1,txb.cmp.addr[1]).
  if avail txb.cif then
         t-temp.name = txb.cif.name.
         t-temp.paydt = txb.lonres.jdt.
  if avail txb.ofc then
         t-temp.ofc-n = txb.ofc.name.
         t-temp.ofc-l = txb.lonres.who.
  if avail txb.ppoint then
         t-temp.spf = txb.ppoint.name.
  
end.
