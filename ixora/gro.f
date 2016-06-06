/* gro.f
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

/* gro.f
*/

form gro.gro     colon 18                gro.rdt    colon  50
     gro.type    colon 18                gro.billno colon  50
     gro.amt     colon 18                gro.duedt  colon   50
     gro.aaa     colon 18                gro.acc    colon 50
     gro.bank    colon 18                vbank            skip
     gro.acct    colon 18                skip
     gro.rem     colon 18
     gro.sts     colon 18                gro.jh    colon  50
     gro.who     colon 18                gro.whn colon    50
     with frame gro side-label row 5
		centered title " KOMUN.PAKLP. RЁґOPER…CIJ ".
