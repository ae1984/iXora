/* customs.p
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
        31/12/99 pragma
 * CHANGES
        31/03/2005 kanat - добавил количество платежей в конце отчета.
        16/05/2005 kanat - добавил районные таможни 
*/


def var d_date_begin as date.
def var d_date_end as date.
def var d_sum as decimal.
def var d_count as integer.

update d_date_begin label "Введите дату начала периода:" with centered side-label.
update d_date_end   label "Введите дату окончания периода:" with centered side-label.

output to customs.img.

put unformatted 'Зачисленные платежи Таможенного управления АО TEXAKABANK c ' d_date_begin ' по ' d_date_end skip.
put unformatted 'Номер квит.   Дата     Номер транз.            Сумма' skip.
put fill("-",80) format "x(80)" skip.


for each commonpl where date >= d_date_begin and date <= d_date_end and rmzdoc <> ? and arp = '000076261' no-lock.

find first remtrz where remtrz.remtrz = rmzdoc no-lock no-error.

if avail remtrz then do:
put unformatted  commonpl.dnum format 'zzzzzzzzzzz' ' ' commonpl.date format '99/99/9999' ' ' commonpl.rmzdoc format 'x(12)' ' ' remtrz.amt format 'zz,zzz,zzz,zzz,zz9.99' skip.
d_sum = d_sum + remtrz.amt.
d_count = d_count + 1.
end.
end.

put unformatted "" skip(1).

put unformatted 'Зачисленные платежи районных таможенных комитетов АО TEXAKABANK c ' d_date_begin ' по ' d_date_end skip.
put unformatted 'Номер квит.   Дата     Номер транз.            Сумма' skip.
put fill("-",80) format "x(80)" skip.


for each commonpl where date >= d_date_begin and date <= d_date_end and rmzdoc <> ? and arp = '002076162' no-lock.

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
run menu-prt ('customs.img').




































