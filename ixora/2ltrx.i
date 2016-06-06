/* 2ltrx.i
 * MODULE
        Платежная система
 * DESCRIPTION
        ручная генерация 2-ой проводки для входящих переводов - собственно генерация проводки
 * RUN
        верхнее меню 5-9-3
 * CALLER
        2trx.p, 2ltrxa.p
 * SCRIPT

 * INHERIT

 * MENU
        5-9-3 2ПровГен, F1 в списке полочки vcon
 * AUTHOR
        16.09.2003 nadejda  - взят кусок из 2ltrx.p
 * CHANGES
        08.10.2003 nadejda  - заменен stdoc_out.i на 2 куска до и после транзакции - 2ltrx_vc.i, 2ltrx_out.i
        19.03.2004 isaev    - добавлена загрузка файла bwx на NTSERVER для платежа по пополнению карт.
                              счета пришедшего с филиала
        24.06.2004 suchkov  - добавил проверку на то, что 2-я проводка уже есть.
        02.05.2006 u00600   - 2-я дата валютирования
	24.06.2006 tsoy     - перекомпиляция
    07.02.2013 evseev - tz-1633
*/


/* 07.10.2003 nadejda - если нужна блокировка суммы, то меняем указанный счет на транзитный счет ВалКона в соответствующей валюте */

{2ltrx_vc.i}


if length(remtrz.racc) = 20 and substr(remtrz.racc,19,2) = "00" then
   find first swift where swift.swift_id = int(remtrz.ref) and swift.rmz = remtrz.remtrz no-lock no-error.
if not avail swift then do:
    /* взять описание проводки из remtrz */
    v-text1 = s-remtrz  + ' ' + trim(remtrz.detpay[1]) + trim(remtrz.detpay[2]) +
               trim(remtrz.detpay[3]) + trim(remtrz.detpay[4]).

    v-text1 = substring(v-text1, 1, 60).
    vparam = remtrz.remtrz          + vdel +
             string(remtrz.amt)     + vdel +
             trim(remtrz.info[10])  + vdel +
             trim(v-cif)            + vdel +
             trim(v-arp)            + vdel +
             v-text1 + vdel +
             "Отправитель: " + substr (remtrz.ord, 1, 55).  /* добавить наименование отправителя */

    /* взять из платежки ЕКНП и записать все во вторую строку комментария */
    find sub-cod where sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" and sub-cod.acc = remtrz.remtrz no-lock no-error.
    if avail sub-cod and sub-cod.rcode <> "" then do:
         /* RMZ0320691 */
      vparam = vparam + vdel + "КОД " + entry (1, sub-cod.rcode) + " КБе " + entry (2, sub-cod.rcode) + " КНП "  + entry (3, sub-cod.rcode).
    end.
    else vparam = vparam + vdel + " ".

    shcode = "PSY0037".
end. else do:
    vparam = remtrz.remtrz      + vdel +
              string(remtrz.amt) + vdel +
              remtrz.sacc + vdel + remtrz.racc + vdel +
              remtrz.remtrz + " " + replace(
              trim(remtrz.detpay[1]) +
              trim(remtrz.detpay[2]) +
              trim(remtrz.detpay[3]) +
              trim(remtrz.detpay[4]) +
              substr(remtrz.ord,1,35) +
              substr(remtrz.ord,36,70) +
              substr(remtrz.ord,71),"^"," ") .
    shcode = "PSY0048".
end.
/* suchkov - 24.06.04 */
if remtrz.jh2 ne ? and remtrz.jh2 ne 0 then do:
   message " 2 проводка уже сделана !" . pause .
   return .
end.

run trxgen(shcode,vdel,vparam,"rmz",remtrz.remtrz,output rcode,
           output rdes,input-output s-jh).

if rcode ne 0 then do :
   v-text = " Ошибка 2 проводки rcode = " + string(rcode) + ":" +
            rdes + " " + remtrz.remtrz + " " + remtrz.dracc .
   message v-text . pause .
   return.
end.

remtrz.jh2  = s-jh.
if length(remtrz.racc) = 20 and substr(remtrz.racc,19,2) = "00" then
   find first swift where swift.swift_id = int(remtrz.ref) and swift.rmz = remtrz.remtrz no-lock no-error.
if avail swift then remtrz.jh1 = s-jh.

/*02.05.2006 u00600 если 2-я дата валютирования отличается от g-today, то меняем*/
v-dt = remtrz.valdt2.
if remtrz.valdt2 <> g-today then remtrz.valdt2 = g-today.

/* 26.02.03 timur */
if remtrz.ptype <> '5' then remtrz.cracc = trim(v-arp).

/* isaev - обработка аттача для BWX */
{bwxatrmz.i}

/* sasco - for KMobile */
if remtrz.source <> 'IBH' then
do:

   {mob333rmz.i}

end.

/* the same for kcell - Kanat */
if remtrz.source <> 'IBH' then
do:

   {ibcomrmz.i}

end.

{1}

if v-dt = remtrz.valdt2 then v-text = "2 TRX сделана вручную " + trim(remtrz.remtrz).
else v-text = "2 TRX сделана вручную и 2-я дата валютирования изменена " + trim(remtrz.remtrz).

run lgps.

{2}

/* 07.10.2003 nadejda - выдача уведомлений для валютных платежей */
{2ltrx_out.i}



