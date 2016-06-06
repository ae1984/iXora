/* csin.p
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
        31/07/2007 madiyar - убрал упоминание удаленной таблицы sta
*/

{global.i}
{mt100.i}
def shared var s-rem like rem.rem.
def shared var s-ref like rem.ref.
def shared var s-sta as char format "x(2)" label "State".
find CurSta where CurSta.ref eq s-ref exclusive-lock no-error.
if available CurSta then do :
    create HisSta.
    HisSta.rem = CurSta.rem.
    HisSta.ref = CurSta.ref.
    HisSta.refer =  CurSta.refer.
    HisSta.sta = CurSta.sta.
    HisSta.jh  = CurSta.jh .
    HisSta.vjh = CurSta.vjh.
    HisSta.FWhn = CurSta.whn.
    HisSta.FTim = CurSta.tim.
    HisSta.FWho = CurSta.who.
    HisSta.SWhn = today.
    HisSta.STim = time.
    HisSta.SWho = g-ofc.
    delete CurSta.
end.
if s-sta ne "~~" then do:
    create CurSta.
    CurSta.rem = s-rem.
    CurSta.ref = s-ref.
    CurSta.sta = s-sta.
    CurSta.Whn = today.
    CurSta.Refer = "".
    CurSta.Tim = time.
    CurSta.Who = g-ofc.
    find rem where rem.rem eq s-rem no-error .
    if available rem then do:
	CurSta.jh  = rem.jh .
	CurSta.vjh = rem.vjh.
    end.
end.
