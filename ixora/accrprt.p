/* accrprt.p
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

{mainhead.i}

define variable s_accrued like aaa.ratmin  format "zzz,zzz,zzz,z99.99".
define variable s_ratmin  like aaa.ratmin  format "zzz,zzz,zzz,z99.99".
define variable s_accrat  like aaa.ratmin  format "zzz,zzz,zzz,z99.99".
define variable s_Ls      like aaa.ratmin  format "z,zzz,zzz,zzz,z99.99".
define variable c_accrued like aaa.ratmin  format "zzz,zzz,zzz,z99.99".
define variable c_ratmin  like aaa.ratmin  format "zzz,zzz,zzz,z99.99".
define variable c_accrat  like aaa.ratmin  format "zzz,zzz,zzz,z99.99".
define variable c_Ls      like aaa.ratmin  format "z,zzz,zzz,zzz,z99.99".
define variable a_Ls_gl   like aaa.ratmin  format "z,zzz,zzz,zzz,z99.99".
define variable a_Ls_ie   like aaa.ratmin  format "z,zzz,zzz,zzz,z99.99".
define variable a_Ls_so   like aaa.ratmin  format "z,zzz,zzz,zzz,z99.99".
define variable for_SVL   like aaa.ratmin  format "z,zzz,zzz,zzz,z99.99".
define variable iffirst   as logical.

{image1.i rpt.img}
{image2.i}
{report1.i 120}

vtitle = "GRUPA               VAL®TA          IEPR.GAD…         №AJ… GAD… 
             KOP…                KOP… (Ls)".

for each lgr where lgr.led eq "CDA" no-lock break by lgr.crc by lgr.accgl:

    {report2.i 120}
    for each aaa where aaa.lgr eq lgr.lgr no-lock:
        s_accrued = s_accrued + aaa.accrued.    
        for_SVL = aaa.ratmin - (aaa.dr[2] - aaa.idr[2]).
            if for_SVL lt 0 then for_SVL = 0.
        s_ratmin  = s_ratmin + for_SVL.
    end.

    find crc where crc.crc eq lgr.crc no-lock.
    s_accrat  = s_accrued - s_ratmin.
    s_Ls      = s_accrued * crc.rate[1] / crc.rate[9].
    c_accrued = c_accrued + s_accrued.
    c_accrat  = c_accrat  + s_accrat.
    c_ratmin  = c_ratmin  + s_ratmin.
    c_Ls      = c_Ls      + s_Ls.

    if s_accrued ne 0 or s_ratmin ne 0 then do:
        if not iffirst then do:
            find gl where gl.gl eq lgr.accgl no-lock.
            put gl.gl " " gl.des skip(1).
            iffirst = true.
        end.

        put lgr.lgr " " lgr.des "   " crc.code " " s_ratmin " " s_accrat " " 
            s_accrued " " s_Ls skip.
    end.

    a_Ls_gl = a_Ls_gl + s_Ls.
    a_Ls_ie = a_Ls_ie + s_ratmin  * crc.rate[1] / crc.rate[9].
    a_Ls_so = a_Ls_so + s_accrat  * crc.rate[1] / crc.rate[9]. 
        
    s_accrued = 0. s_ratmin = 0. s_accrat = 0. s_Ls = 0.

    if last-of (lgr.accgl) and a_Ls_gl ne 0 then do:
        put skip(1) space(10) "KOP… G/GR (Ls)" a_Ls_ie  a_Ls_so space(19)
            a_Ls_gl skip(2).         
        a_Ls_ie = 0.  a_Ls_so = 0.  a_Ls_gl = 0.    
        iffirst = false.
    end.

    if last-of (lgr.crc) and (c_ratmin ne 0 or c_accrued ne 0) then do:
        put space(16) "KOP…      " 
            c_ratmin " " c_accrat " " c_accrued " " c_Ls skip.

        put space(16) "KOP…(Ls)  " 
            c_ratmin  * crc.rate[1] / crc.rate[9] format "zzz,zzz,zzz,z99.99 "
            c_accrat  * crc.rate[1] / crc.rate[9] format "zzz,zzz,zzz,z99.99 "
            c_accrued * crc.rate[1] / crc.rate[9] format "zzz,zzz,zzz,z99.99 "
            c_Ls skip(1).

        c_ratmin = 0. c_accrat = 0. c_accrued = 0. c_Ls = 0.
    end.
end.

{report3.i}
{image3.i}
