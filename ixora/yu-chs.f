/* yu-chs.f
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

define  input parameter vards  as character.
define  input parameter rezims as integer.
define  shared variable rinda  as integer.
define  shared temp-table wrk
               field    code     as character format "x(10)" label "Код"
               field    des      as character format "x(30)" 
               label "Наименование"
               field    ja-ne    as character format "x".
define variable saraksts as character format "x(30)".
form wrk.code
     help "Enter - выбор; стрелки - поиск; F1 - редактирование; F4 - выход"
     wrk.ja-ne no-label
     wrk.des
with 15 down row 1 column 30 overlay title vards scroll 1 frame sar1.

define variable lstkey as integer.
define variable i      as integer.
