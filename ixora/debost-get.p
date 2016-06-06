/* debost-get.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Вспомогательная для расчета остатков дебиторов по срокам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
	run debost-get (grp, ls, arp, dt).
 * CALLER
        Список процедур, вызывающих этот файл
	debost4.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK
 * AUTHOR
        15/01/04 sasco
 * CHANGES
        11/03/04 sasco добавил обработку профит-центра
        16/08/05 marinav добавлен фактический срок
	10/05/06 u00121 - добавил индекс во временную таблицу wjh - формирование отчета сократилось с ~40 минут до ~ 1 минуты 
			- Добавил опцию no-undo в описание переменных и временных таблиц

*/

define input parameter vgr like debls.grp.
define input parameter vls like debls.ls.
define input parameter varp like debgrp.arp.
define input parameter v-dat as date.

DEFINE buffer bdebhis FOR debhis.

define shared temp-table wjh no-undo
         field grp like debls.grp
         field ls like debls.ls
         field jh like debhis.jh
         field closed like debop.closed initial no
	index idx_wjh grp ls jh /*10/05/06 u00121*/
         .

define shared temp-table wrk no-undo          
         field arp like debgrp.arp
         field grp like debls.grp
         field ls like debls.ls
         field jh like debhis.jh
         field ost  like debhis.ost         label "Остаток"
         field date like debhis.date        label "Дата"
         field ctime like debhis.ctime
         field period as character format "x(40)"
         field attn like debop.attn
         field srok as character
         field fsrok as character
         field name as character
         index idx_wrk is primary grp ls date ctime.


for each debhis where debhis.dactive and
                      debhis.grp = vgr and
                      debhis.ls = vls and
                      debhis.date <= v-dat and
                      debhis.jh <> 0
                      no-lock use-index dost:

    /* поищем запись в нашем списке для отчета... */
    find wrk where wrk.grp = debhis.grp and 
                   wrk.ls = debhis.ls and
                   wrk.jh = debhis.djh
                   no-error.
    /* если уже есть такая запись, то не обрабатываем */
    if available wrk then next.

    /* поищем проводку в списке проводок... */
    find wjh where wjh.grp = debhis.grp and
                   wjh.ls = debhis.ls and
                   wjh.jh = debhis.djh 
                   no-error.
    /* если нашли новую проводку, то создадим запись в списке проводок */
    if not available wjh then do:
       create wjh.
       assign wjh.grp = debhis.grp
              wjh.ls = debhis.ls
              wjh.jh = debhis.jh
              wjh.closed = no
              .
    end.

    /* если проводка уже закрыта, то топаем дальше */
    if wjh.closed then next.

    /* поищем, не закрыт ли приход */
    find last bdebhis where bdebhis.djh = wjh.jh and
                            bdebhis.dactive = no and
                            bdebhis.date <= v-dat and
                            bdebhis.grp = wjh.grp and
                            bdebhis.ls = wjh.ls
                            no-lock use-index djh no-error.

    /* если приход закрыт, то сделаем отметку об этом */
    if available bdebhis then do:
       wjh.closed = yes.
       next.
    end.

    /* если приход все-таки не закрыт, то найдем последний остаток */
    find last bdebhis where bdebhis.djh = wjh.jh and
                            bdebhis.dactive and
                            bdebhis.date <= v-dat and
                            bdebhis.grp = wjh.grp and
                            bdebhis.ls = wjh.ls
                            no-lock use-index djh no-error.

    /* если не нашли остаток, то выкинем проводку из отчета */
    if not available bdebhis then do:
       wjh.closed = yes.
       next.
    end.

    /* создадим запись для отчета */

    create wrk.
    assign wrk.grp = wjh.grp
           wrk.ls = wjh.ls
           wrk.jh = wjh.jh
           wrk.ost = bdebhis.dost
           wrk.arp = varp
           .
    /* найдем первоначальный приход */
    find first bdebhis where bdebhis.djh = wjh.jh and
                             bdebhis.grp = wjh.grp and
                             bdebhis.ls = wjh.ls and
                             bdebhis.type < 3 and
                             bdebhis.dactive
                             no-lock
                             use-index djh
                             no-error.
    wrk.fsrok = bdebhis.chval[1].
    wrk.date = bdebhis.date.
    wrk.ctime = bdebhis.ctime.
    /* найдем срок дебитора */
    find first debop where debop.grp = wjh.grp and
                           debop.ls = wjh.ls and
                           debop.jh = wjh.jh and
                           debop.date = bdebhis.date
                           no-lock use-index jh no-error.

    find codfr where codfr.codfr = "debsrok" and 
                     codfr.code = debop.period
                     no-lock no-error.

    if avail codfr then wrk.period = codfr.name[1]. /* срок */
    wrk.srok   = debop.period.
    wrk.attn   = debop.attn. /* профит-центр, к которому привязан приход */

end.
