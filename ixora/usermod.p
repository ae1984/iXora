/* usermod.p
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
        id00477 id00700
 * BASES
        BANK
 * CHANGES
	2012-09-26 перекомпиляция id00700
	2012-09-26 14-30 перекомпиляция id00700
*/

def var v-user as char.
def var v-name as char.
def temp-table ttUser like _user.

input through value ("echo $VUSER") no-echo.
set v-user.
input close.

do transaction on error undo, return:
 find _user where _user._userid = v-user exclusive-lock.
 buffer-copy _user except _TenantId to ttuser.
 v-name = _user._user-name.
 delete _user.
 find first ttUser exclusive-lock.
 ttUser._password = encode("1234").

 create _user.

 /* assign _userid = v-user _user-name = v-name _user._password = encode("1234").*/

 buffer-copy ttuser except _TenantId to _user.
 release _user.

 find ofc where ofc.ofc = v-user exclusive-lock no-error.
 ofc.visadt = today.

 release ofc.
end.
