/* banka_txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Копирование настроек banka в филиал
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
        02/10/2013 galina ТЗ2104
 * BASES
        BANK TXB
 * CHANGES
*/
def input parameter p-bank as char.
def shared temp-table t-banka like txb.banka.

for each txb.banka exclusive-lock:
    delete txb.banka.
end.
for each t-banka where t-banka.bank = p-bank no-lock:
    create txb.banka.
    buffer-copy t-banka to txb.banka.
end.

