/* cif-dda1.f
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

form    aaa.aaa
        aaa.cif
        aaa.pri
        aaa.rate
        v-lgr        label "ODA GRP"
        aaa.craccnt  label "ODA"
        b-aaa.svc label "Технический"
        b-aaa.opnamt label "CREDIT LINE"
        b-aaa.rate   label  "ODA INT%"
        b-aaa.pri    label  "ODA PRIME#"
        b-aaa.cbal   label  "ODA COLLECT BAL"
        with frame ddaoda
         row 3 centered 1 col overlay
        title " DDA/ODA Setup ".
