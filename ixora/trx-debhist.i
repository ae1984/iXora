/* trx-debhist.i
 * MODULE
        Генератор транзакций
 * DESCRIPTION
        Общая для обработки дебиторов
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
        13/01/04 sasco добавил обработку ссылки на время в таблице debc
        05/03/04 recompile
        11/03/04 sasco - добавил обработку профит-центра
        16/08/2005 marinav добавлен фактический срок

*/

define {1} temp-table dtmp
            field grp     like debls.grp  
            field ls      like debls.ls   
            field name    like debls.name
            field ost     like debhis.ost
            field active  as log
            field re-open as log
            field dam     like debhis.amt
            field cam     like debhis.amt
            field rem     like debhis.rem
            field refjh   like debop.refjh
            field refwhn  like debop.refwhn
            .

define {1} temp-table month3
            field grp     like debls.grp
            field ls      like debls.ls
            field name    like debls.name
            field period  like debop.period
            field asked   as logical
            field attn    like debop.attn
            field fsrok   as char
            .

define {1} temp-table deb-dam
            field grp     like debls.grp
            field ls      like debls.ls
            field dam     like debhis.amt
            .

define {1} temp-table debc
            field grp    like debhis.grp
            field ls     like debhis.ls
            field date   like debhis.date
            field ctime  like debhis.ctime
            field cdt    like debop.cdt
            field ost    like debhis.ost
            field jh     like debhis.jh
            field closed like debop.closed initial no
            field period like debop.period
            .

define {1} temp-table dost
            field grp like debls.grp
            field ls like debls.ls
            field ost like debhis.ost.

define {1} temp-table tmon like debmon.

define {1} variable dt-time as integer.

