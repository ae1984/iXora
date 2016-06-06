/* otrrst.p
 * MODULE
        Коммунальный модуль
 * DESCRIPTION
        Реестр контроля по прочим платежам - вместо печати платежек 
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
        18/08/04 kanat
 * CHANGES
        26/08/04 kanat - переделал шапку по просьбе П.С.
        13/08/04 kanat - не берутся в реестр квитанции с пустыми реферансами платежей
        01/04/05 kanat - добавил количество платежей
*/

def var d_date_begin as date.
def var d_date_end as date.
def var d_sum as decimal.
def var d_count as integer.

update d_date_begin label "Введите дату начала периода:" d_date_end label "Введите дату окончания периода:" with centered side-label.

output to drproch.img.
put unformatted 'Зачисленные прочие платежи (ДРР) АО TEXAKABANK c ' d_date_begin ' по ' d_date_end " Счет: 001076668"  skip.
put unformatted 'Номер квит.   Дата     Номер транз.            Сумма' skip.
put fill("-",80) format "x(80)" skip.

for each commonpl where commonpl.date >= d_date_begin and commonpl.date <= d_date_end and 
                        commonpl.rmzdoc <> ? and trim(commonpl.rmzdoc) <> '' and commonpl.arp = '001076668' no-lock.
find first remtrz where remtrz.remtrz = rmzdoc no-lock no-error.
if avail remtrz then do:
put unformatted  commonpl.dnum format 'zzzzzzzzzzz' ' ' commonpl.date format '99/99/9999' ' ' commonpl.rmzdoc format 'x(12)' ' ' remtrz.amt format 'zz,zzz,zzz,zzz,zz9.99' skip.
d_sum = d_sum + remtrz.amt.
d_count = d_count + 1.
end.
end.

put fill("-",80) format "x(80)" skip.
put unformatted 'Итого количество: ' string(d_count) skip(1).
put unformatted 'Итого сумма: ' d_sum format 'zz,zzz,zzz,zzz,zz9.99'.
output close.
run menu-prt ('drproch.img').

