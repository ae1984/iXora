/* taxcis.p
 * MODULE
        Налоговые платежи
 * DESCRIPTION
        Выгрузка данных по штрафам КБ = 204105 для Центра информационных систем 
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
        27/05/05 kanat
 * CHANGES 

Сообщения отправлять по адресу: export@mail.texakabank.kz  <texaka@vancom.kz>
Тема сообщения: encrypt vancom

*/

{global.i}
{comm-txb.i}

def var id_bank as char.            /* Код банка */
def var id_benificiar as char.      /* Код бенефициара */
def var id_pack as char.            /* Порядковый номер */

def var id_face_type as char.       /* Код типа лица. ФЛ - 1, ЮЛ - 2 */  
def var v-surname as char.          /* Фамилия */  
def var v-name as char.             /* Имя ФЛ или наименование ЮЛ */
def var patronic as char.           /* Отчетство */
def var birthdate as char.          /* Дата рождения */
def var id_ic_type as char.         /* Код типа документа удостоверющего личность */
def var ic_series as char.          /* Серия документа, удостоверяющего личность */
def var ic_number as char.          /* Номер документа, удостоверяющего личность */
def var v-rnn as char.              /* РНН */ 
def var v-number as char.           /* Номер протокола об административном правонарушении */
def var v-kbk as char.              /* КБК */
def var pay_number as char.         /* Номер платежного документа */
def var pay_date as char.           /* Дата оплаты */
def var pay_sum as char.            /* Сумма оплаты */

def var out as char.
def var v-date-begin as date.
def var ourbank as char.

v-date-begin = g-today - 1.
ourbank = comm-txb().

update v-date-begin format '99/99/9999' label " Введите дату статистики: " 
with centered frame df.

output to value(string(v-date-begin, "999999") + ".xml").
put unformatted "<?xml version=""1.0"" encoding=""koi8-r""?>" skip
                "<Envelope xmlns=""http://www.w3.org/2003/05/soap-envelope"">" skip
                "<Header>" skip
                "<MessageInfo>" skip
                "<To>CIS</To>" skip
                "<From>TEXAKABANK</From>" skip
                "</MessageInfo>" skip
                "</Header>" skip
                "<Body>" skip.

id_bank = "1".
id_benificiar = "1".
id_pack = string(time).

put unformatted "<Id_bank>"       id_bank       "</Id_bank>" skip
                "<Id_benificiar>" id_benificiar "</Id_benificiar>" skip
                "<Id_pack>"       id_pack       "</Id_pack>" skip.

put unformatted "<Payers>" skip.

for each tax where tax.txb = 0 and tax.date = v-date-begin and tax.duid = ? and tax.kb = 204105 no-lock.

put unformatted "<Payer>" skip.

find first rnn where rnn.trn = tax.rnn no-lock no-error.
if avail rnn then do:

id_face_type = "1".
v-surname = trim(rnn.lname).
v-name = trim(rnn.fname).
patronic = trim(rnn.mname).
birthdate = string(rnn.byear).
ic_number = trim(string(rnn.nompas)).
ic_series = trim(rnn.serpas).

if rnn.serpas matches "*УДО*" then
id_ic_type = "0".  /* Паспорт = 0, УДОСТ = 1 */
else
id_ic_type = "1".  /* Паспорт = 0, УДОСТ = 1 */

end.
else do:
find first rnnu where rnnu.trn = tax.rnn no-lock no-error.
if avail rnnu then do:

id_face_type = "2".
v-surname = " ".
v-name = trim(rnnu.busname).
patronic = "".
birthdate = "".
ic_number = "0".
ic_series = "0".

end.
end.

v-rnn = tax.rnn.
v-number = string(tax.info).
v-kbk = string(tax.kb).

find first remtrz where remtrz.remtrz = tax.senddoc no-lock no-error.
if avail remtrz then do:
pay_date = string(remtrz.valdt2).
end.
else do:
pay_date = string(tax.date).
end.

pay_number = string(tax.dnum).
pay_sum = string(tax.sum).

/* XML start */
put unformatted "<Id_face_type>"  id_face_type  "</Id_face_type>" skip 
                "<Surname>"       v-surname     "</Surname>" skip
                "<Name>"          v-name        "</Name>" skip
                "<Patronic>"      patronic      "</Patronic>" skip
                "<Birthdate>"     birthdate     "</Birthdate>" skip
                "<Id_ic_type>"    id_ic_type    "</Id_ic_type>" skip
                "<Ic_series>"     ic_series     "</Ic_series>" skip
                "<Ic_number>"     ic_number     "</Ic_number>" skip
                "<Rnn>"           v-rnn         "</Rnn>" skip
                "<Number>"        v-number      "</Number>" skip
                "<Kbk>"           v-kbk         "</Kbk>" skip
                "<Pay_number>"    pay_number    "</Pay_number>" skip
                "<Pay_date>"      pay_date      "</Pay_date>" skip
                "<Pay_sum>"       pay_sum       "</Pay_sum>" skip.

/* XML finish */

put unformatted "</Payer>" skip.
end.

put unformatted "</Payers>" skip.

put unformatted "</Body>" skip
                "</Envelope>" skip. 
output close.

out = string(v-date-begin, "999999") + ".xml".

run mail("kanat@elexnet.kz, EXPORTER <export@mail.texakabank.kz>",
         "abpk@elexnet.kz", "encrypt vancom", 
          "", "1", "", out).

unix silent value("rm -f " + out).

message "Данные успешно отправлены" view-as alert-box title "Внимание".

