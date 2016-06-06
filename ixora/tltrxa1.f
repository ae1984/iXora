/* tltrxa1.f
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

form
	    m-char
    column-label "Laiks"
	    aal.who
    column-label "Izpild.
	    aal.aah format 'zzzzzzz9'
    column-label "IDN"
	    aal.ln
    column-label "LЁn"
	    aal.jh
    column-label "Oper.#"
	    aal.aax
    column-label "Oper. kods"
	    aax.des
    column-label "Oper–cija"
	    aal.aaa
    column-label "Konts"
	    m-amtd format "z,zzz,zzz,zzz,zz9.99-"
    column-label "Debets"
	    m-amtk format "z,zzz,zzz,zzz,zz9.99-"
    column-label "KredЁts"
	    aal.teller
    column-label "Akcepts"
	    aah.stn
    column-label "STS"
    header skip(1)
	    with row 7 4 down frame aaltl no-box  .
