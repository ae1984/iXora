/* findclsaaatxb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        10/05/2011 evseev - поиск закрытых или несуществующих счетов по филиалам
 * BASES
        BANK COMM
 * CHANGES
        23/11/2011 evseev - логирование
        25/11/2011 evseev - логирование
        20/01/2012 evseev - добавил no-undo
        01/02/2012 evseev - Изменил вложенность циклов (for each и do to на do to и for each) стр 60.  Отправка уведомления на почту
        02.02.2012 evseev - тестовый отдельный конект по базам
        07.02.2012 evseev - закоментировал run savelog
        13/02/2012 evseev - добавил r-branch
        22/02/2012 evseev - если 1 счет в списке, то не искать по филиалам
        28/04/2012 evseev - изменил логирование
        11/05/2012 evseev - изменил логирование, убрал оповещение
*/

def input parameter i-aaacurrent like aaa.aaa no-undo.
def input parameter i-aaalist as char no-undo.
def output parameter o-res as logical no-undo.
def            var i      as integer no-undo.
def new shared var s-aaa  like aaa.aaa no-undo.
def new shared var s-res  as logical no-undo.


s-res = yes.
o-res = yes.


if i-aaacurrent = i-aaalist then do:
   run savelog( "findclsaaatxb", "Закрываемый счет один в списке арестованных счетов. счет " + i-aaacurrent + " = список " + i-aaalist).
end. else do:
   /*run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "Поиск не закрытых счетов (findclsaaatxb) счет ", i-aaacurrent + "  список " + i-aaalist, "1", "", "").*/

   do i = 1 to num-entries(i-aaalist):
        s-aaa = entry(i,i-aaalist).
        for each comm.txb where comm.txb.consolid = true no-lock:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                /*run savelog( "findclsaaatxb", s-aaa + "  Имеется список счетов 1) " + i-aaalist + " txb=" + string(comm.txb.txb)).*/
                if s-aaa <> i-aaacurrent then run  findclsaaatxb1.
                if s-res = no then do:
                    run savelog( "findclsaaatxb", s-aaa + "  Имеется список счетов 1.1) " + i-aaalist  + " txb=" + string(comm.txb.txb) + " - NO" ).
                    o-res = no.
                    if connected ("txb") then disconnect "txb".
                    return.
                end. else run savelog( "findclsaaatxb", s-aaa + "  Имеется список счетов 1.2) " + i-aaalist  + " txb=" + string(comm.txb.txb) + " - YES" ).
        end.
    end.
    if connected ("txb") then disconnect "txb".
end.
