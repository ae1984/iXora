/* vkins.i
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

/* ======================================================
=							=
=		Valsts Kase Related 			=
=							=
====================================================== */	

if {1}.dc = "c" then do:
 find first sysc where sysc.sysc = "LINKJL" no-lock no-error.
 if available sysc and ( sysc.chval matches( "*" + {1}.account + "*" ) )  then do:

    define variable add_detail as character.

    if {1}.dealtrn begins "RMZ" then do:
	find first linkjl where {1}.d_date = linkjl.jdt and 
                                linkjl.rem = {1}.dealtrn no-lock no-error.
 
        if available linkjl then add_detail = trim(atr[12]). 

    end.     /* -- RMZ processing ... */
    else do:
        find first linkjl where {1}.d_date = linkjl.jdt and 
                                linkjl.jh = b-jl.jh and
                                linkjl.ln = b-jl.ln no-lock no-error.

        if available linkjl then add_detail = trim(atr[12]). 
        else do: 
           find first linkjl where {1}.d_date = linkjl.jdt and 
                                   linkjl.jh = b-jl.aah no-lock no-error.

           if available linkjl then add_detail = trim(atr[12]).
        end.
    end.     /* -- Transaction processing ... */

    if add_detail <> "" and add_detail <> ? then {1}.dealsdet = {1}.dealsdet + " Subkonts: " + add_detail.

 end. /* if available sysc ... */
end.  /* --- if credit ...     */
