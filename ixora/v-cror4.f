/* v-cror4.f
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

/* v-cror4.f  9.06.95*/
/*BURU*/
    if crc.rate[8] ne 0
    then
    l[nt] = l[nt] + "*".
    disp stream rpt
                    l[nt] label "Nos."
                    crc.crc label "Kods"
                    rate[9] label "Daudz." format "zzz,zz9.9"
                    cab[nt] label "Pёrk " format "zzzz.9999"
                    cas[nt] label "P–rd." format "zzzz.9999"
                    ncb[nt] label "Pёrk " format "zzzz.9999"
                    ncs[nt] label "P–rd." format "zzzz.9999"
                    lbk[nt] label "LB kurss" format "zzzz.9999"
                    with down frame okona with width 80.
