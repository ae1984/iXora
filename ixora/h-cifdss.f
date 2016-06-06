/* h-cifdss.f
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        11.11.2011 damir - перекомпиляция
*/

form
    cifdss.fiomain  label "ФИО руководит." format "x(48)"
    cifdss.rnnokpo  label "РНН предпр." format "x(12)"
    cifdss.dtnumreg label "Дата и № регистр." format "x(45)"
with overlay row 1 centered width 110 scroll 1 title "ВЫБЕРИТЕ КЛИЕНТА" down frame cifdss.


