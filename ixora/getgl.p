/* getgl.p
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
*/

def input parameter accnt as char.

find first arp where arp.arp = accnt no-lock no-error.
if avail arp then return string(arp.gl).
find first aaa where aaa.aaa = accnt no-lock no-error.
if avail aaa then return string(aaa.gl).
find first ast where ast.ast= accnt no-lock no-error.
if avail ast then return string(ast.gl).
find first dfb where dfb.dfb = accnt no-lock no-error.
if avail dfb then return string(dfb.gl).
find first eps where eps.eps = accnt no-lock no-error.
if avail eps then return string(eps.gl).
find first fun where fun.fun = accnt no-lock no-error.
if avail fun then return string(fun.gl).
find first lcr where lcr.lcr = accnt no-lock no-error.
if avail lcr then return string(lcr.gl).
find first lon where lon.lon = accnt no-lock no-error.
if avail lon then return string(lon.gl).
find first ock where ock.ock = accnt no-lock no-error.
if avail ock then return string(ock.gl).
return ''.







