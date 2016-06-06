/* mframe.i
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
        26/07/04 recompile
*/

/** mframe.i **/

define {1} variable d_cif   like cif.cif.
define {1} variable c_cif   like cif.cif.
define {1} variable d_avail as character format "x(25)".
define {1} variable c_avail as character format "x(25)".
define {1} variable m_avail as character format "x(25)".
define {1} variable d_atl   as character.
define {1} variable c_atl   as character.
define {1} variable m_atl   as character.
define {1} variable d_lab   as character.
define {1} variable d_izm   as character format "x(25)".
define {1} variable dname_1 as character format "x(38)".
define {1} variable dname_2 as character format "x(38)".
define {1} variable dname_3 as character format "x(38)".
define {1} variable cname_1 as character format "x(38)".
define {1} variable cname_2 as character format "x(38)".
define {1} variable cname_3 as character format "x(38)".

define {1} variable db_com  as character format "x(10)" view-as combo-box.
define {1} variable cr_com  as character format "x(10)" view-as combo-box.
define {1} variable com_com as character format "x(10)" view-as combo-box.

define {1} variable m_sub   as character initial "jou".

define {1} frame f_main 
"__________________ДЕБЕТ______________________________КРЕДИТ____________________" skip
    v_doc label "ДОКУМЕНТ " help "SPACE BAR, ENTER - новый документ   "
    joudoc.num label "ДОК.Nr." at 23
    joudoc.chk at 48 label "ЧЕК  Nr." format "9999999"
    joudoc.jh label "ТРН" at 66
        skip
    db_com no-label 
    help "СТРЕЛКА ВНИЗ/ВВЕРХ - выбор, ENTER - дальше "
    joudoc.dracc at 16 no-label format "x(21)"
    d_cif at 37 no-label
    cr_com at 45 no-label 
    help "СТРЕЛКА ВНИЗ/ВВЕРХ - выбор, ENTER - дальше "
    joudoc.cracc at 60 no-label format "x(21)"
    c_cif at 80 no-label skip
    d_atl no-label d_avail at 13 no-label
    c_atl at 41 no-label c_avail at 50 no-label skip
    d_lab no-label d_izm at 13 no-label skip
    dname_1 no-label  cname_1 at 45 no-label skip
    dname_2 no-label  cname_2 at 45 no-label skip
    dname_3 no-label  cname_3 at 45 no-label skip
    joudoc.drcur label "ВАЛЮТА"
        validate (can-find (crc where crc.crc eq joudoc.drcur), 
        "КОД ВАЛЮТЫ НЕ НАЙДЕН.")
    crc.des format "x(27)" no-label
    joudoc.crcur  at 45 label "ВАЛЮТА"
        validate (can-find (crc where crc.crc eq joudoc.crcur), 
        "КОД ВАЛЮТЫ НЕ НАЙДЕН.")
    bcrc.des format "x(24)" no-label                                skip
    joudoc.dramt format "zzz,zzz,zzz,zz9.99" label "СУММА"          
    joudoc.cramt format "zzz,zzz,zzz,zz9.99" at 45 label "СУММА"    skip
    joudoc.brate format "999.9999" label "КУРС ПОКУП"
    loccrc1 no-label 
    "/" joudoc.bn format "zzzzzzz" no-label space(1) f-code no-label    
    joudoc.srate format "999.9999" at 45 label "КУРС ПРОД."
    loccrc2 no-label
    "/" joudoc.sn format "zzzzzzz" no-label space(1) t-code no-label
    joudoc.remark[1] label "ПРИМЕЧ." 
    joudoc.remark[2] no-label at 10
    joudoc.rescha[3] format "x(70)" no-label at 10
"______________________________________________________________________________"
    skip
    joudoc.comcode label "КОД КОМИССИИ  " 
    tarif2.pakalp no-label format "x(54)" skip
    com_com no-label
    help "СТРЕЛКА ВНИЗ/ВВЕРХ - выбор, ENTER - дальше "
    joudoc.comacc  at 16 format "x(21)" no-label 
    joudoc.comcur at 46 label "ВАЛЮТА" 
    ccrc.des format "x(24)" 
    no-label skip
    m_atl no-label m_avail at 13 no-label
    joudoc.comamt format "z,zzz,zzz,zz9.99" at 46 label "СУММА" skip
    "ПЛАТА ЗА ОбНАЛИЧИВАНИЕ:" joudoc.nalamt no-label 
    format "z,zzz,zzz,zz9.99" "(код тарифа 409)" 
     with row 6 side-labels no-box.

