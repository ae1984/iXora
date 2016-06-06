/* vcothdntype.i
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
        03/10/11 damir
 * CHANGES
        04.10.2011 damir - поставил доп.проверки на инопартнера.
        08.12.2011 aigul - if cttype = 6 then update vcdocs.payret
        15.12.2011 aigul - if cttype <> 6 then payret 02,03 yes
*/

update vcdocs.dntype with frame vcdndocs. run deftypename.
update vcdocs.dnnum with frame vcdndocs.
update vcdocs.dndate with frame vcdndocs.
if vcdocs.dndate entered then do:
    run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
    displ vcdocs.cursdoc-con vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon
    with frame vcdndocs.
end.
update vcdocs.sumpercent when (index('p', s-dnvid) > 0 or vcdocs.dntype = '17') with frame vcdndocs.
if vccontrs.cttype <> '6' and vccontrs.expimp = 'i' and  vcdocs.dntype = '02' then vcdocs.payret = yes.
if vccontrs.cttype <> '6' and vccontrs.expimp = 'e' and  vcdocs.dntype = '03' then vcdocs.payret = yes.
if vccontrs.cttype = '6' then do:
    update vcdocs.payret with frame vcdndocs.
    display vcdocs.payret with frame vcdndocs.
    update vcdocs.info[2] with frame vcdndocs.
    if vcdocs.info[2] entered then run defprocent.
    display v-procent with frame vcdndocs.
end.
update vcdocs.pcrc with frame vcdndocs.
if vcdocs.pcrc entered then do:
    run defcrckod.
    run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
    displ v-crckod vcdocs.cursdoc-con vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon
    with frame vcdndocs.
end.
update vcdocs.sum with frame vcdndocs.
if vcdocs.sum entered then displ vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon with frame vcdndocs.
update vcdocs.cursdoc-con /*when vcdocs.cursdoc-con = 0*/ with frame vcdndocs.
if vcdocs.cursdoc-con entered then
displ vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon with frame vcdndocs.
if index('p', s-dnvid) > 0 then do:
    update vcdocs.info[4] with frame vcdndocs.
    run defpartner. displ v-partner v-locatben with frame vcdndocs.
end.
if (vccontrs.cttype = "1" and index('o', s-dnvid) > 0) then do:
    update vcdocs.info[4] with frame vcdndocs.
    run defpartner. displ v-partner v-locatben with frame vcdndocs.
end.
update vcdocs.knp /*vcdocs.origin*/ with frame vcdndocs.
update vcdocs.kod14 with frame vcdndocs.
update vcdocs.info[1] with frame vcdndocs.
