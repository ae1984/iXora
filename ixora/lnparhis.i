/* lnparhis.i
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
        03/08/2004 tsoy   - добавил в сохранение истории новые параметры ( Коммисисия за кред.линию, Пролонгация 1,
        04/08/2004 tsoy   - добавил создание нескольких записей в истрии в один опердень.
        11.08.2004 tsoy Добавил Вид, Договор, Выбрать до, Причину
        03.09.2004 tsoy Добавил день погашения и Ответсвенного
        15/10/2009 madiyar - в комментарий пишется, что менялось, с какого и на какое значение
        20/10/2009 madiyar - формирование строки в примечании - поставил везде кавычки
        26/01/2011 madiyar - lon.idtXX, lon.duedtXX
*/


find last ln%his where ln%his.lon = s-lon and ln%his.stdat > date ( 1, 1, 1000 ) no-lock no-error .

if available ln%his then vf0 = ln%his.f0.

    create ln%his.
         ln%his.lon     = s-lon.
         ln%his.stdat   = g-today.
         ln%his.who     = g-ofc.
         ln%his.whn     = today.
         ln%his.cif     = lon.cif.
         ln%his.duedt   = lon.duedt.
         ln%his.grp     = lon.grp.
         ln%his.gua     = lon.gua.
         ln%his.rdt     = lon.rdt.
         ln%his.lcnt    = loncon.lcnt.
         ln%his.intrate = lon.prem.
         ln%his.loncat  = lon.loncat.
         ln%his.opnamt  = lon.opnamt.
         ln%his.pnlt1   = loncon.sods1.
         ln%his.pnlt2   = loncon.sods2.
         ln%his.comln   = v-komcl.
         ln%his.long1   = lon.ddt[5].
         ln%his.long2   = lon.cdt[5].
         ln%his.kcrc    = v-crc.
         ln%his.drate   = v-rate.
         ln%his.f0      = vf0 + 1.
         ln%his.plan    = lon.plan.
         ln%his.crc     = lon.crc.
         ln%his.object  = loncon.objekts.
         ln%his.ldate   = lon.idt15.
         ln%his.proc-no = loncon.proc-no.

         ln%his.day       =   lon.day.
         ln%his.pase-pier =  loncon.pase-pier.

update  ln%his.rem format "x(45)" label " Причина"
    with overlay centered side-label row 5 frame f-dt.

ln%his.rem = ln%his.rem + " parm=" + "{&parm}" + " oldval=" + string({&oldval}) + " newval=" + string({&newval}).




