/* ord_help.f
 * MODULE
        Платежная система
 * DESCRIPTION
        Помощь полю - Отправитель
 * RUN
        ord_help.p
 * CALLER
        ord_help.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-3-14
 * AUTHOR
        24.06.2005 saltanat 
 * CHANGES
        22.09.2005 dpuchkov увеличил format поля Филиал, уменьшил format поля Форма собственности 
*/

form
    clfilials.namefil     label "Филиал             " format "x(40)"   
    clfilials.forma_sobst label "Форма собственности" format "x(10)"
    clfilials.rnn         label "РНН                " format "x(12)"
with 11 down title "ФИЛИАЛЫ" overlay centered row 6 frame fr.
