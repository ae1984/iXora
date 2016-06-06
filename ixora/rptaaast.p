/* rptaaast.p
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

/* rptaaast.p
*/

{mainhead.i BTRSTS}  /* ACCOUNTS STATUS REPORT */

define var vcnt as int.
define var vfdt as date.
define var vdate like g-today.
define variable v-lgr like lgr.lgr.

{image1.i rpt.img}

update v-lgr label "ГРУППА СЧЕТОВ" validate (v-lgr eq "" or 
    can-find (lgr where lgr.lgr eq v-lgr), "ПРОВЕРЬТЕ ГРУППУ СЧЕТОВ") 
    with frame c centered no-box side-labels.

    if v-lgr ne "" then find lgr where lgr.lgr eq v-lgr no-lock no-error.
    else find first lgr.                    

{image2.i}
{report1.i 59}

vtitle = "".
for each crc where crc.crc eq (if v-lgr eq "" then crc.crc else lgr.crc) and
    crc.sts ne 9 break by crc.crc:

    {report2.i 132}
    find first aaa where aaa.crc = crc.crc no-lock no-error.
        if not available aaa then next.

    if first-of(crc.crc) then do:
        if not first(crc.crc) then page.
        display   skip(1)
            "[ ВАЛЮТА   - "  + crc.des  + " ]"  format "x(45)" skip
            with no-label no-box page-top frame crc.
    end.

    for each led  no-lock
        ,each lgr of led where lgr.lgr eq (if v-lgr eq "   " then lgr.lgr
        else v-lgr) 
        no-lock
        ,each aaa of lgr where aaa.crc = crc.crc
            and (aaa.cr[1] - aaa.dr[1] ne 0 or aaa.accrued ne 0) no-lock
        ,each cif of aaa no-lock break by aaa.lgr by aaa.aaa:

        if month(aaa.regdt) eq month(g-today) then vfdt = aaa.regdt.
        else vfdt = date(month(g-today),1,year(g-today)).

        if first-of(aaa.lgr) then do:
            if not first(aaa.lgr) then page.
            display lgr.lgr label "ГРУППА" lgr.des label "НАИМЕНОВАНИЕ ГРУППЫ" 
            with side-label frame lgr.
        end.
        vcnt = 0.
        
        display aaa.aaa label "СЧЕТ" 
        (sub-count by aaa.lgr by crc.crc) 
        aaa.regdt label "ДАТА РЕГ."
        aaa.cif label "КИФ"
        trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)" label "НАИМЕНОВАНИЕ КЛИЕНТА"
            (aaa.dr[1] - aaa.cr[1]) * led.drcr
            (sub-total by crc.crc by aaa.lgr)
            format "zzz,zzz,zzz,zz9.99CR" label "БАЛАНС "
            round(aaa.accrued,2) format "zzz,zzz,zz9.99CR"
            (sub-total by crc.crc by aaa.lgr)
            label "НАЧИСЛ.%"
            /*(aaa.mtdacc + (aaa.cr[1] - aaa.dr[1]))
            / (g-today - vfdt + 1) label "AVERAGE"
         format "z,zzz,zzz,zzz,zzz,zz9.99CR" (sub-average by crc.crc by aaa.lgr)
          */
            /*aaa.cnt[1] + vcnt label "#OF CHK"    */
            with width 132 down frame aaa.
    end.
end.
{report3.i}
{image3.i}
