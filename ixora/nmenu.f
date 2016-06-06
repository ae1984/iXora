/* nmenu.f
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
        20/08/04 sasco Ctrl+F - поиск по названию
        21/02/2008 madiyar - подправил под новый размер терминала
*/

/* nmenu.f */

form space(4) nmenu.ln help " " nmdes.des format "x(59)" nmenu.fname format "x(16)"
     with centered row 3 32 down no-label width 110 overlay frame nmenu.

form "CTRL+F - Поиск. Выберите меню, имя функции или QUIT для выхода"
     g-fname
     with centered row 37 no-box no-label 1 down frame fname.

form "Системная и операционная даты отличаются"
     with row 10 centered no-label frame chck title " -ПРЕДУПРЕЖДЕНИЕ- "
          overlay top-only.

form "У вас нет полномочий на выполнение этой процедуры."
     with row 10 centered frame sorry1 overlay top-only no-label.

/** SASCO >>> поиск пункта меню **/
define variable vtmenmode as logical initial no.
define variable vtmen as character format "x(60)".

define temp-table tmen
            field dlen as character format "x(25)" label "ДЛИНА"
            field depth as character format "x(21)" label "МЕНЮ"
            field des as character format "x(41)" label "НАЗВАНИЕ"
            field fname as character format "x(8)" label "ФУНКЦИЯ" 
            index idx_tmen is primary dlen depth.

/* browse для поиска */
define query qt for tmen.
define browse bt query qt
              displ tmen.depth
                    tmen.des
                    tmen.fname
              with row 1 centered 17 down title "ПОИСК".
define frame ft bt help "ENTER-запуск, F4-вернуться"
             with row 1 centered overlay no-box.

/* browse для дерева меню */
define query qtr for tmen.
define browse btr query qtr
              displ tmen.depth
                    tmen.des
                    tmen.fname
              with row 1 centered 28 down.
define frame ftr btr /* help "ENTER-запуск/Перейти, F4-отмена" */
             with row 3 centered overlay title "ДЕРЕВО".

